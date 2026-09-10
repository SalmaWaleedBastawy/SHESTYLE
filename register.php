<?php

require_once("database.php");

header("Content-Type: application/json; charset=UTF-8");

$con = db_get_connect();


if ($_SERVER['REQUEST_METHOD'] == "POST" && isset($_POST['register'])) {

    $uname = trim($_POST['uname']);
    $uemail = trim($_POST['uemail']);
    $upass = trim($_POST['upass']);
    $cupass = trim($_POST['cupass']);


    // ================= VALIDATE NAME =================

    if (empty($uname)) {
        echo json_encode([
            "ok" => false,
            "error" => "name required"
        ]);
        exit;
    }

    if (!preg_match("/^[a-zA-Z ]+$/", $uname)) {
        echo json_encode([
            "ok" => false,
            "error" => "uname must be letters only"
        ]);
        exit;
    }

    if (strlen($uname) < 3 || strlen($uname) > 20) {
        echo json_encode([
            "ok" => false,
            "error" => "user name must be greater than 3 letters and less than 20 letters"
        ]);
        exit;
    }


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

    if (empty($upass) || empty($cupass)) {
        echo json_encode([
            "ok" => false,
            "error" => "user password required"
        ]);
        exit;
    }

    if ($upass !== $cupass) {
        echo json_encode([
            "ok" => false,
            "error" => "password not match"
        ]);
        exit;
    }

    if (!preg_match(
        "/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).{8,}$/",
        $upass
    )) {
        echo json_encode([
            "ok" => false,
            "error" => "password must contain one lowercase letter, one uppercase letter, digit, special character and length 8"
        ]);
        exit;
    }


    // ================= CHECK EMAIL =================

    $sql = "SELECT UserID
            FROM Users
            WHERE Email = ?";

    $stmt = $con->prepare($sql);
    $stmt->execute([$uemail]);

    if ($stmt->fetch()) {
        echo json_encode([
            "ok" => false,
            "error" => "Email already exists"
        ]);
        exit;
    }


    // ================= HASH PASSWORD =================

    $passwordHash = password_hash($upass, PASSWORD_DEFAULT);


    // ================= INSERT USER =================

    $sql = "INSERT INTO Users
            (FullName, Email, PasswordHash)
            VALUES (?, ?, ?)";

    $stmt = $con->prepare($sql);

    $stmt->execute([
        $uname,
        $uemail,
        $passwordHash
    ]);


    // ================= SUCCESS =================

    echo json_encode([
        "ok" => true,
        "message" => "Account created successfully!"
    ]);

    exit;

} else {

    header("Location: register.html");
    exit;

}

?>