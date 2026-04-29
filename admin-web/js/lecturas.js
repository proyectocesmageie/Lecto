// 🚀 Cargar lecturas con filtros
async function cargarLecturas() {

  const cicloSeleccionado = document.getElementById("filtroCiclo").value;
  const lectorSeleccionado = document.getElementById("filtroLector").value;

  let query = supabaseClient
    .from("toma_lecturas")
    .select(`
      nombre_usuario,
      lectura_actual,
      estado,
      fecha_lectura,
      asignaciones (
        rutas ( nombre_ruta ),
        ciclos ( nombre_ciclo ),
        lectores ( identificador )
      )
    `);

  // 🔎 Filtros
  if (cicloSeleccionado) {
    query = query.eq("asignaciones.ciclos.nombre_ciclo", cicloSeleccionado);
  }

  if (lectorSeleccionado) {
    query = query.eq("asignaciones.lectores.identificador", lectorSeleccionado);
  }

  const { data, error } = await query;

  if (error) {
    console.error("Error al cargar lecturas:", error);
    return;
  }

  // 📊 Tabla
  const tabla = document.querySelector("#tablaLecturas tbody");
  tabla.innerHTML = "";

  let total = 0;
  let anomalias = 0;
  let lectores = new Set();

  data.forEach(item => {

    const ruta = item.asignaciones?.rutas?.nombre_ruta || "Sin ruta";
    const ciclo = item.asignaciones?.ciclos?.nombre_ciclo || "Sin ciclo";
    const lector = item.asignaciones?.lectores?.identificador || "Sin lector";
    const fecha = item.fecha_lectura || "Sin fecha";

    // 📊 Contadores
    total++;

    if (item.estado && item.estado.toLowerCase().includes("anom")) {
      anomalias++;
    }

    lectores.add(lector);

    // 🎨 Estado visual
    let estadoClase = "";
    if (item.estado === "OK") estadoClase = "estado-ok";
    else if (item.estado === "ANOMALA") estadoClase = "estado-anomalo";

    const fila = `
      <tr>
        <td>${item.nombre_usuario}</td>
        <td>${ruta}</td>
        <td>${ciclo}</td>
        <td>${item.lectura_actual}</td>
        <td class="${estadoClase}">${item.estado}</td>
        <td>${fecha}</td>
      </tr>
    `;

    tabla.innerHTML += fila;
  });

  // 🔥 Tarjetas
  document.getElementById("totalLecturas").textContent = total;
  document.getElementById("lecturasAnomalias").textContent = anomalias;
  document.getElementById("lectoresActivos").textContent = lectores.size;

}

// 🚀 Evento botón (PRO)
document.addEventListener("DOMContentLoaded", () => {

  const btn = document.getElementById("btnBuscar");

  if (btn) {
    btn.addEventListener("click", cargarLecturas);
  }

  // Carga inicial
  cargarLecturas();

});
