window.addEventListener("DOMContentLoaded", () => {

  cargarEstadisticas();
  cargarLecturas();

});


// =======================================
// 📊 CARGAR ESTADÍSTICAS
// =======================================

async function cargarEstadisticas() {

  try {

    // 🔹 TOTAL LECTURAS
    const { count: totalLecturas, error: errorTotal } =
      await supabaseClient
        .from("toma_lecturas")
        .select("*", { count: "exact", head: true });

    // 🔹 LECTURAS ANÓMALAS
    const { count: anomalias, error: errorAnomalias } =
      await supabaseClient
        .from("toma_lecturas")
        .select("*", { count: "exact", head: true })
        .gt("novedad", 0);

    // 🔹 LECTORES ACTIVOS
    const { data: lectoresData, error: errorLectores } =
      await supabaseClient
        .from("toma_lecturas")
        .select("lector");

    // 🔥 OBTENER LECTORES ÚNICOS
    const lectoresUnicos = [...new Set(
      lectoresData.map(item => item.lector)
    )];

    // =====================================
    // 📊 ACTUALIZAR TARJETAS
    // =====================================

    document.getElementById("totalLecturas").textContent =
      totalLecturas || 0;

    document.getElementById("lecturasAnomalias").textContent =
      anomalias || 0;

    document.getElementById("lectoresActivos").textContent =
      lectoresUnicos.length || 0;

  } catch (error) {

    console.error("Error cargando estadísticas:", error);

  }

}


// =======================================
// 📋 CARGAR TABLA
// =======================================

async function cargarLecturas() {

  try {

    const ciclo = document.getElementById("filtroCiclo")?.value;
    const lector = document.getElementById("filtroLector")?.value;

    let query = supabaseClient
      .from("toma_lecturas")
      .select("*")
      .order("fecha_lectura", { ascending: false });

    // 🔍 FILTRO CICLO
    if (ciclo) {
      query = query.eq("ciclo", ciclo);
    }

    // 🔍 FILTRO LECTOR
    if (lector) {
      query = query.eq("lector", lector);
    }

    const { data, error } = await query;

    if (error) {
      console.error(error);
      return;
    }

    const tabla = document.querySelector("#tablaLecturas tbody");

    tabla.innerHTML = "";

    data.forEach(item => {

      const fila = `
        <tr>
          <td>${item.nombre_usuario || ""}</td>
          <td>${item.direccion || ""}</td>
          <td>${item.ciclo || ""}</td>
          <td>${item.lectura_actual || 0}</td>
          <td>
            <span class="estado-badge estado-${(item.estado || '').toLowerCase()}">
              ${item.estado || ""}
            </span>
          </td>
          <td>${item.fecha_lectura || ""}</td>
        </tr>
      `;

      tabla.innerHTML += fila;

    });

  } catch (error) {

    console.error("Error cargando lecturas:", error);

  }

}