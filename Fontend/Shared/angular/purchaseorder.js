var app = angular.module("AppRetailPos");

app.controller(
  "purchaseorderCtrl",
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
    // ====== AUTH ======
    $scope.currentUser = AuthService.getCurrentUser(); // lấy user hiện tại

    // ====== DỮ LIỆU + PHÂN TRANG ======
    $scope.purchaseOrders = []; // mảng dữ liệu đơn mua hàng
    $scope.pager = { page: 1, size: 10, total: 0, pages: 1 }; // phân trang

    // ====== THỐNG KÊ (nếu cần hiển thị giống categories) ======
    $scope.stats = {
      total: 0,           // Tổng số đơn mua hàng
      countApproved: 0,   // Số lượng đơn đã Approved
      countPending: 0,    // Số lượng đơn Pending
      countProcessing: 0  // Số lượng đơn Processing
    };

    // ====== Ô TÌM KIẾM (5 trường) ======
    $scope.searchFromDate = "";
    $scope.searchToDate = "";
    $scope.searchMinAmount = "";
    $scope.searchMaxAmount = "";
    $scope.searchStatus = "";

    // ====== MODEL CHO FORM ADD ======
    $scope.newPurchaseOrder = {
      SupplierID: ""
      
    };
    $scope.savingAdd = false;

    // ====== MODEL CHO EDIT ======
    $scope.editingPurchaseOrder = null;
    $scope.savingEdit = false;

    // ====== MODEL CHO DELETE ======
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
    $scope.LoadPurchaseOrders = function () {
      // nếu searchPurchaseOrder có giá trị → dùng làm status
      var statusFilter = $scope.searchPurchaseOrder?.trim() || $scope.searchStatus || "";

      $http({
        method: "POST",
        url: current_url + "/api-core/purchaseorder/search",
        data: {
          page: $scope.pager.page,
          pageSize: $scope.pager.size,
          fromDate: $scope.searchFromDate || null,
          toDate: $scope.searchToDate || null,
          minTotalAmount: $scope.searchMinAmount || null,
          maxTotalAmount: $scope.searchMaxAmount || null,
          status: statusFilter
        },
        headers: { "Content-Type": "application/json" }
      }).then(function (res) {
        var body = res.data || {};
        $scope.purchaseOrders = body.data || [];
        var total = body.totalItems || 0;
        $scope.pager.total = total;
        $scope.pager.pages = Math.max(1, Math.ceil(total / $scope.pager.size));
        $scope.CalculateStats();
      }, function (err) {
        console.error(err);
        $scope.purchaseOrders = [];
        $scope.pager.total = 0;
        $scope.pager.pages = 1;
      });
    };


    // tối ưu khi search
    var typingTimer;
    function triggerSearch() {
      $scope.pager.page = 1;
      $timeout.cancel(typingTimer);
      typingTimer = $timeout($scope.LoadPurchaseOrders, 300);
    }

    // theo dõi 5 ô tìm kiếm
    $scope.$watch("searchFromDate", triggerSearch);
    $scope.$watch("searchToDate", triggerSearch);
    $scope.$watch("searchMinAmount", triggerSearch);
    $scope.$watch("searchMaxAmount", triggerSearch);
    $scope.$watch("searchStatus", triggerSearch);

    $scope.searchPurchaseOrder = "";

    $scope.$watch("searchPurchaseOrder", triggerSearch);


    // phân trang
    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.LoadPurchaseOrders();
    };

    // thay đổi số bản ghi trên trang
    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.LoadPurchaseOrders();
    };

    // tính thống kê cho Purchase Orders
    $scope.CalculateStats = function () {
      if (!$scope.purchaseOrders || $scope.purchaseOrders.length === 0) {
        $scope.stats = { total: 0, countApproved: 0, countPending: 0, countProcessing: 0 };
        return;
      }

      // Tổng số đơn
      $scope.stats.total = $scope.purchaseOrders.length;

      // Đếm theo trạng thái
      let approved = 0, pending = 0, processing = 0;
      for (let po of $scope.purchaseOrders) {
        let status = po.Status || po.status;
        if (status === "Approved") approved++;
        else if (status === "Pending") pending++;
        else if (status === "Processing") processing++;
      }

      $scope.stats.countApproved = approved;
      $scope.stats.countPending = pending;
      $scope.stats.countProcessing = processing;
    };
    // format ngày hiển thị trong bảng
    $scope.formatDate = function (dateStr) {
      if (!dateStr) return "";
      var d = new Date(dateStr);
      return d.toLocaleDateString("vi-VN"); // hiển thị dd/mm/yyyy
    };


    // thêm mới Purchase Order
    $scope.addPurchaseOrder = function () {
      // Chuẩn model giống PurchaseOrderModel bên C#
      var model = {
        SupplierID: $scope.newPurchaseOrder.SupplierID,
        
        // POID và OrderDate không cần nhập vì SQL tự tăng / tự tạo
      };

      $scope.savingAdd = true;

      $http({
        method: "POST",
        url: current_url + "/api-core/purchaseorder/create",
        // vì controller nhận List<PurchaseOrderModel>, ta gửi mảng chứa 1 phần tử
        data: [model],
        headers: { "Content-Type": "application/json" }
      }).then(
        function (res) {
          $scope.savingAdd = false;
          alert("Thêm đơn mua hàng thành công!");

          // reset form
          $scope.resetAddForm();

          // reload lại danh sách (về trang 1 cho dễ thấy)
          $scope.pager.page = 1;
          $scope.LoadPurchaseOrders();

          // đóng modal
          $scope.closeAddModal();
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
      $scope.newPurchaseOrder = {
        SupplierID: "",
        
      };
      if ($scope.frmAddPO) {
        $scope.frmAddPO.$setPristine();
        $scope.frmAddPO.$setUntouched();
      }
    };

    // =====================edit=====================
    // Khi bấm nút Edit trong bảng
    $scope.edit = function (row) {
      $scope.editingPO = {
        POID: row.POID || row.poid,
        SupplierID: row.SupplierID || row.supplierID,
        Status: row.Status || row.status
      };

      // Gọi JS thuần để mở modal
      openEditPOModal();
    };

    // Gửi dữ liệu lên API update-purchaseorder
    $scope.updatePurchaseOrder = function () {
      if (!$scope.editingPO) return;

      if (!$scope.editingPO.SupplierID || !$scope.editingPO.Status) {
        alert("Vui lòng nhập đầy đủ SupplierID và Status.");
        return;
      }

      var model = {
        POID: $scope.editingPO.POID,
        SupplierID: parseInt($scope.editingPO.SupplierID),
        Status: $scope.editingPO.Status
      };

      $scope.savingEditPO = true;

      $http({
        method: "POST",
        url: current_url + "/api-core/purchaseorder/update",
        data: model,
      }).then(
        function (res) {
          $scope.savingEditPO = false;
          alert("Cập nhật đơn hàng thành công!");

          // Ẩn form edit & refresh list
          closeEditPOModal();
          $scope.editingPO = null;
          $scope.LoadPurchaseOrders();
        },
        function (err) {
          $scope.savingEditPO = false;
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
    $scope.remove = function (po) {
      $scope.deleting = {
        POID: po.POID || po.poid,
        SupplierID: po.SupplierID || po.supplierID,
        Status: po.Status || po.status
      };
      $scope.showDelete = true;
      document.body.classList.add("modal-open");
    };

    // bấm Cancel
    $scope.cancelDelete = function (e) {
      if (e) e.preventDefault();
      $scope.showDelete = false;
      $scope.deleting = null;
      $scope.deletingBusy = false;
      document.body.classList.remove("modal-open");
    };

    // bấm Delete PurchaseOrder gọi API xoá
    $scope.confirmDelete = function () {
      if (!$scope.deleting || !$scope.deleting.POID) return;
      $scope.deletingBusy = true;

      $http({
        method: "POST",
        url: current_url + "/api-core/purchaseorder/delete",
        data: $scope.deleting, // gửi cả model để khớp với [FromBody]PurchaseOrderModel
      }).then(
        function (res) {
          $scope.deletingBusy = false;

          if (res.data && res.data.data === "OK") {
            alert("Xoá đơn hàng thành công!");
          } else {
            alert("Xoá đơn hàng không thành công!");
          }

          // Đóng popup & reload list
          $scope.cancelDelete();
          $scope.pager.page = 1;
          $scope.LoadPurchaseOrders();
        },
        function (err) {
          $scope.deletingBusy = false;
          console.error(err);
          alert("Xoá không thành công!");
        }
      );
    };


    //Export Excel
    $scope.exportPO = function (po) {
      var id = po.POID || po.poid; // lấy giá trị dù là hoa hay thường

      if (!id) {
        alert("Không xác định được POID.");
        console.log("Export PO object:", po);
        return;
      }

      $http({
        method: "GET",
        url: current_url + "/api-core/purchaseorder/export-excel/" + id,
        responseType: "arraybuffer"
      }).then(function (res) {
        var blob = new Blob([res.data], {
          type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        });
        var url = URL.createObjectURL(blob);
        var a = document.createElement("a");
        a.href = url;
        a.download = "purchaseorder_" + id + ".xlsx";
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
      }).catch(function (err) {
        console.error(err);
        alert("Export thất bại");
      });
    };



    // ================== PURCHASE ORDER DETAIL ==================
    $scope.showDetail = false;
    $scope.detailPO = {};
    $scope.purchaseOrderDetails = [];

    // mở modal detail khi bấm nút 🔍
    $scope.viewDetail = function (po) {
      $scope.detailPO = { POID: po.POID || po.poid };
      $scope.showDetail = true;
      document.body.classList.add("modal-open");

      // gọi API GET để lấy danh sách chi tiết theo POID
      $http({
        method: "GET",
        url: current_url + "/api-core/purchaseorderdetails/get-by-poid/" + $scope.detailPO.POID
      }).then(function (res) {
        var body = res.data || [];
        $scope.purchaseOrderDetails = body; // API trả List<PurchaseOrderDetailsModel>
      }).catch(function (err) {
        console.error("❌ Load details error:", err);
        $scope.purchaseOrderDetails = [];
      });
    };

    // đóng modal detail
    $scope.closeDetailModal = function () {
      $scope.showDetail = false;
      $scope.detailPO = {};
      $scope.purchaseOrderDetails = [];
      document.body.classList.remove("modal-open");
    };


    // Thêm mới chi tiết đơn hàng
    $scope.newDetail = {
      ProductID: "",
      Quantity: "",
      UnitPrice: ""
    };
    $scope.savingDetail = false;

    // Thêm mới chi tiết đơn hàng
    $scope.addDetail = function () {
      var poid = $scope.detailPO.POID;
      if (!poid) {
        alert("Không xác định được POID.");
        return;
      }

      var model = {
        POID: poid,
        ProductID: parseInt($scope.newDetail.ProductID),
        Quantity: parseInt($scope.newDetail.Quantity),
        UnitPrice: parseFloat($scope.newDetail.UnitPrice)
      };

      if (!model.ProductID || !model.Quantity || isNaN(model.UnitPrice)) {
        alert("Vui lòng nhập đầy đủ thông tin.");
        return;
      }

      $scope.savingDetail = true;

      $http({
        method: "POST",
        url: current_url + "/api-core/purchaseorderdetails/create",
        data: [model],
        headers: { "Content-Type": "application/json" }
      }).then(function (res) {
        $scope.savingDetail = false;
        alert("Thêm chi tiết đơn hàng thành công!");

        // reset form
        $scope.resetAddDetail();

        // ✅ tự động reload lại toàn bộ trang
        $window.location.reload();

      }).catch(function (err) {
        $scope.savingDetail = false;
        console.error("❌ Add detail error:", err);
        alert("Thêm không thành công!");
      });
    };

    //chọn dữ liệu hiển thị ra các trường nhạp
    $scope.selectDetail = function (detail) {
      $scope.newDetail = {
        ProductID: detail.productID,
        Quantity: detail.quantity,
        UnitPrice: detail.unitPrice
      };
    };

    //delete
    $scope.deleteDetail = function () {
      var poid = $scope.detailPO.POID;
      var productID = $scope.newDetail.ProductID;

      if (!poid || !productID) {
        alert("Vui lòng chọn bản ghi cần xoá.");
        return;
      }

      if (!confirm("Bạn có chắc muốn xoá chi tiết này?")) return;

      var model = {
        POID: poid,
        ProductID: parseInt(productID)
      };

      $http({
        method: "POST",
        url: current_url + "/api-core/purchaseorderdetails/delete",
        data: model,
        headers: { "Content-Type": "application/json" }
      }).then(function (res) {
        alert("Xoá chi tiết thành công!");
        $scope.resetAddDetail();
        $scope.viewDetail({ POID: poid }); // reload lại bảng chi tiết
        // ✅ tự động reload lại toàn bộ trang
        $window.location.reload();
      }).catch(function (err) {
        console.error("❌ Delete detail error:", err);
        alert("Xoá không thành công!");
      });
    };



    // Reset form thêm chi tiết
    $scope.resetAddDetail = function () {
      $scope.newDetail = {
        ProductID: "",
        Quantity: "",
        UnitPrice: ""
      };
      if ($scope.frmAddDetail) {
        $scope.frmAddDetail.$setPristine();
        $scope.frmAddDetail.$setUntouched();
      }
    };


    // khởi tạo
    $scope.LoadPurchaseOrders();
  }
);


