var submitPhoto = document.getElementById("submit-photo");

if (submitPhoto) {  
  submitPhoto.addEventListener("click", displayUploading)

  function displayUploading(e) {
    e.target.removeEventListener("click", displayUploading)
    if (e.target.innerHTML) {
      e.target.innerHTML = "Uploading..."
    }
  }
}
