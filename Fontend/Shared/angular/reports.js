var app = angular.module("AppRetailPos");

app.controller("reportCtrl",function ($scope,$http,$timeout,AuthService,PermissionService,$window,TranslateService) {
    // ================== ĐA NGÔN NGỮ ==================
    function applyLanguage(lang) {
      TranslateService.loadLanguage(lang).then(() => {
        $scope.t = TranslateService.t;
      });
    }
    applyLanguage(localStorage.getItem("appLang") || "EN");

    // ================== STATE CHUNG ==================
    $scope.activeTab = "sales";

    $scope.currentUser = AuthService.getCurrentUser();
    if (!$scope.currentUser) {
      $window.location.href = "../AuthFE/login.html";
      return;
    }

    $scope.canShow = function (key) {
      return PermissionService.canShow(key);
    };

    // --- Report + KPI ---
    $scope.reports = [];
    $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };

    $scope.totalRevenue = 0;
    $scope.totalProfit = 0;
    $scope.bestCategory = "";
    $scope.topProductMonth = ""; // ⭐ Top theo THÁNG
    $scope.dailyTopByDate = {}; // ⭐ { '2025-11-01': 'Tên SP', ... }

    $scope.prevMonthRevenue = 0;
    $scope.prevMonthProfit = 0;

    $scope.revenueChange = 0;
    $scope.profitChange = 0;

    // --- Stock & Import/Export state ---
    $scope.stats = { total: 0, instock: 0, outstock: 0 };

    $scope.searchMonth = new Date("2025-11-01"); // filter Import–Export
    $scope.selectedMonth = new Date("2025-11-01"); // filter Revenue

    $scope.rawImportExport = [];
    $scope.totalImport = 0;
    $scope.totalExport = 0;
    $scope.topImportProduct = "—";
    $scope.leastImportProduct = "—";
    $scope.topExportProduct = "—";
    $scope.leastExportProduct = "—";
    $scope.mostImportedName = "—";
    $scope.mostExportedName = "—";

    // ================== 1) DOANH THU THEO THÁNG (CHART) ==================
    $scope.loadMonthlyRevenue = function () {
      console.log("Month picked:", $scope.selectedMonth);

      let year = $scope.selectedMonth.getFullYear();
      let m = $scope.selectedMonth.getMonth() + 1;
      let monthStr = m.toString().padStart(2, "0");

      let fromDate = `${year}-${monthStr}-01`;
      let lastDay = new Date(year, m, 0).getDate();
      let toDate = `${year}-${monthStr}-${lastDay.toString().padStart(2, "0")}`;

      // =============================
      // 🔥 1) LẤY KPI CHO CẢ THÁNG (OPTION = MONTH)
      // =============================
      $http.post(current_url + "/api-core/report/revenue", {
        fromDate: fromDate,
        toDate: toDate,
        option: "MONTH"
      })
        .then((res) => {
          let monthData = res.data.data || [];

          if (monthData.length > 0) {
            $scope.totalRevenue = monthData[0].revenue || 0;
            $scope.totalProfit = monthData[0].grossProfit || 0;
            $scope.bestCategory = monthData[0].bestCategory || "—";
            $scope.topProductMonth = monthData[0].topProduct || "—";
          } else {
            $scope.totalRevenue = 0;
            $scope.totalProfit = 0;
            $scope.bestCategory = "—";
            $scope.topProductMonth = "—";
          }
        });

      // =============================
      // 🔥 2) LẤY DỮ LIỆU BIỂU ĐỒ (OPTION = DAY)
      // =============================
      $http.post(current_url + "/api-core/report/revenue", {
        fromDate: fromDate,
        toDate: toDate,
        option: "DAY"
      })
        .then((res) => {
          const apiData = res.data.data || [];

          // Map top theo ngày
          $scope.dailyTopByDate = {};
          apiData.forEach((x) => {
            const d = x.date.substring(0, 10);
            $scope.dailyTopByDate[d] = x.dailyTopProduct || "";
          });

          // =============================
          // Build dữ liệu đầy đủ cho chart
          // =============================
          const daysInMonth = new Date(year, m, 0).getDate();
          let fullData = [];

          for (let day = 1; day <= daysInMonth; day++) {
            const d = `${year}-${monthStr}-${day.toString().padStart(2, "0")}`;
            const found = apiData.find((x) => x.date.substring(0, 10) === d);

            fullData.push(
              found || {
                date: d,
                revenue: 0,
                grossProfit: 0,
                dailyTopProduct: "",
              }
            );
          }

          const wrapper = document.querySelector(".chart-wrapper");
          wrapper.style.width = fullData.length * 39 + "px";

          $timeout(() => {
            const canvas = document.getElementById("revenueChart");

            if ($scope.revenueChart) $scope.revenueChart.destroy();

            canvas.width = wrapper.offsetWidth;
            canvas.height = 400;

            $scope.revenueChart = new Chart(canvas, {
              type: "line",
              data: {
                labels: fullData.map((x) => Number(x.date.slice(8, 10))),
                datasets: [
                  {
                    label: "Revenue",
                    data: fullData.map((x) => x.revenue),
                    borderColor: "#0ea5e9",
                    backgroundColor: "rgba(14,165,233,0.15)",
                    borderWidth: 2,
                    tension: 0.35,
                    pointRadius: 3,
                    fill: true,
                  },
                ],
              },
              options: {
                responsive: false,
                maintainAspectRatio: false,
              },
            });
          }, 30);
        });
    };

    function getSelectedYearMonth() {
      if (!$scope.selectedMonth) return null;

      var d = $scope.selectedMonth;

      // Nếu là string "2025-11" thì chuyển thành Date
      if (typeof d === "string") {
        if (d.length === 7) { // dạng "YYYY-MM"
          d = new Date(d + "-01");
        } else {
          d = new Date(d);
        }
      }

      if (isNaN(d.getTime())) return null;

      var year = d.getFullYear();
      var m = d.getMonth() + 1;
      var monthStr = ("0" + m).slice(-2);

      return { year: year, month: m, monthStr: monthStr };
    }

    // ================== 1) DOANH THU THEO THÁNG (CHART) ==================
    $scope.loadMonthlyRevenue = function () {
      var ym = getSelectedYearMonth();
      if (!ym) return;

      var year = ym.year;
      var m = ym.month;
      var monthStr = ym.monthStr;

      var fromDate = year + "-" + monthStr + "-01";
      var lastDay = new Date(year, m, 0).getDate();
      var toDate = year + "-" + monthStr + "-" + ("0" + lastDay).slice(-2);

      $http.post(current_url + "/api-core/report/revenue", {
        fromDate: fromDate,
        toDate: toDate,
        option: "DAY",
      }).then(function (res) {
        var apiData = (res.data && res.data.data) ? res.data.data : [];

        // Map top theo ngày
        $scope.dailyTopByDate = {};
        apiData.forEach(function (x) {
          var d = x.date.substring(0, 10);
          $scope.dailyTopByDate[d] = x.dailyTopProduct || "";
        });

        // Build full data cho đủ ngày trong tháng
        var daysInMonth = new Date(year, m, 0).getDate();
        var fullData = [];

        for (var day = 1; day <= daysInMonth; day++) {
          var dStr = year + "-" + monthStr + "-" + ("0" + day).slice(-2);
          var found = apiData.find(function (x) {
            return x.date.substring(0, 10) === dStr;
          });

          fullData.push(
            found || {
              date: dStr,
              revenue: 0,
              grossProfit: 0,
              dailyTopProduct: "",
            }
          );
        }

        var wrapper = document.querySelector(".chart-wrapper");
        wrapper.style.width = fullData.length * 39 + "px";

        $timeout(function () {
          var canvas = document.getElementById("revenueChart");
          if ($scope.revenueChart) $scope.revenueChart.destroy();

          canvas.width = wrapper.offsetWidth;
          canvas.height = 400;

          $scope.revenueChart = new Chart(canvas, {
            type: "line",
            data: {
              labels: fullData.map(function (x) { return Number(x.date.slice(8, 10)); }),
              datasets: [
                {
                  label: $scope.t('TOTAL_REVENUE'),
                  data: fullData.map(function (x) { return x.revenue; }),
                  borderColor: "#0ea5e9",
                  backgroundColor: "rgba(14,165,233,0.15)",
                  borderWidth: 2,
                  tension: 0.35,
                  pointRadius: 3,
                  fill: true,
                },
              ],
            },
            options: {
              responsive: true,
              maintainAspectRatio: false,
              scales: {
                y: { beginAtZero: true }
              }
            }
          });
        }, 30);
      });
    };

    // ================== 2) KPI THÁNG HIỆN TẠI vs THÁNG TRƯỚC ==================
    $scope.loadKPI = function () {
      var ym = getSelectedYearMonth();
      if (!ym) return;

      var year = ym.year;
      var m = ym.month;
      var monthStr = ym.monthStr;

      var fromDate = year + "-" + monthStr + "-01";
      var lastDay = new Date(year, m, 0).getDate();
      var toDate = year + "-" + monthStr + "-" + ("0" + lastDay).slice(-2);

      // --- KPI THÁNG HIỆN TẠI ---
      $http.post(current_url + "/api-core/report/revenue", {
        fromDate: fromDate,
        toDate: toDate,
        option: "MONTH",
      }).then(function (res) {
        var data = (res.data && res.data.data) ? res.data.data : [];
        var row = data.length > 0 ? data[0] : null;

        if (row) {
          $scope.totalRevenue = row.revenue || 0;
          $scope.totalProfit = row.grossProfit || 0;
          $scope.bestCategory = row.bestCategory || "—";
          $scope.topProductMonth = row.topProduct || "—";
        } else {
          $scope.totalRevenue = 0;
          $scope.totalProfit = 0;
          $scope.bestCategory = "—";
          $scope.topProductMonth = "—";
        }

        // Sau khi có KPI tháng hiện tại → load tháng trước
        $scope.loadPrevMonthKPI();
      });
    };

    $scope.loadPrevMonthKPI = function () {
      var ym = getSelectedYearMonth();
      if (!ym) return;

      var year = ym.year;
      var m = ym.month;

      var prevMonth = m - 1;
      var prevYear = year;
      if (prevMonth === 0) {
        prevMonth = 12;
        prevYear--;
      }
      var prevMonthStr = ("0" + prevMonth).slice(-2);

      var prevFrom = prevYear + "-" + prevMonthStr + "-01";
      var prevLast = new Date(prevYear, prevMonth, 0).getDate();
      var prevTo = prevYear + "-" + prevMonthStr + "-" + ("0" + prevLast).slice(-2);

      $http.post(current_url + "/api-core/report/revenue", {
        fromDate: prevFrom,
        toDate: prevTo,
        option: "MONTH",
      }).then(function (res) {
        var data = (res.data && res.data.data) ? res.data.data : [];
        var prev = data.length > 0 ? data[0] : {};

        var prevRevenue = prev.revenue || 0;
        var prevProfit = prev.grossProfit || 0;

        $scope.revenueChange =
          prevRevenue === 0
            ? "—"
            : ((($scope.totalRevenue - prevRevenue) / prevRevenue) * 100).toFixed(2);

        $scope.profitChange =
          prevProfit === 0
            ? "—"
            : ((($scope.totalProfit - prevProfit) / prevProfit) * 100).toFixed(2);
      });
    };






    // ================== 4) IMPORT – EXPORT (FILTER BY MONTH) ==================
    $scope.filterByMonth = function () {
      if (!$scope.searchMonth) return;

      let year = $scope.searchMonth.getFullYear();
      let m = $scope.searchMonth.getMonth() + 1;

      let fromDate = `${year}-${m.toString().padStart(2, "0")}-01`;
      let lastDay = new Date(year, m, 0).getDate();
      let toDate = `${year}-${m.toString().padStart(2, "0")}-${lastDay}`;

      // 🔥 1) KPI theo tháng (MONTH)
      $http.post(current_url + "/api-core/report/import-export", {
        fromDate: fromDate,
        toDate: toDate,
        option: "MONTH"
      }).then(res => {

        let kpi = res.data.data?.[0] || {};

        $scope.totalImport = kpi.totalImportQty || 0;
        $scope.totalExport = kpi.totalExportQty || 0;

        $scope.topImportProduct = kpi.topImportedProduct || "—";
        $scope.leastImportProduct = kpi.leastImportedProduct || "—";

        $scope.topExportProduct = kpi.topExportedProduct || "—";
        $scope.leastExportProduct = kpi.leastExportedProduct || "—";

        $scope.mostImportedName = kpi.topImportedProduct || "—";
        $scope.mostExportedName = kpi.topExportedProduct || "—";
      });

      // 🔥 2) Biểu đồ theo ngày (DAY)
      $http.post(current_url + "/api-core/report/import-export", {
        fromDate: fromDate,
        toDate: toDate,
        option: "DAY"
      }).then(res => {
        let daily = res.data.data || [];
        updateImportExportChart(daily);
      });
    };


    function updateImportExportChart(data) {
      const ctx = document.getElementById("importExportChart");

      if ($scope.importExportChart) {
        $scope.importExportChart.destroy();
      }

      let year = $scope.searchMonth.getFullYear();
      let m = $scope.searchMonth.getMonth() + 1;
      let days = new Date(year, m, 0).getDate();

      let fullData = [];

      for (let d = 1; d <= days; d++) {
        let dateStr = `${year}-${("0" + m).slice(-2)}-${("0" + d).slice(-2)}`;
        let f = data.find(x => x.date.startsWith(dateStr));

        fullData.push(f || { importQty: 0, exportQty: 0, date: dateStr });
      }

      let labels = fullData.map(x => x.date.substring(8, 10));
      let importData = fullData.map(x => x.importQty);
      let exportData = fullData.map(x => x.exportQty);

      $scope.importExportChart = new Chart(ctx, {
        type: "line",
        data: {
          labels: labels,
          datasets: [
            {
              label: $scope.t('TOTAL_IMPORT'),
              data: importData,
              borderColor: "#22c55e",
              borderWidth: 2,
              fill: false
            },
            {
              label: $scope.t('TOTAL_EXPORT'),
              data: exportData,
              borderColor: "#f97316",
              borderWidth: 2,
              fill: false
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            y: { beginAtZero: true }
          }
        }
      });
    }


    // ================== 5) STOCK REPORT ==================
    $scope.loadStock = function () {
      $http.get(current_url + "/api-core/report/stock").then((res) => {

        let data = res.data.data || [];

        // KPI nằm ở dòng đầu tiên do SP trả về (ROW 0)
        let kpi = data[0] || {};

        $scope.stockStats = {
          totalProducts: kpi.totalQty || 0,
          totalQty: 0,
          lowStock: kpi.lowStockCount || 0,      // ⬅ LẤY TỪ PROCE
          totalStockValue: kpi.totalStockValue || 0,
          expiringSoon: kpi.minDaysToExpire || 0
        };

        let grouped = {};
        let today = new Date(); data.forEach((x) => {
          grouped[x.productID] = true;
          $scope.stockStats.totalQty += x.qtyRemain;
        })
        // Dữ liệu chi tiết sản phẩm (nếu SP tách KPI và list)
        let details = data.details || data; // tùy cách backend trả về

        // let today = new Date();

        // TOP 5 tồn lâu nhất
        let sortedAge = [...details].sort((a, b) => b.ageInDays - a.ageInDays);
        $scope.stockList = sortedAge.slice(0, 5);

        // TOP 4 sắp hết hạn (dùng details)
        let expList = details
          .filter((x) => x.expiryDate)
          .map((x) => {
            let exp = new Date(x.expiryDate);
            let days = Math.ceil((exp - today) / (1000 * 60 * 60 * 24));
            return {
              productName: x.productName,
              sku: x.sku,
              batchNo: x.batchNo,
              expiryDate: x.expiryDate,
              daysLeft: days,
            };
          })
          .filter((x) => x.daysLeft >= 0)
          .sort((a, b) => a.daysLeft - b.daysLeft)
          .slice(0, 5);

        $scope.expiringList = expList;


        // Danh sách sản phẩm dưới MinStock (chỉ hiển thị 1 lần mỗi ProductID)
        let belowList = {};

        details.forEach(x => {
          if (x.balance < x.minStock) {
            if (!belowList[x.productID]) {
              belowList[x.productID] = {
                productName: x.productName,
                sku: x.sku,
                balance: x.balance,
                minStock: x.minStock
              };
            }
          }
        })

        // Convert object → array
        $scope.belowMinStockList = Object.values(belowList);

      });




    };


    // ================== 6) WATCHERS & AUTO LOAD ==================
    $scope.$watch("activeTab", function (v) {
      if (v === "stock") {
        $scope.loadStock();
      }
    });

    $scope.$watch("activeTab", function (v) {
      if (v === "sales") {
        $scope.loadMonthlyRevenue();
      }
    });

    $scope.$watch("activeTab", function (v) {
      if (v === "import") {
        $scope.filterByMonth();
      }
    });

    $scope.$watch("searchMonth", function () {
      $scope.filterByMonth();
    });

    $scope.$watch("selectedMonth", function () {
      $scope.loadKPI();      // KPI + % so với tháng trước
      $scope.loadPrevMonthKPI();   // Chart (option: "DAY")
    });


    // LẦN ĐẦU VÀO MÀN HÌNH → GỌI HÀM
    $scope.loadKPI();
    $scope.loadMonthlyRevenue();
    $scope.filterByMonth();
  }
);
