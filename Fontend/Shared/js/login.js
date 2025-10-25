const passwordInput = document.getElementById("password");
const togglePass = document.getElementById("togglePass");

togglePass.addEventListener("click",function(){
if(passwordInput.type === "password"){
    passwordInput.type = "text";
    togglePass.src = "../Shared/img/login/eye.svg"
}
else{
    passwordInput.type ="password";
    togglePass.src = "../Shared/img/login/eye-slash.svg"
}
});