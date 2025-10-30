// 🧭 Khai báo phần tử cần dùng
const addBtn = document.getElementById("addBtn");


let editingProductId = null;

// 🧩 API URL
const API_BASE = "https://localhost:7092/api/product";
const tableBody = document.querySelector(".product-table tbody");

// 🔹 1. Load danh sách sản phẩm
async function loadProducts() {
    tableBody.innerHTML = "<tr><td colspan='12'>Đang tải dữ liệu...</td></tr>";
    try {
        const body = {
            page: 1,
            pageSize: 50,
            productID: null,
            sku: "",
            barcode: "",
            productName: "",
            categoryID: null,
            status: ""
        };
        

        const response = await fetch(`${API_BASE}/search-product`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body),
        });

        if (!response.ok) throw new Error("Lỗi tải danh sách sản phẩm");
        const result = await response.json();
        renderProducts(result.data);
    } catch (error) {
        console.error("❌ Error:", error);
        tableBody.innerHTML = "<tr><td colspan='12' style='color:red;'>Không thể tải dữ liệu!</td></tr>";
    }
}

// 🔹 2. Render danh sách
function renderProducts(products) {
    if (!products || products.length === 0) {
        tableBody.innerHTML = "<tr><td colspan='12'>Không có sản phẩm nào</td></tr>";
        return;
    }

    tableBody.innerHTML = products.map(p => `
        <tr>
            <td><span class="all ">${p.productID}</td>
            <td><span class="all ">${p.sku || ""}</td>
            <td><span class="all ">${p.barcode || ""}</td>
            <td><span class="all ">${p.productName || ""}</td>
            <td><span class="all ">${p.categoryID ?? ""}</td>
            <td><span class="all ">${p.unit || ""}</td>
            <td><span class="all ">${p.minStock}</td>
            <td><span class="all "><span class="stock ${p.quantity <= p.minStock ? "low" : "good"}">${p.quantity}</span></td>
            <td><span class="all ">${p.vatRate ?? 0}</td>
            <td><span class="all "><span class="status ">${p.status}</span></td>
            <td>${p.image ? `<img src="https://localhost:7092/${p.image}" 
     alt="${p.productName || 'Product Image'}" width="50">
` : ""}</td>
            <td class="actions">
                <button class="icon-btn view" title="Xem">&#128065;</button>
                <button class="icon-btn edit" title="Sửa">&#9998;</button>
                <button class="icon-btn delete" title="Xóa" data-id="${p.productID}">&#128465;</button>
            </td>
        </tr>
    `).join("");

    attachEventListeners();
}

// 🔹 3. Gắn sự kiện sau render
function attachEventListeners() {
    document.querySelectorAll('.icon-btn.view').forEach(btn => {
        btn.addEventListener('click', e => {
            const img = e.target.closest('tr').querySelector('img');
            if (img) showImageModal(img.src);
        });
    });

    

    document.querySelectorAll('.icon-btn.delete').forEach(btn => {
        btn.addEventListener('click', async e => {
            const id = e.target.dataset.id;
            if (confirm(`Bạn có chắc chắn muốn xóa sản phẩm ID: ${id}?`)) {
                await deleteProduct(id);
            }
        });
    });
}

// 🔹 4. Xóa sản phẩm
async function deleteProduct(id) {
    try {
        const res = await fetch(`${API_BASE}/delete-product/${id}`, { method: "DELETE" });
        if (!res.ok) throw new Error("Xóa sản phẩm thất bại");
        alert("✅ Đã xóa sản phẩm thành công!");
        loadProducts();
    } catch {
        alert("❌ Lỗi khi xóa sản phẩm!");
    }
}

// 🔹 5. Modal xem ảnh
function showImageModal(src) {
    const imageModal = document.getElementById('imageModal');
    const modalImg = document.getElementById('modalImage');
    imageModal.style.display = 'flex';
    modalImg.src = src;

    const closeImageModal = document.getElementById('closeModal');
    closeImageModal.addEventListener('click', () => imageModal.style.display = 'none');

    imageModal.addEventListener('click', e => {
        if (e.target === imageModal) imageModal.style.display = 'none';
    });
}







// 🔹 10. Tải danh sách khi mở trang
window.addEventListener("DOMContentLoaded", loadProducts);



// ======================================================
// 🔍  TÌM KIẾM SẢN PHẨM THEO TÊN, SKU, HOẶC BARCODE
// ======================================================

const searchInput = document.getElementById("searchInput");

// Gọi API khi người dùng nhập
searchInput.addEventListener("input", debounce(handleSearch, 400));

async function handleSearch() {
    const keyword = searchInput.value.trim();

    // Nếu ô tìm kiếm rỗng → tải lại toàn bộ
    if (keyword === "") {
        loadProducts();
        return;
    }

    tableBody.innerHTML = "<tr><td colspan='12'>🔎 Đang tìm kiếm...</td></tr>";

    try {
        const response = await fetch(`${API_BASE}/search-product`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                page: 1,
                pageSize: 50,
                productID: null,
                sku: keyword,            // ✅ chỉ tìm theo SKU
                barcode: keyword,        // ✅ hoặc Barcode
                productName: "",         // 🚫 KHÔNG tìm theo tên sản phẩm
                categoryID: null,
                status: ""
            }),
        });

        if (!response.ok) throw new Error("Không thể tìm kiếm sản phẩm!");

        const result = await response.json();
        renderProducts(result.data);
    } catch (error) {
        console.error("❌ Lỗi tìm kiếm:", error);
        tableBody.innerHTML = "<tr><td colspan='12' style='color:red;'>❌ Lỗi khi tìm kiếm!</td></tr>";
    }
}

// ✅ Hàm chống gọi API liên tục khi người dùng gõ nhanh
function debounce(func, delay) {
    let timer;
    return function (...args) {
        clearTimeout(timer);
        timer = setTimeout(() => func.apply(this, args), delay);
    };
}



// =====================================================
// 🗂️ Load danh sách Category từ SQL qua API
// =====================================================
async function loadCategories() {
  const apiCategory = "https://localhost:7092/api/category/search";
  const select = document.getElementById("searchCategory");

  try {
    // Gọi API lấy toàn bộ danh mục (pageSize = 0 để lấy hết)
    const response = await fetch(apiCategory, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        page: 1,
        pageSize: 9999999,         // ✅ lấy tất cả danh mục
        CategoryID: null,
        CategoryName: "",
        option: ""
      }),
    });

    if (!response.ok) throw new Error("Không thể tải danh mục!");

    const result = await response.json();
    const categories = result.data;

    // Làm sạch dropdown
    select.innerHTML = '<option value="">Select</option>';

    // Đổ danh sách danh mục vào dropdown
    categories.forEach(c => {
      const option = document.createElement("option");
      option.value = c.categoryID;        // ✅ backend trả "CategoryID"
      option.textContent = c.categoryName; // ✅ backend trả "CategoryName"
      select.appendChild(option);
    });


    new Choices(select, {
        searchEnabled: true,
        itemSelectText: "",
        shouldSort: false,
        allowHTML: true
    });



  } catch (error) {
    console.error("❌ Lỗi khi tải danh mục:", error);
    select.innerHTML = '<option value="">(Không tải được dữ liệu)</option>';
  }
}

// Gọi hàm khi trang load xong
window.addEventListener("DOMContentLoaded", loadCategories);
