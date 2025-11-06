const inputPass = document.getElementById("password");
const togglePass = document.getElementById("toggle-password");

togglePass.addEventListener("click", function () {
  if (inputPass.type === "text") {
    inputPass.type = "password";
    togglePass.src = "../Shared/img/login/eye-slash.svg";
  } else {
    inputPass.type = "text";
    togglePass.src = "../Shared/img/login/eye.svg";
  }
});
