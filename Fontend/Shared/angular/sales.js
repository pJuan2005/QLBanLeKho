var app = angular.module("AppRetailPos");

app.controller(
  "salesCtrl",
  function ($scope, $http, AuthService, PermissionService, $window, $document, TranslateService) {
    function applyLanguage(lang) {
      TranslateService.loadLanguage(lang).then(() => {
        $scope.t = TranslateService.t;
      });
    }
    applyLanguage(localStorage.getItem("appLang") || "EN");
    $scope.$on("languageChanged", function () {
      applyLanguage(localStorage.getItem("appLang") || "EN");
    });
    // ==========================================================
    // 0. AUTH & MENU
    // ==========================================================
    $scope.currentUser = AuthService.getCurrentUser();
    if (!$scope.currentUser) {
      $window.location.href = "../AuthFE/login.html";
      return;
    }

    $scope.canShow = function (key) {
      return PermissionService.canShow(key);
    };

    // Helper format tiền VND
    $scope.formatVnd = function (n) {
      if (n == null) return "0 ₫";
      return (
        Number(n).toLocaleString("vi-VN", { maximumFractionDigits: 0 }) + " ₫"
      );
    };

    // ==========================================================
    // 1. STATE FILTER + PAGER + DATA
    // ==========================================================
    $scope.filters = {
      fromDate: null,
      toDate: null,
      status: "", // "", "Paid", "Unpaid", "Partial"
      keyword: "", // invoice hoặc customer name
    };

    $scope.pager = {
      page: 1,
      size: 10,
      total: 0,
      pages: 1,
    };

    // danh sách sale cho bảng
    $scope.sales = [];

    // dữ liệu cho 4 KPI card
    $scope.salesDashboard = {
      totalSales: 0,
      totalRevenue: 0,
      avgOrderValue: 0,
      paidCount: 0,
      unpaidCount: 0,
    };

    // ========= STATE MODAL =========
    $scope.showDetailModal = false;
    $scope.showInvoiceModal = false;
    $scope.selectedSale = null;
    $scope.saleDetail = {};
    $scope.saleItems = [];
    $scope.saleTotals = {};

    // ==========================================================
    // 2. BUILD PAYLOAD CHO API (CHỈ GỬI FILTER KHI CÓ GIÁ TRỊ)
    // ==========================================================
    function buildListPayload() {
      var body = {
        page: $scope.pager.page,
        pageSize: $scope.pager.size,
      };

      if ($scope.filters.fromDate) body.fromDate = $scope.filters.fromDate;
      if ($scope.filters.toDate) body.toDate = $scope.filters.toDate;
      if ($scope.filters.status) body.status = $scope.filters.status;
      if ($scope.filters.keyword) body.keyword = $scope.filters.keyword;

      return body;
    }

    // ==========================================================
    // 3. CALL API LIST
    // ==========================================================
    $scope.loadSales = function () {
      var payload = buildListPayload();

      $http.post(current_url + "/api-core/sales/list", payload).then(
        function (res) {
          var d = res.data || {};

          var rawItems = d.data || d.Data || [];
          var total = d.totalItems || d.TotalItems || 0;
          var page = d.page || d.Page || $scope.pager.page;
          var size = d.pageSize || d.PageSize || $scope.pager.size;

          // chuẩn hoá về camelCase cho FE
          $scope.sales = rawItems.map(function (x) {
            return {
              saleId: x.saleId || x.saleID || x.SaleID,
              invoiceNo: x.invoiceNo || x.InvoiceNo,
              saleDate: x.saleDate || x.SaleDate,
              customerName: x.customerName || x.CustomerName,
              totalAmount: x.totalAmount || x.TotalAmount,
              paymentStatus: x.paymentStatus || x.PaymentStatus,
              paymentMethod: x.paymentMethod || x.PaymentMethod,
            };
          });

          $scope.pager.total = total;
          $scope.pager.page = page;
          $scope.pager.size = size;
          $scope.pager.pages =
            $scope.pager.size > 0
              ? Math.max(1, Math.ceil($scope.pager.total / $scope.pager.size))
              : 1;
        },
        function (err) {
          console.error("Load sales list error:", err);
        }
      );
    };

    // ==========================================================
    // 4. CALL API DASHBOARD (TÁI SỬ DỤNG PAYLOAD)
    // ==========================================================
    $scope.loadDashboard = function () {
      var payload = buildListPayload();

      $http.post(current_url + "/api-core/sales/dashboard", payload).then(
        function (res) {
          var d = res.data || {};
          $scope.salesDashboard = {
            totalSales: d.totalSales || d.TotalSales || 0,
            totalRevenue: d.totalRevenue || d.TotalRevenue || 0,
            avgOrderValue: d.avgOrderValue || d.AvgOrderValue || 0,
            paidCount: d.paidCount || d.PaidCount || 0,
            unpaidCount: d.unpaidCount || d.UnpaidCount || 0,
          };
        },
        function (err) {
          console.error("Load sales dashboard error:", err);
        }
      );
    };

    // ==========================================================
    // 5. FILTER HANDLERS
    // ==========================================================
    $scope.onFilterChanged = function () {
      $scope.pager.page = 1;
      $scope.loadSales();
      $scope.loadDashboard();
    };

    // ==========================================================
    // 6. PAGER HANDLERS
    // ==========================================================
    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.loadSales();
    };

    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.loadSales();
    };

    // ==========================================================
    // 7. ACTION MENU (3 CHẤM)
    // ==========================================================
    $scope.toggleAction = function (sale, $event) {
      if ($event) $event.stopPropagation();

      // đóng menu khác
      $scope.sales.forEach(function (s) {
        if (s !== sale) s.showMenu = false;
      });

      sale.showMenu = !sale.showMenu;
    };

    // Click ra ngoài thì đóng tất cả menu 3 chấm
    var docClickHandler = function () {
      $scope.$applyAsync(function () {
        $scope.sales.forEach(function (s) {
          s.showMenu = false;
        });
      });
    };

    $document.on("click", docClickHandler);

    // cleanup khi scope destroy
    $scope.$on("$destroy", function () {
      $document.off("click", docClickHandler);
    });

    // ==========================================================
    // 8. LOAD CHI TIẾT ĐƠN (DÙNG CHUNG CHO 2 MODAL)
    // ==========================================================
    function loadSaleDetail(saleId) {
      return $http
        .get(current_url + "/api-core/sales/detail", {
          params: { saleId: saleId },
        })
        .then(
          function (res) {
            var d = res.data || {};
            $scope.saleDetail = d.sale || d.Sale || {};
            $scope.saleItems = d.items || d.Items || [];
            $scope.saleTotals = d.totals || d.Totals || {};
          },
          function (err) {
            console.error("Load sale detail error:", err);
          }
        );
    }

    // ==========================================================
    // 9. MODALS
    // ==========================================================

    // Mở modal xem chi tiết sale
    $scope.openDetailModal = function (sale, $event) {
      if ($event) $event.stopPropagation();

      $scope.selectedSale = sale;
      $scope.showDetailModal = true;
      $scope.showInvoiceModal = false;

      // đóng menu 3 chấm
      $scope.sales.forEach(function (s) {
        s.showMenu = false;
      });

      loadSaleDetail(sale.saleId);
    };

    // Mở modal invoice để in
    $scope.openInvoiceModal = function (sale, $event) {
      if ($event) $event.stopPropagation();

      $scope.selectedSale = sale;
      $scope.showInvoiceModal = true;
      $scope.showDetailModal = false;

      // đóng menu 3 chấm
      $scope.sales.forEach(function (s) {
        s.showMenu = false;
      });

      loadSaleDetail(sale.saleId);
    };

    // Hàm đóng tất cả modal
    $scope.closeModals = function () {
      $scope.showDetailModal = false;
      $scope.showInvoiceModal = false;
    };

    // Hàm in PDF (tạm thời dùng window.print)
    $scope.printInvoicePdf = function () {
      window.print();
    };

    // ==========================================================
    // 10. CHIP STATUS
    // ==========================================================
    $scope.getStatusClass = function (sale) {
      var status = (sale.paymentStatus || "").toLowerCase();
      if (status === "paid") return "status-paid";
      if (status === "unpaid") return "status-unpaid";
      if (status === "partial") return "status-partial";
      return "";
    };

    // ==========================================================
    // 11. INIT
    // ==========================================================
    $scope.init = function () {
      $scope.loadSales();
      $scope.loadDashboard();
    };

    $scope.init();
  }
);
