
var app = angular.module("AppRetailPos");
app.controller("reportCtrl", function ($scope, $http, $timeout, AuthService, PermissionService, $window, TranslateService) {
    function applyLanguage(lang) {
        TranslateService.loadLanguage(lang).then(() => {
            $scope.t = TranslateService.t;
        });
    }
    applyLanguage(localStorage.getItem("appLang") || "EN");

    $scope.activeTab = 'sales';
    $scope.activeTab = 'import';

    $scope.currentUser = AuthService.getCurrentUser(); // lấy user 
    $scope.reports = [];
    $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };
    $scope.stats = { total: 0, instock: 0, outstock: 0 };
    $scope.totalRevenue = 0;
    $scope.totalProfit = 0;
    $scope.bestCategory = "";
    $scope.topProduct = "";


    $scope.prevMonthRevenue = 0;
    $scope.prevMonthProfit = 0;

    $scope.revenueChange = 0;
    $scope.profitChange = 0;





    $scope.savingAdd = false;

    $scope.editingProduct = null;
    $scope.savingEdit = false;

    $scope.showDelete = false;
    $scope.deleting = null;





    // ------Kiểm tra đăng nhập, logout và chia màn hình theo quyền---------
    if (!$scope.currentUser) {
        $window.location.href = "../AuthFE/login.html";
        return;
    }
    $scope.canShow = function (key) {
        return PermissionService.canShow(key);
    }





    $scope.selectedMonth = new Date("2025-11-01");


    $scope.loadMonthlyRevenue = function () {
        console.log("Month picked:", $scope.selectedMonth);

        let year = $scope.selectedMonth.getFullYear();
        let month = ($scope.selectedMonth.getMonth() + 1).toString().padStart(2, "0");

        let fromDate = `${year}-${month}-01`;
        let lastDay = new Date(year, month, 0);
        let day = lastDay.getDate().toString().padStart(2, "0");
        let mm = month.toString().padStart(2, "0"); // month đã đúng format
        let toDate = `${year}-${mm}-${day}`;


        // Tháng trước
        let prevMonth = month - 1;
        let prevYear = year;

        if (prevMonth === 0) {
            prevMonth = 12;
            prevYear -= 1;
        }
        console.log("Sending request:", {
            fromDate: fromDate,
            toDate: toDate,
            option: "DAY"
        });
        $http.post(current_url + "/api-core/report/revenue", {
            fromDate: fromDate,
            toDate: toDate,
            option: "DAY"
        }).then(res => {
            const apiData = res.data.data || [];

            // =============================
            //  PHẦN LẤY KPI TỪ API
            // =============================
            if (apiData.length > 0) {
                // Tổng Revenue + Profit
                $scope.totalRevenue = apiData.reduce((s, x) => s + (x.revenue || 0), 0);
                $scope.totalProfit = apiData.reduce((s, x) => s + (x.grossProfit || 0), 0);

                // Best Category / Top Product (API trả giống nhau mỗi dòng)
                $scope.bestCategory = apiData[0].bestCategory || "—";
                $scope.topProduct = apiData[0].topProduct || "—";
            } else {
                $scope.totalRevenue = 0;
                $scope.totalProfit = 0;
                $scope.bestCategory = "—";
                $scope.topProduct = "—";
            }


            // =============================
            //  TIẾP TỤC LOGIC VẼ BIỂU ĐỒ
            // =============================
            const daysInMonth = new Date(year, month, 0).getDate();
            let fullData = [];

            for (let day = 1; day <= daysInMonth; day++) {
                const d = `${year}-${month}-${day.toString().padStart(2, '0')}`;
                const found = apiData.find(x => x.date.substring(0, 10) === d);
                fullData.push(found || { date: d, revenue: 0, grossProfit: 0 });
            }

            // Width theo ngày
            const wrapper = document.querySelector(".chart-wrapper");
            wrapper.style.width = (fullData.length * 39) + "px";

            console.log("Wrapper width:", wrapper.style.width);

            // Delay để DOM cập nhật width
            $timeout(() => {

                const canvas = document.getElementById("revenueChart");

                // ⭐⭐ RESET WIDTH CHO CANVAS ⭐⭐
                canvas.width = wrapper.offsetWidth;
                canvas.height = 400; // ép luôn height cho chắc chắn

                console.log("Canvas width:", canvas.width);

                // Nếu có chart cũ → xóa
                if ($scope.revenueChart) $scope.revenueChart.destroy();

                // Tạo chart mới
                $scope.revenueChart = new Chart(canvas, {
                    type: "line",
                    data: {
                        labels: fullData.map(x => Number(x.date.slice(8, 10))),
                        datasets: [{
                            label: "Revenue",
                            data: fullData.map(x => x.revenue),
                            borderColor: "#0ea5e9",
                            backgroundColor: "rgba(14,165,233,0.15)",
                            borderWidth: 2,
                            tension: 0.35,
                            pointRadius: 3,
                            pointHoverRadius: 5,
                            fill: true
                        }]
                    },
                    options: {
                        responsive: false,          // ⭐ QUAN TRỌNG
                        maintainAspectRatio: false, // ⭐ QUAN TRỌNG
                        plugins: {
                            legend: {
                                labels: {
                                    usePointStyle: true,
                                    pointStyle: "circle",
                                    font: { size: 12 }
                                }
                            },
                            tooltip: {
                                callbacks: {
                                    label: (ctx) => "Doanh thu: " +
                                        ctx.raw.toLocaleString() + "₫"
                                },
                                backgroundColor: "rgba(15,23,42,0.9)",
                                titleColor: "#fff",
                                bodyColor: "#fff",
                                padding: 10,
                                borderColor: "#0ea5e9",
                                borderWidth: 1
                            }
                        },
                        scales: {
                            x: {
                                grid: { color: "rgba(0,0,0,0.05)" },
                                ticks: {
                                    color: "#334155",
                                    font: { size: 11 },
                                    autoSkip: false
                                }
                            },
                            y: {
                                beginAtZero: true,
                                grid: { color: "rgba(0,0,0,0.05)" },
                                ticks: {
                                    color: "#64748b",
                                    font: { size: 12 },
                                    callback: value => value.toLocaleString()
                                }
                            }
                        }
                    }
                });

                // ép resize lần cuối
                setTimeout(() => {
                    $scope.revenueChart.resize();
                }, 20);

            }, 30);
        });
    };





    $scope.loadKPI = function () {
        let year = $scope.selectedMonth.getFullYear();
        let month = $scope.selectedMonth.getMonth() + 1;

        // ======= TÍNH NGÀY ĐẦU & NGÀY CUỐI THÁNG HIỆN TẠI (KHÔNG DÙNG ISO) =======
        let fromDate = `${year}-${month.toString().padStart(2, '0')}-01`;
        let lastDay = new Date(year, month, 0).getDate();
        let toDate = `${year}-${month.toString().padStart(2, '0')}-${lastDay}`;

        // --- API THÁNG HIỆN TẠI ---
        $http.post(current_url + "/api-core/report/revenue", {
            fromDate: fromDate,
            toDate: toDate,
            option: "DAY"
        }).then(res => {

            let data = res.data.data || [];

            $scope.totalRevenue = data.reduce((sum, x) => sum + (x.revenue || 0), 0);
            $scope.totalProfit = data.reduce((sum, x) => sum + (x.grossProfit || 0), 0);


            // ======= TÍNH THÁNG TRƯỚC =======
            let prevMonth = month - 1;
            let prevYear = year;

            if (prevMonth === 0) {
                prevMonth = 12;
                prevYear -= 1;
            }

            let prevFrom = `${prevYear}-${prevMonth.toString().padStart(2, '0')}-01`;
            let prevLastDay = new Date(prevYear, prevMonth, 0).getDate();
            let prevTo = `${prevYear}-${prevMonth.toString().padStart(2, '0')}-${prevLastDay}`;

            // --- API THÁNG TRƯỚC ---
            $http.post(current_url + "/api-core/report/revenue", {
                fromDate: prevFrom,
                toDate: prevTo,
                option: "DAY"
            }).then(res2 => {

                let prevData = res2.data.data || [];

                let prevRevenue = prevData.reduce((s, x) => s + (x.revenue || 0), 0);
                let prevProfit = prevData.reduce((s, x) => s + (x.grossProfit || 0), 0);

                $scope.prevMonthRevenue = prevRevenue;
                $scope.prevMonthProfit = prevProfit;

                // ======= TÍNH % =======
                $scope.revenueChange = prevRevenue === 0
                    ? "—"
                    : ((($scope.totalRevenue - prevRevenue) / prevRevenue) * 100).toFixed(2);

                $scope.profitChange = prevProfit === 0
                    ? "—"
                    : ((($scope.totalProfit - prevProfit) / prevProfit) * 100).toFixed(2);

            });
        });
    };







    $scope.selectedMonth = new Date("2025-11-01");

    $scope.loadReport = function () {

        let year = $scope.selectedMonth.getFullYear();
        let month = $scope.selectedMonth.getMonth() + 1;

        let fromDate = `${year}-${month.toString().padStart(2, "0")}-01`;
        let lastDay = new Date(year, month, 0);
        let day = lastDay.getDate().toString().padStart(2, "0");
        let mm = month.toString().padStart(2, "0"); // month đã đúng format
        let toDate = `${year}-${mm}-${day}`;



        // Tháng trước
        let prevMonth = month - 1;
        let prevYear = year;

        if (prevMonth === 0) {
            prevMonth = 12;
            prevYear -= 1;
        }

        let prevFrom = `${prevYear}-${prevMonth.toString().padStart(2, "0")}-01`;
        let prevLastDay = new Date(prevYear, prevMonth, 0).getDate();
        let prevTo = `${prevYear}-${prevMonth.toString().padStart(2, "0")}-${prevLastDay}`;

        // GỌI API HAI THÁNG CÙNG LÚC
        Promise.all([
            $http.post(current_url + "/api-core/report/revenue", {
                fromDate: fromDate,
                toDate: toDate,
                option: "DAY"
            }),
            $http.post(current_url + "/api-core/report/revenue", {
                fromDate: prevFrom,
                toDate: prevTo,
                option: "DAY"
            })
        ]).then(([cur, prev]) => {

            let curData = cur.data.data || [];
            let prevData = prev.data.data || [];

            // =============================
            // 1. TÍNH KPI THÁNG HIỆN TẠI
            // =============================
            $scope.totalRevenue = curData.reduce((s, x) => s + (x.revenue || 0), 0);
            $scope.totalProfit = curData.reduce((s, x) => s + (x.grossProfit || 0), 0);

            // Best category & top product
            if (curData.length > 0) {
                $scope.bestCategory = curData[0].bestCategory || "—";
                $scope.topProduct = curData[0].topProduct || "—";
            } else {
                $scope.bestCategory = "—";
                $scope.topProduct = "—";
            }

            // =============================
            // 2. TÍNH KPI THÁNG TRƯỚC
            // =============================
            let prevRevenue = prevData.reduce((s, x) => s + (x.revenue || 0), 0);
            let prevProfit = prevData.reduce((s, x) => s + (x.grossProfit || 0), 0);

            // =============================
            // 3. TÍNH % THAY ĐỔI
            // =============================
            $scope.revenueChange =
                prevRevenue === 0
                    ? 100
                    : (($scope.totalRevenue - prevRevenue) / prevRevenue * 100).toFixed(2);

            $scope.profitChange =
                prevProfit === 0
                    ? 100
                    : (($scope.totalProfit - prevProfit) / prevProfit * 100).toFixed(2);


            // =============================
            // 4. BUILD BIỂU ĐỒ
            // =============================
            let daysInMonth = new Date(year, month, 0).getDate();
            let fullData = [];

            for (let day = 1; day <= daysInMonth; day++) {
                const d = `${year}-${month.toString().padStart(2, "0")}-${day.toString().padStart(2, "0")}`;

                const found = curData.find(x => x.date.substring(0, 10) === d);
                fullData.push(found || { date: d, revenue: 0 });
            }

            const wrapper = document.querySelector(".chart-wrapper");
            wrapper.style.width = (fullData.length * 39) + "px";

            $timeout(() => {
                const canvas = document.getElementById("revenueChart");
                if ($scope.revenueChart) $scope.revenueChart.destroy();

                canvas.width = wrapper.offsetWidth;
                canvas.height = 400;

                $scope.revenueChart = new Chart(canvas, {
                    type: "line",
                    data: {
                        labels: fullData.map(x => Number(x.date.slice(8, 10))),
                        datasets: [{
                            label: "Revenue",
                            data: fullData.map(x => x.revenue),
                            borderColor: "#0ea5e9",
                            backgroundColor: "rgba(14,165,233,0.15)",
                            borderWidth: 2,
                            tension: 0.35,
                            pointRadius: 3,
                            fill: true
                        }]
                    },
                    options: {
                        responsive: false,
                        maintainAspectRatio: false
                    }
                });
            }, 40);

        });
    };






    /* ============================================================
       IMPORT – EXPORT (FILTER BY MONTH)
    ============================================================ */

    $scope.searchMonth = new Date("2025-11-01");   // default
    $scope.rawImportExport = [];

    // KPI defaults
    $scope.totalImport = 0;
    $scope.totalExport = 0;

    $scope.topImportProduct = "—";
    $scope.leastImportProduct = "—";
    $scope.topExportProduct = "—";
    $scope.leastExportProduct = "—";

    $scope.mostImportedName = "—";
    $scope.mostExportedName = "—";


    /* ============================================================
       GỌI API IMPORT–EXPORT THEO THÁNG
    ============================================================ */
    $scope.filterByMonth = function () {

        if (!$scope.searchMonth) return;

        let year = $scope.searchMonth.getFullYear();
        let month = $scope.searchMonth.getMonth() + 1;

        let fromDate = `${year}-${month.toString().padStart(2, "0")}-01`;
        let lastDay = new Date(year, month, 0);
        let day = lastDay.getDate().toString().padStart(2, "0");
        let mm = month.toString().padStart(2, "0"); // month đã đúng format
        let toDate = `${year}-${mm}-${day}`;


        $http.post(current_url + "/api-core/report/import-export", {
            fromDate: fromDate,
            toDate: toDate,
            option: "DAY"
        }).then(res => {

            let data = res.data.data || [];
            $scope.rawImportExport = data;

            updateImportExportKPI(data);
            updateImportExportChart(data);
        });
    };


    /* ============================================================
       CẬP NHẬT KPI IMPORT – EXPORT
    ============================================================ */
    function updateImportExportKPI(data) {

        if (data.length === 0) {

            $scope.totalImport = 0;
            $scope.totalExport = 0;

            $scope.topImportProduct =
                $scope.leastImportProduct =
                $scope.topExportProduct =
                $scope.leastExportProduct =
                $scope.mostImportedName =
                $scope.mostExportedName = "—";

            return;
        }

        // KPI của API nằm tại phần tử đầu tiên
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


    /* ============================================================
       VẼ BIỂU ĐỒ IMPORT / EXPORT
    ============================================================ */
    function updateImportExportChart(data) {

        const ctx = document.getElementById("importExportChart");

        // Hủy chart cũ nếu có
        if ($scope.importExportChart) {
            $scope.importExportChart.destroy();
        }

        function fillFullMonth(data, year, month) {
            let days = new Date(year, month, 0).getDate();

            let full = [];

            for (let d = 1; d <= days; d++) {

                let dayStr = `${year}-${month.toString().padStart(2, "0")}-${d.toString().padStart(2, "0")}`;

                let found = data.find(x => x.date.startsWith(dayStr));

                full.push(found || { importQty: 0, exportQty: 0, date: dayStr });
            }

            return full;
        }


        let year = $scope.searchMonth.getFullYear();
        let month = $scope.searchMonth.getMonth() + 1;

        let fullData = fillFullMonth(data, year, month);

        let labels = fullData.map(x => x.date.substring(8, 10));
        let importData = fullData.map(x => x.importQty);
        let exportData = fullData.map(x => x.exportQty);



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
                        tension: 0.3
                    },
                    {
                        label: "Export",
                        data: exportData,
                        borderColor: "#f97316",
                        borderWidth: 2,
                        fill: false,
                        tension: 0.3
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


    /* ============================================================
       AUTO LOAD
    ============================================================ */
    $scope.filterByMonth();

    /* ============================================================
       WATCH — khi thay tháng thì đổi dữ liệu
    ============================================================ */
    $scope.$watch("searchMonth", function () {
        $scope.filterByMonth();
    });



    $scope.loadStock = function () {
        $http.get(current_url + "/api-core/report/stock").then(res => {
            let data = res.data.data || [];

            // reset KPI
            $scope.stockStats = {
                totalProducts: 0,
                totalQty: 0,
                lowStock: 0,
                totalStockValue: 0,
                expiringSoon: 0
            };

            let grouped = {};
            let today = new Date();

            data.forEach(x => {
                grouped[x.productID] = true;

                // Tổng tồn theo lô
                $scope.stockStats.totalQty += x.qtyRemain;

                // Tổng giá trị tồn kho
                $scope.stockStats.totalStockValue += (x.qtyRemain * (x.unitPrice || 0));

                // kiểm tra LowStock
                if (x.qtyRemain < x.minStock) {
                    $scope.stockStats.lowStock++;
                }

                // kiểm tra hạn sử dụng
                if (x.expiryDate) {
                    let exp = new Date(x.expiryDate);
                    let days = Math.ceil((exp - today) / (1000 * 60 * 60 * 24));

                    if (days <= 30 && days >= 0) {
                        $scope.stockStats.expiringSoon++;
                    }
                }
            });

            // tổng số sản phẩm duy nhất
            $scope.stockStats.totalProducts = Object.keys(grouped).length;

            // --------------------------------------------
            // ✔ TOP 5 tồn lâu nhất (Age cao nhất)
            // --------------------------------------------
            let sortedAge = [...data].sort((a, b) => b.ageInDays - a.ageInDays);
            $scope.stockList = sortedAge.slice(0, 5);


            // --------------------------------------------
            // ✔ TOP 5 sản phẩm sắp hết hạn (MinDaysToExpire)
            // --------------------------------------------
            let expList = data
                .filter(x => x.expiryDate) // có hạn sử dụng
                .map(x => {
                    let exp = new Date(x.expiryDate);
                    let days = Math.ceil((exp - today) / (1000 * 60 * 60 * 24));
                    return {
                        productName: x.productName,
                        sku: x.sku,
                        batchNo: x.batchNo,
                        expiryDate: x.expiryDate,
                        daysLeft: days
                    };
                })
                .filter(x => x.daysLeft >= 0)            // chưa hết hạn
                .sort((a, b) => a.daysLeft - b.daysLeft) // sắp xếp tăng dần
                .slice(0, 4);                            // chỉ lấy 5 record

            $scope.expiringList = expList;
        });
    };

















    $scope.$watch("activeTab", function (v) {
        if (v === 'stock') {
            $scope.loadStock();
        }
    });
    $scope.$watch("activeTab", function (v) {
        if (v === 'sales') {
            $scope.loadMonthlyRevenue();
        }
    });
    $scope.$watch("activeTab", function (v) {
        if (v === 'import') {
            $scope.loadReport();
        }
    });


    // CHẠY HÀM
    $scope.loadReport();

    // Khi user thay tháng → gọi hàm hợp nhất
    $scope.$watch("selectedMonth", function () {
        $scope.loadReport();
    });








    $scope.loadMonthlyRevenue();
    $scope.loadKPI();
})
