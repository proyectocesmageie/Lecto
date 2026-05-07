const archivoInput = document.getElementById("archivo");
const dropZone = document.getElementById("dropZone");
const btnSeleccionar = document.getElementById("btnSeleccionar");

btnSeleccionar.addEventListener("click", () => {
  archivoInput.click();
});

dropZone.addEventListener("click", () => {
  archivoInput.click();
});

archivoInput.addEventListener("change", mostrarArchivo);

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

function mostrarArchivo() {

  const archivo = archivoInput.files[0];

  if (!archivo) return;

  document.getElementById("archivoInfo").style.display = "block";

  document.getElementById("nombreArchivo").textContent =
    archivo.name;

  const reader = new FileReader();

  reader.onload = function(e) {

    const lineas = e.target.result.split("\n");

    document.getElementById("totalRegistros").textContent =
      lineas.length;

  };

  reader.readAsText(archivo);

}

async function procesarArchivo(texto) {

  document.getElementById("progressContainer").style.display = "block";
  document.getElementById("progressBar").style.width = "30%";

  const ciclo = document.getElementById("ciclo").value;
  const lector = document.getElementById("lector").value;

  // ⚠️ Validar selección
  if (!ciclo || !lector) {
    alert("Debes seleccionar ciclo y lector");
    return;
  }

  const lineas = texto.split("\n");

  const datos = lineas.map(linea => {

    if (!linea.trim()) return null;

    const columnas = linea.split(",");

    // ⚠️ Validar estructura mínima
    if (columnas.length < 19) return null;

return {

  codigo_suscriptor: columnas[3]?.trim(),

  direccion: columnas[11]?.trim(),

  lectura_anterior: parseFloat(columnas[13]),

  numero_medidor: columnas[14]?.trim(),

  lectura_minima: parseFloat(columnas[15]),

  consecutivo: parseInt(columnas[16]),

  nombre_usuario: columnas[17]?.trim(),

  lectura_actual: parseFloat(columnas[18]),

  lectura_maxima: parseFloat(columnas[19]),

  novedad: parseInt(columnas[20]),

  estado: "PENDIENTE",

  ciclo: ciclo,

  lector: lector

};

  }).filter(item =>
    item !== null &&
    item.codigo_suscriptor &&
    item.nombre_usuario &&
    !isNaN(item.lectura_actual) &&
    item.codigo_suscriptor
  );

  console.log("Datos procesados:", datos);

  if (datos.length === 0) {
    alert("El archivo no tiene datos válidos");
    return;
  }

try {

  // 🔍 CONSULTAR REGISTROS EXISTENTES
  const { data: existentes, error: errorConsulta } = await supabaseClient
    .from("toma_lecturas")
    .select("codigo_suscriptor, ciclo");

  if (errorConsulta) {
    console.error(errorConsulta);
    alert("Error consultando registros existentes");
    return;
  }

  // 🔥 FILTRAR DUPLICADOS
  const nuevosDatos = datos.filter(item => {

    const existe = existentes.some(registro =>
      registro.codigo_suscriptor === item.codigo_suscriptor &&
      registro.ciclo === item.ciclo
    );

    return !existe;

  });

  // ⚠️ SI TODOS EXISTEN
  if (nuevosDatos.length === 0) {
    alert("Todos los registros ya existen");
    return;
  }

  // 🚀 INSERTAR SOLO NUEVOS
  document.getElementById("progressBar").style.width = "70%";

  const { error } = await supabaseClient
    .from("toma_lecturas")
    .insert(nuevosDatos);

    if (error) {
      console.error("Error al guardar:", error);
      alert("Error al guardar datos");
      return;
    }

    const duplicados = datos.length - nuevosDatos.length;

    // ✅ COMPLETAR BARRA
    document.getElementById("progressBar").style.width = "100%";

    alert(`
    ✅ ${nuevosDatos.length} registros insertados
    ⚠️ ${duplicados} duplicados omitidos
    `);
setTimeout(() => {

  document.getElementById("progressBar").style.width = "0%";
  document.getElementById("progressContainer").style.display = "none";

}, 1500);

  } catch (err) {

    console.error("Error inesperado:", err);
    alert("Ocurrió un error inesperado");

  }

}