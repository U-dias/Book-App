document.addEventListener("change", (e) => {
  if (e.target.id !== "image_input") return;

  const file = e.target.files[0];
  if (!file) return;

  const preview = document.getElementById("preview");
  if (!preview) return;

  preview.src = URL.createObjectURL(file);
});
