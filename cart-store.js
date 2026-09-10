/* =========================================================
   SHESTYLE — cart-store.js
   SQL Server Cart + localStorage fallback for guests
   ========================================================= */

const CART_KEY = "shestyle_cart";
const CART_API = "backend/cart.php";


/* =========================================================
   LOCAL STORAGE
   ========================================================= */

function getCart() {
    try {
        return JSON.parse(localStorage.getItem(CART_KEY) || "[]");
    } catch (e) {
        return [];
    }
}


function saveCart(list) {

    localStorage.setItem(
        CART_KEY,
        JSON.stringify(list)
    );

    updateCartBadges();
}


/* =========================================================
   FIND FRONTEND PRODUCT
   ========================================================= */

function findFrontendProduct(id) {

    if (typeof PRODUCTS === "undefined") {
        return null;
    }

    for (var i = 0; i < PRODUCTS.length; i++) {

        if (PRODUCTS[i].id === id) {
            return PRODUCTS[i];
        }
    }

    return null;
}


/* =========================================================
   SEND REQUEST TO PHP
   ========================================================= */

async function cartAPI(action, data) {

    var formData = new URLSearchParams();

    formData.append("action", action);

    if (data) {

        Object.keys(data).forEach(function (key) {

            formData.append(
                key,
                data[key]
            );

        });
    }


    var response = await fetch(
        CART_API + "?action=" + encodeURIComponent(action),
        {
            method: "POST",
            headers: {
                "Content-Type":
                    "application/x-www-form-urlencoded"
            },
            body: formData,
            credentials: "include"
        }
    );


    var result = await response.json();

    return result;
}


/* =========================================================
   ADD TO CART
   ========================================================= */

async function addToCart(id, qty) {

    qty = qty || 1;


    /* Find product in frontend */

    var product = findFrontendProduct(id);


    /*
       We send ProductName too.

       Why?

       Your frontend IDs can be strings such as:

       shoes-photo-001

       while SQL Server ProductID is INT.

       The backend can therefore use the product name
       to identify the SQL product.
    */

    var productName = product
        ? product.name
        : "";


    try {

        var result = await cartAPI(
            "add",
            {
                productID:
                    product && product.dbId
                        ? product.dbId
                        : "",
                productName: productName,
                quantity: qty
            }
        );


        if (result.ok) {

            /*
               Keep localStorage updated too.
               This keeps the current frontend working.
            */

            var list = getCart();

            var item = null;

            for (var i = 0; i < list.length; i++) {

                if (list[i].id === id) {

                    item = list[i];

                    break;
                }
            }


            if (item) {

                item.qty += qty;

            } else {

                list.push({
                    id: id,
                    qty: qty
                });

            }


            saveCart(list);


            if (typeof showToast === "function") {

                showToast(
                    (product
                        ? product.name
                        : "Item") +
                    " added to cart"
                );
            }


            try {

                window.dispatchEvent(
                    new CustomEvent(
                        "shestyle:cart-updated"
                    )
                );

            } catch (e) {}


            return list;
        }


        /*
           If user isn't logged in yet,
           keep the old guest-cart behavior.
        */

        if (
            result.error ===
            "Please login first"
        ) {

            return addGuestCart(id, qty);
        }


        alert(result.error || "Unable to add product.");

        return getCart();


    } catch (error) {

        /*
           If backend isn't available,
           don't break the frontend.
        */

        console.error(
            "Cart API error:",
            error
        );

        return addGuestCart(id, qty);
    }
}


/* =========================================================
   GUEST CART
   ========================================================= */

function addGuestCart(id, qty) {

    var list = getCart();

    var item = null;


    for (var i = 0; i < list.length; i++) {

        if (list[i].id === id) {

            item = list[i];

            break;
        }
    }


    if (item) {

        item.qty += qty;

    } else {

        list.push({
            id: id,
            qty: qty
        });

    }


    saveCart(list);


    var product = findFrontendProduct(id);


    if (typeof showToast === "function") {

        showToast(
            (product
                ? product.name
                : "Item") +
            " added to cart"
        );
    }


    try {

        window.dispatchEvent(
            new CustomEvent(
                "shestyle:cart-updated"
            )
        );

    } catch (e) {}


    return list;
}


/* =========================================================
   REMOVE FROM CART
   ========================================================= */

async function removeFromCart(id) {

    var product = findFrontendProduct(id);

    var productName = product
        ? product.name
        : "";


    try {

        var result = await cartAPI(
            "remove",
            {
                productID:
                    product && product.dbId
                        ? product.dbId
                        : "",
                productName: productName
            }
        );


        /*
           If logged in and backend succeeded,
           update local cart too.
        */

        if (result.ok) {

            var list = getCart().filter(
                function (item) {

                    return item.id !== id;

                }
            );

            saveCart(list);

            return list;
        }


        if (
            result.error ===
            "Please login first"
        ) {

            return removeGuestCart(id);
        }


    } catch (error) {

        console.error(
            "Remove cart API error:",
            error
        );

        return removeGuestCart(id);
    }


    return getCart();
}


function removeGuestCart(id) {

    var list = getCart().filter(
        function (item) {

            return item.id !== id;

        }
    );

    saveCart(list);

    return list;
}


/* =========================================================
   UPDATE QUANTITY
   ========================================================= */

async function setCartQty(id, qty) {

    qty = Math.max(1, qty);


    var product = findFrontendProduct(id);

    var productName = product
        ? product.name
        : "";


    try {

        var result = await cartAPI(
            "update",
            {
                productID:
                    product && product.dbId
                        ? product.dbId
                        : "",
                productName: productName,
                quantity: qty
            }
        );


        if (result.ok) {

            var list = getCart();


            for (
                var i = 0;
                i < list.length;
                i++
            ) {

                if (list[i].id === id) {

                    list[i].qty = qty;

                    break;
                }
            }


            saveCart(list);

            return list;
        }


        if (
            result.error ===
            "Please login first"
        ) {

            return setGuestCartQty(
                id,
                qty
            );
        }


        alert(
            result.error ||
            "Unable to update quantity."
        );


    } catch (error) {

        console.error(
            "Update cart API error:",
            error
        );

        return setGuestCartQty(
            id,
            qty
        );
    }


    return getCart();
}


/* =========================================================
   GUEST QUANTITY
   ========================================================= */

function setGuestCartQty(id, qty) {

    var list = getCart();


    for (
        var i = 0;
        i < list.length;
        i++
    ) {

        if (list[i].id === id) {

            list[i].qty =
                Math.max(1, qty);

            break;
        }
    }


    saveCart(list);

    return list;
}


/* =========================================================
   CART COUNT
   ========================================================= */

function getCartCount() {

    return getCart().reduce(
        function (sum, item) {

            return sum + item.qty;

        },
        0
    );
}


function updateCartBadges() {

    var n = getCartCount();


    document
        .querySelectorAll(".cart-count")
        .forEach(
            function (el) {

                el.textContent = n;

            }
        );
}


/* =========================================================
   INITIALIZE
   ========================================================= */

document.addEventListener(
    "DOMContentLoaded",
    function () {

        updateCartBadges();

    }
);