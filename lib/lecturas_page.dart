import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LecturasPage extends StatefulWidget {
  const LecturasPage({super.key});

  @override
  _LecturasPageState createState() => _LecturasPageState();
}

class _LecturasPageState extends State<LecturasPage> {
  final TextEditingController lecturaController = TextEditingController();

  bool sinLectura = false;
  bool mostrarCamara = false;
  bool confirmado = false;

  int intentos = 0;

  String estadoConexion = "En línea";

  String novedadSeleccionada = "Sin novedad";
  String mensajeSeleccionado = "";

  String alerta = "";

  int lecturaAnterior = 100;
  int promedio = 20;

  bool alertaActiva = false;
  String ultimaLecturaIntento = "";

  @override
  void initState() {
    super.initState();

    lecturaController.addListener(() {
      if (confirmado) {
        setState(() {
          confirmado = false;
        });
      }

      alertaActiva = false;
    });
  }

  bool puedeConfirmar() {
    if (intentos >= 3) return false;

    if (sinLectura) {
      return novedadSeleccionada != "Sin novedad";
    } else {
      return lecturaController.text.trim().isNotEmpty;
    }
  }

  void confirmarLectura() {
    String lecturaTexto = lecturaController.text.trim();
    int lecturaActual = int.tryParse(lecturaTexto) ?? 0;

    setState(() {
      alerta = "";
    });

    // 🔴 SI YA LLEGÓ A 3 → FORZAR ENVÍO
    if (intentos >= 3) {
      setState(() {
        confirmado = true;
        mostrarCamara = true;
        alerta = "Máximo de intentos alcanzado";
        alertaActiva = false;
      });
      return;
    }

    // 🔹 SIN LECTURA
    if (sinLectura) {
      setState(() {
        confirmado = true;
        mostrarCamara = true;
      });
      return;
    }

    int consumo = lecturaActual - lecturaAnterior;

    double porcentaje = promedio >= 40 ? 0.35 : 0.65;
    double desviacion = promedio * porcentaje;

    double limiteSuperior = promedio + desviacion;
    double limiteInferior = promedio - desviacion;

    bool hayDesviacion =
        consumo >= limiteSuperior ||
        consumo <= limiteInferior ||
        consumo < 0;

    // 🔴 PRIMERA VEZ → ALERTA Y SUMA INTENTO
    if (hayDesviacion && !alertaActiva) {
      setState(() {
        alerta = consumo < 0
            ? "Consumo negativo"
            : consumo >= limiteSuperior
                ? "Consumo alto"
                : "Consumo bajo";

        alertaActiva = true;

        if (lecturaTexto != ultimaLecturaIntento) {
          intentos++;
          ultimaLecturaIntento = lecturaTexto;
        }
      });

      // 🔥 SI AQUÍ LLEGA A 3 → FORZAR ESTADO FINAL
      if (intentos >= 3) {
        setState(() {
          confirmado = true;
          mostrarCamara = true;
        });
      }

      return;
    }

    // 🔥 SEGUNDA CONFIRMACIÓN → NO SUMA
    if (hayDesviacion && alertaActiva) {
      setState(() {
        confirmado = true;
        mostrarCamara = true;
        alerta = "";
        alertaActiva = false;
      });
      return;
    }

    // 🟢 LECTURA NORMAL
    setState(() {
      if (lecturaTexto != ultimaLecturaIntento) {
        intentos++;
        ultimaLecturaIntento = lecturaTexto;
      }

      confirmado = true;
      mostrarCamara = false;
      alerta = "";

      novedadSeleccionada = "Sin novedad";
      mensajeSeleccionado = "Lectura normal";
    });

    // 🔥 SI LLEGA A 3 → FORZAR CÁMARA
    if (intentos >= 3) {
      setState(() {
        confirmado = true;
        mostrarCamara = true;
        alerta = "Máximo de intentos alcanzado";
      });
    }
  }

  void enviarLectura() {
    print("Lectura enviada");

    setState(() {
      lecturaController.clear();
      sinLectura = false;
      mostrarCamara = false;
      confirmado = false;
      intentos = 0;

      novedadSeleccionada = "Sin novedad";
      mensajeSeleccionado = "";
      alerta = "";
      alertaActiva = false;
      ultimaLecturaIntento = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    bool habilitarBoton = confirmado || puedeConfirmar();

    return Scaffold(
      appBar: AppBar(
        title: Text("Lecturas"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF009688),
                    Color(0xFF039354),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.white),
                      SizedBox(width: 8),
                      Text("App Medidores v1.0",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text("Bienvenido, Wilmer",
                      style: TextStyle(color: Colors.white)),
                  Text("Estado: $estadoConexion",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

            SizedBox(height: 15),

            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titulo("Datos del usuario"),
                  Text("Código: 001"),
                  Text("Nombre: Juan Pérez"),
                  Text("Serial: 123456"),
                  Text("Dirección: Calle 123"),
                ],
              ),
            ),

            SizedBox(height: 15),

            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titulo("Registro de lectura"),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lecturaController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          enabled: !sinLectura && intentos < 3,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration:
                              InputDecoration(labelText: "Lectura"),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text("$intentos/3"),
                    ],
                  ),

                  if (alerta.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        alerta,
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                  CheckboxListTile(
                    value: sinLectura,
                    title: Text("Sin lectura"),
                    onChanged: (intentos < 3)
                        ? (value) {
                            setState(() {
                              sinLectura = value!;
                              mostrarCamara = value;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titulo("Novedades"),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: novedadSeleccionada,
                          isExpanded: true,
                          items: [
                            "Sin novedad",
                            "Medidor dañado",
                            "Predio cerrado"
                          ]
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (sinLectura && intentos < 3)
                              ? (value) {
                                  setState(() {
                                    novedadSeleccionada = value!;
                                  });
                                }
                              : null,
                        ),
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: DropdownButton<String>(
                          value: mensajeSeleccionado.isEmpty
                              ? null
                              : mensajeSeleccionado,
                          hint: Text("Mensaje"),
                          isExpanded: true,
                          items: [
                            "Lectura normal",
                            "Revisar",
                            "Cliente no disponible"
                          ]
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (sinLectura || confirmado)
                              ? (value) {
                                  setState(() {
                                    mensajeSeleccionado = value!;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            if (mostrarCamara)
              _card(
                Column(
                  children: [
                    Text("Cámara"),
                    Icon(Icons.camera_alt, size: 50),
                  ],
                ),
              ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: habilitarBoton
                  ? (confirmado ? enviarLectura : confirmarLectura)
                  : null,
              child: Text(confirmado ? "Enviar" : "Confirmar"),
            )
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}