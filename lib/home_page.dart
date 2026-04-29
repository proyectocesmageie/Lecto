import 'package:app_medidores/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lecturas_page.dart';
import 'rutas_page.dart';

class HomePage extends StatelessWidget {
  final String nombreOperario = "Wilmer";
  final String version = "v1.0";
  final bool conectado = true;

  final Color texto = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔵 HEADER
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 45, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF009688), Color(0xFF039354)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text(
                          "App Medidores",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    Text(version, style: TextStyle(color: Colors.white70)),
                  ],
                ),

                SizedBox(height: 10),

                Text(
                  "Bienvenido, $nombreOperario",
                  style: TextStyle(color: Colors.white),
                ),

                SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: conectado ? Colors.greenAccent : Colors.red,
                    ),
                    SizedBox(width: 5),
                    Text(
                      conectado ? "En línea" : "Sin conexión",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // 📦 MÓDULOS
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  // 🔥 LECTURAS (DESHABILITADO DIRECTO)
                  _cardModulo(
                    context,
                    titulo: "Lecturas",
                    icono: Icons.speed,
                    onTap: () async {
                      final rutas = await AppStorage.obtenerRutas();

                      if (rutas.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("No hay rutas cargadas")),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LecturasPage(
                            datosRuta: rutas.firstWhere(
                              (r) => r["estado"] != "leido",
                              orElse: () => rutas[0],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 15),

                  // ✅ RUTAS
                  _cardModulo(
                    context,
                    titulo: "Gestión de rutas",
                    icono: Icons.map,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RutasPage()),
                      );
                    },
                  ),

                  SizedBox(height: 15),

                  _cardModulo(
                    context,
                    titulo: "Configuración",
                    icono: Icons.settings,
                    onTap: () {},
                  ),
                ],
              ),
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
