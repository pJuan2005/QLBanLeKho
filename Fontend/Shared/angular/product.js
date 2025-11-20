var app = angular.module("AppRetailPos");
app.controller("productCtrl", function ($scope, $http, $timeout, AuthService, PermissionService, $window, TranslateService) {
function applyLanguage(lang) {
    TranslateService.loadLanguage(lang).then(() => {
        $scope.t = TranslateService.t;
    });
}
applyLanguage(localStorage.getItem("appLang") || "EN");



  $scope.currentUser = AuthService.getCurrentUser(); // lấy user 
  $scope.products = [];
  $scope.pager = { page: 1, size: 10, total: 0, pages: 1 };
  $scope.stats = { total: 0, instock: 0, outstock: 0 };
  $scope.searchProduct = "";
  $scope.searchSKU = "";
  $scope.MinPrice !== "" ? Number($scope.MinPrice) : null,
  $scope.MaxPrice !== "" ? Number($scope.MaxPrice) : null,



  $scope.newProduct = {
    ProductName: "",
    SKU: "",
    Barcode: "",
    CategoryID: null,
    unitPrice:0,
    Unit: "",
    MinStock: 0,
    Quantity: 0,
    VATRate: null,
    Status: "Active",
    image: null

  };
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
  };


  $scope.LoadProducts = function () {
  // chuẩn hóa SKU & tên sản phẩm để tránh lỗi null
  var skuExact = $scope.searchSKU ? $scope.searchSKU.trim() : "";
  var productName = $scope.searchProduct ? $scope.searchProduct.trim() : "";

  $http({
    method: "POST",
    url: current_url + "/api-core/product/search-product",
    data: {
      page: $scope.pager.page,
      pageSize: $scope.pager.size,
      ProductID: null,
      SKU: skuExact,
      Barcode: "",
      ProductName: productName,
      CategoryID: null,
      Status: "",
      MinPrice: $scope.MinPrice,
      MaxPrice: $scope.MaxPrice,
    },
  }).then(
    function (res) {
      var body = res.data || {};

      // ✅ Chuẩn hóa danh sách sản phẩm
      $scope.products = (body.data || body.Data || []).map(p => ({
      productID:   p.ProductID ?? p.productID,
      productName: p.ProductName ?? p.productName ?? "",
      sku:         p.SKU ?? p.sku ?? "",
      barcode:     p.Barcode ?? p.barcode ?? "",
      categoryID:  (p.CategoryID ?? p.categoryID) ?? null,
      unitPrice:   Number(p.UnitPrice ?? p.unitPrice ?? 0),
      unit:        p.Unit ?? p.unit ?? "",
      minStock:    Number(p.MinStock ?? p.minStock ?? 0),
      quantity:    Number(p.Quantity ?? p.quantity ?? 0),
      vatRate:     Number(p.VATRate ?? p.vatRate ?? 0),
      status:      p.Status ?? p.status ?? "Active",
      image: p.ImageBase64 ?? p.imageBase64 ?? p.Image ?? p.image ?? ""

    }));



      // ✅ Tính tổng số bản ghi & phân trang
      $scope.pager.total = body.totalItems || body.TotalItems || 0;
      $scope.pager.pages = Math.max(1, Math.ceil($scope.pager.total / $scope.pager.size));

      // ✅ Tính thống kê tồn kho
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
  if (!$scope.products || $scope.products.length === 0) {
    $scope.stats = { total: 0, instock: 0, outstock: 0 };
    return;
  }

  // Tổng sản phẩm
  const total = $scope.products.length;

  // Đếm tồn kho
  let instock = 0;
  for (let p of $scope.products) {
    let qty = parseFloat(p.quantity || 0);
    if (qty > 0) instock++;
  }

  $scope.stats = {
    total: total,
    instock: instock,
    outstock: total - instock
  };
};
$scope.generateBarcode = function () {
  $scope.newProduct.barcode = Math.floor(10000 + Math.random() * 90000).toString();
};



  // ====== THÊM MỚI SẢN PHẨM ======
$scope.add = function () {
  if ($scope.savingAdd) return;

  if (
    !$scope.newProduct.productName ||
    !$scope.newProduct.sku ||
    !$scope.newProduct.barcode ||
    !$scope.newProduct.categoryID
  ) {
    alert("⚠️ Vui lòng nhập đầy đủ Product Name, SKU, Barcode và chọn Category!");
    return;
  }

  const formData = new FormData();
  formData.append("ProductName", $scope.newProduct.productName);
  formData.append("SKU",         $scope.newProduct.sku);
  formData.append("Barcode",     $scope.newProduct.barcode);
  formData.append("CategoryID",  Number($scope.newProduct.categoryID));
  formData.append("UnitPrice",   Number($scope.newProduct.unitPrice) || 0);
  formData.append("Unit",        $scope.newProduct.unit || "");
  formData.append("MinStock",    Number($scope.newProduct.minStock) || 0);
  formData.append("Status",      $scope.newProduct.status || "Active");
  formData.append("Quantity",    Number($scope.newProduct.quantity) || 0);

  if ($scope.newProduct.vatRate !== undefined &&
    $scope.newProduct.vatRate !== null &&
    $scope.newProduct.vatRate !== "") {
  formData.append("VATRate", Number($scope.newProduct.vatRate));
  }

  if ($scope.newProduct.vatRate !== undefined && $scope.newProduct.vatRate !== null && $scope.newProduct.vatRate !== "") {
    formData.append("VATRate", Number($scope.newProduct.vatRate));
  }

  const imageInput = document.getElementById("imageInputAdd");
  if (imageInput.files.length > 0) {
    formData.append("imageFile", imageInput.files[0]);
  }

  $http.post(current_url + "/api-core/product/create-product", formData, {
    transformRequest: angular.identity,
    headers: { "Content-Type": undefined },
  })
  .then(function () {
    alert("✅ Thêm sản phẩm thành công!");
    $scope.newProduct = {
      productName: "", sku: "", barcode: "", categoryID: null, unitPrice: 0,
      unit: "", minStock: 0, quantity: 0, vatRate: null, status: "Active", image: null
    };
    
  $timeout(function () {
    const fileInput = document.getElementById("imageInputAdd");
    if (fileInput) fileInput.value = "";       // clear selection
  }, 0);
  $scope.pager.page = 1;
  $scope.LoadProducts();
  })
  .catch(function (err) {
    console.error("❌ Lỗi khi thêm sản phẩm:", err);
    alert(err?.data?.message || "Thêm sản phẩm không thành công!");
  });
};


// ====== MỞ FORM EDIT VÀ ĐỔ DỮ LIỆU ======
$scope.edit = function (row) {
  $scope.editingProduct = angular.copy(row);
  if ($scope.editingProduct.categoryID != null) {
    $scope.editingProduct.categoryID = Number($scope.editingProduct.categoryID);
  }

  const openForm = function() {
    // force digest cycle để Angular render ng-options trước khi mở modal
    $timeout(() => {
      console.log("🧩 CategoryID hiện tại:", $scope.editingProduct.categoryID);
      console.log("🧩 Categories:", $scope.categories);
      openEditModal();
    }, 150);
  };

  if (!$scope.categories || $scope.categories.length === 0) {
    $scope.LoadCategories().finally(openForm);
  } else {
    openForm();
  }
};


// ====== CẬP NHẬT SẢN PHẨM ======
$scope.updateProduct = function () {
  if (!$scope.editingProduct || $scope.savingEdit) return;
  $scope.savingEdit = true;

  const id = $scope.editingProduct.productID;
  const formData = new FormData();
  formData.append("ProductID",   id);
  formData.append("ProductName", $scope.editingProduct.productName);
  formData.append("SKU",         $scope.editingProduct.sku);
  formData.append("Barcode",     $scope.editingProduct.barcode);
  formData.append("CategoryID",  Number($scope.editingProduct.categoryID));
  formData.append("UnitPrice",   Number($scope.editingProduct.unitPrice) || 0); // ✅ FIX
  formData.append("Unit",        $scope.editingProduct.unit || "");
  formData.append("MinStock",    Number($scope.editingProduct.minStock) || 0);
  formData.append("Status",      $scope.editingProduct.status || "Active");
  formData.append("Quantity",    Number($scope.editingProduct.quantity) || 0);



  if ($scope.editingProduct.vatRate !== undefined &&
    $scope.editingProduct.vatRate !== null &&
    $scope.editingProduct.vatRate !== "") {
  formData.append("VATRate", Number($scope.editingProduct.vatRate));
  }




  if ($scope.editingProduct.vatRate !== undefined && $scope.editingProduct.vatRate !== null && $scope.editingProduct.vatRate !== "") {
    formData.append("VATRate", Number($scope.editingProduct.vatRate));
  }

  
  const imageInput = document.getElementById("imageInputEdit");
  if (imageInput.files.length > 0) {
    formData.append("imageFile", imageInput.files[0]);
  }

  $http.put(current_url + "/api-core/product/update-product/" + id, formData, {
    transformRequest: angular.identity,
    headers: { "Content-Type": undefined },
  })
  .then(function () {
      $scope.savingEdit = false;
      alert("✅ Cập nhật sản phẩm thành công!");
      closeEditModal();
      $scope.editingProduct = null;
      $scope.LoadProducts();
  }, function (err) {
      $scope.savingEdit = false;
      console.error("❌ Lỗi khi cập nhật sản phẩm:", err);
      alert("Cập nhật sản phẩm không thành công!");
  });
};


$scope.previewImageAdd = function (input) {
  if (input.files && input.files[0]) {
    const reader = new FileReader();
    reader.onload = function (e) {
      $scope.$apply(() => $scope.newProduct.image = e.target.result);
    };
    reader.readAsDataURL(input.files[0]);
  }
};

$scope.previewImageEdit = function (input) {
  if (input.files && input.files[0]) {
    const reader = new FileReader();
    reader.onload = function (e) {
      $scope.$apply(() => $scope.editingProduct.image = e.target.result);
    };
    reader.readAsDataURL(input.files[0]);
  }
};


$scope.categories = [];
$scope.LoadCategories = function () {
  return $http({
    method: "POST",
    url: current_url + "/api-core/category/search",
    data: { page: 1, pageSize: 1000, CategoryName: "", vatExact: null, option: "" },
  }).then(function (res) {
    var body = res.data || {};
    var raw = body.data || body.Data || [];
    $scope.categories = raw.map(c => ({
      categoryID: Number(c.CategoryID || c.categoryID),
      categoryName: c.CategoryName || c.categoryName
    }));
  }).catch(function (err) {
    console.error("❌ Load categories error:", err);
    $scope.categories = [];
  })};


  // ================== DELETE PRODUCT ==================
$scope.showDelete = false;
$scope.deleting = null;
$scope.deletingBusy = false;

// Khi bấm nút 🗑 Delete trong bảng
$scope.remove = function (p) {
  $scope.deleting = angular.copy(p);
  $scope.showDelete = true;
};

// Bấm Cancel (đóng popup)
$scope.cancelDelete = function (e) {
  if (e) e.preventDefault();
  $scope.showDelete = false;
  $scope.deleting = null;
  $scope.deletingBusy = false;
};

// Khi click ra ngoài vùng modal → đóng
$scope.closeDeleteOnOverlay = function (event) {
  if (event.target.classList.contains("form-delete")) {
    $scope.cancelDelete(event);
  }
};

// ✅ Xác nhận xoá sản phẩm
$scope.confirmDelete = function ($event) {
  if ($event) $event.stopPropagation(); // 🚫 chặn click lan ra overlay
  if ($scope.deletingBusy) return; // ngăn double click
  if (!$scope.deleting || !$scope.deleting.productID) return;

  $scope.deletingBusy = true;
  const id = $scope.deleting.productID;

  console.log("🧩 confirmDelete() CALLED, deleting ID:", id);

  $http({
    method: "DELETE",
    url: current_url + "/api-core/product/delete-product/" + id,
  })
    .then(function (res) {
      alert("🗑 Xoá sản phẩm thành công!",res);
      $scope.cancelDelete();
      // chờ 300ms để backend cập nhật rồi reload
      $timeout(() => $scope.LoadProducts(), 300);
    })
    .catch(function (err) {
      console.error("❌ Lỗi khi xoá sản phẩm:", err);
      alert("Xoá sản phẩm không thành công!");
    })
    .finally(function () {
      $scope.deletingBusy = false;
    })};

  
  //tối ưu khi search
    var typingTimer;
    function triggerSearch() {
      $scope.pager.page = 1;
      $timeout.cancel(typingTimer);
      typingTimer = $timeout($scope.LoadProducts, 300);
    }

    $scope.$watch("MinPrice", triggerSearch);
    $scope.$watch("MaxPrice", triggerSearch);
    $scope.$watch("searchProduct", triggerSearch);
    $scope.$watch("searchSKU", triggerSearch);

    // phân trang
    $scope.go = function (p) {
      if (p < 1 || p > $scope.pager.pages) return;
      $scope.pager.page = p;
      $scope.LoadProducts();
    };
    //thay đổi số bản ghi trên trang
    $scope.changeSize = function () {
      $scope.pager.page = 1;
      $scope.LoadProducts();
    };






  // ========== EXPORT EXCEL (theo phân trang hoặc tất cả) ==========
  // ========== EXPORT EXCEL (KHÔNG CÓ HÌNH ẢNH) ==========
$scope.exportExcel = function () {
    if (!$scope.products || $scope.products.length === 0) {
        alert("❌ Không có dữ liệu để export!");
        return;
    }

    const workbook = new ExcelJS.Workbook();
    const ws = workbook.addWorksheet("Products");

    // Định nghĩa cột Excel
    ws.columns = [
        { header: "ID", key: "ProductID", width: 10 },
        { header: "Product Name", key: "ProductName", width: 30 },
        { header: "SKU", key: "SKU", width: 15 },
        { header: "Barcode", key: "Barcode", width: 20 },
        { header: "CategoryID", key: "CategoryID", width: 12 },
        { header: "Price", key: "UnitPrice", width: 15 },
        { header: "Unit", key: "Unit", width: 12 },
        { header: "MinStock", key: "MinStock", width: 12 },
        { header: "Quantity", key: "Quantity", width: 12 },
        { header: "VAT Rate (%)", key: "VATRate", width: 12 },
        { header: "Status", key: "Status", width: 12 }
    ];

    // Ghi từng dòng
    $scope.products.forEach(p => {
        ws.addRow({
            ProductID: p.productID,
            ProductName: p.productName,
            SKU: p.sku,
            Barcode: p.barcode,
            CategoryID: p.categoryID,
            UnitPrice: p.unitPrice,
            Unit: p.unit,
            MinStock: p.minStock,
            Quantity: p.quantity,
            VATRate: p.vatRate,
            Status: p.status
        });
    });

    // Tải file
    workbook.xlsx.writeBuffer().then(buffer => {
        saveAs(new Blob([buffer]), "Products.xlsx");
    });

    alert("✅ Xuất Excel thành công !");
};




// $scope.triggerImportFile = function () {
//     document.getElementById("fileImport").click();
// };

// $scope.generateSKU = function (index) {
//     return "SKU" + index.toString().padStart(4, "0");
// };

// $scope.generateBarcode = function (index) {
//     return "BC" + index.toString().padStart(4, "0");
// };
// $scope.handleImportFile = async function (input) {
//     $scope.$applyAsync(); // bắt Angular digest

//     console.log("▶ handleImportFile CALLED");

//     if (!input.files || input.files.length === 0) {
//         alert("❌ Không có file!");
//         return;
//     }

//     let file = input.files[0];

//     console.log("📦 File nhận được:", file.name);

//     const workbook = new ExcelJS.Workbook();
//     await workbook.xlsx.load(await file.arrayBuffer());

//     const ws = workbook.worksheets[0];
//     if (!ws) {
//         alert("❌ File Excel không hợp lệ!");
//         return;
//     }

//     alert("📥 File đã load, bắt đầu import...");

//     let rows = [];
//     let index = 1;

//     ws.eachRow((row, rowIndex) => {
//         if (rowIndex === 1) return;

//         rows.push({
//             ProductName: row.getCell(1).value || "",
//             CategoryID: Number(row.getCell(2).value || 0),
//             UnitPrice: Number(row.getCell(3).value || 0),
//             Unit: row.getCell(4).value || "",
//             MinStock: Number(row.getCell(5).value || 0),
//             Quantity: Number(row.getCell(6).value || 0),
//             VATRate: Number(row.getCell(7).value || 0),
//             SKU: $scope.generateSKU(index),
//             Barcode: $scope.generateBarcode(index)
//         });

//         index++;
//     });

//     console.log("✔ Rows parsed:", rows);

//     if (rows.length === 0) {
//         alert("❌ File không có dữ liệu!");
//         return;
//     }

//     for (let item of rows) {
//         let formData = new FormData();
//         formData.append("ProductName", item.ProductName);
//         formData.append("SKU", item.SKU);
//         formData.append("Barcode", item.Barcode);
//         formData.append("CategoryID", item.CategoryID);
//         formData.append("UnitPrice", item.UnitPrice);
//         formData.append("Unit", item.Unit);
//         formData.append("MinStock", item.MinStock);
//         formData.append("Quantity", item.Quantity);
//         formData.append("VATRate", item.VATRate);
//         formData.append("Status", "Active");

//         await $http.post(current_url + "/api-core/product/create-product",
//             formData,
//             {
//                 transformRequest: angular.identity,
//                 headers: { "Content-Type": undefined }
//             }
//         );
//     }

//     alert("🎉 Import thành công!");
//     $scope.LoadProducts();

//     input.value = "";
// };







// ========== IMAGE MODAL VIEWER ==========
$scope.showImageModal = false;
$scope.selectedImage = null;

// Mở modal xem ảnh
$scope.openImageModal = function (imgUrl) {
  $scope.selectedImage = imgUrl;
  $scope.showImageModal = true;
};

// Đóng modal khi click ra ngoài
$scope.closeImageModal = function (event) {
  if (event.target.classList.contains('image-viewer')) {
    $scope.showImageModal = false;
    $scope.selectedImage = null;
  }
};
  $scope.LoadCategories();
  $scope.LoadProducts();
});