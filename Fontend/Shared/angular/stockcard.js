var app = angular.module("AppRetailPos");
app.controller("stockcardCtrl", function ($scope, $http, $timeout, AuthService, PermissionService, $window) {
  $scope.currentUser = AuthService.getCurrentUser(); // lấy user 
  $scope.stocks = [];
  $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };
  $scope.stats = { total: 0, instock: 0, outstock: 0 };
  $scope.searchProduct = "";
  $scope.searchType = "";
  $scope.searchFromDate = null;
  $scope.searchToDate = null;





if (!$scope.currentUser) {
    $window.location.href = "../AuthFE/login.html";
    return;
  }
  $scope.canShow = function (key) {
    return PermissionService.canShow(key);
  };


  $scope.filter = function () {
    $scope.pager.page = 1;
    $scope.LoadStocks();
};

$scope.LoadStocks = function () {

    var productName = $scope.searchProduct 
                      ? $scope.searchProduct.trim()
                      : "";

    var type = $scope.searchType && $scope.searchType !== "ALL"
               ? $scope.searchType
               : "";

    var fromDate = $scope.searchFromDate ? $scope.searchFromDate : null;
    var toDate   = $scope.searchToDate   ? $scope.searchToDate   : null;

    $http({
        method: "POST",
        url: current_url + "/api-core/stockcard/search-stockcard",
        data: {
            page: $scope.pager.page,
            pageSize: $scope.pager.size,

            stockID: null,
            productID: null,
            productName: productName,
            transactionType: type,
            balance: null,
            receiptID: null,
            issueID: null,
            supplierID: null,
            batchNo: "",

            fromDate: fromDate,
            toDate: toDate
        }
    }).then(function (res) {

        console.log("DEBUG API RESPONSE:", res.data);

        let body = res.data;

        $scope.stocks = body.data || body.stockcards || [];

        $scope.pager.total = body.totalItems || 0;
        $scope.pager.pages = Math.max(1, Math.ceil($scope.pager.total / $scope.pager.size));

        $scope.CalculateStats();
    },
    function (err) {
      console.error("❌ Lỗi LoadProducts:", err);
      $scope.products = [];
      $scope.pager.total = 0;
      $scope.pager.pages = 1;
    }
);
};





  $scope.CalculateStats = function () {

    if (!$scope.stocks || $scope.stocks.length === 0) {
        $scope.stats = { total: 0, instock: 0, outstock: 0 };
        return;
    }

    let total = $scope.stocks.length;

    let instock = 0;
    let outstock = 0;

    for (let s of $scope.stocks) {

        let type = (s.transactionType || "").toUpperCase();

        if (type === "IN") instock++;
        else if (type === "OUT") outstock++;
    }

    $scope.stats = {
        total: total,
        instock: instock,
        outstock: outstock
    };
};


$scope.detailStock = {}; 
$scope.showDetail = false;

$scope.detail = function (s) {
    $scope.detailStock = angular.copy(s);
    $scope.showDetail = true;

    // mở modal
    document.querySelector(".form-detail").classList.add("open");

    // khóa cuộn nền
    document.body.classList.add("modal-open");
};

$scope.closeForm = function () {
    $scope.showDetail = false;

    document.querySelector(".form-detail").classList.remove("open");

    document.body.classList.remove("modal-open");
};



// ====================== DELETE STOCK ======================

// mở modal xóa
$scope.remove = function (item) {
    $scope.deleting = item;      // lưu sản phẩm cần xóa
    $scope.showDelete = true;    // mở modal
    $scope.deletingBusy = false;

    document.querySelector(".form-delete").classList.add("open");
    document.body.classList.add("modal-open");
};

// đóng modal khi nhấn Cancel
$scope.cancelDelete = function (event) {

    if (event) event.stopPropagation();   // ✔ only if event exists

    $scope.showDelete = false;

    document.body.classList.remove("modal-open");
};


// đóng modal khi click ra ngoài
$scope.closeDeleteOnOverlay = function (event) {
    if (event.target.classList.contains("form-delete")) {
        $scope.cancelDelete(event);
    }
};

// xác nhận xóa
$scope.confirmDelete = function () {
    if (!$scope.deleting) return;

    $scope.deletingBusy = true;

    $http.delete(current_url + "/api-core/stockcard/delete/" + $scope.deleting.stockID)
        .then(function (res) {

            console.log("SUCCESS:", res.data);

            alert(res.data.message || "Delete success!");

            $scope.deletingBusy = false;
            $scope.cancelDelete();
            $scope.LoadStocks();
        })
        .catch(function (err) {

            console.log("ERROR:", err);

            let msg = err.data?.message || "Delete failed! Server error.";

            alert(msg);

            $scope.deletingBusy = false;
        });
};




var typingTimer;
    function triggerSearch() {
      $scope.pager.page = 1;
      $timeout.cancel(typingTimer);
      typingTimer = $timeout($scope.LoadStocks, 300);
    }
    $scope.$watch("searchProduct", triggerSearch);
    $scope.$watch("searchType", triggerSearch);

    // phân trang
    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.LoadStocks();
    };
    //thay đổi số bản ghi trên trang
    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.LoadStocks();
    };



    $scope.exportExcel = function () {

    if (!$scope.stocks || $scope.stocks.length === 0) {
        alert("No data to export!");
        return;
    }

    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet("Stockcard");

    worksheet.columns = [
        { header: "StockID", key: "stockID", width: 10 },
        { header: "Product Name", key: "productName", width: 25 },
        { header: "Transaction Type", key: "transactionType", width: 15 },
        { header: "Quantity", key: "quantity", width: 10 },
        { header: "Balance", key: "balance", width: 10 },
        { header: "Date", key: "transactionDate", width: 15 },
        { header: "ProductID", key: "productID", width: 10 },
        { header: "ReceiptID", key: "receiptID", width: 10 },
        { header: "IssueID", key: "issueID", width: 10 },
        { header: "SupplierID", key: "supplierID", width: 10 },
        { header: "Batch No", key: "batchNo", width: 15 }
    ];

    // thêm dữ liệu TRANG HIỆN TẠI
    $scope.stocks.forEach(item => {
        worksheet.addRow({
            stockID: item.stockID,
            productName: item.productName,
            transactionType: item.transactionType,
            quantity: item.quantity,
            balance: item.balance,
            transactionDate: new Date(item.transactionDate).toLocaleDateString("en-GB"),
            productID: item.productID,
            receiptID: item.receiptID,
            issueID: item.issueID,
            supplierID: item.supplierID,
            batchNo: item.batchNo
        });
    });

    // style header
    worksheet.getRow(1).eachCell((cell) => {
        cell.font = { bold: true, color: { argb: "FFFFFFFF" } };
        cell.fill = {
            type: "pattern",
            pattern: "solid",
            fgColor: { argb: "FF4CAF50" }
        };
    });

    workbook.xlsx.writeBuffer().then((buffer) => {
        let fileName = `Stockcard_Page_${$scope.pager.page}_Size_${$scope.pager.size}.xlsx`;
        saveAs(new Blob([buffer]), fileName);
    });
};


$scope.LoadStocks();

})


