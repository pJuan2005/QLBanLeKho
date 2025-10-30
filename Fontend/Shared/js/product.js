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
            <td>${p.productID}</td>
            <td>${p.sku || ""}</td>
            <td>${p.barcode || ""}</td>
            <td>${p.productName || ""}</td>
            <td>${p.categoryID ?? ""}</td>
            <td>${p.unit || ""}</td>
            <td>${p.minStock}</td>
            <td><span class="stock ${p.quantity < p.minStock ? "low" : "good"}">${p.quantity}</span></td>
            <td>${p.vatRate ?? 0}</td>
            <td><span class="status ${p.status === "Active" ? "active" : ""}">${p.status}</span></td>
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

// // 🔹 6. Thêm sản phẩm
// addBtn.addEventListener("click", () => {
//     editingProductId = null;
//     modalTitle.textContent = "➕ Thêm sản phẩm";
//     form.reset();
//     productModal.style.display = "flex";
// });

// // 🔹 7. Sửa sản phẩm
// async function openEditModal(id) {
//     try {
//         const res = await fetch(`${API_BASE}/get-product/${id}`);
//         if (!res.ok) throw new Error("Không tìm thấy sản phẩm");
//         const p = await res.json();

//         editingProductId = id;
//         modalTitle.textContent = "✏️ Sửa sản phẩm";
//         form.sku.value = p.sku || "";
//         form.barcode.value = p.barcode || "";
//         form.productName.value = p.productName || "";
//         form.categoryID.value = p.categoryID || "";
//         form.unit.value = p.unit || "";
//         form.minStock.value = p.minStock || 0;
//         form.quantity.value = p.quantity || 0;
//         form.vatRate.value = p.vatRate || 0;
//         form.status.value = p.status || "Active";
//         form.image.value = p.image || "";

//         productModal.style.display = "flex";
//     } catch {
//         alert("❌ Không thể tải thông tin sản phẩm!");
//     }
// }


// // 🔹 8. Đóng modal thêm/sửa
// closeModalBtn.addEventListener("click", closeProductModal);
// function closeProductModal() {
//     productModal.style.display = "none";
//     form.reset();
//     editingProductId = null;
// }


// // 🔹 9. Submit form
// form.addEventListener("submit", async e => {
//     e.preventDefault();
//     const product = Object.fromEntries(new FormData(form).entries());
//     product.categoryID = parseInt(product.categoryID) || null;
//     product.minStock = parseInt(product.minStock) || 0;
//     product.quantity = parseInt(product.quantity) || 0;
//     product.vatRate = parseFloat(product.vatRate) || 0;

//     try {
//         // 🔍 Bước 1: Kiểm tra trùng SKU hoặc Barcode
//         const checkResponse = await fetch(`${API_BASE}/search-product`, {
//             method: "POST",
//             headers: { "Content-Type": "application/json" },
//             body: JSON.stringify({
//                 page: 1,
//                 pageSize: 1,
//                 sku: product.sku,
//                 barcode: product.barcode,
//                 productName: "",
//                 categoryID: null,
//                 status: ""
//             }),
//         });

//         const checkResult = await checkResponse.json();

//         // 🔸 Nếu có sản phẩm trùng SKU hoặc Barcode
//         if (checkResult.data && checkResult.data.length > 0 && !editingProductId) {
//             const exist = checkResult.data[0];
//             if (exist.sku === product.sku) {
//                 alert("❌ SKU này đã tồn tại trong hệ thống!");
//                 return;
//             }
//             if (exist.barcode === product.barcode && product.barcode !== "") {
//                 alert("❌ Barcode này đã tồn tại trong hệ thống!");
//                 return;
//             }
//         }

//         const url = editingProductId
//             ? `${API_BASE}/update-product/${editingProductId}`
//             : `${API_BASE}/create-product`;

//         const method = editingProductId ? "PUT" : "POST";
//         const res = await fetch(url, {
//             method,
//             headers: { "Content-Type": "application/json" },
//             body: JSON.stringify(product)
//         });

//         if (!res.ok) throw new Error();
//         alert("✅ Lưu sản phẩm thành công!");
//         closeProductModal();
//         loadProducts();
//     } catch {
//         alert("❌ Lỗi khi lưu sản phẩm!");
//     }
// })

// 🔹 10. Tải danh sách khi mở trang
window.addEventListener("DOMContentLoaded", loadProducts);
