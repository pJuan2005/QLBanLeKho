var app = angular.module("AppRetailPos");
app.controller("dashboardCtrl", function ($scope, $http, AuthService, PermissionService, $window) {
  // function applyLanguage(lang) {
  //     TranslateService.loadLanguage(lang).then(() => {
  //         $scope.t = TranslateService.t;
  //     });
  // }
  // applyLanguage(localStorage.getItem("appLang") || "EN");



  $scope.currentUser = AuthService.getCurrentUser(); //lấy user hiện tại
  // ------Kiểm tra đăng nhập, logout và chia màn hình theo quyền---------
  if (!$scope.currentUser) {
    $window.location.href = "../AuthFE/login.html";
    return;
  }
  $scope.canShow = function (key) {
    return PermissionService.canShow(key);
  };



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
      option: "DAY"
    });

    // --- Gọi API hôm qua ---
    let yesterdayAPI = $http.post(current_url + "/api-core/report/revenue", {
      fromDate: yesterdayStr,
      toDate: yesterdayStr,
      option: "DAY"
    });

    Promise.all([todayAPI, yesterdayAPI]).then(results => {

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









  let weeklyChart = null;   // để destroy chart cũ



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



    $http.post(current_url + "/api-core/report/revenue", {
      FromDate: fmtLocal(past7),
      ToDate: fmtLocal(today),
      Option: "DAY"
    }).then(res => {
      let rows = res.data.data || [];

      // 👉 đổi date thành weekday
      let labels = rows.map(x => getWeekday(x.date));
      let revenue = rows.map(x => x.revenue);
      let profit = rows.map(x => x.grossProfit);

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
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,

        plugins: {
          legend: {
            labels: { font: { size: 14, family: "Inter" } }
          },
          tooltip: {
            callbacks: {
              label: function (item) {
                return item.raw.toLocaleString() + "₫";
              }
            }
          }
        },

        scales: {
          x: {
            ticks: { font: { size: 12, family: "Inter" } },
            grid: { display: false }
          },
          y: {
            beginAtZero: true,
            ticks: {
              font: { size: 12, family: "Inter" },
              callback: val => val.toLocaleString() + "₫"
            },
            grid: { color: "#e5e7eb" }
          }
        }
      }
    });
  }









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


    $http.post(current_url + "/api-core/report/top-products", {
      fromDate: fmtLocal(past7),
      toDate: fmtLocal(today),
      option: "DAY" // nếu backend yêu cầu

    }).then(res => {

      let rows = res.data.data || [];

      let labels = rows.map(x => x.productName);
      let values = rows.map(x => x.totalQty);

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
        datasets: [{
          data: values,
          backgroundColor: [
            "#38bdf8", "#0ea5e9", "#0369a1", "#0284c7", "#94a3b8"
          ],
          borderColor: "#fff",
          borderWidth: 3,
          hoverOffset: 10
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,

        plugins: {
          legend: {
            position: "top",
            labels: { font: { size: 14, family: "Inter" } }
          },

          tooltip: {
            callbacks: {
              label: function (item) {
                let pct = ((item.raw / values.reduce((a, b) => a + b, 0)) * 100).toFixed(1);
                return `${item.label}: ${item.raw} (${pct}%)`;
              }
            }
          }
        }
      }
    });
  }

  function getYesterday() {
    let d = new Date();
    d.setDate(d.getDate() - 1);

    let yyyy = d.getFullYear();
    let mm = (d.getMonth() + 1).toString().padStart(2, "0");
    let dd = d.getDate().toString().padStart(2, "0");

    return `${yyyy}-${mm}-${dd}`;
  }


  






  $scope.loadTopProductsChart();
  $scope.loadTodayKPI();
  $scope.loadWeeklyChart();

});


