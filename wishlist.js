/* ==========================================================================
   SHESTYLE — wishlist.js
   Wishlist connected to Database
   ========================================================================== */

const WISHLIST_KEY = "shestyle_wishlist";

var wishlistDbIds = [];


/* ==========================================================
   Local Storage
   ========================================================== */

function getWishlist() {

    try {

        return JSON.parse(
            localStorage.getItem(WISHLIST_KEY) || "[]"
        );

    } catch (e) {

        return [];

    }
}


function saveWishlist(list) {

    localStorage.setItem(
        WISHLIST_KEY,
        JSON.stringify(list)
    );

}


/* ==========================================================
   Get Database Product ID
   ========================================================== */

function getProductDbId(id) {

    /* If ID is already a number */

    if (!isNaN(id)) {
        return Number(id);
    }


    /* Find product in PRODUCTS */

    if (typeof PRODUCTS !== "undefined") {

        var product = PRODUCTS.find(function (p) {

            return p.id === id;

        });


        if (product && product.dbId) {
            return Number(product.dbId);
        }

    }


    return null;
}


/* ==========================================================
   Check Wishlist
   ========================================================== */

function isInWishlist(id) {

    var list = getWishlist();

    return list.indexOf(id) !== -1;

}


/* ==========================================================
   Load Wishlist From Database
   ========================================================== */

function loadWishlistFromDatabase() {

    fetch("backend/wishlist.php")

        .then(function (response) {

            return response.json();

        })

        .then(function (result) {

            if (!result.ok) {

                return;

            }


            wishlistDbIds = result.wishlist || [];


            /*
             * Convert DB ProductID
             * to frontend product id
             */

            if (typeof PRODUCTS !== "undefined") {

                var frontendWishlist = [];


                PRODUCTS.forEach(function (product) {

                    if (!product.dbId) {
                        return;
                    }


                    if (
                        wishlistDbIds.indexOf(
                            Number(product.dbId)
                        ) !== -1
                    ) {

                        frontendWishlist.push(product.id);

                    }

                });


                saveWishlist(frontendWishlist);


                /*
                 * Tell the page that wishlist
                 * has been loaded from database.
                 */

                document.dispatchEvent(
                    new Event("wishlistUpdated")
                );

            }

        })

        .catch(function (error) {

            console.log(
                "Wishlist database error:",
                error
            );

        });

}


/* ==========================================================
   Add / Remove Wishlist
   ========================================================== */

function toggleWishlist(id) {

    var list = getWishlist();

    var idx = list.indexOf(id);

    var dbProductId = getProductDbId(id);


    /* ======================================================
       REMOVE
       ====================================================== */

    if (idx !== -1) {

        list.splice(idx, 1);

        saveWishlist(list);


        if (dbProductId) {

            var formData = new FormData();

            formData.append("action", "remove");
            formData.append(
                "productID",
                dbProductId
            );


            fetch("backend/wishlist.php", {

                method: "POST",
                body: formData

            })

            .then(function (response) {

                return response.json();

            })

            .then(function (result) {

                if (!result.ok) {

                    console.log(result.error);

                }

            })

            .catch(function (error) {

                console.log(
                    "Wishlist remove error:",
                    error
                );

            });

        }


        return false;

    }


    /* ======================================================
       ADD
       ====================================================== */

    list.push(id);

    saveWishlist(list);


    if (dbProductId) {

        var formData = new FormData();

        formData.append("action", "add");
        formData.append(
            "productID",
            dbProductId
        );


        fetch("backend/wishlist.php", {

            method: "POST",
            body: formData

        })

        .then(function (response) {

            return response.json();

        })

        .then(function (result) {

            if (!result.ok) {

                console.log(result.error);

            }

        })

        .catch(function (error) {

            console.log(
                "Wishlist add error:",
                error
            );

        });

    }


    return true;

}


/* ==========================================================