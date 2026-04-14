import 'package:flutter/material.dart';
import 'lecturas_page.dart';

class RutasPage extends StatefulWidget {
  @override
  _RutasPageState createState() => _RutasPageState();
}

class _RutasPageState extends State<RutasPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> rutas = [];
  bool cargando = false;

  bool enviando = false;
  String estadoEnvio = "No enviado";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // 🔥 SIMULA CARGA DESDE BASE DE DATOS
  void cargarRutas() async {
    setState(() {
      cargando = true;
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      rutas = [
        {
          "codigo": "001",
          "direccion": "Calle 123",
          "barrio": "Centro",
          "estado": "Pendiente"
        },
        {
          "codigo": "002",
          "direccion": "Carrera 10",
          "barrio": "San Juan",
          "estado": "Pendiente"
        },
        {
          "codigo": "003",
          "direccion": "Av. Panamericana",
          "barrio": "Norte",
          "estado": "Pendiente"
        },
      ];

      cargando = false;
    });
  }

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

          // 🔹 TAB 1: LISTA DE RUTAS
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [

                // 🔘 BOTÓN CARGAR
                ElevatedButton.icon(
                  onPressed: cargando ? null : cargarRutas,
                  icon: Icon(Icons.download),
                  label: Text("Cargar rutas"),
                ),

                SizedBox(height: 15),

                // ⏳ LOADING
                if (cargando)
                  CircularProgressIndicator(),

                // 📋 LISTA
                Expanded(
                  child: rutas.isEmpty
                      ? Center(child: Text("No hay rutas cargadas"))
                      : ListView.builder(
                          itemCount: rutas.length,
                          itemBuilder: (context, index) {
                            var ruta = rutas[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LecturasPage(),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Código: ${ruta["codigo"]}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("Dirección: ${ruta["direccion"]}"),
                                    Text("Barrio: ${ruta["barrio"]}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
          ),

          // 🔹 TAB 2: ENVÍO
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("Resumen",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                SizedBox(height: 10),

                Text("Total rutas: ${rutas.length}"),

                Text("Pendientes: ${rutas.where((r) => r["estado"] == "Pendiente").length}"),

                Text("Enviadas: ${rutas.where((r) => r["estado"] == "Enviado").length}"),

                SizedBox(height: 20),

                Text("Estado: $estadoEnvio"),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: enviando ? null : enviarRutas,
                  child: enviando
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Enviar rutas"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}