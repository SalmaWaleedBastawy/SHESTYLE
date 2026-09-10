<?php

require_once("database.php");

header("Content-Type: application/json; charset=UTF-8");

session_start();

$con = db_get_connect();


/* ---------- Check Login ---------- */

if (!isset($_SESSION["UserID"]))
{
    echo json_encode([
        "ok" => false,
        "error" => "Please login first"
    ]);

    exit;
}


$userID = $_SESSION["UserID"];


/* ==========================================================
   GET WISHLIST
   ========================================================== */

if ($_SERVER["REQUEST_METHOD"] == "GET")
{
    $sql = "SELECT ProductID
            FROM Wishlist
            WHERE UserID = ?";

    $stmt = $con->prepare($sql);
    $stmt->execute([$userID]);

    $items = $stmt->fetchAll();

    $wishlist = [];

    foreach ($items as $item)
    {
        $wishlist[] = $item["ProductID"];
    }

    echo json_encode([
        "ok" => true,
        "wishlist" => $wishlist
    ]);

    exit;
}


/* ==========================================================
   POST ACTION
   ========================================================== */

if ($_SERVER["REQUEST_METHOD"] == "POST")
{
    $action = $_POST["action"] ?? "";
    $productID = $_POST["productID"] ?? "";


    if ($productID == "")
    {
        echo json_encode([
            "ok" => false,
            "error" => "Product ID is required"
        ]);

        exit;
    }


    /* ---------- ADD ---------- */

    if ($action == "add")
    {
        /* Check product */

        $sql = "SELECT ProductID
                FROM Products
                WHERE ProductID = ?
                AND IsActive = 1";

        $stmt = $con->prepare($sql);
        $stmt->execute([$productID]);

        $product = $stmt->fetch();


        if (!$product)
        {
            echo json_encode([
                "ok" => false,
                "error" => "Product not found"
            ]);

            exit;
        }


        /* Check if already exists */

        $sql = "SELECT WishlistID
                FROM Wishlist
                WHERE UserID = ?
                AND ProductID = ?";

        $stmt = $con->prepare($sql);
        $stmt->execute([
            $userID,
            $productID
        ]);

        $item = $stmt->fetch();


        /* Insert */

        if (!$item)
        {
            $sql = "INSERT INTO Wishlist
                    (UserID, ProductID)
                    VALUES (?, ?)";

            $stmt = $con->prepare($sql);

            $stmt->execute([
                $userID,
                $productID
            ]);
        }


        echo json_encode([
            "ok" => true
        ]);

        exit;
    }


    /* ---------- REMOVE ---------- */

    if ($action == "remove")
    {
        $sql = "DELETE FROM Wishlist
                WHERE UserID = ?
                AND ProductID = ?";

        $stmt = $con->prepare($sql);

        $stmt->execute([
            $userID,
            $productID
        ]);


        echo json_encode([
            "ok" => true
        ]);

        exit;
    }
}


/* ---------- Invalid Request ---------- */

echo json_encode([
    "ok" => false,
    "error" => "Invalid request"
]);

exit;

?>