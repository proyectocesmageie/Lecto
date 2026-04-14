import 'package:flutter/material.dart';
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
      backgroundColor: Colors.white, // 🔥 fondo limpio
      body: Column(
        children: [

          // 🔵 HEADER CON DEGRADADO SUAVE
Container(
  width: double.infinity,
  padding: EdgeInsets.fromLTRB(20, 45, 20, 20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF009688), // 🔵 azul verdoso (teal)
        Color(0xFF039354), // 🟢 verde
      ],
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
              Icon(Icons.water_drop,
                  color: Colors.white, size: 28),
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
          Text(
            "v1.0",
            style: TextStyle(color: Colors.white70),
          )
        ],
      ),

      SizedBox(height: 10),

      Text(
        "Bienvenido, Wilmer",
        style: TextStyle(color: Colors.white),
      ),

      SizedBox(height: 5),

      Row(
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: Colors.greenAccent,
          ),
          SizedBox(width: 5),
          Text(
            "En línea",
            style: TextStyle(color: Colors.white),
          ),
        ],
      )
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

                  _cardModulo(
                    context,
                    titulo: "Lecturas",
                    icono: Icons.speed,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LecturasPage()),
                      );
                    },
                  ),

                  SizedBox(height: 15),

                  _cardModulo(
                    context,
                    titulo: "Gestión de rutas",
                    icono: Icons.map,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RutasPage()),
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
          )
        ],
      ),
    );
  }

  // 🔥 TARJETA CON EFECTO PROFESIONAL
  Widget _cardModulo(BuildContext context,
      {required String titulo,
      required IconData icono,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 3, // sombra elegante
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
              Icon(Icons.arrow_forward_ios, size: 14)
            ],
          ),
        ),
      ),
    );
  }
}