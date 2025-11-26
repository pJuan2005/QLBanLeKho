var app = angular.module("AppRetailPos");

app.controller(
  "reportCtrl",
  function (
    $scope,
    $http,
    $timeout,
    AuthService,
    PermissionService,
    $window,
    TranslateService
  ) {
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

      console.log("Sending request:", {
        fromDate: fromDate,
        toDate: toDate,
        option: "DAY",
      });

      $http
        .post(current_url + "/api-core/report/revenue", {
          fromDate: fromDate,
          toDate: toDate,
          option: "DAY",
        })
        .then((res) => {
          const apiData = res.data.data || [];

          // =============================
          //  LẤY KPI TỪ API
          // =============================
          if (apiData.length > 0) {
            // Tổng Revenue + Profit
            $scope.totalRevenue = apiData.reduce(
              (s, x) => s + (x.revenue || 0),
              0
            );
            $scope.totalProfit = apiData.reduce(
              (s, x) => s + (x.grossProfit || 0),
              0
            );

            // Best Category / Top Product (theo THÁNG)
            $scope.bestCategory = apiData[0].bestCategory || "—";
            // nếu backend chưa thêm MonthlyTopProduct thì fallback về TopProduct
            $scope.topProductMonth =
              apiData[0].monthlyTopProduct || apiData[0].topProduct || "—";

            // Map top theo NGÀY
            $scope.dailyTopByDate = {};
            apiData.forEach((x) => {
              const d = x.date.substring(0, 10);
              $scope.dailyTopByDate[d] = x.dailyTopProduct || "";
            });
          } else {
            $scope.totalRevenue = 0;
            $scope.totalProfit = 0;
            $scope.bestCategory = "—";
            $scope.topProductMonth = "—";
            $scope.dailyTopByDate = {};
          }

          // =============================
          //  BUILD DỮ LIỆU CHO CHART
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

          console.log("Wrapper width:", wrapper.style.width);

          // Delay để DOM cập nhật width
          $timeout(() => {
            const canvas = document.getElementById("revenueChart");

            // RESET width/height cho canvas
            canvas.width = wrapper.offsetWidth;
            canvas.height = 400;

            console.log("Canvas width:", canvas.width);

            // Nếu có chart cũ → destroy
            if ($scope.revenueChart) $scope.revenueChart.destroy();

            // Tạo chart mới
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
                    pointHoverRadius: 5,
                    fill: true,
                  },
                ],
              },
              options: {
                responsive: false,
                maintainAspectRatio: false,
                plugins: {
                  legend: {
                    labels: {
                      usePointStyle: true,
                      pointStyle: "circle",
                      font: { size: 12 },
                    },
                  },
                  tooltip: {
                    callbacks: {
                      label: function (ctx) {
                        const point = fullData[ctx.dataIndex];
                        let base =
                          "Doanh thu: " +
                          ctx.raw.toLocaleString("vi-VN") +
                          " ₫";
                        if (point.dailyTopProduct) {
                          base += " | Top SP: " + point.dailyTopProduct;
                        }
                        return base;
                      },
                    },
                    backgroundColor: "rgba(15,23,42,0.9)",
                    titleColor: "#fff",
                    bodyColor: "#fff",
                    padding: 10,
                    borderColor: "#0ea5e9",
                    borderWidth: 1,
                  },
                },
                scales: {
                  x: {
                    grid: { color: "rgba(0,0,0,0.05)" },
                    ticks: {
                      color: "#334155",
                      font: { size: 11 },
                      autoSkip: false,
                    },
                  },
                  y: {
                    beginAtZero: true,
                    grid: { color: "rgba(0,0,0,0.05)" },
                    ticks: {
                      color: "#64748b",
                      font: { size: 12 },
                      callback: (value) => value.toLocaleString("vi-VN"),
                    },
                  },
                },
              },
            });

            // ép resize lần cuối
            setTimeout(() => {
              $scope.revenueChart.resize();
            }, 20);
          }, 30);
        });
    };

    // ================== 2) KPI THÁNG HIỆN TẠI vs THÁNG TRƯỚC ==================
    $scope.loadKPI = function () {
      let year = $scope.selectedMonth.getFullYear();
      let m = $scope.selectedMonth.getMonth() + 1;

      let fromDate = `${year}-${m.toString().padStart(2, "0")}-01`;
      let lastDay = new Date(year, m, 0).getDate();
      let toDate = `${year}-${m.toString().padStart(2, "0")}-${lastDay}`;

      // --- API THÁNG HIỆN TẠI ---
      $http
        .post(current_url + "/api-core/report/revenue", {
          fromDate: fromDate,
          toDate: toDate,
          option: "DAY",
        })
        .then((res) => {
          let data = res.data.data || [];

          $scope.totalRevenue = data.reduce(
            (sum, x) => sum + (x.revenue || 0),
            0
          );
          $scope.totalProfit = data.reduce(
            (sum, x) => sum + (x.grossProfit || 0),
            0
          );

          // ======= TÍNH THÁNG TRƯỚC =======
          let prevMonth = m - 1;
          let prevYear = year;

          if (prevMonth === 0) {
            prevMonth = 12;
            prevYear -= 1;
          }

          let prevFrom = `${prevYear}-${prevMonth
            .toString()
            .padStart(2, "0")}-01`;
          let prevLastDay = new Date(prevYear, prevMonth, 0).getDate();
          let prevTo = `${prevYear}-${prevMonth
            .toString()
            .padStart(2, "0")}-${prevLastDay}`;

          // --- API THÁNG TRƯỚC ---
          $http
            .post(current_url + "/api-core/report/revenue", {
              fromDate: prevFrom,
              toDate: prevTo,
              option: "DAY",
            })
            .then((res2) => {
              let prevData = res2.data.data || [];

              let prevRevenue = prevData.reduce(
                (s, x) => s + (x.revenue || 0),
                0
              );
              let prevProfit = prevData.reduce(
                (s, x) => s + (x.grossProfit || 0),
                0
              );

              $scope.prevMonthRevenue = prevRevenue;
              $scope.prevMonthProfit = prevProfit;

              // ======= TÍNH % =======
              $scope.revenueChange =
                prevRevenue === 0
                  ? "—"
                  : (
                      (($scope.totalRevenue - prevRevenue) / prevRevenue) *
                      100
                    ).toFixed(2);

              $scope.profitChange =
                prevProfit === 0
                  ? "—"
                  : (
                      (($scope.totalProfit - prevProfit) / prevProfit) *
                      100
                    ).toFixed(2);
            });
        });
    };

    // ================== 3) LOAD REPORT (SO SÁNH 2 THÁNG + CHART) ==================
    $scope.loadReport = function () {
      let year = $scope.selectedMonth.getFullYear();
      let m = $scope.selectedMonth.getMonth() + 1;

      let fromDate = `${year}-${m.toString().padStart(2, "0")}-01`;
      let lastDay = new Date(year, m, 0).getDate();
      let toDate = `${year}-${m.toString().padStart(2, "0")}-${lastDay
        .toString()
        .padStart(2, "0")}`;

      // Tháng trước
      let prevMonth = m - 1;
      let prevYear = year;

      if (prevMonth === 0) {
        prevMonth = 12;
        prevYear -= 1;
      }

      let prevFrom = `${prevYear}-${prevMonth.toString().padStart(2, "0")}-01`;
      let prevLastDay = new Date(prevYear, prevMonth, 0).getDate();
      let prevTo = `${prevYear}-${prevMonth
        .toString()
        .padStart(2, "0")}-${prevLastDay}`;

      // GỌI API HAI THÁNG CÙNG LÚC
      Promise.all([
        $http.post(current_url + "/api-core/report/revenue", {
          fromDate: fromDate,
          toDate: toDate,
          option: "DAY",
        }),
        $http.post(current_url + "/api-core/report/revenue", {
          fromDate: prevFrom,
          toDate: prevTo,
          option: "DAY",
        }),
      ]).then(([cur, prev]) => {
        let curData = cur.data.data || [];
        let prevData = prev.data.data || [];

        // 1. KPI THÁNG HIỆN TẠI
        $scope.totalRevenue = curData.reduce((s, x) => s + (x.revenue || 0), 0);
        $scope.totalProfit = curData.reduce(
          (s, x) => s + (x.grossProfit || 0),
          0
        );

        // Best category & top product tháng
        if (curData.length > 0) {
          $scope.bestCategory = curData[0].bestCategory || "—";
          $scope.topProductMonth =
            curData[0].monthlyTopProduct || curData[0].topProduct || "—";

          $scope.dailyTopByDate = {};
          curData.forEach((x) => {
            const d = x.date.substring(0, 10);
            $scope.dailyTopByDate[d] = x.dailyTopProduct || "";
          });
        } else {
          $scope.bestCategory = "—";
          $scope.topProductMonth = "—";
          $scope.dailyTopByDate = {};
        }

        // 2. KPI THÁNG TRƯỚC
        let prevRevenue = prevData.reduce((s, x) => s + (x.revenue || 0), 0);
        let prevProfit = prevData.reduce((s, x) => s + (x.grossProfit || 0), 0);

        // 3. % THAY ĐỔI
        $scope.revenueChange =
          prevRevenue === 0
            ? 100
            : (
                (($scope.totalRevenue - prevRevenue) / prevRevenue) *
                100
              ).toFixed(2);

        $scope.profitChange =
          prevProfit === 0
            ? 100
            : ((($scope.totalProfit - prevProfit) / prevProfit) * 100).toFixed(
                2
              );

        // 4. BUILD BIỂU ĐỒ
        let daysInMonth = new Date(year, m, 0).getDate();
        let fullData = [];

        for (let day = 1; day <= daysInMonth; day++) {
          const d = `${year}-${m.toString().padStart(2, "0")}-${day
            .toString()
            .padStart(2, "0")}`;
          const found = curData.find((x) => x.date.substring(0, 10) === d);

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
        }, 40);
      });
    };

    // ================== 4) IMPORT – EXPORT (FILTER BY MONTH) ==================
    $scope.filterByMonth = function () {
      if (!$scope.searchMonth) return;

      let year = $scope.searchMonth.getFullYear();
      let m = $scope.searchMonth.getMonth() + 1;

      let fromDate = `${year}-${m.toString().padStart(2, "0")}-01`;
      let lastDay = new Date(year, m, 0).getDate();
      let toDate = `${year}-${m.toString().padStart(2, "0")}-${lastDay
        .toString()
        .padStart(2, "0")}`;

      $http
        .post(current_url + "/api-core/report/import-export", {
          fromDate: fromDate,
          toDate: toDate,
          option: "DAY",
        })
        .then((res) => {
          let data = res.data.data || [];
          $scope.rawImportExport = data;

          updateImportExportKPI(data);
          updateImportExportChart(data);
        });
    };

    function updateImportExportKPI(data) {
      if (data.length === 0) {
        $scope.totalImport = 0;
        $scope.totalExport = 0;

        $scope.topImportProduct =
          $scope.leastImportProduct =
          $scope.topExportProduct =
          $scope.leastExportProduct =
          $scope.mostImportedName =
          $scope.mostExportedName =
            "—";

        return;
      }

      // KPI của API nằm ở phần tử đầu
      let kpi = data[0];

      $scope.totalImport = kpi.totalImportQty || 0;
      $scope.totalExport = kpi.totalExportQty || 0;

      $scope.topImportProduct = kpi.topImportedProduct || "—";
      $scope.leastImportProduct = kpi.leastImportedProduct || "—";

      $scope.topExportProduct = kpi.topExportedProduct || "—";
      $scope.leastExportProduct = kpi.leastExportedProduct || "—";

      $scope.mostImportedName = kpi.topImportedProduct || "—";
      $scope.mostExportedName = kpi.topExportedProduct || "—";
    }

    function updateImportExportChart(data) {
      const ctx = document.getElementById("importExportChart");

      if ($scope.importExportChart) {
        $scope.importExportChart.destroy();
      }

      function fillFullMonth(data, year, m) {
        let days = new Date(year, m, 0).getDate();
        let full = [];

        for (let d = 1; d <= days; d++) {
          let dayStr = `${year}-${m.toString().padStart(2, "0")}-${d
            .toString()
            .padStart(2, "0")}`;

          let found = data.find((x) => x.date.startsWith(dayStr));
          full.push(found || { importQty: 0, exportQty: 0, date: dayStr });
        }
        return full;
      }

      let year = $scope.searchMonth.getFullYear();
      let m = $scope.searchMonth.getMonth() + 1;

      let fullData = fillFullMonth(data, year, m);

      let labels = fullData.map((x) => x.date.substring(8, 10));
      let importData = fullData.map((x) => x.importQty);
      let exportData = fullData.map((x) => x.exportQty);

      $scope.importExportChart = new Chart(ctx, {
        type: "line",
        data: {
          labels: labels,
          datasets: [
            {
              label: "Import",
              data: importData,
              borderColor: "#22c55e",
              borderWidth: 2,
              fill: false,
              tension: 0.3,
            },
            {
              label: "Export",
              data: exportData,
              borderColor: "#f97316",
              borderWidth: 2,
              fill: false,
              tension: 0.3,
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            y: { beginAtZero: true },
          },
        },
      });
    }

    // ================== 5) STOCK REPORT ==================
    $scope.loadStock = function () {
      $http.get(current_url + "/api-core/report/stock").then((res) => {
        let data = res.data.data || [];

        $scope.stockStats = {
          totalProducts: 0,
          totalQty: 0,
          lowStock: 0,
          totalStockValue: 0,
          expiringSoon: 0,
        };

        let grouped = {};
        let today = new Date();

        data.forEach((x) => {
          grouped[x.productID] = true;

          $scope.stockStats.totalQty += x.qtyRemain;
          $scope.stockStats.totalStockValue += x.qtyRemain * (x.unitPrice || 0);

          if (x.qtyRemain < x.minStock) {
            $scope.stockStats.lowStock++;
          }

          if (x.expiryDate) {
            let exp = new Date(x.expiryDate);
            let days = Math.ceil((exp - today) / (1000 * 60 * 60 * 24));

            if (days <= 30 && days >= 0) {
              $scope.stockStats.expiringSoon++;
            }
          }
        });

        $scope.stockStats.totalProducts = Object.keys(grouped).length;

        // TOP 5 tồn lâu nhất
        let sortedAge = [...data].sort((a, b) => b.ageInDays - a.ageInDays);
        $scope.stockList = sortedAge.slice(0, 5);

        // TOP 4 sắp hết hạn
        let expList = data
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
          .slice(0, 4);

        $scope.expiringList = expList;
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
      $scope.loadReport();
      $scope.loadMonthlyRevenue();
      $scope.loadKPI();
    });

    // LẦN ĐẦU VÀO MÀN HÌNH → GỌI HÀM
    $scope.filterByMonth();
    $scope.loadReport();
    $scope.loadMonthlyRevenue();
    $scope.loadKPI();
  }
);
