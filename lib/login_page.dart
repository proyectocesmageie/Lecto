import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String error = "";
  bool cargando = false;
Future<void> iniciarSesion() async {
  String usuario = usuarioController.text.trim();
  String password = passwordController.text.trim();

  if (usuario.isEmpty || password.isEmpty) {
    setState(() {
      error = "Todos los campos son obligatorios";
    });
    return;
  }

  setState(() {
    cargando = true;
    error = "";
  });

  await Future.delayed(Duration(seconds: 1)); // Simula conexión

  // 🔥 SIMULACIÓN REALISTA (como si fuera BD)
  if (usuario == "admin" && password == "1234") {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  } else {
    setState(() {
      error = "Usuario o contraseña incorrectos";
    });
  }

  setState(() {
    cargando = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inicio de Sesión"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usuarioController,
              decoration: InputDecoration(labelText: "Correo"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Contraseña"),
            ),
            SizedBox(height: 20),

            cargando
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: iniciarSesion,
                    child: Text("Iniciar sesión"),
                  ),

            SizedBox(height: 10),

            Text(
              error,
              style: TextStyle(color: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}


