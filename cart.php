<?php

require_once("../database.php");

header("Content-Type: application/json; charset=UTF-8");

session_start();

$con = db_get_connect();


// ================= CHECK LOGIN =================

if (!isset($_SESSION['UserID'])) {

    echo json_encode([
        "ok" => false,
        "error" => "Please login first"
    ]);

    exit;
}

$userID = $_SESSION['UserID'];


// ================= CHECK ACTION =================

if ($_SERVER['REQUEST_METHOD'] == "POST" && isset($_POST['action'])) {

    $action = $_POST['action'];

    // ================= GET OR CREATE CART =================

    $sql = "SELECT CartID
            FROM Cart
            WHERE UserID = ?";

    $stmt = $con->prepare($sql);
    $stmt->execute([$userID]);

    $cart = $stmt->fetch();

    if (!$cart) {

        $sql = "INSERT INTO Cart (UserID)
                VALUES (?)";

        $stmt = $con->prepare($sql);
        $stmt->execute([$userID]);

        $sql = "SELECT CartID
                FROM Cart
                WHERE UserID = ?";

        $stmt = $con->prepare($sql);
        $stmt->execute([$userID]);

        $cart = $stmt->fetch();
    }

    $cartID = $cart['CartID'];


    // ================= FIND PRODUCT =================

    $productID = !empty($_POST['productID']) ? $_POST['productID'] : "";
    $productName = !empty($_POST['productName']) ? trim($_POST['productName']) : "";

    $product = false;

    if ($productID != "") {

        $sql = "SELECT ProductID, ProductName, Stock, IsActive
                FROM Products
                WHERE ProductID = ?";

        $stmt = $con->prepare($sql);
        $stmt->execute([$productID]);

        $product = $stmt->fetch();
    }

    if (!$product && $productName != "") {

        $sql = "SELECT ProductID, ProductName, Stock, IsActive
                FROM Products
                WHERE ProductName = ?";

        $stmt = $con->prepare($sql);
        $stmt->execute([$productName]);

        $product = $stmt->fetch();
    }


    if (!$product) {

        echo json_encode([
            "ok" => false,
            "error" => "Product not found"
        ]);

        exit;
    }


    // ================= CHECK PRODUCT =================

    if ($product['IsActive'] != 1) {

        echo json_encode([
            "ok" => false,
            "error" => "Product is not available"
        ]);

        exit;
    }


    $productID = $product['ProductID'];


    // ==================================================
    // ================= ADD TO CART ====================
    // ==================================================

    if ($action == "add") {

        $quantity = isset($_POST['quantity']) ? (int)$_POST['quantity'] : 1;

        if ($quantity < 1) {
            $quantity = 1;
        }


        // Check if product already exists in cart

        $sql = "SELECT CartItemID, Quantity
                FROM CartItems
                WHERE CartID = ? AND ProductID = ?";

        $stmt = $con->prepare($sql);
        $stmt->execute([$cartID, $productID]);

        $item = $stmt->fetch();


        if ($item) {

            $newQuantity = $item['Quantity'] + $quantity;

            if ($newQuantity > $product['Stock']) {

                echo json_encode([
                    "ok" => false,
                    "error" => "Not enough stock"
                ]);

                exit;
            }


            $sql = "UPDATE CartItems
                    SET Quantity = ?
                    WHERE CartItemID = ?";

            $stmt = $con->prepare($sql);

            $stmt->execute([
                $newQuantity,
                $item['CartItemID']
            ]);

        } else {

            if ($quantity > $product['Stock']) {

                echo json_encode([
                    "ok" => false,
                    "error" => "Not enough stock"
                ]);

                exit;
            }


            $sql = "INSERT INTO CartItems
                    (CartID, ProductID, Quantity)
                    VALUES (?, ?, ?)";

            $stmt = $con->prepare($sql);

            $stmt->execute([
                $cartID,
                $productID,
                $quantity
            ]);
        }


        echo json_encode([
            "ok" => true,
            "message" => "Product added to cart"
        ]);

        exit;
    }


    // ==================================================
    // ================= REMOVE FROM CART ===============
    // ==================================================

    if ($action == "remove") {

        $sql = "DELETE FROM CartItems
                WHERE CartID = ? AND ProductID = ?";

        $stmt = $con->prepare($sql);

        $stmt->execute([
            $cartID,
            $productID
        ]);


        echo json_encode([
            "ok" => true,
            "message" => "Product removed from cart"
        ]);

        exit;
    }


    // ==================================================
    // ================= UPDATE QUANTITY ================
    // ==================================================

    if ($action == "update") {

        $quantity = isset($_POST['quantity']) ? (int)$_POST['quantity'] : 1;

        if ($quantity < 1) {
            $quantity = 1;
        }


        if ($quantity > $product['Stock']) {

            echo json_encode([
                "ok" => false,
                "error" => "Not enough stock"
            ]);

            exit;
        }


        $sql = "UPDATE CartItems
                SET Quantity = ?
                WHERE CartID = ? AND ProductID = ?";

        $stmt = $con->prepare($sql);

        $stmt->execute([
            $quantity,
            $cartID,
            $productID
        ]);


        echo json_encode([
            "ok" => true,
            "message" => "Cart updated successfully"
        ]);

        exit;
    }


    // ================= INVALID ACTION =================

    echo json_encode([
        "ok" => false,
        "error" => "Invalid action"
    ]);

    exit;

} else {

    echo json_encode([
        "ok" => false,
        "error" => "Invalid request"
    ]);

    exit;
}

?>