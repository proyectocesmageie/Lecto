import 'dart:ffi';
import 'package:flutter/material.dart';
import 'lecturas_page.dart';
import '../services/supabase_service.dart';
import '../services/local_storage.dart';

class RutasPage extends StatefulWidget {
  @override
  _RutasPageState createState() => _RutasPageState();
}

class _RutasPageState extends State<RutasPage>
    with SingleTickerProviderStateMixin {
  final Color texto = Color(0xFF333333);
  late TabController _tabController;

  List<Map<String, dynamic>> rutas = [];
  bool cargando = false;

  bool enviando = false;
  String estadoEnvio = "No enviado";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    cargarRutasLocal();
  }

  // 🔥 CARGAR DESDE SUPABASE
  Future<void> cargarRutas() async {
    setState(() {
      cargando = true;
    });

    try {
      final data = await supabase.from('toma_lecturas').select();

      await AppStorage.guardarRutas(data);

      setState(() {
        rutas = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print("Error cargando rutas: $e");
    }

    setState(() {
      cargando = false;
    });
  }

   void cargarRutasLocal() async {
      final data = await AppStorage.obtenerRutas();

      if (data.isNotEmpty) {
        setState(() {
          rutas = List<Map<String, dynamic>>.from(data);
        });
      }
    }

  

  // 🔥 SIMULA ENVÍO
  void enviarRutas() async {
    setState(() {
      enviando = true;
      estadoEnvio = "Enviando...";
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      enviando = false;
      estadoEnvio = "Enviado";

      rutas = rutas.map((r) {
        return {...r, "estado": "Enviado"};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestión de Rutas"),

        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Lista de rutas"),
            Tab(text: "Envío"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 🔹 TAB 1: LISTA
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: cargando ? null : cargarRutas,
                  icon: Icon(Icons.download),
                  label: Text("Cargar rutas"),
                ),

                SizedBox(height: 15),

                Expanded(
                  child: cargando
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: rutas.length,
                          itemBuilder: (context, index) {
                            final ruta = rutas[index];

                            return Card(
                              elevation: 3,
                              child: ListTile(
                                title: Text(
                                  ruta["direccion"]?.toString() ?? "",
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Código: ${ruta["codigo_suscriptor"] ?? ""}",
                                    ),
                                    Text("Barrio: ${ruta["barrio"] ?? ""}"),
                                  ],
                                ),
                                trailing: Icon(ruta["estado"] == "leido"
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                          color: ruta["estado"] == "leido"
                                          ? Colors.green
                                          : Colors.grey,
                                
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LecturasPage(datosRuta: ruta),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // 🔹 TAB 2: ENVÍO
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Resumen",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 10),

                Text("Total rutas: ${rutas.length}"),

                Text(
                  "Pendientes: ${rutas.where((r) => r["estado"] != "Enviado").length}",
                ),

                Text(
                  "Enviadas: ${rutas.where((r) => r["estado"] == "Enviado").length}",
                ),

                SizedBox(height: 20),

                Text("Estado: $estadoEnvio"),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: enviando ? null : enviarRutas,
                  child: enviando
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Enviar rutas"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 TARJETA
  Widget _cardModulo(
    BuildContext context, {
    required String titulo,
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        splashColor: Colors.teal.withOpacity(0.2),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(icono, color: Colors.teal, size: 28),
              SizedBox(width: 15),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: texto,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
