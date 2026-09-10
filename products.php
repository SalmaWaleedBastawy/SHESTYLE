<?php

require_once("database.php");

header("Content-Type: application/json; charset=UTF-8");

$con = db_get_connect();

if ($_SERVER["REQUEST_METHOD"] == "GET")
{
    // Get one product by ProductID
    if (isset($_GET["id"]))
    {
        $id = $_GET["id"];

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
                WHERE ProductID = ?
                AND IsActive = 1";

        $stmt = $con->prepare($sql);
        $stmt->execute([$id]);

        $product = $stmt->fetch();

        if ($product)
        {
            echo json_encode([
                "ok" => true,
                "product" => $product
            ]);
        }
        else
        {
            echo json_encode([
                "ok" => false,
                "error" => "Product not found"
            ]);
        }

        exit;
    }


    // Get one product by ProductName
    if (isset($_GET["name"]))
    {
        $name = $_GET["name"];

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
                WHERE ProductName = ?
                AND IsActive = 1";

        $stmt = $con->prepare($sql);
        $stmt->execute([$name]);

        $product = $stmt->fetch();

        if ($product)
        {
            echo json_encode([
                "ok" => true,
                "product" => $product
            ]);
        }
        else
        {
            echo json_encode([
                "ok" => false,
                "error" => "Product not found"
            ]);
        }

        exit;
    }


    // Get all products
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
            WHERE IsActive = 1
            ORDER BY ProductID";

    $stmt = $con->prepare($sql);
    $stmt->execute();

    $products = $stmt->fetchAll();

    echo json_encode([
        "ok" => true,
        "products" => $products
    ]);

    exit;
}


echo json_encode([
    "ok" => false,
    "error" => "Invalid request"
]);

exit;

?>