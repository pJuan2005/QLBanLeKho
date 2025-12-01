var app = angular.module("AppRetailPos");
app.controller(
  "categoriesCtrl",
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

    $scope.currentUser = AuthService.getCurrentUser(); // lấy user hiện tại
    $scope.categories = [];
    $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };
    $scope.stats = { total: 0, avgVat: 0, mostCommon: "" };
    $scope.searchCategories = "";
    $scope.searchVAT = "";
    // model cho form add
    $scope.newCategory = {
      CategoryName: "",
      Description: "",
      VATRate: "",
    };
    $scope.savingAdd = false;

    // ----  EDIT ----
    $scope.editingCategory = null;
    $scope.savingEdit = false;

    // ------DELETE------
    $scope.showDelete = false;
    $scope.deleting = null;

    // ------Kiểm tra đăng nhập, logout và chia màn hình theo quyền---------

    if (!$scope.currentUser) {
      $window.location.href = "../AuthFE/login.html";
      return;
    }
    $scope.canShow = function (key) {
      return PermissionService.canShow(key);
    };

    // load dữ liệu từ api search
    $scope.LoadCategories = function () {
      // chuẩn hoá VAT: rỗng sẽ là null có giá trị thì phải là kiểu số
      var vatExact =
        $scope.searchVAT === "" || $scope.searchVAT == null
          ? null
          : parseFloat($scope.searchVAT);
      $http({
        method: "POST",
        url: current_url + "/api-core/category/search",
        data: {
          page: $scope.pager.page,
          pageSize: $scope.pager.size,
          CategoryName: $scope.searchCategories || "",
          vatExact: isNaN(vatExact) ? null : vatExact,
          option: "",
        },
      }).then(
        function (res) {
          var body = res.data || {};
          $scope.categories = body.data || body.Data || [];
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
          $scope.categories = [];
          $scope.pager.total = 0;
          $scope.pager.pages = 1;
        }
      );
    };

    // thêm mới category
    $scope.add = function () {
      var vat = parseFloat($scope.newCategory.VATRate);
      // if (isNaN(vat)) {
      //   alert("VAT không hợp lệ.");
      //   return;
      // }

      // Chuẩn model giống CategoryModel bên C#
      var model = {
        CategoryName: $scope.newCategory.CategoryName,
        Description: $scope.newCategory.Description,
        VATRate: vat,
      };

      $scope.savingAdd = true;

      $http({
        method: "POST",
        url: current_url + "/api-core/category/create-category",
        data: model,
      }).then(
        function (res) {
          $scope.savingAdd = false;
          alert("Thêm danh mục thành công!");

          // reset form
          $scope.resetAddForm();

          // reload lại danh sách (về trang 1 cho dễ thấy)
          $scope.pager.page = 1;
          $scope.LoadCategories();
        },
        function (err) {
          $scope.savingAdd = false;
          console.error(err);
          alert("Thêm không thành công!");
        }
      );
    };

    // reset form add
    $scope.resetAddForm = function () {
      $scope.newCategory = {
        CategoryName: "",
        Description: "",
        VATRate: null,
      };
      if ($scope.frmAdd) {
        $scope.frmAdd.$setPristine();
        $scope.frmAdd.$setUntouched();
      }
    };

    // =====================edit=====================
    // Khi bấm nút Edit trong bảng
    $scope.edit = function (row) {
      $scope.editingCategory = {
        CategoryID: row.CategoryID || row.categoryID,
        CategoryName: row.CategoryName || row.categoryName,
        Description: row.Description || row.description,
        VATRate: parseFloat(row.VATRate || row.vatRate),
      };

      // Gọi JS thuần để mở modal
      openEditModal();
    };

    // Gửi dữ liệu lên API update-category
    $scope.updateCategory = function () {
      if (!$scope.editingCategory) return;

      if (
        !$scope.editingCategory.CategoryName ||
        !$scope.editingCategory.Description
      ) {
        alert("Vui lòng nhập đầy đủ tên và mô tả.");
        return;
      }

      var vat = parseFloat($scope.editingCategory.VATRate);
      if (isNaN(vat)) {
        alert("VAT không hợp lệ.");
        return;
      }

      var model = {
        CategoryID: $scope.editingCategory.CategoryID,
        CategoryName: $scope.editingCategory.CategoryName,
        Description: $scope.editingCategory.Description,
        VATRate: vat,
      };

      $scope.savingEdit = true;

      $http({
        method: "POST",
        url: current_url + "/api-core/category/update-category",
        data: model,
      }).then(
        function (res) {
          $scope.savingEdit = false;
          alert("Cập nhật danh mục thành công!");

          // Ẩn form edit & refresh list
          closeEditModal();
          $scope.editingCategory = null;
          $scope.LoadCategories();
        },
        function (err) {
          $scope.savingEdit = false;
          console.error(err);
          alert("Cập nhật không thành công!");
        }
      );
    };

    // ------DELETE------
    $scope.showDelete = false;
    $scope.deleting = null;
    $scope.deletingBusy = false;

    // mở popup delete khi bấm nút 🗑 trong bảng
    $scope.remove = function (c) {
      // Chuẩn hoá object
      $scope.deleting = {
        CategoryID: c.CategoryID || c.categoryID,
        CategoryName: c.CategoryName || c.categoryName,
      };
      $scope.showDelete = true;
      document.body.classList.add("modal-open");
    };

    // bấm Cancel (nút trong popup)
    $scope.cancelDelete = function (e) {
      if (e) e.preventDefault();
      $scope.showDelete = false;
      $scope.deleting = null;
      $scope.deletingBusy = false;
      document.body.classList.remove("modal-open");
    };
    // bấm nút Delete Category gọi API xoá
    $scope.confirmDelete = function () {
      if (!$scope.deleting || !$scope.deleting.CategoryID) return;
      $scope.deletingBusy = true;

      $http({
        method: "POST",
        url: current_url + "/api-core/category/delete-category",
        // [FromBody]int Id → gửi số thuần
        data: $scope.deleting.CategoryID,
      }).then(
        function (res) {
          $scope.deletingBusy = false;

          // Thông báo từ API
          if (res.data && res.data.message) {
            alert(res.data.message);
          } else {
            alert("Xoá danh mục thành công!");
          }

          // Đóng popup & reload list
          $scope.cancelDelete();
          $scope.pager.page = 1; // có thể quay về trang 1
          $scope.LoadCategories();
        },
        function (err) {
          $scope.deletingBusy = false;
          console.error(err);
          alert("Xoá không thành công!");
        }
      );
    };

    //tối ưu khi search
    var typingTimer;
    function triggerSearch() {
      $scope.pager.page = 1;
      $timeout.cancel(typingTimer);
      typingTimer = $timeout($scope.LoadCategories, 300);
    }
    $scope.$watch("searchCategories", triggerSearch);
    $scope.$watch("searchVAT", triggerSearch);

    // phân trang
    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.LoadCategories();
    };
    //thay đổi số bản ghi trên trang
    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.LoadCategories();
    };

    $scope.CalculateStats = function () {
      if (!$scope.categories || $scope.categories.length === 0) {
        $scope.stats = { total: 0, avgVat: 0, mostCommon: "" };
        return;
      }

      // Tổng số danh mục
      $scope.stats.total = $scope.categories.length;

      // Trung bình VAT
      let sumVat = 0;
      let freq = {};
      for (let c of $scope.categories) {
        let vat = parseFloat(c.VATRate || c.vatRate || 0);
        sumVat += vat;
        let name = c.CategoryName || c.categoryName;
        freq[name] = (freq[name] || 0) + 1;
      }
      $scope.stats.avgVat = sumVat / $scope.categories.length;

      // Loại phổ biến nhất
      let max = 0,
        common = "";
      for (let name in freq) {
        if (freq[name] > max) {
          max = freq[name];
          common = name;
        }
      }
      $scope.stats.mostCommon = common;
    };

    // export excel
    $scope.exportExcel = function () {
      $http({
        method: "POST",
        url: current_url + "/api-core/category/export-excel",
        data: {
          CategoryName: $scope.searchCategories || "",
          vatExact: $scope.searchVAT || null,
        },
        responseType: "arraybuffer",
      }).then(
        function (res) {
          var blob = new Blob([res.data], {
            type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
          });
          var url = URL.createObjectURL(blob);
          var a = document.createElement("a");
          a.href = url;
          a.download = "categories.xlsx";
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
          URL.revokeObjectURL(url);
        },
        function (err) {
          console.error(err);
          alert("Export thất bại");
        }
      );
    };

    //import excel
    $scope.importFile = null;
    // mở dialog chọn file khi bấm icon Import
    $scope.openImportDialog = function () {
      var input = document.getElementById("fileImport");
      if (input) {
        input.click();
      }
    };

    $scope.importFile = null;

    $scope.onImportFileChange = function (element) {
      $scope.$apply(function () {
        $scope.importFile = element.files[0];

        if ($scope.importFile) {
          // gọi luôn import
          $scope.importExcel();

          // reset input để lần sau chọn lại cùng 1 file vẫn chạy onchange
          element.value = null;
        }
      });
    };

    $scope.importExcel = function () {
      if (!$scope.importFile) {
        alert("Chọn file Excel trước đã.");
        return;
      }

      var formData = new FormData();
      formData.append("file", $scope.importFile);

      $http
        .post(current_url + "/api-core/category/import-excel", formData, {
          transformRequest: angular.identity,
          headers: { "Content-Type": undefined },
        })
        .then(
          function (res) {
            alert(res.data.message || "Import Excel thành công!");
            $scope.LoadCategories();
          },
          function (err) {
            console.error(err);
            alert("Import Excel thất bại!");
          }
        );
    };

    // khởi tạo
    $scope.LoadCategories();
  }
);
