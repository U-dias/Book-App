console.log("JS動いてる");
document.addEventListener("turbo:load", () => {
  const input = document.getElementById("image_input");
  const preview = document.getElementById("preview");

  if (!input || !preview) return;

  input.onchange = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const blobUrl = URL.createObjectURL(file);
    preview.src = blobUrl;
  };
});
