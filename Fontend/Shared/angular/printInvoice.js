// Dùng lại module đã khai báo trong global.js
var app = angular.module("AppRetailPos");

app.controller("printInvoiceCtrl", function ($scope, $window) {
  // format tiền
  $scope.formatVnd = function (n) {
    if (n == null) return "0 ₫";
    return (
      Number(n).toLocaleString("vi-VN", { maximumFractionDigits: 0 }) + " ₫"
    );
  };

  // Lấy dữ liệu từ localStorage
  var raw = $window.localStorage.getItem("RetailPro_LastInvoice");
  if (!raw) {
    alert("Không tìm thấy dữ liệu hoá đơn. Vui lòng tạo đơn từ POS.");
    $window.location.href = "../AdminFE/pos.html";
    return;
  }

  var invoice = JSON.parse(raw) || {};
  $scope.invoice = invoice;

  // Tính lại subtotal, VAT, line total
  var subtotal = 0;
  var vatTotal = 0;

  (invoice.items || []).forEach(function (it) {
    var price = Number(it.UnitPrice) || 0;
    var qty = Number(it.Quantity) || 0;
    var vatRate = Number(it.VATRate) || 0;

    var base = price * qty;
    var lineVat = base * (vatRate / 100);

    it._lineBase = base;
    it._lineVat = lineVat;
    it._lineTotal = base + lineVat;

    subtotal += base;
    vatTotal += lineVat;
  });

  $scope.subtotal = subtotal;
  $scope.vatTotal = vatTotal;

  if (!invoice.orderTotal || invoice.orderTotal === 0) {
    invoice.orderTotal = subtotal + vatTotal;
  }

  // Tiền thừa (change)
  $scope.changeToReturn = Math.max(
    0,
    (invoice.prepay || 0) - (invoice.orderTotal || 0)
  );

  // Tự động mở hộp thoại in sau khi load 1 chút
  setTimeout(function () {
    window.print();
  }, 500);
});
