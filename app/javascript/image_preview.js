document.addEventListener("turbo:load", () => {
  const input = document.getElementById("image_input");
  const preview = document.getElementById("preview");

  if (!input) return; // ← edit画面じゃないとき用の安全装置

  input.addEventListener("change", (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const blobUrl = URL.createObjectURL(file);
    preview.src = blobUrl;
  });
});
