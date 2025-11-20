var app = angular.module("AppRetailPos");
app.controller("returnCtrl", function ($scope, $http, $timeout, AuthService, PermissionService, $window, TranslateService) {
function applyLanguage(lang) {
    TranslateService.loadLanguage(lang).then(() => {
        $scope.t = TranslateService.t;
    });
}
applyLanguage(localStorage.getItem("appLang") || "EN");


  $scope.currentUser = AuthService.getCurrentUser(); // lấy user 
  $scope.returns = [];
  $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };
  $scope.stats = { total: 0, returnSupplier: 0, returnCustomer: 0 };
  $scope.searchPartnerName = "";
  $scope.searchPartnerPhone = "";
  $scope.searchReturnType = "";
  $scope.searchFromDate = null;
  $scope.searchToDate = null;

  $scope.newReturn = {
    ReturnType: "",
    SaleID: null,
    ReceiptID: null,
    PartnerPhone: "",
    ProductID: null,
    Quantity: 1,
    ReturnDate: new Date(),
    Reason: ""
};



$scope.savingAdd = false;

  $scope.editingReturn = null;
  $scope.savingEdit = false;

  $scope.showDelete = false;
  $scope.deleting = null;


  if (!$scope.currentUser) {
    $window.location.href = "../AuthFE/login.html";
    return;
  }
  $scope.canShow = function (key) {
    return PermissionService.canShow(key);
  };


  $scope.LoadReturns = function () {

  // Chuẩn hóa dữ liệu tìm kiếm (tránh null)
  var returnID     = $scope.searchReturnID ? $scope.searchReturnID.trim() : "";
  var returnType = ($scope.searchReturnType === "" ? null : Number($scope.searchReturnType));
  var partnerName  = $scope.searchPartnerName ? $scope.searchPartnerName.trim() : "";
  var partnerPhone = $scope.searchPartnerPhone ? $scope.searchPartnerPhone.trim() : "";
  var productName  = $scope.searchProductName ? $scope.searchProductName.trim() : "";

  var fromDate = $scope.searchFromDate || null;
  var toDate   = $scope.searchToDate   || null;

  $http({
    method: "POST",
    url: current_url + "/api-core/return/search",
    data: {
      page: $scope.pager.page,
      pageSize: $scope.pager.size,

      ReturnID:     returnID || null,
      ReturnType:   returnType,
      PartnerName:  partnerName,
      PartnerPhone: partnerPhone,
      ProductID:    null,        // tìm theo tên → backend filter Last
      ProductName:  productName, // nếu backend hỗ trợ
      FromDate:     fromDate,
      ToDate:       toDate
    }
  }).then(
    function (res) {
      var body = res.data || {};

      // Lấy danh sách trả về từ API
      var list = body.data || body.Data || [];

      // Chuẩn hóa danh sách returns
      $scope.returns = list.map(r => ({
    returnID:      r.ReturnID ?? r.returnID ?? null,
    returnType:    r.ReturnType ?? r.returnType ?? null,
    partnerName:   r.PartnerName ?? r.partnerName ?? "",
    partnerPhone:  r.PartnerPhone ?? r.partnerPhone ?? "",
    productName:   r.ProductName ?? r.productName ?? "",
    productID:     r.ProductID ?? r.productID ?? null,
    returnDate:    r.ReturnDate ?? r.returnDate ?? null,
    reason:        r.Reason ?? r.reason ?? "",

    saleID:        r.SaleID ?? r.saleID ?? null,
    receiptID:     r.ReceiptID ?? r.receiptID ?? null,
    customerID:    r.CustomerID ?? r.customerID ?? null,
    supplierID:    r.SupplierID ?? r.supplierID ?? null,
    quantity:      r.Quantity ?? r.quantity ?? null,
    unitPrice:     r.UnitPrice ?? r.unitPrice ?? null
}));



      $scope.CalculateStats();



      // Tổng số bản ghi từ API
      $scope.pager.total = body.totalItems || body.TotalItems || 0;

      // Tổng số trang
      $scope.pager.pages = Math.max(1, Math.ceil($scope.pager.total / $scope.pager.size));
    },
    function (err) {
      console.error("❌ Lỗi LoadReturns:", err);
      $scope.returns = [];
      $scope.pager.total = 0;
      $scope.pager.pages = 1;
    }
  );
};


$scope.CalculateStats = function () {
  if (!$scope.returns || $scope.returns.length === 0) {
    $scope.stats = {
      total: 0,
      returncustomer: 0,
      returnsupplier: 0
    };
    return;
  }

  const total = $scope.returns.length;

  let returnCustomer = 0;
  let returnSupplier = 0;

  for (let r of $scope.returns) {
    const type = Number(r.returnType || r.ReturnType || 0);

    if (type === 1) returnCustomer++;
    if (type === 2) returnSupplier++;
  }

  $scope.stats = {
    total: total,
    returncustomer: returnCustomer,
    returnsupplier: returnSupplier
  };
};

$scope.searchReturnType = "";





// ================== THÊM MỚI RETURN ==================
// ================== THÊM MỚI RETURN ==================
$scope.add = function () {
    if ($scope.savingAdd) return;
    $scope.savingAdd = true;

    const r = $scope.newReturn;

    // Ép kiểu ReturnType
    r.ReturnType = Number(r.ReturnType);

    if (![1, 2].includes(r.ReturnType)) {
        alert("⚠️ Vui lòng chọn ReturnType (1 = customer, 2 = supplier)");
        $scope.savingAdd = false;
        return;
    }

    if (!r.PartnerPhone || !r.ProductID || !r.Quantity) {
        alert("⚠️ Vui lòng nhập đầy đủ PartnerPhone, ProductID và Quantity!");
        $scope.savingAdd = false;
        return;
    }

    if (r.ReturnType === 1 && !r.SaleID) {
        alert("⚠️ Customer return cần SaleID!");
        $scope.savingAdd = false;
        return;
    }

    if (r.ReturnType === 2 && !r.ReceiptID) {
        alert("⚠️ Supplier return cần ReceiptID!");
        $scope.savingAdd = false;
        return;
    }

    let safeDate = new Date(r.ReturnDate);

    const payload = {
        ReturnType: r.ReturnType,
        PartnerPhone: r.PartnerPhone,
        SaleID: r.ReturnType === 1 ? r.SaleID : null,
        ReceiptID: r.ReturnType === 2 ? r.ReceiptID : null,
        ProductID: r.ProductID,
        Quantity: r.Quantity,
        ReturnDate: safeDate,
        Reason: r.Reason || null
    };

    $http.post(current_url + "/api-core/return/create", payload)
        .then(() => {
            alert("✔️ Thêm return thành công!");
            $scope.LoadReturns();

            // Reset form
            $scope.newReturn = {
                ReturnType: "",
                SaleID: null,
                ReceiptID: null,
                PartnerPhone: "",
                ProductID: null,
                Quantity: 1,
                ReturnDate: null,
                Reason: ""
            };
        })
        .catch(err => {

            console.error("❌ Lỗi thêm return:", err);

            let msg = "Không thể thêm return!";

            // Lấy lỗi từ backend
            if (typeof err.data === "string") {
                msg = err.data;
            }
            else if (err.data && err.data.error) {
                msg = err.data.error;   // <-- nhận thông báo đúng RAISERROR
            }
            else if (err.data && err.data.message) {
                msg = err.data.message;
            }

            alert(msg);  // hiển thị đúng lỗi SQL
        })
        .finally(() => {
            $scope.savingAdd = false;
        });
};






$scope.onTypeChange = function () {
    const type = Number($scope.newReturn.ReturnType);

    if (type === 1) {
        $scope.newReturn.ReceiptID = null; // Customer → xóa ReceiptID
    } else if (type === 2) {
        $scope.newReturn.SaleID = null;    // Supplier → xóa SaleID
    }
};





    // SEARCH DELAY
    var typingTimer;

    function triggerSearch() {
      $timeout.cancel(typingTimer);

      typingTimer = $timeout(function () {
        $scope.pager.page = 1;
        $scope.LoadReturns();
      }, 300);
    }

    // Watch các field search
    $scope.$watch("searchPartnerName", triggerSearch);
    $scope.$watch("searchPartnerPhone", triggerSearch);
    $scope.$watch("searchReturnType", triggerSearch);
    $scope.$watch("searchFromDate", triggerSearch);
    $scope.$watch("searchToDate", triggerSearch);


    // phân trang
    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.LoadReturns();
    };
    //thay đổi số bản ghi trên trang
    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.LoadReturns();
    };





    
$scope.detailReturn = {}; 
$scope.showDetail = false;

$scope.detail = function (s) {

    $http.get(current_url + "/api-core/return/get-by-id/" + s.returnID)
        .then(res => {
            const d = res.data;

            $scope.detailReturn = {
                returnID: d.ReturnID,
                returnType: d.ReturnType,
                partnerName: d.PartnerName,
                partnerPhone: d.PartnerPhone,
                productName: d.ProductName,
                returnDate: d.ReturnDate ? new Date(d.ReturnDate) : null,
                reason: d.Reason,

                saleID: d.SaleID,
                receiptID: d.ReceiptID,
                customerID: d.CustomerID,
                supplierID: d.SupplierID,
                productID: d.ProductID,
                quantity: d.Quantity,
                unitPrice: d.UnitPrice
            };

            // mở modal
            document.querySelector(".form-detail").classList.add("open");
            document.body.classList.add("modal-open");
        })
        .catch(err => {
            console.error("Lỗi load chi tiết:", err);
            alert("Không tải được chi tiết return!");
        });
};




// ---------------- DETAIL RETURN -----------------
$scope.detailReturn = {}; 
$scope.showDetail = false;

$scope.detail = function (s) {
    $scope.detailReturn = {
        returnID: s.returnID ?? s.returnID,
        returnType: s.returnType,
        partnerName: s.partnerName,
        partnerPhone: s.partnerPhone,
        productName: s.productName,
        returnDate: s.returnDate ? new Date(s.returnDate) : null,
        reason: s.reason,

        saleID: s.saleID,
        receiptID: s.receiptID,
        customerID: s.customerID,
        supplierID: s.supplierID,
        productID: s.productID,
        quantity: s.quantity,
        unitPrice: s.unitPrice
    };

    $scope.showDetail = true;

    document.querySelector(".form-detail").classList.add("open");
    document.body.classList.add("modal-open");
};


$scope.closeForm = function () {
    $scope.showDetail = false;
    document.querySelector(".form-detail").classList.remove("open");
    document.body.classList.remove("modal-open");
};




// ====== MỞ FORM EDIT RETURN ======
$scope.edit = function(row) {
    const id = row.returnID;

    // Gọi API để lấy dữ liệu chi tiết
    $http.get(current_url + "/api-core/return/get-by-id/" + id)
        .then(res => {
            const d = res.data;

            // Gán dữ liệu vào editingReturn
            $scope.editingReturn = {
                ReturnID:     d.returnID ?? d.ReturnID,
                ReturnType: Number(d.returnType),

                PartnerPhone: d.partnerPhone ?? d.PartnerPhone,
                ProductID:    d.productID ?? d.ProductID,
                Quantity:     d.quantity ?? d.Quantity,
                ReturnDate:   d.returnDate ? new Date(d.returnDate) : null,
                Reason:       d.reason ?? d.Reason,

                // THÔNG TIN BỔ SUNG
                SaleID:       d.saleID ?? d.SaleID,
                ReceiptID:    d.receiptID ?? d.ReceiptID,
                CustomerID:   d.customerID ?? d.CustomerID,
                SupplierID:   d.supplierID ?? d.SupplierID,
                UnitPrice:    d.unitPrice ?? d.UnitPrice
            };

            // Disable tự động theo ReturnType
            $scope.onEditTypeChange();

            // mở modal
            document.querySelector(".form-edit").classList.add("open");
            document.body.classList.add("modal-open");
        })
        .catch(err => {
            console.error("❌ Lỗi load chi tiết:", err);
            alert("Không load được dữ liệu Return cần sửa!");
        });
};




$scope.onEditTypeChange = function() {
    const t = Number($scope.editingReturn.ReturnType);

    if (t === 1) {
        $scope.editingReturn.ReceiptID = null;
    } 
    else if (t === 2) {
        $scope.editingReturn.SaleID = null;
    }
};




// ====== CẬP NHẬT RETURN ======
$scope.updateReturn = function () {

    if (!$scope.editingReturn || $scope.savingEdit) return;
    $scope.savingEdit = true;

    const id = $scope.editingReturn.ReturnID;

    const payload = {
        ReturnID: id,
        ReturnType: Number($scope.editingReturn.ReturnType),
        PartnerPhone: $scope.editingReturn.PartnerPhone,
        ProductID: Number($scope.editingReturn.ProductID),
        Quantity: Number($scope.editingReturn.Quantity),
        ReturnDate: $scope.editingReturn.ReturnDate,
        Reason: $scope.editingReturn.Reason,
        SaleID: $scope.editingReturn.ReturnType == 1 ? $scope.editingReturn.SaleID : null,
        ReceiptID: $scope.editingReturn.ReturnType == 2 ? $scope.editingReturn.ReceiptID : null
    };

    $http.post(current_url + "/api-core/return/update", payload)
        .then(() => {
            alert("✔️ Cập nhật Return thành công!");
            closeEditModal();
            $scope.LoadReturns();
        })
        .catch(err => {
            console.error("❌ Lỗi cập nhật return:", err);

            let msg = "Không thể cập nhật return!";

            // --- lấy lỗi từ backend ---
            if (typeof err.data === "string") {
                msg = err.data;
            }
            else if (err.data && err.data.error) {
                msg = err.data.error;
            }

            // --- xử lý lỗi chi tiết ---
            if (msg.includes("ReceiptID bắt buộc")) {
                alert("⚠️ Khi ReturnType = 2 (Supplier Return), ReceiptID là bắt buộc!");
            }
            else if (msg.includes("Số điện thoại nhà cung cấp không tồn tại")) {
                alert("⚠️ PartnerPhone không tồn tại trong danh sách nhà cung cấp!");
            }
            else if (msg.includes("Số điện thoại khách hàng không tồn tại")) {
                alert("⚠️ PartnerPhone không tồn tại trong danh sách khách hàng!");
            }
            else if (msg.includes("SaleID không tồn tại")) {
                alert("⚠️ SaleID không tồn tại trong hệ thống!");
            }
            else if (msg.includes("ReceiptID không tồn tại")) {
                alert("⚠️ ReceiptID không tồn tại trong hệ thống!");
            }
            else {
                alert(msg);
            }
        })
        .finally(() => {
            $scope.savingEdit = false;
        });
};



$scope.returnTypes = [
    { value: 1, label: "Customer Return" },
    { value: 2, label: "Supplier Return" }
];





// ==== XÓA RETURN ====

// mở popup khi bấm icon 🗑
$scope.remove = function (row, $event) {
    if ($event) $event.stopPropagation();

    $scope.deleting = {
        ReturnID: row.returnID || row.ReturnID,
        partnerName: row.partnerName,
        partnerPhone: row.partnerPhone
    };

    $scope.showDelete = true;      // để ng-class { open:showDelete } hoạt động
};

// bấm Cancel
$scope.cancelDelete = function ($event) {
    if ($event) $event.stopPropagation();
    $scope.showDelete = false;
    $scope.deleting = null;
};

// click ra ngoài overlay để đóng popup
$scope.closeDeleteOnOverlay = function ($event) {
    if ($event.target.classList.contains("form-delete")) {
        $scope.showDelete = false;
        $scope.$applyAsync();
    }
};


// cờ disable nút xoá
$scope.deletingBusy = false;



$scope.confirmDelete = function () {
    if ($scope.deletingBusy || !$scope.deleting) return;

    $scope.deletingBusy = true;

    let id = $scope.deleting.ReturnID;

    $http.delete(current_url + "/api-core/return/delete/" + id)
        .then(function () {
            alert("✔️ Xoá return thành công!");
            $scope.showDelete = false;
            $scope.deleting = null;
            $scope.LoadReturns();
        })
        .catch(function (err) {
            console.error("❌ Lỗi xoá return:", err);
            alert("❗ " + (err.data?.message || "Không thể xoá return!"));
        })
        .finally(function () {
            $scope.deletingBusy = false;
        });
};



$scope.$watch("searchReturnType", triggerSearch);


// ========================= EXPORT EXCEL =========================
$scope.exportExcel = function () {

    if (!$scope.returns || $scope.returns.length === 0) {
        alert("⚠ Không có dữ liệu để export!");
        return;
    }

    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet("Returns");

    // ===== Header =====
    sheet.addRow([
        "ReturnID",
        "Return Type",
        "Partner Name",
        "Partner Phone",
        "Product Name",
        "Product ID",
        "Unit Price",
        "Quantity",
        "Return Date",
        "SaleID",
        "ReceiptID",
        "CustomerID",
        "SupplierID",
        "Reason"
    ]);

    sheet.getRow(1).font = { bold: true };

    // ===== Body =====
    $scope.returns.forEach(r => {
        sheet.addRow([
            r.returnID ?? r.ReturnID,
            (Number(r.returnType ?? r.ReturnType) === 1 ? "Customer Return" : "Supplier Return"),
            r.partnerName ?? r.PartnerName,
            r.partnerPhone ?? r.PartnerPhone,
            r.productName ?? r.ProductName,
            r.productID ?? r.ProductID,
            r.unitPrice ?? r.UnitPrice,
            r.quantity ?? r.Quantity,
            r.returnDate ? new Date(r.returnDate).toLocaleDateString("vi-VN") : "",
            r.saleID ?? r.SaleID,
            r.receiptID ?? r.ReceiptID,
            r.customerID ?? r.CustomerID,
            r.supplierID ?? r.SupplierID,
            r.reason ?? r.Reason
        ]);
    });

    // ===== Auto width =====
    sheet.columns.forEach(col => {
        let maxLength = 12;
        col.eachCell(cell => {
            const len = (cell.value?.toString().length || 0) + 2;
            if (len > maxLength) maxLength = len;
        });
        col.width = maxLength;
    });

    // ===== Xuất file =====
    workbook.xlsx.writeBuffer().then(buffer => {
        saveAs(new Blob([buffer]), "Returns.xlsx");
    });
};





$scope.LoadReturns();
$scope.CalculateStats();

});


