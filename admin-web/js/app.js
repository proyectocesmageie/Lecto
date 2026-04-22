async function cargarLecturas() {
  const { data, error } = await supabaseClient
    .from("toma_lecturas")
    .select(`
      nombre_usuario,
      lectura_actual,
      estado,
      fecha_lectura,
      asignaciones (
        rutas ( nombre_ruta ),
        ciclos ( nombre_ciclo )
      )
    `);

  if (error) {
    console.error("Error:", error);
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