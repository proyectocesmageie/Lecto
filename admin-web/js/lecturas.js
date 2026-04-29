async function cargarLecturas() {

  const ciclo = document.getElementById("filtroCiclo").value;
  const lector = document.getElementById("filtroLector").value;

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

  if (ciclo) {
    query = query.eq("asignaciones.ciclos.nombre_ciclo", ciclo);
  }

  if (lector) {
    query = query.eq("asignaciones.lectores.identificador", lector);
  }

  const { data, error } = await query;

  if (error) {
    console.error(error);
    return;
  }

  const tabla = document.querySelector("#tablaLecturas tbody");
  tabla.innerHTML = "";

  data.forEach(item => {
    const ruta = item.asignaciones?.rutas?.nombre_ruta || "";
    const ciclo = item.asignaciones?.ciclos?.nombre_ciclo || "";

    const fila = `
      <tr>
        <td>${item.nombre_usuario}</td>
        <td>${ruta}</td>
        <td>${ciclo}</td>
        <td>${item.lectura_actual}</td>
        <td>${item.estado}</td>
        <td>${item.fecha_lectura}</td>
      </tr>
    `;

    tabla.innerHTML += fila;
  });

}
