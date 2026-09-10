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
   GET USERS
   ========================================================== */

if ($_SERVER["REQUEST_METHOD"] == "GET")
{
    $sql = "SELECT
                UserID,
                FullName,
                Email,
                Phone,
                Address,
                Role
            FROM Users
            ORDER BY UserID DESC";

    $stmt = $con->prepare($sql);
    $stmt->execute();

    $users = $stmt->fetchAll();


    echo json_encode([
        "ok" => true,
        "users" => $users
    ]);

    exit;
}


/* ==========================================================
   UPDATE USER ROLE
   ========================================================== */

if ($_SERVER["REQUEST_METHOD"] == "POST")
{
    $action = $_POST["action"] ?? "";

    $userID = $_POST["userID"] ?? "";

    $role = $_POST["role"] ?? "";


    if ($action == "updateRole")
    {
        if ($userID == "" || $role == "")
        {
            echo json_encode([
                "ok" => false,
                "error" => "User ID and role are required"
            ]);

            exit;
        }


        $allowedRoles = [
            "User",
            "Admin"
        ];


        if (!in_array($role, $allowedRoles))
        {
            echo json_encode([
                "ok" => false,
                "error" => "Invalid role"
            ]);

            exit;
        }


        /* Prevent admin from changing their own role */

        if ($userID == $_SESSION["UserID"])
        {
            echo json_encode([
                "ok" => false,
                "error" => "You cannot change your own role"
            ]);

            exit;
        }


        $sql = "UPDATE Users
                SET Role = ?
                WHERE UserID = ?";

        $stmt = $con->prepare($sql);

        $stmt->execute([
            $role,
            $userID
        ]);


        echo json_encode([
            "ok" => true,
            "message" => "User role updated successfully"
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