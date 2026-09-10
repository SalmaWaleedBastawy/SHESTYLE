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


/* ---------- Get Categories ---------- */

$sql = "SELECT CategoryID, CategoryName
        FROM Categories
        ORDER BY CategoryName";

$stmt = $con->prepare($sql);
$stmt->execute();

$categories = $stmt->fetchAll();


echo json_encode([
    "ok" => true,
    "categories" => $categories
]);

exit;

?>