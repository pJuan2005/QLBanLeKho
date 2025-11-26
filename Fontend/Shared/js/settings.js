const avatar = document.getElementById("avatar");
const information = document.getElementById("information");
//nút mở setting admin
avatar.addEventListener("click", function () {
  information.classList.toggle("active"); //toggle sẽ xoá class nếu nó đã có rồi và thêm vào nếu nó chưa có
});

document.addEventListener("click", function (e) {
  if (!avatar.contains(e.target) && !information.contains(e.target)) {
    information.classList.remove("active");
  }
});