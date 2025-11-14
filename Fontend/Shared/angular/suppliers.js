var app = angular.module("AppRetailPos");
app.controller(
  "suppliersCtrl",
  function ($scope, $http, $timeout, AuthService, PermissionService, $window) {
    $scope.currentUser = AuthService.getCurrentUser(); // lấy user hiện tại

    // ------Kiểm tra đăng nhập, logout và chia màn hình theo quyền---------
    if (!$scope.currentUser) {
      $window.location.href = "../AuthFE/login.html";
      return;
    }
    $scope.canShow = function (key) {
      return PermissionService.canShow(key);
    };

    // ====== DỮ LIỆU + PHÂN TRANG ======
    $scope.suppliers = []; // mảng dữ liệu nhà cung cấp
    $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };

    // ====== THỐNG KÊ ======
    $scope.stats = { totalSupplier: 0 };

    // ====== Ô TÌM KIẾM ======

    $scope.searchPhone = "";

    function syncBodyClass() {
      if ($scope.showAdd || $scope.showEdit || $scope.showDelete) {
        document.body.classList.add("modal-open");
      } else {
        document.body.classList.remove("modal-open");
      }
    }


    // load dữ liệu từ api search
    $scope.LoadSuppliers = function () {
      $http({
        method: "POST",
        url: current_url + "/api-admin/supplier/search",
        data: {
          pageIndex: $scope.pager.page,
          pageSize: $scope.pager.size,
          Phone: $scope.searchPhone || "",
          option: ""
        }
      }).then(
        function (res) {
          var body = res.data || {};
          $scope.suppliers = body.data || body.Data || [];
          var total = body.totalItems || body.TotalItems || 0;
          $scope.pager.total = total;
          $scope.pager.pages = Math.max(1, Math.ceil(total / $scope.pager.size));
          $scope.stats.totalSupplier = $scope.suppliers.length;
        },
        function (err) {
          console.error(err);
          $scope.suppliers = [];
          $scope.pager.total = 0;
          $scope.pager.pages = 1;
          $scope.stats.totalSupplier = 0;
        }
      );
    };

    // tối ưu khi tìm kiếm theo Phone
    var typingTimer;
    function triggerSearch() {
      $scope.pager.page = 1;
      $timeout.cancel(typingTimer);
      typingTimer = $timeout($scope.LoadSuppliers, 300);
    }
    $scope.$watch("searchPhone", triggerSearch);

    // phân trang
    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.LoadSuppliers();
    };

    // thay đổi số bản ghi trên trang
    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.LoadSuppliers();
    };

    // tính thống kê cho Supplier
    $scope.CalculateStats = function () {
      if (!$scope.suppliers || $scope.suppliers.length === 0) {
        $scope.stats = { totalSupplier: 0 };
        return;
      }

      // tổng số nhà cung cấp
      $scope.stats.totalSupplier = $scope.suppliers.length;
    };


    // model cho form add Supplier
    $scope.newSupplier = {
      SupplierName: "",
      Phone: "",
      Email: "",
      Address: ""
    };
    $scope.savingAdd = false;

    // trạng thái modal
    $scope.showAdd = false;

    // mở modal Add
    $scope.openAdd = function () {
      $scope.resetAddForm();
      $scope.showAdd = true;
      syncBodyClass();
    };

    // đóng modal khi click overlay
    $scope.closeAddOnOverlay = function (e) {
      if (e.target.classList.contains("form-add")) {
        $scope.cancelAdd();
        $scope.$applyAsync();
      }
    };

    // cancel Add
    $scope.cancelAdd = function () {
      $scope.showAdd = false;
      syncBodyClass();
    };

    // thêm Supplier
    $scope.addSupplier = function () {
      var model = {
        SupplierName: $scope.newSupplier.SupplierName,
        Phone: $scope.newSupplier.Phone,
        Email: $scope.newSupplier.Email,
        Address: $scope.newSupplier.Address
      };

      $scope.savingAdd = true;

      $http({
        method: "POST",
        url: current_url + "/api-admin/supplier/create-supplier",
        data: model
      }).then(
        function () {
          $scope.savingAdd = false;
          alert("Thêm nhà cung cấp mới thành công!");
          $scope.resetAddForm();
          $scope.showAdd = false;
          syncBodyClass();
          $scope.pager.page = 1;
          $scope.LoadSuppliers(); // refresh bảng
        },
        function (err) {
          $scope.savingAdd = false;
          console.error(err);
          alert("Thêm nhà cung cấp không thành công!");
        }
      );
    };

    // reset form Add
    $scope.resetAddForm = function () {
      $scope.newSupplier = {
        SupplierName: "",
        Phone: "",
        Email: "",
        Address: ""
      };
      if ($scope.frmAddSupplier) {
        $scope.frmAddSupplier.$setPristine();
        $scope.frmAddSupplier.$setUntouched();
      }
    };

    // ======== EDIT ========
    $scope.editingSupplier = null;
    $scope.savingEdit = false;

    // ======== TRẠNG THÁI MODAL ========
    $scope.showEdit = false;

    // ======== EDIT SUPPLIER ========
    $scope.edit = function (s) {
      $scope.editSupplier = {
        SupplierID: s.supplierID || s.SupplierID,
        SupplierName: s.supplierName || s.SupplierName,
        Phone: s.phone || s.Phone,
        Email: s.email || s.Email,
        Address: s.address || s.Address
      };

      if ($scope.frmEditSupplier) {
        $scope.frmEditSupplier.$setPristine();
        $scope.frmEditSupplier.$setUntouched();
      }

      $scope.showEdit = true;
      syncBodyClass();
    };


    $scope.closeEditOnOverlay = function (e) {
      if (e.target.classList.contains("form-edit")) {
        $scope.cancelEdit();
        $scope.$applyAsync();
      }
    };

    $scope.cancelEdit = function () {
      $scope.showEdit = false;
      syncBodyClass();
    };

    $scope.updateSupplier = function () {
      if (!$scope.editSupplier) return;

      var model = {
        SupplierID: $scope.editSupplier.SupplierID,
        SupplierName: $scope.editSupplier.SupplierName,
        Phone: $scope.editSupplier.Phone,
        Email: $scope.editSupplier.Email,
        Address: $scope.editSupplier.Address
      };

      $scope.savingEdit = true;

      $http({
        method: "POST", // hoặc PUT nếu BE dùng PUT
        url: current_url + "/api-admin/supplier/update-supplier",
        data: model
      }).then(
        function () {
          $scope.savingEdit = false;
          alert("Cập nhật nhà cung cấp thành công!");
          $scope.showEdit = false;
          syncBodyClass();
          $scope.LoadSuppliers();
        },
        function (err) {
          $scope.savingEdit = false;
          console.error(err);
          alert("Cập nhật nhà cung cấp không thành công!");
        }
      );
    };

    // ----------delete---------
    $scope.showDelete = false;
    $scope.deleting = null;

    // ======== TRẠNG THÁI MODAL ========
    $scope.showDelete = false;

    // ======== DELETE SUPPLIER =========
    $scope.deleting = null;

    $scope.remove = function (s) {
      $scope.deleting = {
        SupplierID: s.supplierID || s.SupplierID,
        SupplierName: s.supplierName || s.SupplierName
      };
      $scope.showDelete = true;
      syncBodyClass();
    };

    $scope.closeDeleteOnOverlay = function (e) {
      if (e.target.classList.contains("form-delete")) {
        $scope.cancelDelete(e);
        $scope.$applyAsync();
      }
    };

    $scope.cancelDelete = function (e) {
      if (e) e.stopPropagation();
      $scope.showDelete = false;
      syncBodyClass();
    };

    $scope.confirmDelete = function () {
      if (!$scope.deleting) return;
      var id = $scope.deleting.SupplierID;

      $http({
        method: "POST", // BE đang dùng POST cho delete
        url: current_url + "/api-admin/supplier/delete-supplier/" + id
      }).then(
        function () {
          alert("Xóa nhà cung cấp thành công!");
          $scope.showDelete = false;
          syncBodyClass();
          $scope.LoadSuppliers();
        },
        function (err) {
          console.log(err);
          alert("Xóa nhà cung cấp không thành công!");
        }
      );
    };


    // ================= EXPORT EXCEL SUPPLIER =================
    $scope.exportExcel = function () {
      $http({
        method: "POST",
        url: current_url + "/api-admin/supplier/export-excel", // đúng route BE
        data: {
          Phone: $scope.searchPhone || "",
          Address: $scope.searchAddress || ""
        },
        responseType: "arraybuffer" // tải file nhị phân
      }).then(
        function (res) {
          var blob = new Blob([res.data], {
            type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          });
          var url = URL.createObjectURL(blob);
          var a = document.createElement("a");
          a.href = url;
          a.download = "suppliers.xlsx";
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
          URL.revokeObjectURL(url);
        },
        function (err) {
          console.error(err);
          alert("Export Excel thất bại!");
        }
      );
    };

    // ================= IMPORT EXCEL SUPPLIER =================
    $scope.importFile = null;

    // mở dialog chọn file Excel
    $scope.openImportDialog = function () {
      var input = document.getElementById("fileImport");
      if (input) {
        input.click();
      }
    };

    $scope.onImportFileChange = function (element) {
      $scope.$apply(function () {
        $scope.importFile = element.files[0];

        if ($scope.importFile) {
          $scope.importExcel();
          // reset input để lần sau chọn lại cùng 1 file vẫn chạy onchange
          element.value = null;
        }
      });
    };

    $scope.importExcel = function () {
      if (!$scope.importFile) {
        alert("Vui lòng chọn file Excel trước.");
        return;
      }

      var formData = new FormData();
      formData.append("file", $scope.importFile);

      $http
        .post(current_url + "/api-admin/supplier/import-excel", formData, {
          transformRequest: angular.identity,
          headers: { "Content-Type": undefined },
        })
        .then(
          function (res) {
            alert(res.data.message || "Import Excel nhà cung cấp thành công!");
            $scope.LoadSuppliers();
          },
          function (err) {
            console.error(err);
            alert("Import Excel nhà cung cấp thất bại!");
          }
        );
    };



    // khởi tạo
    $scope.LoadSuppliers();




  }
);
