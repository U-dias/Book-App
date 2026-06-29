document.addEventListener("turbo:load", () => {
  const input = document.getElementById("image_input");
  if (!input) return;

  input.addEventListener("change", (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const preview = document.getElementById("preview");
    if (!preview) return;

    preview.src = URL.createObjectURL(file);
  });
});
