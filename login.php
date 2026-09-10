<?php

require_once("database.php");

header("Content-Type: application/json; charset=UTF-8");

$con = db_get_connect();


if ($_SERVER['REQUEST_METHOD'] == "POST") {

    $uemail = trim($_POST['email']);
    $upass = trim($_POST['password']);


    // ================= VALIDATE EMAIL =================

    if (empty($uemail)) {
        echo json_encode([
            "ok" => false,
            "error" => "user email required"
        ]);
        exit;
    }

    if (!filter_var($uemail, FILTER_VALIDATE_EMAIL)) {
        echo json_encode([
            "ok" => false,
            "error" => "user email must contain @ and ."
        ]);
        exit;
    }


    // ================= VALIDATE PASSWORD =================

    if (empty($upass)) {
        echo json_encode([
            "ok" => false,
            "error" => "user password required"
        ]);
        exit;
    }


    // ================= CHECK USER =================

    $sql = "SELECT UserID, FullName, Email, PasswordHash, Role
            FROM Users
            WHERE Email = ?";

    $stmt = $con->prepare($sql);
    $stmt->execute([$uemail]);

    $user = $stmt->fetch();


    // ================= CHECK EMAIL =================

    if (!$user) {
        echo json_encode([
            "ok" => false,
            "error" => "Invalid email or password"
        ]);
        exit;
    }


    // ================= CHECK PASSWORD =================

    if (!password_verify($upass, $user['PasswordHash'])) {
        echo json_encode([
            "ok" => false,
            "error" => "Invalid email or password"
        ]);
        exit;
    }


    // ================= LOGIN SUCCESS =================

    session_start();

    $_SESSION['UserID'] = $user['UserID'];
    $_SESSION['FullName'] = $user['FullName'];
    $_SESSION['Email'] = $user['Email'];
    $_SESSION['Role'] = $user['Role'];


    echo json_encode([
        "ok" => true,
        "user" => [
            "userID" => $user['UserID'],
            "fullName" => $user['FullName'],
            "email" => $user['Email'],
            "role" => $user['Role']
        ]
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