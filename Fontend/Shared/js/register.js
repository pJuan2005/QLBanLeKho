const passwordInput = document.getElementById("password");
const togglePass = document.getElementById("togglePass");
const togglePass2 = document.getElementById("togglePass2");
const confirmPassInput = document.getElementById("confirmpass");

togglePass.addEventListener("click", function () {
  if (passwordInput.type === "password") {
    passwordInput.type = "text";
    togglePass.src = "../Shared/img/register/eye.svg";
  } else {
    passwordInput.type = "password";
    togglePass.src = "../Shared/img/register/eye-slash.svg";
  }
});

togglePass2.addEventListener("click", function () {
  if (confirmPassInput.type === "password") {
    confirmPassInput.type = "text";
    togglePass2.src = "../Shared/img/register/eye.svg";
  } else {
    confirmPassInput.type = "password";
    togglePass2.src = "../Shared/img/register/eye-slash.svg";
  }
});
