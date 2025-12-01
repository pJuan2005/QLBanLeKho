var app = angular.module("AppRetailPos");
app.controller(
  "customerCtrl",
  function ($scope, $http, $timeout, AuthService, PermissionService, $window, TranslateService) {
    function applyLanguage(lang) {
      TranslateService.loadLanguage(lang).then(() => {
        $scope.t = TranslateService.t;
      });
    }
    applyLanguage(localStorage.getItem("appLang") || "EN");
    $scope.$on("languageChanged", function () {
      applyLanguage(localStorage.getItem("appLang") || "EN");
    });


    applyLanguage(localStorage.getItem("appLang") || "EN");
    $scope.currentUser = AuthService.getCurrentUser(); //lấy user hiện tại
    // ------Kiểm tra đăng nhập, logout và chia màn hình theo quyền---------
    if (!$scope.currentUser) {
      $window.location.href = "../AuthFE/login.html";
      return;
    }
    $scope.canShow = function (key) {
      return PermissionService.canShow(key);
    };

    $scope.customers = [];
    $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };
    $scope.stats = { totalCustomer: 0, withDebt: 0 };
    $scope.searchAddress = "";
    $scope.searchPhone = "";

    // model cho form add
    $scope.newCustomer = {
      CustomerName: "",
      CustomerPhone: "",
      CustomerEmail: "",
      CustomerAddress: "",
      CustomerDebt: "",
    };
    $scope.savingAdd = false;

    // ----------edit-------
    $scope.editingCustomer = null;
    $scope.savingEdit = false;

    // ----------delete---------
    $scope.showDelete = false;
    $scope.deleting = null;

    // ======== trạng thái modal ========
    $scope.showAdd = false;
    $scope.showEdit = false;
    $scope.showDelete = false;

    function syncBodyClass() {
      if ($scope.showAdd || $scope.showEdit || $scope.showDelete) {
        document.body.classList.add("modal-open");
      } else {
        document.body.classList.remove("modal-open");
      }
    }

    // load dữ liệu từ api search
    $scope.LoadCustomers = function () {
      $http({
        method: "POST",
        url: current_url + "/api-core/customer/search-customer",
        data: {
          pageIndex: $scope.pager.page,
          pageSize: $scope.pager.size,
          Address: $scope.searchAddress || "",
          Phone: $scope.searchPhone || "",
          option: "",
        },
      }).then(
        function (res) {
          var body = res.data || {};
          $scope.customers = body.data || body.Data || [];
          var total = body.totalItems || body.TotalItems || 0;
          $scope.pager.total = total;
          $scope.pager.pages = Math.max(
            1,
            Math.ceil(total / $scope.pager.size)
          );
          $scope.CalculateStats();
        },
        function (err) {
          console.log(err);
          $scope.customers = [];
          $scope.pager.total = 0;
          $scope.pager.pages = 1;
        }
      );
    };

    // ======== ADD =========
    $scope.newCustomer = {
      CustomerName: "",
      CustomerPhone: "",
      CustomerEmail: "",
      CustomerAddress: "",
      CustomerDebt: "",
    };
    $scope.savingAdd = false;

    $scope.openAdd = function () {
      $scope.resetAddForm();
      $scope.showAdd = true;
      syncBodyClass();
    };

    $scope.closeAddOnOverlay = function (e) {
      if (e.target.classList.contains("form-add")) {
        $scope.cancelAdd();
        $scope.$applyAsync();
      }
    };

    $scope.cancelAdd = function () {
      $scope.showAdd = false;
      syncBodyClass();
    };

    $scope.add = function () {
      var debt = parseFloat($scope.newCustomer.CustomerDebt);
      if (isNaN(debt) || debt < 0) {
        alert("Debt Limit không hợp lệ!");
        return;
      }

      var model = {
        CustomerName: $scope.newCustomer.CustomerName,
        Phone: $scope.newCustomer.CustomerPhone,
        Email: $scope.newCustomer.CustomerEmail,
        Address: $scope.newCustomer.CustomerAddress,
        DebtLimit: debt,
      };

      $scope.savingAdd = true;

      $http({
        method: "POST",
        url: current_url + "/api-core/customer/create-customer",
        data: model,
      }).then(
        function () {
          $scope.savingAdd = false;
          alert("Thêm khách hàng mới thành công!");
          $scope.resetAddForm();
          $scope.showAdd = false;
          syncBodyClass();
          $scope.pager.page = 1;
          $scope.LoadCustomers();
        },
        function (err) {
          $scope.savingAdd = false;
          console.log(err);
          alert("Thêm khách hàng không thành công!");
        }
      );
    };

    $scope.resetAddForm = function () {
      $scope.newCustomer = {
        CustomerName: "",
        CustomerPhone: "",
        CustomerEmail: "",
        CustomerAddress: "",
        CustomerDebt: null,
      };
      if ($scope.frmAdd) {
        $scope.frmAdd.$setPristine();
        $scope.frmAdd.$setUntouched();
      }
    };
    // ======== EDIT =========
    $scope.editingCustomer = null;
    $scope.savingEdit = false;

    $scope.edit = function (c) {
      $scope.editingCustomer = {
        CustomerID: c.customerID || c.CustomerID,
        CustomerName: c.customerName || c.CustomerName,
        CustomerPhone: c.phone || c.Phone,
        CustomerEmail: c.email || c.Email,
        CustomerAddress: c.address || c.Address,
        CustomerDebt: c.debtLimit || c.DebtLimit || 0,
      };

      if ($scope.frmEdit) {
        $scope.frmEdit.$setPristine();
        $scope.frmEdit.$setUntouched();
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

    $scope.updateCustomer = function () {
      if (!$scope.editingCustomer) return;

      var debt = parseFloat($scope.editingCustomer.CustomerDebt);
      if (isNaN(debt) || debt < 0) {
        alert("Debt Limit không hợp lệ!");
        return;
      }

      var model = {
        CustomerID: $scope.editingCustomer.CustomerID,
        CustomerName: $scope.editingCustomer.CustomerName,
        Phone: $scope.editingCustomer.CustomerPhone,
        Email: $scope.editingCustomer.CustomerEmail,
        Address: $scope.editingCustomer.CustomerAddress,
        DebtLimit: debt,
      };

      $scope.savingEdit = true;

      $http({
        method: "POST",
        url: current_url + "/api-core/customer/update-customer",
        data: model,
      }).then(
        function () {
          $scope.savingEdit = false;
          alert("Cập nhật khách hàng thành công!");
          $scope.showEdit = false;
          syncBodyClass();
          $scope.LoadCustomers();
        },
        function (err) {
          $scope.savingEdit = false;
          console.log(err);
          alert("Cập nhật khách hàng không thành công!");
        }
      );
    };

    // ======== DELETE =========
    $scope.deleting = null;

    $scope.remove = function (c) {
      $scope.deleting = {
        customerID: c.customerID || c.CustomerID,
        customerName: c.customerName || c.CustomerName,
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
      var id = $scope.deleting.customerID;

      $http({
        method: "POST",
        url: current_url + "/api-core/customer/delete-customer/" + id,
      }).then(
        function () {
          alert("Xóa khách hàng thành công!");
          $scope.showDelete = false;
          syncBodyClass();
          $scope.LoadCustomers();
        },
        function (err) {
          console.log(err);
          alert("Xóa khách hàng không thành công!");
        }
      );
    };

    // tối ưu khi tìm kiếm
    var typingTimer;
    function triggerSearch() {
      $scope.pager.page = 1;
      $timeout.cancel(typingTimer);
      typingTimer = $timeout($scope.LoadCustomers, 300);
    }
    $scope.$watch("searchAddress", triggerSearch);
    $scope.$watch("searchPhone", triggerSearch);

    // phân trang
    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.LoadCustomers();
    };

    // thay dổi số bản ghi trên trang
    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.LoadCustomers();
    };

    $scope.CalculateStats = function () {
      if (!$scope.customers || $scope.customers.length === 0) {
        $scope.stats = { totalCustomer: 0, withDebt: 0 };
        return;
      }

      // tổng khách hàng
      $scope.stats.totalCustomer = $scope.customers.length;

      // số khách hàng nợ
      let sumCusDebt = 0;
      for (let c of $scope.customers) {
        let numDebt = parseFloat(c.debtLimit || c.DebtLimit || 0);
        if (numDebt > 0) sumCusDebt++;
      }
      $scope.stats.withDebt = sumCusDebt;
    };

    // ================= EXPORT EXCEL =================
    $scope.exportExcel = function () {
      $http({
        method: "POST",
        url: current_url + "/api-core/customer/export-excel",
        data: {
          Phone: $scope.searchPhone || "",
          Address: $scope.searchAddress || "",
        },
        responseType: "arraybuffer", // tải file nhị phân
      }).then(
        function (res) {
          var blob = new Blob([res.data], {
            type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
          });
          var url = URL.createObjectURL(blob);
          var a = document.createElement("a");
          a.href = url;
          a.download = "customers.xlsx";
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

    // ================= IMPORT EXCEL =================
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
        .post(current_url + "/api-core/customer/import-excel", formData, {
          transformRequest: angular.identity,
          headers: { "Content-Type": undefined },
        })
        .then(
          function (res) {
            alert(res.data.message || "Import Excel thành công!");
            $scope.LoadCustomers();
          },
          function (err) {
            console.error(err);
            alert("Import Excel thất bại!");
          }
        );
    };

    // khởi tạo
    $scope.LoadCustomers();
  }
);
