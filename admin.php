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
   TOTAL ORDERS
   ========================================================== */

$sql = "SELECT COUNT(*) AS TotalOrders
        FROM Orders";

$stmt = $con->prepare($sql);
$stmt->execute();

$totalOrders = $stmt->fetch()["TotalOrders"];


/* ==========================================================
   TOTAL PRODUCTS
   ========================================================== */

$sql = "SELECT COUNT(*) AS TotalProducts
        FROM Products
        WHERE IsActive = 1";

$stmt = $con->prepare($sql);
$stmt->execute();

$totalProducts = $stmt->fetch()["TotalProducts"];


/* ==========================================================
   TOTAL USERS
   ========================================================== */

$sql = "SELECT COUNT(*) AS TotalUsers
        FROM Users";

$stmt = $con->prepare($sql);
$stmt->execute();

$totalUsers = $stmt->fetch()["TotalUsers"];


/* ==========================================================
   TOTAL SALES
   ========================================================== */

$sql = "SELECT ISNULL(SUM(TotalAmount), 0) AS TotalSales
        FROM Orders
        WHERE Status != 'Cancelled'";

$stmt = $con->prepare($sql);
$stmt->execute();

$totalSales = $stmt->fetch()["TotalSales"];


/* ==========================================================
   RECENT ORDERS
   ========================================================== */

$sql = "SELECT TOP 5
            OrderID,
            OrderNumber,
            FullName,
            TotalAmount,
            OrderDate,
            Status
        FROM Orders
        ORDER BY OrderDate DESC";

$stmt = $con->prepare($sql);
$stmt->execute();

$recentOrders = $stmt->fetchAll();


/* ==========================================================
   TOP PRODUCTS
   ========================================================== */

$sql = "SELECT TOP 5
            oi.ProductID,
            oi.ProductName,
            SUM(oi.Quantity) AS SoldQuantity
        FROM OrderItems oi
        INNER JOIN Orders o
            ON oi.OrderID = o.OrderID
        WHERE o.Status != 'Cancelled'
        GROUP BY
            oi.ProductID,
            oi.ProductName
        ORDER BY SoldQuantity DESC";

$stmt = $con->prepare($sql);
$stmt->execute();

$topProducts = $stmt->fetchAll();


/* ==========================================================
   RESULT
   ========================================================== */

echo json_encode([
    "ok" => true,

    "stats" => [
        "orders" => (int)$totalOrders,
        "products" => (int)$totalProducts,
        "users" => (int)$totalUsers,
        "sales" => (float)$totalSales
    ],

    "recentOrders" => $recentOrders,

    "topProducts" => $topProducts
]);

exit;

?>