document
  .getElementById("btnGuardar")
  .addEventListener("click", guardarUsuario);

async function guardarUsuario() {

  const nombre =
    document.getElementById("nombre").value.trim();

  const correo =
    document.getElementById("correo").value.trim();

  const contrasena =
    document.getElementById("contrasena").value.trim();

  const rol =
    document.getElementById("rol").value;

  const identificador =
    document.getElementById("identificador").value.trim();

  // VALIDACIONES
  if (
    !nombre ||
    !correo ||
    !contrasena ||
    !rol ||
    !identificador
  ) {
    alert("Completa todos los campos");
    return;
  }

  try {

    // INSERTAR EN SUPABASE
let respuesta;

if (window.usuarioEditando) {

  respuesta = await supabaseClient
    .from("usuarios")
    .update({
      nombre,
      correo,
      contrasena,
      rol,
      identificador
    })
    .eq("id_usuario", window.usuarioEditando);

} else {

  respuesta = await supabaseClient
    .from("usuarios")
    .insert([
      {
        nombre,
        correo,
        contrasena,
        rol,
        identificador
      }
    ]);

}

const { error } = respuesta;

    if (error) {
      console.error(error);
      alert("Error al guardar usuario");
      return;
    }

        alert(
        window.usuarioEditando
            ? "✅ Usuario actualizado"
            : "✅ Usuario registrado"
        );

window.usuarioEditando = null;

    limpiarFormulario();

    cargarUsuarios();

  } catch (err) {

    console.error(err);

    alert("Error inesperado");

  }

}

function limpiarFormulario() {

  document.getElementById("nombre").value = "";
  document.getElementById("correo").value = "";
  document.getElementById("contrasena").value = "";
  document.getElementById("rol").value = "";
  document.getElementById("identificador").value = "";

}

async function cargarUsuarios() {

  const tabla =
    document.getElementById("tablaUsuarios");

  tabla.innerHTML = `
    <tr>
      <td colspan="4">
        Cargando usuarios...
      </td>
    </tr>
  `;

  try {

    const { data, error } = await supabaseClient
      .from("usuarios")
      .select("*")
      .order("nombre", { ascending: true });

    if (error) {
      console.error(error);

      tabla.innerHTML = `
        <tr>
          <td colspan="4">
            Error cargando usuarios
          </td>
        </tr>
      `;

      return;
    }

    if (!data.length) {

      tabla.innerHTML = `
        <tr>
          <td colspan="4">
            No hay usuarios registrados
          </td>
        </tr>
      `;

      return;
    }

    tabla.innerHTML = "";

    data.forEach(usuario => {

      tabla.innerHTML += `
  <tr>

    <td>${usuario.nombre}</td>

    <td>${usuario.correo}</td>

    <td>${usuario.rol}</td>

    <td>${usuario.identificador}</td>

    <td>

      <button
        class="btn-editar"
        onclick="editarUsuario('${usuario.id_usuario}')"
      >
        ✏️
      </button>

      <button
        class="btn-eliminar"
        onclick="eliminarUsuario('${usuario.id_usuario}')"
      >
        🗑️
      </button>

    </td>

  </tr>
`;

    });

  } catch (err) {

    console.error(err);

    tabla.innerHTML = `
      <tr>
        <td colspan="4">
          Error inesperado
        </td>
      </tr>
    `;

  }

}

// 🚀 CARGAR AL ABRIR
cargarUsuarios();

async function eliminarUsuario(id) {

  const confirmar =
    confirm("¿Eliminar usuario?");

  if (!confirmar) return;

  try {

    const { error } = await supabaseClient
      .from("usuarios")
      .delete()
      .eq("id_usuario", id);

    if (error) {
      console.error(error);
      alert("Error eliminando usuario");
      return;
    }

    alert("✅ Usuario eliminado");

    cargarUsuarios();

  } catch (err) {

    console.error(err);

    alert("Error inesperado");

  }

}

async function editarUsuario(id) {

  try {

    const { data, error } = await supabaseClient
      .from("usuarios")
      .select("*")
      .eq("id_usuario", id)
      .single();

    if (error) {
      console.error(error);
      return;
    }

    document.getElementById("nombre").value =
      data.nombre;

    document.getElementById("correo").value =
      data.correo;

    document.getElementById("contrasena").value =
      data.contrasena;

    document.getElementById("rol").value =
      data.rol;

    document.getElementById("identificador").value =
      data.identificador;

    // ⚠️ guardar id temporal
    window.usuarioEditando = id;

  } catch (err) {

    console.error(err);

  }

}