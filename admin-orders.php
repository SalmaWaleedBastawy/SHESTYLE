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
   GET ORDERS
   ========================================================== */

if ($_SERVER["REQUEST_METHOD"] == "GET")
{
    $sql = "SELECT
                o.OrderID,
                o.OrderNumber,
                o.FullName,
                o.Email,
                o.TotalAmount,
                o.OrderDate,
                o.Status,
                COUNT(oi.OrderItemID) AS ItemsCount
            FROM Orders o
            LEFT JOIN OrderItems oi
                ON o.OrderID = oi.OrderID
            GROUP BY
                o.OrderID,
                o.OrderNumber,
                o.FullName,
                o.Email,
                o.TotalAmount,
                o.OrderDate,
                o.Status
            ORDER BY o.OrderDate DESC";

    $stmt = $con->prepare($sql);
    $stmt->execute();

    $orders = $stmt->fetchAll();


    echo json_encode([
        "ok" => true,
        "orders" => $orders
    ]);

    exit;
}


/* ==========================================================
   UPDATE ORDER STATUS
   ========================================================== */

if ($_SERVER["REQUEST_METHOD"] == "POST")
{
    $action = $_POST["action"] ?? "";

    $orderID = $_POST["orderID"] ?? "";

    $status = $_POST["status"] ?? "";


    if ($action == "updateStatus")
    {
        if ($orderID == "" || $status == "")
        {
            echo json_encode([
                "ok" => false,
                "error" => "Order ID and status are required"
            ]);

            exit;
        }


        $allowedStatuses = [
            "Pending",
            "Processing",
            "Shipped",
            "Delivered",
            "Cancelled"
        ];


        if (!in_array($status, $allowedStatuses))
        {
            echo json_encode([
                "ok" => false,
                "error" => "Invalid order status"
            ]);

            exit;
        }


        $sql = "UPDATE Orders
                SET Status = ?
                WHERE OrderID = ?";

        $stmt = $con->prepare($sql);

        $stmt->execute([
            $status,
            $orderID
        ]);


        echo json_encode([
            "ok" => true,
            "message" => "Order status updated successfully"
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