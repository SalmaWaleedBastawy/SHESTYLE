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


/* ---------- Check Admin ---------- */

if (!isset($_SESSION["Role"]) || $_SESSION["Role"] != "Admin")
{
    echo json_encode([
        "ok" => false,
        "error" => "Access denied"
    ]);

    exit;
}


/* ==========================================================
   GET PRODUCTS
   ========================================================== */

if ($_SERVER["REQUEST_METHOD"] == "GET")
{
    $sql = "SELECT
                ProductID,
                ProductName,
                Description,
                Price,
                OriginalPrice,
                Stock,
                CategoryID,
                IsActive
            FROM Products
            ORDER BY ProductID DESC";

    $stmt = $con->prepare($sql);
    $stmt->execute();

    $products = $stmt->fetchAll();


    echo json_encode([
        "ok" => true,
        "products" => $products
    ]);

    exit;
}


/* ==========================================================
   POST ACTION
   ========================================================== */

if ($_SERVER["REQUEST_METHOD"] == "POST")
{
    $action = $_POST["action"] ?? "";


    /* ======================================================
       ADD PRODUCT
       ====================================================== */

    if ($action == "add")
    {
        $name = trim($_POST["productName"] ?? "");
        $description = trim($_POST["description"] ?? "");
        $price = $_POST["price"] ?? "";
        $originalPrice = $_POST["originalPrice"] ?? "";
        $stock = $_POST["stock"] ?? "";
        $categoryID = $_POST["categoryID"] ?? "";


        if ($name == "" || $price == "" || $stock == "" || $categoryID == "")
        {
            echo json_encode([
                "ok" => false,
                "error" => "Please fill all required fields"
            ]);

            exit;
        }


        $sql = "INSERT INTO Products
                (
                    ProductName,
                    Description,
                    Price,
                    OriginalPrice,
                    Stock,
                    CategoryID,
                    IsActive
                )
                VALUES (?, ?, ?, ?, ?, ?, 1)";

        $stmt = $con->prepare($sql);

        $stmt->execute([
            $name,
            $description,
            $price,
            $originalPrice == "" ? null : $originalPrice,
            $stock,
            $categoryID
        ]);


        echo json_encode([
            "ok" => true,
            "message" => "Product added successfully"
        ]);

        exit;
    }


    /* ======================================================
       UPDATE PRODUCT
       ====================================================== */

    if ($action == "update")
    {
        $productID = $_POST["productID"] ?? "";

        $name = trim($_POST["productName"] ?? "");
        $description = trim($_POST["description"] ?? "");
        $price = $_POST["price"] ?? "";
        $originalPrice = $_POST["originalPrice"] ?? "";
        $stock = $_POST["stock"] ?? "";
        $categoryID = $_POST["categoryID"] ?? "";


        if (
            $productID == "" ||
            $name == "" ||
            $price == "" ||
            $stock == "" ||
            $categoryID == ""
        )
        {
            echo json_encode([
                "ok" => false,
                "error" => "Please fill all required fields"
            ]);

            exit;
        }


        $sql = "UPDATE Products
                SET
                    ProductName = ?,
                    Description = ?,
                    Price = ?,
                    OriginalPrice = ?,
                    Stock = ?,
                    CategoryID = ?
                WHERE ProductID = ?";

        $stmt = $con->prepare($sql);

        $stmt->execute([
            $name,
            $description,
            $price,
            $originalPrice == "" ? null : $originalPrice,
            $stock,
            $categoryID,
            $productID
        ]);


        echo json_encode([
            "ok" => true,
            "message" => "Product updated successfully"
        ]);

        exit;
    }


    /* ======================================================
       DELETE / DEACTIVATE PRODUCT
       ====================================================== */

    if ($action == "delete")
    {
        $productID = $_POST["productID"] ?? "";


        if ($productID == "")
        {
            echo json_encode([
                "ok" => false,
                "error" => "Product ID is required"
            ]);

            exit;
        }


        /*
         * We deactivate instead of deleting because
         * the product may already exist in OrderItems.
         */

        $sql = "UPDATE Products
                SET IsActive = 0
                WHERE ProductID = ?";

        $stmt = $con->prepare($sql);

        $stmt->execute([
            $productID
        ]);


        echo json_encode([
            "ok" => true,
            "message" => "Product deactivated successfully"
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