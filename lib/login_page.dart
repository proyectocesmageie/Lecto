import 'package:flutter/material.dart';
import 'home_page.dart';
import 'services/supabase_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool cargando = false;

  void iniciarSesion() async {
    String usuario = usuarioController.text.trim();
    String password = passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final data = await supabase
          .from('usuarios')
          .select()
          .eq('identificador', usuario)
          .eq('contrasena', password)
          .maybeSingle();

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Usuario o contraseña incorrectos")),
        );
      } else if (data["rol"] != "operario") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Acceso solo para operarios")),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión")),
      );
      print(e);
    }

    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(Icons.water_drop, size: 80, color: Colors.teal),

            SizedBox(height: 20),

            Text(
              "App Medidores",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            TextField(
              controller: usuarioController,
              decoration: InputDecoration(
                labelText: "Usuario",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cargando ? null : iniciarSesion,
                child: cargando
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Iniciar sesión"),
              ),
            )
          ],
        ),
      ),
    );
  }
}


