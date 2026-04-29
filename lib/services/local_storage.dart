import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const String keyRutas = "rutas_guardadas";

  // 🔽 GUARDAR RUTAS
  static Future<void> guardarRutas(List rutas) async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(rutas);
    await prefs.setString(keyRutas, data);
  }

  // 🔽 OBTENER RUTAS
  static Future<List> obtenerRutas() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(keyRutas);

    if (data == null) return [];

    return jsonDecode(data);
  }

  // 🔽 LIMPIAR
  static Future<void> limpiarRutas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyRutas);
  }

static Future<void> actualizarRuta(Map rutaActualizada) async {
  final prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString(keyRutas);

  if (data == null) return;

  List rutas = jsonDecode(data);

  List nuevasRutas = rutas.map((r) {
    if (r["codigo_suscriptor"].toString() ==
        rutaActualizada["codigo_suscriptor"].toString()) {
      return rutaActualizada; // 🔥 reemplaza correctamente
    }
    return r;
  }).toList();

  await prefs.setString(keyRutas, jsonEncode(nuevasRutas));
}

 
}

