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

// ==================form add Purchase Order================
const poModal = document.querySelector(".form-add");          // modal Add PO
const poBtnOpen = document.getElementById("btnOpenAdd");      // nút mở Add PO
const poBtnCancel = poModal.querySelector(".cancel");         // nút Cancel trong modal

// mở modal khi bấm nút Add Purchase Order
poBtnOpen.addEventListener("click", () => {
  poModal.classList.add("open");
  document.body.classList.add("modal-open");
});

// đóng modal khi bấm Cancel
poBtnCancel.addEventListener("click", (e) => {
  e.preventDefault();
  poModal.classList.remove("open");
  document.body.classList.remove("modal-open");
});

// ==============form edit========================
const formEditPO = document.querySelector(".form-edit-po");
const btnCancelEditPO = formEditPO.querySelector(".cancel");

// Mở modal
function openEditPOModal() {
  formEditPO.classList.add("open");
  document.body.classList.add("modal-open");
}

// Đóng modal
function closeEditPOModal() {
  formEditPO.classList.remove("open");
  document.body.classList.remove("modal-open");
}

// Khi nhấn Cancel
btnCancelEditPO.addEventListener("click", (e) => {
  e.preventDefault();
  closeEditPOModal();
});

