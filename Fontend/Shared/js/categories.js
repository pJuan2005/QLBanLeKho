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

// ==================form add================
const modal = document.querySelector(".form-add");
const btnOpen = document.getElementById("btnOpenAdd");
const btnCancel = modal.querySelector(".cancel");

// mở
btnOpen.addEventListener("click", () => {
  modal.classList.add("open");
  document.body.classList.add("modal-open");
});

// đóng khi ấn Cancel
btnCancel.addEventListener("click", (e) => {
  e.preventDefault();
  modal.classList.remove("open");
  document.body.classList.remove("modal-open");
});

// ==============form edit========================
const formEdit = document.querySelector(".form-edit");
const btnCancelEdit = formEdit.querySelector(".cancel");

// Ví dụ: khi nhấn nút Edit trong bảng
function openEditModal() {
  formEdit.classList.add("open");
  document.body.classList.add("modal-open");
}

function closeEditModal() {
  formEdit.classList.remove("open");
  document.body.classList.remove("modal-open");
}

// Khi nhấn Cancel
btnCancelEdit.addEventListener("click", (e) => {
  e.preventDefault();
  formEdit.classList.remove("open");
  document.body.classList.remove("modal-open");
});
