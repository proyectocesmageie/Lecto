document
  .getElementById("btnLogin")
  .addEventListener("click", iniciarSesion);

async function iniciarSesion() {

  const correo =
    document.getElementById("correo").value;

  const contrasena =
    document.getElementById("contrasena").value;

  if (!correo || !contrasena) {

    alert("Completa todos los campos");
    return;

  }

  try {

    const { data, error } = await supabaseClient

      .from("usuarios")

      .select("*")

      .eq("correo", correo)

      .eq("contrasena", contrasena)

      .single();

    if (error || !data) {

      alert("Credenciales incorrectas");
      return;

    }

    // ✅ GUARDAR SESIÓN
    localStorage.setItem(
      "usuario",
      JSON.stringify(data)
    );

    // ✅ REDIRECCIÓN POR ROL
window.location = "index.html";

  } catch (err) {

    console.error(err);

    alert("Error inesperado");

  }

}