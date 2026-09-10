<?php

require_once("database.php");

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


// ================= CHECK REQUEST =================

if ($_SERVER['REQUEST_METHOD'] != "POST" || !isset($_POST['action'])) {

    echo json_encode([
        "ok" => false,
        "error" => "Invalid request"
    ]);

    exit;
}


$action = $_POST['action'];


// ================= CHECK ACTION =================

if ($action != "create") {

    echo json_encode([
        "ok" => false,
        "error" => "Invalid action"
    ]);

    exit;
}


// ================= GET SHIPPING DATA =================

$fullName = trim($_POST['fullName'] ?? "");
$email = trim($_POST['email'] ?? "");
$address = trim($_POST['address'] ?? "");
$city = trim($_POST['city'] ?? "");
$postalCode = trim($_POST['postalCode'] ?? "");
$phone = trim($_POST['phone'] ?? "");


// ================= VALIDATE DATA =================

if (empty($fullName)) {

    echo json_encode([
        "ok" => false,
        "error" => "Full name required"
    ]);

    exit;
}


if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {

    echo json_encode([
        "ok" => false,
        "error" => "Valid email required"
    ]);

    exit;
}


if (empty($address)) {

    echo json_encode([
        "ok" => false,
        "error" => "Address required"
    ]);

    exit;
}


if (empty($city)) {

    echo json_encode([
        "ok" => false,
        "error" => "City required"
    ]);

    exit;
}


if (empty($phone)) {

    echo json_encode([
        "ok" => false,
        "error" => "Phone required"
    ]);

    exit;
}


// ================= START TRANSACTION =================

try {

    $con->beginTransaction();


    // ================= GET USER CART =================

    $sql = "SELECT CartID
            FROM Cart
            WHERE UserID = ?";

    $stmt = $con->prepare($sql);
    $stmt->execute([$userID]);

    $cart = $stmt->fetch();


    if (!$cart) {

        throw new Exception("Cart is empty");
    }


    $cartID = $cart['CartID'];


    // ================= GET CART ITEMS =================

    $sql = "SELECT
                ci.ProductID,
                ci.Quantity,
                p.ProductName,
                p.Price,
                p.Stock,
                p.IsActive
            FROM CartItems ci
            INNER JOIN Products p
                ON ci.ProductID = p.ProductID
            WHERE ci.CartID = ?";

    $stmt = $con->prepare($sql);
    $stmt->execute([$cartID]);

    $items = $stmt->fetchAll();


    if (count($items) == 0) {

        throw new Exception("Cart is empty");
    }


    // ================= CALCULATE SUBTOTAL =================

    $subtotal = 0;


    foreach ($items as $item) {

        if ($item['IsActive'] != 1) {

            throw new Exception(
                "Product " . $item['ProductName'] . " is not available"
            );
        }


        if ($item['Quantity'] > $item['Stock']) {

            throw new Exception(
                "Not enough stock for " . $item['ProductName']
            );
        }


        $subtotal += $item['Price'] * $item['Quantity'];
    }


    // ================= CALCULATE SHIPPING =================

    if ($subtotal >= 59) {

        $shippingCost = 0;

    } else {

        $shippingCost = 5.99;
    }


    // ================= CALCULATE TOTAL =================

    $totalAmount = $subtotal + $shippingCost;


    // ================= CREATE ORDER NUMBER =================

    $orderNumber = "SHE-" . date("YmdHis") . "-" . $userID;


    // ================= INSERT ORDER =================

    $sql = "INSERT INTO Orders
            (
                OrderNumber,
                UserID,
                FullName,
                Email,
                Phone,
                Address,
                City,
                PostalCode,
                Subtotal,
                ShippingCost,
                TotalAmount,
                PaymentMethod
            )
            VALUES
            (
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
            )";

    $stmt = $con->prepare($sql);

    $stmt->execute([
        $orderNumber,
        $userID,
        $fullName,
        $email,
        $phone,
        $address,
        $city,
        $postalCode,
        $subtotal,
        $shippingCost,
        $totalAmount,
        "Card"
    ]);


    // ================= GET ORDER ID =================

    $sql = "SELECT OrderID
            FROM Orders
            WHERE OrderNumber = ?";

    $stmt = $con->prepare($sql);
    $stmt->execute([$orderNumber]);

    $order = $stmt->fetch();


    if (!$order) {

        throw new Exception("Could not create order");
    }


    $orderID = $order['OrderID'];


    // ================= INSERT ORDER ITEMS =================

    foreach ($items as $item) {

        $lineTotal = $item['Price'] * $item['Quantity'];


        $sql = "INSERT INTO OrderItems
                (
                    OrderID,
                    ProductID,
                    ProductName,
                    UnitPrice,
                    Quantity,
                    LineTotal
                )
                VALUES
                (
                    ?, ?, ?, ?, ?, ?
                )";

        $stmt = $con->prepare($sql);

        $stmt->execute([
            $orderID,
            $item['ProductID'],
            $item['ProductName'],
            $item['Price'],
            $item['Quantity'],
            $lineTotal
        ]);
    }


    // ================= CREATE PAYMENT =================

    $sql = "INSERT INTO Payments
            (
                OrderID,
                PaymentMethod,
                PaymentStatus,
                Amount
            )
            VALUES
            (
                ?, ?, ?, ?
            )";

    $stmt = $con->prepare($sql);

    $stmt->execute([
        $orderID,
        "Card",
        "Pending",
        $totalAmount
    ]);


    // ================= UPDATE STOCK =================

    foreach ($items as $item) {

        $sql = "UPDATE Products
                SET Stock = Stock - ?
                WHERE ProductID = ?
                AND Stock >= ?";

        $stmt = $con->prepare($sql);

        $stmt->execute([
            $item['Quantity'],
            $item['ProductID'],
            $item['Quantity']
        ]);


        if ($stmt->rowCount() == 0) {

            throw new Exception(
                "Not enough stock for " . $item['ProductName']
            );
        }
    }


    // ================= CLEAR CART =================

    $sql = "DELETE FROM CartItems
            WHERE CartID = ?";

    $stmt = $con->prepare($sql);

    $stmt->execute([$cartID]);


    // ================= COMMIT =================

    $con->commit();


    // ================= SUCCESS =================

    echo json_encode([
        "ok" => true,
        "message" => "Order created successfully",
        "order" => [
            "orderId" => $orderID,
            "orderNumber" => $orderNumber,
            "subtotal" => $subtotal,
            "shipping" => $shippingCost,
            "total" => $totalAmount
        ]
    ]);

    exit;


} catch (Exception $e) {

    // ================= ROLLBACK =================

    if ($con->inTransaction()) {
        $con->rollBack();
    }


    echo json_encode([
        "ok" => false,
        "error" => $e->getMessage()
    ]);

    exit;
}

?>