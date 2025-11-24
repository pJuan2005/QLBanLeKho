var app = angular.module("AppRetailPos");

app.controller("userCtrl", function ($scope, $http, $timeout, AuthService, PermissionService, $window) {

  // ------Kiểm tra đăng nhập, logout và chia màn hình theo quyền---------
  $scope.currentUser = AuthService.getCurrentUser();
  if (!$scope.currentUser) {
    $window.location.href = "../AuthFE/login.html";
    return;
  }


  $scope.canShow = function (key) {
    return PermissionService.canShow(key);
  };

  // ====== DATA ======
  $scope.users = [];
  $scope.searchUserText = "";

  $scope.pager = {
    page: 1,
    size: 10,
    total: 0,
    pages: 1
  };

  // ====== LOAD USER TỪ API ======
  $scope.LoadUsers = function () {

    $http({
      method: "POST",
      url: current_url + "/api-admin/user/search",
      data: {
        pageIndex: $scope.pager.page,
        pageSize: $scope.pager.size,
        FullName: $scope.searchUserText,
        UserName: $scope.searchUserText
      }
    }).then(
      function (res) {
        var body = res.data || {};

        $scope.users = body.data || body.Data || [];
        var total = body.totalItems || body.TotalItems || 0;

        $scope.pager.total = total;
        $scope.pager.pages = Math.max(1, Math.ceil(total / $scope.pager.size));
      },
      function (err) {
        console.error("LoadUsers error:", err);
        $scope.users = [];
        $scope.pager.total = 0;
        $scope.pager.pages = 1;
      }
    );
  };

  // ====== TÌM KIẾM (DEBOUNCE 300ms) ======
  var typingTimer;
  function triggerSearch() {
    $scope.pager.page = 1;
    $timeout.cancel(typingTimer);
    typingTimer = $timeout($scope.LoadUsers, 300);
  }
  $scope.$watch("searchUserText", triggerSearch);

  // ====== PHÂN TRANG ======
  $scope.go = function (p) {
    if (p < 1 || p > $scope.pager.pages) return;
    $scope.pager.page = p;
    $scope.LoadUsers();
  };

  $scope.changeSize = function () {
    $scope.pager.page = 1;
    $scope.LoadUsers();
  };

  // ======== DETAIL USER ========
  $scope.detailUser = null; // model lưu thông tin user
  $scope.showDetail = false; // trạng thái modal

  // mở modal Detail
  $scope.detail = function (u) {
    $scope.detailUser = {
      UserID: u.userID || u.UserID,
      Username: u.username || u.Username,
      PasswordHash: u.passwordHash || u.PasswordHash
    };

    $scope.showDetail = true;
    syncBodyClass(); // khóa scroll nền
  };

  // đóng modal khi click overlay
  $scope.closeDetailOnOverlay = function (e) {
    if (e.target.classList.contains("form-detail")) {
      $scope.cancelDetail();
      $scope.$applyAsync();
    }
  };

  // hủy/đóng modal
  $scope.cancelDetail = function () {
    $scope.showDetail = false;
    syncBodyClass();
  };

  // ========================== SYNC BODY CLASS ==========================
  function syncBodyClass() {
    if ($scope.showAdd) {
      document.body.classList.add("modal-open");
    } else {
      document.body.classList.remove("modal-open");
    }
  }

  // ========================== MODEL FORM ADD USER ==========================
  $scope.newUser = {
    Username: "",
    PasswordHash: "",
    FullName: "",
    Role: "",
    Email: "",
    Phone: ""
  };

  $scope.savingAdd = false;

  // trạng thái modal
  $scope.showAdd = false;

  // ========================== OPEN MODAL ADD ==========================
  $scope.openAdd = function () {
    $scope.resetAddForm();
    $scope.showAdd = true;
    syncBodyClass();
  };

  // ========================== CLICK OVERLAY TO CLOSE ==========================
  $scope.closeAddOnOverlay = function (e) {
    if (e.target.classList.contains("form-add")) {
      $scope.cancelAdd();
      $scope.$applyAsync();
    }
  };

  // ========================== CANCEL ADD ==========================
  $scope.cancelAdd = function () {
    $scope.showAdd = false;
    syncBodyClass();
  };

  // ========================== ADD USER ==========================
  $scope.addUser = function () {
    var model = {
      Username: $scope.newUser.Username,
      PasswordHash: $scope.newUser.PasswordHash,
      FullName: $scope.newUser.FullName,
      Role: $scope.newUser.Role,
      Email: $scope.newUser.Email,
      Phone: $scope.newUser.Phone
    };

    $scope.savingAdd = true;

    $http({
      method: "POST",
      url: current_url + "/api-admin/user/create-user",
      data: model
    }).then(
      function () {
        $scope.savingAdd = false;
        alert("Thêm người dùng mới thành công!");

        $scope.resetAddForm();
        $scope.showAdd = false;
        syncBodyClass();

        $scope.pager.page = 1;
        $scope.LoadUsers(); // refresh bảng User
      },
      function (err) {
        $scope.savingAdd = false;
        console.error(err);
        alert("Thêm người dùng không thành công!");
      }
    );
  };

  // ========================== RESET ADD FORM ==========================
  $scope.resetAddForm = function () {
    $scope.newUser = {
      Username: "",
      PasswordHash: "",
      FullName: "",
      Role: "",
      Email: "",
      Phone: ""
    };

    if ($scope.frmAddUser) {
      $scope.frmAddUser.$setPristine();
      $scope.frmAddUser.$setUntouched();
    }
  };

  // ======== EDIT ========
  $scope.editingUser = null;
  $scope.savingEdit = false;

  // ======== TRẠNG THÁI MODAL ========
  $scope.showEdit = false;

  // ======== EDIT USER ========
  $scope.edit = function (u) {
    // điền sẵn dữ liệu vào form edit
    $scope.editUser = {
      UserID: u.userID || u.UserID,
      Username: u.username || u.Username,
      PasswordHash: u.passwordHash || u.PasswordHash, // điền hash từ dữ liệu
      Role: u.role || u.Role,
      FullName: u.fullName || u.FullName,
      Email: u.email || u.Email,
      Phone: u.phone || u.Phone
    };


    // reset trạng thái form Angular
    if ($scope.frmEditUser) {
      $scope.frmEditUser.$setPristine();
      $scope.frmEditUser.$setUntouched();
    }

    // mở modal
    $scope.showEdit = true;
    syncBodyClass();
  };

  // ======== ĐÓNG MODAL KHI CLICK OVERLAY ========
  $scope.closeEditOnOverlay = function (e) {
    if (e.target.classList.contains("form-edit")) {
      $scope.cancelEdit();
      $scope.$applyAsync();
    }
  };

  // ======== CANCEL EDIT ========
  $scope.cancelEdit = function () {
    $scope.showEdit = false;
    syncBodyClass();
  };

  // ======== UPDATE USER ========
  $scope.updateUser = function () {
    if (!$scope.editUser) return;

    var model = {
      UserID: $scope.editUser.UserID,
      Username: $scope.editUser.Username,
      PasswordHash: $scope.editUser.PasswordHash || null, // null nghĩa không đổi
      Role: $scope.editUser.Role,
      FullName: $scope.editUser.FullName,
      Email: $scope.editUser.Email,
      Phone: $scope.editUser.Phone
    };


    $scope.savingEdit = true;

    $http({
      method: "POST",
      url: current_url + "/api-admin/user/update-user",
      data: model
    }).then(
      function () {
        $scope.savingEdit = false;
        alert("Cập nhật người dùng thành công!");
        $scope.showEdit = false;
        syncBodyClass();
        $scope.LoadUsers();
      },
      function (err) {
        $scope.savingEdit = false;
        console.error(err);
        alert("Cập nhật người dùng không thành công!");
      }
    );
  };

  // ---------- DELETE USER ----------
  $scope.showDelete = false;
  $scope.deletingUser = null;

  // Mở modal Delete
  $scope.remove = function (u) {
    $scope.deletingUser = {
      UserID: u.userID || u.UserID,
      FullName: u.fullName || u.FullName,
      Username: u.username || u.Username
    };
    $scope.showDelete = true;
    syncBodyClass();
  };

  // Đóng modal khi click overlay
  $scope.closeDeleteOnOverlay = function (e) {
    if (e.target.classList.contains("form-delete")) {
      $scope.cancelDelete(e);
      $scope.$applyAsync();
    }
  };

  // Cancel Delete
  $scope.cancelDelete = function (e) {
    if (e) e.stopPropagation();
    $scope.showDelete = false;
    syncBodyClass();
  };

  // Xác nhận Delete
  $scope.confirmDelete = function () {
    if (!$scope.deletingUser) return;
    var id = $scope.deletingUser.UserID;

    $scope.savingDelete = true;

    $http({
      method: "POST", 
      url: current_url + "/api-admin/user/delete-user",
      data: id
    }).then(
      function (res) {
        $scope.savingDelete = false;
        alert(res.data.message || "Xóa người dùng thành công!");
        $scope.showDelete = false;
        syncBodyClass();
        $scope.LoadUsers(); // load lại bảng
      },
      function (err) {
        $scope.savingDelete = false;
        console.error(err);
        alert("Xóa người dùng không thành công!");
      }
    );
  };






  // ====== LOADING TRANG BAN ĐẦU ======
  $scope.LoadUsers();
});
