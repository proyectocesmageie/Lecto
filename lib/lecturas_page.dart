import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/local_storage.dart';

class LecturasPage extends StatefulWidget {
  final Map datosRuta;

  const LecturasPage({super.key, required this.datosRuta});

  @override
  State<LecturasPage> createState() => _LecturasPageState();
}

class _LecturasPageState extends State<LecturasPage> {
  final String nombreOperario = "Wilmer";
  final String version = "v1.0";
  final bool conectado = true;
  final TextEditingController lecturaController = TextEditingController();

  bool sinLectura = false;
  bool confirmado = false;
  bool mostrarCamara = false;
  bool fotoTomada = false;

  int intentos = 0;

  String alerta = "";

  String? novedadSeleccionada;
  String? mensajeSeleccionado;

  final ImagePicker picker = ImagePicker();

  // 🔥 NUEVO CONTROL DE ESTADO (CLAVE)
  String ultimaLecturaConfirmada = "";
  bool hayAlerta = false;

  Map<String, List<String>> novedadesMensajes = {
    "3 - Caja con obstáculo": [
      "Reja con candado",
      "Carro en cajilla",
      "Medidor interno",
    ],
    "5 - Caja inundada": ["Agua acumulada", "Tubería rota"],
    "10 - Sin identificar": ["No se encontró medidor", "Dirección incorrecta"],
    "24 - Medidor con vidrio ilegible": ["Vidrio empañado", "Vidrio rayado"],
    "29 - Medidor invertido": ["Medidor al revés", "Instalación incorrecta"],
  };

  // 🔥 CUSTOM APPBAR - TU HEADER CONVERTIDO
  // 🔥 CUSTOM APPBAR MEJORADA - Flecha + Centrado
  Widget customAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 35, 18, 5),
      decoration: const BoxDecoration(
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
        children: [
          // 🔵 FILA SUPERIOR: Flecha + Logo + Versión
          Row(
            children: [
              // 🔥 FLECHA DE RETROCEDER
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 30,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              // Logo + Título
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.water_drop, color: Colors.white, size: 30),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "App Medidores",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.center, // Centrado
                      ),
                    ),
                  ],
                ),
              ),
              // Versión a la derecha
              const Text("v1.0", style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 55),
            ],
          ),
          const SizedBox(height: 5),

          // 🔥 CONTENIDO CENTRADO
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Registro de lecturas", // ← Cambia por $nombreOperario si es dinámico
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centrado
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.greenAccent),
                    SizedBox(width: 5),
                    Text("En línea", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> tomarFoto() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        fotoTomada = true;
      });
    }
  }

  bool puedeEnviar() {
    if (sinLectura) {
      return novedadSeleccionada != null &&
          mensajeSeleccionado != null &&
          fotoTomada;
    } else {
      return lecturaController.text.trim().isNotEmpty;
    }
  }

  // 🔥 LÓGICA CORREGIDA (ÚNICO CAMBIO REAL)
  void confirmarLectura() {
    String lecturaTexto = lecturaController.text.trim();
    int lecturaActual = int.tryParse(lecturaTexto) ?? 0;

    int lecturaAnterior = widget.datosRuta["lectura_anterior"] ?? 0;

    double limiteSuperior = (widget.datosRuta["lectura_maxima"] ?? 0)
        .toDouble();

    double limiteInferior = (widget.datosRuta["lectura_minima"] ?? 0)
        .toDouble();

    // 🔁 MISMA LECTURA + ALERTA → ACEPTAR
    if (hayAlerta && lecturaTexto == ultimaLecturaConfirmada) {
      setState(() {
        confirmado = true;
        mostrarCamara = true;
      });
      return;
    }

    // 🔁 NUEVA LECTURA → SUMA INTENTO
    if (lecturaTexto != ultimaLecturaConfirmada) {
      intentos++;
      if (intentos > 3) intentos = 3;
    }

    alerta = "";
    hayAlerta = false;

    // 🔍 VALIDACIÓN
    if (lecturaActual < lecturaAnterior) {
      alerta = "Consumo negativo";
      hayAlerta = true;
    } else if (lecturaActual >= limiteSuperior) {
      alerta = "Consumo alto";
      hayAlerta = true;
    } else if (lecturaActual <= limiteInferior) {
      alerta = "Consumo bajo";
      hayAlerta = true;
    }

    setState(() {
      ultimaLecturaConfirmada = lecturaTexto;

      if (!hayAlerta) {
        confirmado = true;
      } else {
        confirmado = false;
      }

      if (intentos >= 3) {
        confirmado = true;
        mostrarCamara = true;
      }
    });
  }

  void enviarLectura() async {
    Map rutaActualizada = {
      ...widget.datosRuta,
      "lectura": lecturaController.text,
      "estado": "leido",
      "novedad": novedadSeleccionada,
      "mensaje": mensajeSeleccionado,
    };

    print("Ruta guardada: $rutaActualizada");

    await AppStorage.actualizarRuta(rutaActualizada);

    print("Guardado local");

    List rutas = await AppStorage.obtenerRutas();
    print(rutas);

    Map<String, dynamic>? siguiente;

    try {
      siguiente = rutas.firstWhere(
        (r) => r["estado"] != "leido",
      );
    } catch (e) {
      siguiente = null;
    }

    if (siguiente !=null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LecturasPage(datosRuta: siguiente!,
        ),
      ),
    );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Todas las lecturas completadas")));
   

    Navigator.pop(context);
     }
  }

  @override
  Widget build(BuildContext context) {
    bool habilitado = puedeEnviar();

    return Scaffold(
      appBar: PreferredSize(
        // 🔥 APPBAR PERSONALIZADA
        preferredSize: const Size.fromHeight(100), // Altura de tu header
        child: customAppBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15), // 🔥 Espaciado ajustado

            _card(
              Container(
                height: 130,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titulo("Datos del usuario"),
                      Text("Código: ${widget.datosRuta["codigo_suscriptor"]}"),
                      Text("Nombre: ${widget.datosRuta["nombre_usuario"]}"),
                      Text("Medidor: ${widget.datosRuta["numero_medidor"]}"),
                      Text("Dirección: ${widget.datosRuta["direccion"]}"),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titulo("Registro de lectura"),

                  TextField(
                    controller: lecturaController,
                    keyboardType: TextInputType.number,
                    enabled: !sinLectura && intentos < 3,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) {
                      setState(() {
                        confirmado = false; // 🔥 clave
                      });
                    },
                    decoration: InputDecoration(labelText: "Lectura"),
                  ),

                  Text("$intentos/3"),

                  if (alerta.isNotEmpty)
                    Text(alerta, style: TextStyle(color: Colors.red)),

                  CheckboxListTile(
                    value: sinLectura,
                    title: Text("Sin lectura"),
                    enabled: intentos < 3,
                    onChanged: (value) {
                      setState(() {
                        sinLectura = value!;
                        mostrarCamara = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            if (sinLectura)
              DropdownButtonFormField<String>(
                value: novedadSeleccionada,
                hint: Text("Seleccione novedad"),
                items: novedadesMensajes.keys.map<DropdownMenuItem<String>>((
                  novedad,
                ) {
                  return DropdownMenuItem<String>(
                    value: novedad,
                    child: Text(novedad),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    novedadSeleccionada = value;
                    mensajeSeleccionado = null;
                  });
                },
              ),

            const SizedBox(height: 10),

            if (sinLectura)
              DropdownButtonFormField<String>(
                value: mensajeSeleccionado,
                hint: Text("Seleccione mensaje"),
                items:
                    (novedadSeleccionada != null
                            ? novedadesMensajes[novedadSeleccionada]!
                            : [])
                        .map<DropdownMenuItem<String>>((mensaje) {
                          return DropdownMenuItem<String>(
                            value: mensaje,
                            child: Text(mensaje),
                          );
                        })
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    mensajeSeleccionado = value;
                  });
                },
              ),

            const SizedBox(height: 15),

            if (sinLectura || mostrarCamara)
              ElevatedButton.icon(
                onPressed: tomarFoto,
                icon: Icon(Icons.camera_alt),
                label: Text(fotoTomada ? "Foto tomada" : "Tomar foto"),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: habilitado
                  ? (confirmado || sinLectura
                        ? enviarLectura
                        : confirmarLectura)
                  : null,
              child: Text(confirmado || sinLectura ? "Enviar" : "Confirmar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 150, // 🔥 mismo tamaño visual pero flexible
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}
