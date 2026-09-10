document.addEventListener("DOMContentLoaded", async function () {

    const params = new URLSearchParams(window.location.search);
    const productId = params.get("id");

    if (!productId) {
        console.log("Product ID not found");
        return;
    }

    // Get the product from the frontend data
    const oldProduct = PRODUCTS.find(p => p.id === productId);

    if (!oldProduct) {
        console.log("Frontend product not found");
        return;
    }

    try {

        // Get the product from database using its name
        const response = await fetch(
            "backend/products.php?name=" +
            encodeURIComponent(oldProduct.name)
        );

        const result = await response.json();

        if (!result.ok) {
            console.log(result.error);
            return;
        }

        const dbProduct = result.product;

        // Keep frontend data
        // and update database data
        const product = oldProduct;

        product.dbId = dbProduct.ProductID;
        product.name = dbProduct.ProductName;
        product.description = dbProduct.Description;
        product.price = Number(dbProduct.Price);

        product.originalPrice =
            dbProduct.OriginalPrice !== null
                ? Number(dbProduct.OriginalPrice)
                : null;

        product.stock = Number(dbProduct.Stock);

        // -----------------------------
        // Product title
        // -----------------------------

        const titleElement = document.getElementById("pdTitle");

        if (titleElement) {
            titleElement.textContent = product.name;
        }

        // -----------------------------
        // Page title
        // -----------------------------

        const pageTitle = document.getElementById("pdPageTitle");

        if (pageTitle) {
            pageTitle.textContent =
                product.name + " — SHESTYLE";
        }

        // -----------------------------
        // Price
        // -----------------------------

        const priceElement =
            document.getElementById("pdPrice");

        if (priceElement) {
            priceElement.textContent =
                "$" + product.price.toFixed(2);
        }

        // -----------------------------
        // Original Price
        // -----------------------------

        const originalPriceElement =
            document.getElementById("pdOriginalPrice");

        if (originalPriceElement) {

            if (product.originalPrice !== null) {

                originalPriceElement.textContent =
                    "$" + product.originalPrice.toFixed(2);

                originalPriceElement.style.display = "";

            } else {

                originalPriceElement.textContent = "";
                originalPriceElement.style.display = "none";
            }
        }

        // -----------------------------
        // Description
        // -----------------------------

        const descriptionElement =
            document.getElementById("pdDescription");

        if (descriptionElement) {
            descriptionElement.textContent =
                product.description || "";
        }

        // -----------------------------
        // Stock
        // -----------------------------

        const stockElement =
            document.getElementById("pdStock");

        if (stockElement) {

            if (product.stock > 0) {

                stockElement.textContent =
                    product.stock + " items available";

            } else {

                stockElement.textContent =
                    "Out of stock";
            }
        }

        // -----------------------------
        // Keep existing product details
        // -----------------------------

        if (typeof renderProductImages === "function") {
            renderProductImages(product);
        }

        if (typeof renderColors === "function") {
            renderColors(product);
        }

        if (typeof renderSizes === "function") {
            renderSizes(product);
        }

        if (typeof renderRating === "function") {
            renderRating(product);
        }

        if (typeof renderProductDetails === "function") {
            renderProductDetails(product);
        }

        // -----------------------------
        // Add to cart
        // -----------------------------

        const addButton =
            document.querySelector("[data-add-to-cart]");

        if (addButton) {

            addButton.addEventListener("click", function () {

                if (product.stock <= 0) {
                    alert("This product is out of stock.");
                    return;
                }

                const quantityElement =
                    document.getElementById("quantity");

                let quantity = 1;

                if (quantityElement) {
                    quantity =
                        Number(quantityElement.value) || 1;
                }

                // Use database ProductID
                addToCart(product.id, quantity);

            });
        }

    }
    catch (error) {

        console.error(
            "Error loading product:",
            error
        );

    }

});