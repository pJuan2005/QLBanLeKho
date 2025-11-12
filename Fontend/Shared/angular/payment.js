var app = angular.module("AppRetailPos");

app.controller("paymentCtrl", function ($scope, $http, $timeout, AuthService, PermissionService, $window) {
  $scope.currentUser = AuthService.getCurrentUser();
  $scope.payments = [];
  $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };

  $scope.newPayment = {
    SaleID: null,
    CustomerID: null,
    SupplierID: null,
    ReceiptID: null,
    Amount: 0,
    PaymentDate: new Date(),
    Method: "",
    Description: ""
  };

  if (!$scope.currentUser) {
    $window.location.href = "../AuthFE/login.html";
    return;
  }

  $scope.canShow = function (key) {
    return PermissionService.canShow(key);
  };

  $scope.LoadPayments = function () {
    $http({
      method: "POST",
      url: current_url + "/api-core/payments/search-payment",
      data: {
        page: $scope.pager.page,
        pageSize: $scope.pager.size,
        SaleID: null,
        CustomerID: null,
        SupplierID: null,
        ReceiptID: null,
        Method: "",
        FromDate: null,
        ToDate: null
      },
    }).then(
      function (res) {
        var body = res.data || {};
        $scope.payments = (body.data || body.Data || []).map(p => ({
          PaymentID: p.PaymentID || p.paymentID,
          SaleID: p.SaleID || p.saleID,
          CustomerID: p.CustomerID || p.customerID,
          SupplierID: p.SupplierID || p.supplierID,
          ReceiptID: p.ReceiptID || p.receiptID,
          Amount: p.Amount || p.amount || 0,
          PaymentDate: p.PaymentDate || p.paymentDate,
          Method: p.Method || p.method,
          Description: p.Description || p.description
        }));

        $scope.pager.total = body.totalItems || body.TotalItems || 0;
        $scope.pager.pages = Math.max(1, Math.ceil($scope.pager.total / $scope.pager.size));
      },
      function (err) {
        console.error("❌ Lỗi LoadPayments:", err);
        $scope.payments = [];
        $scope.pager.total = 0;
        $scope.pager.pages = 1;
      }
    );
  };

  // Load lần đầu
  $scope.LoadPayments();
});
