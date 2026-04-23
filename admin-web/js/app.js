async function cargarLecturas() {
  const { data, error } = await supabaseClient
  .from("toma_lecturas")
  .select("*");

  if (error) {
  console.error("Error completo:", error.message, error.details, error.hint);
  return;
}

  const tabla = document.querySelector("#tablaLecturas tbody");
  tabla.innerHTML = "";

  data.forEach(item => {

    const ruta = item.asignaciones?.rutas?.nombre_ruta || "Sin ruta";
    const ciclo = item.asignaciones?.ciclos?.nombre_ciclo || "Sin ciclo";
    const fecha = item.fecha_lectura || "Sin fecha";

    const fila = `
      <tr>
        <td>${item.nombre_usuario}</td>
        <td>${ruta}</td>
        <td>${ciclo}</td>
        <td>${item.lectura_actual}</td>
        <td>${item.estado}</td>
        <td>${fecha}</td>
      </tr>
    `;

    tabla.innerHTML += fila;
  });
}

cargarLecturas();