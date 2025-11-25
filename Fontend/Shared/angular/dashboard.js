var app = angular.module("AppRetailPos");

app.controller(
  "dashboardCtrl",
  function ($scope, $http, AuthService, PermissionService, $window, $document) {
    // ==========================================================
    // 0. AUTH & MENU
    // ==========================================================
    $scope.currentUser = AuthService.getCurrentUser(); //lấy user hiện tại

    if (!$scope.currentUser) {
      $window.location.href = "../AuthFE/login.html";
      return;
    }

    $scope.canShow = function (key) {
      return PermissionService.canShow(key);
    };

    // Helper format tiền VND (dùng ở KPI + bảng Recent Transactions + modal)
    $scope.formatVnd = function (n) {
      if (n == null) return "0 ₫";
      return (
        Number(n).toLocaleString("vi-VN", { maximumFractionDigits: 0 }) + " ₫"
      );
    };

    // ==========================================================
    // 1. KPI HÔM NAY vs HÔM QUA
    // ==========================================================
    $scope.loadTodayKPI = function () {
      let today = new Date();
      let yyyy = today.getFullYear();
      let mm = (today.getMonth() + 1).toString().padStart(2, "0");
      let dd = today.getDate().toString().padStart(2, "0");
      let todayStr = `${yyyy}-${mm}-${dd}`;

      let yesterdayStr = getYesterday();

      // --- Gọi API hôm nay ---
      let todayAPI = $http.post(current_url + "/api-core/report/revenue", {
        fromDate: todayStr,
        toDate: todayStr,
        option: "DAY",
      });

      // --- Gọi API hôm qua ---
      let yesterdayAPI = $http.post(current_url + "/api-core/report/revenue", {
        fromDate: yesterdayStr,
        toDate: yesterdayStr,
        option: "DAY",
      });

      Promise.all([todayAPI, yesterdayAPI]).then((results) => {
        let todayData = results[0].data.data || [];
        let yesterdayData = results[1].data.data || [];

        // Giá trị hôm nay
        let todayRev = todayData.length ? todayData[0].revenue : 0;
        let todayProf = todayData.length ? todayData[0].grossProfit : 0;

        // Giá trị hôm qua
        let yRev = yesterdayData.length ? yesterdayData[0].revenue : 0;
        let yProf = yesterdayData.length ? yesterdayData[0].grossProfit : 0;

        // Set KPI
        $scope.totalRevenue = todayRev;
        $scope.totalProfit = todayProf;
        $scope.bestCategory = todayData[0]?.bestCategory || "—";
        $scope.topProduct = todayData[0]?.topProduct || "—";

        // ============================
        // ⭐ TÍNH % THAY ĐỔI
        // ============================
        function percentChange(today, yesterday) {
          if (yesterday === 0) {
            return today > 0 ? 100 : 0; // tránh chia 0
          }
          return (((today - yesterday) / yesterday) * 100).toFixed(1);
        }

        $scope.revenueChange = percentChange(todayRev, yRev);
        $scope.profitChange = percentChange(todayProf, yProf);

        $scope.$applyAsync();
      });
    };

    function getYesterday() {
      let d = new Date();
      d.setDate(d.getDate() - 1);

      let yyyy = d.getFullYear();
      let mm = (d.getMonth() + 1).toString().padStart(2, "0");
      let dd = d.getDate().toString().padStart(2, "0");

      return `${yyyy}-${mm}-${dd}`;
    }

    // ==========================================================
    // 2. CHART DOANH THU & LỢI NHUẬN 7 NGÀY
    // ==========================================================
    let weeklyChart = null; // để destroy chart cũ

    $scope.loadWeeklyChart = function () {
      let today = new Date();
      let past7 = new Date();
      past7.setDate(today.getDate() - 6);

      function fmtLocal(d) {
        let yyyy = d.getFullYear();
        let mm = (d.getMonth() + 1).toString().padStart(2, "0");
        let dd = d.getDate().toString().padStart(2, "0");
        return `${yyyy}-${mm}-${dd}`;
      }

      function getWeekday(dateStr) {
        const d = new Date(dateStr);
        const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        return weekdays[d.getDay()];
      }

      $http
        .post(current_url + "/api-core/report/revenue", {
          FromDate: fmtLocal(past7),
          ToDate: fmtLocal(today),
          Option: "DAY",
        })
        .then((res) => {
          let rows = res.data.data || [];

          // 👉 đổi date thành weekday
          let labels = rows.map((x) => getWeekday(x.date));
          let revenue = rows.map((x) => x.revenue);
          let profit = rows.map((x) => x.grossProfit);

          renderWeeklyChart(labels, revenue, profit);
        });
    };

    function renderWeeklyChart(labels, revenue, profit) {
      const ctx = document.getElementById("salesProfitChart").getContext("2d");

      if (weeklyChart) weeklyChart.destroy();

      // Tạo màu gradient đẹp
      let gradient1 = ctx.createLinearGradient(0, 0, 0, 200);
      gradient1.addColorStop(0, "rgba(56, 189, 248, 0.9)");
      gradient1.addColorStop(1, "rgba(56, 189, 248, 0.2)");

      let gradient2 = ctx.createLinearGradient(0, 0, 0, 200);
      gradient2.addColorStop(0, "rgba(14, 165, 233, 0.9)");
      gradient2.addColorStop(1, "rgba(14, 165, 233, 0.2)");

      weeklyChart = new Chart(ctx, {
        type: "bar",
        data: {
          labels: labels,
          datasets: [
            {
              label: "Revenue",
              data: revenue,
              backgroundColor: gradient1,
              borderRadius: 6,
              borderWidth: 0,
            },
            {
              label: "Profit",
              data: profit,
              backgroundColor: gradient2,
              borderRadius: 6,
              borderWidth: 0,
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,

          plugins: {
            legend: {
              labels: { font: { size: 14, family: "Inter" } },
            },
            tooltip: {
              callbacks: {
                label: function (item) {
                  return item.raw.toLocaleString() + "₫";
                },
              },
            },
          },

          scales: {
            x: {
              ticks: { font: { size: 12, family: "Inter" } },
              grid: { display: false },
            },
            y: {
              beginAtZero: true,
              ticks: {
                font: { size: 12, family: "Inter" },
                callback: (val) => val.toLocaleString() + "₫",
              },
              grid: { color: "#e5e7eb" },
            },
          },
        },
      });
    }

    // ==========================================================
    // 3. CHART TOP PRODUCTS 7 NGÀY
    // ==========================================================
    $scope.loadTopProductsChart = function () {
      let today = new Date();
      let past7 = new Date();
      past7.setDate(today.getDate() - 6);

      function fmtLocal(d) {
        let yyyy = d.getFullYear();
        let mm = (d.getMonth() + 1).toString().padStart(2, "0");
        let dd = d.getDate().toString().padStart(2, "0");
        return `${yyyy}-${mm}-${dd}`;
      }

      $http
        .post(current_url + "/api-core/report/top-products", {
          fromDate: fmtLocal(past7),
          toDate: fmtLocal(today),
          option: "DAY", // nếu backend yêu cầu
        })
        .then((res) => {
          let rows = res.data.data || [];

          let labels = rows.map((x) => x.productName);
          let values = rows.map((x) => x.totalQty);

          renderTopProductsChart(labels, values);
        });
    };

    let pieChart = null;

    function renderTopProductsChart(labels, values) {
      const ctx = document.getElementById("topProductChart").getContext("2d");

      if (pieChart) pieChart.destroy();

      pieChart = new Chart(ctx, {
        type: "pie",
        data: {
          labels: labels,
          datasets: [
            {
              data: values,
              backgroundColor: [
                "#38bdf8",
                "#0ea5e9",
                "#0369a1",
                "#0284c7",
                "#94a3b8",
              ],
              borderColor: "#fff",
              borderWidth: 3,
              hoverOffset: 10,
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,

          plugins: {
            legend: {
              position: "top",
              labels: { font: { size: 14, family: "Inter" } },
            },

            tooltip: {
              callbacks: {
                label: function (item) {
                  let pct = (
                    (item.raw / values.reduce((a, b) => a + b, 0)) *
                    100
                  ).toFixed(1);
                  return `${item.label}: ${item.raw} (${pct}%)`;
                },
              },
            },
          },
        },
      });
    }

    // ==========================================================
    // 4. RECENT TRANSACTIONS (BẢNG + PHÂN TRANG + MODAL)
    // ==========================================================

    // PAGER
    $scope.pager = {
      page: 1,
      size: 10,
      total: 0,
      pages: 1,
    };

    // danh sách sale cho bảng
    $scope.sales = [];

    // STATE MODAL
    $scope.showDetailModal = false;
    $scope.showInvoiceModal = false;
    $scope.selectedSale = null;
    $scope.saleDetail = {};
    $scope.saleItems = [];
    $scope.saleTotals = {};

    // ---- LOAD LIST RECENT SALES ----
    $scope.loadSales = function () {
      var payload = {
        page: $scope.pager.page,
        pageSize: $scope.pager.size,
        // không filter gì thêm → backend trả về mới nhất
      };

      $http.post(current_url + "/api-core/sales/list", payload).then(
        function (res) {
          var d = res.data || {};

          var rawItems = d.data || d.Data || [];
          var total = d.totalItems || d.TotalItems || 0;
          var page = d.page || d.Page || $scope.pager.page;
          var size = d.pageSize || d.PageSize || $scope.pager.size;

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
          console.error("Load recent sales error:", err);
        }
      );
    };

    // ---- PAGER HANDLERS ----
    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.loadSales();
    };

    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.loadSales();
    };

    // ---- ACTION MENU 3 CHẤM ----
    $scope.toggleAction = function (sale, $event) {
      if ($event) $event.stopPropagation();

      $scope.sales.forEach(function (s) {
        if (s !== sale) s.showMenu = false;
      });

      sale.showMenu = !sale.showMenu;
    };

    // click ra ngoài đóng hết menu
    var docClickHandler = function () {
      $scope.$applyAsync(function () {
        $scope.sales.forEach(function (s) {
          s.showMenu = false;
        });
      });
    };

    $document.on("click", docClickHandler);

    $scope.$on("$destroy", function () {
      $document.off("click", docClickHandler);
    });

    // ---- LOAD CHI TIẾT SALE (dùng chung cho 2 modal) ----
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

    // ---- MODALS ----
    $scope.openDetailModal = function (sale, $event) {
      if ($event) $event.stopPropagation();

      $scope.selectedSale = sale;
      $scope.showDetailModal = true;
      $scope.showInvoiceModal = false;

      $scope.sales.forEach(function (s) {
        s.showMenu = false;
      });

      loadSaleDetail(sale.saleId);
    };

    $scope.openInvoiceModal = function (sale, $event) {
      if ($event) $event.stopPropagation();

      $scope.selectedSale = sale;
      $scope.showInvoiceModal = true;
      $scope.showDetailModal = false;

      $scope.sales.forEach(function (s) {
        s.showMenu = false;
      });

      loadSaleDetail(sale.saleId);
    };

    $scope.closeModals = function () {
      $scope.showDetailModal = false;
      $scope.showInvoiceModal = false;
    };

    $scope.printInvoicePdf = function () {
      window.print();
    };

    // ---- CHIP STATUS ----
    $scope.getStatusClass = function (sale) {
      var status = (sale.paymentStatus || "").toLowerCase();
      if (status === "paid") return "status-paid";
      if (status === "unpaid") return "status-unpaid";
      if (status === "partial") return "status-partial";
      return "";
    };

    // ==========================================================
    // 5. INIT
    // ==========================================================
    $scope.init = function () {
      $scope.loadTodayKPI();
      $scope.loadWeeklyChart();
      $scope.loadTopProductsChart();
      $scope.loadSales(); // recent transactions
    };

    $scope.init();
  }
);
