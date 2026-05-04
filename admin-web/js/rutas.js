document.getElementById("btnSubir").addEventListener("click", leerArchivo);

function leerArchivo() {
  const fileInput = document.getElementById("archivo");

  if (!fileInput.files.length) {
    alert("Selecciona un archivo");
    return;
  }

  const file = fileInput.files[0];
  const reader = new FileReader();

  reader.onload = async function (e) {
    const contenido = e.target.result;

    await procesarArchivo(contenido);
  };

  reader.readAsText(file);
}

async function procesarArchivo(texto) {

  const lineas = texto.split("\n");

  const datos = lineas.map(linea => {

    if (!linea.trim()) return null;

    const columnas = linea.split(",");

    // ⚠️ VALIDACIÓN
    if (columnas.length < 19) return null;

    return {
      nombre_usuario: columnas[17]?.trim(),
      lectura_actual: parseInt(columnas[18]),
      estado: "PENDIENTE"
    };

  }).filter(item => item !== null);

  console.log("Datos procesados:", datos);

  if (datos.length === 0) {
    alert("El archivo no tiene datos válidos");
    return;
  }

  // 🚀 INSERTAR EN SUPABASE
  const { error } = await supabaseClient
    .from("toma_lecturas")
    .insert(datos);

  if (error) {
    console.error("Error al guardar:", error);
    alert("Error al guardar datos");
  } else {
    alert(`Datos cargados correctamente 🚀 (${datos.length} registros)`);
  }

}