<?php

require_once("database.php");

try {

    $con = db_get_connect();

    echo "DATABASE CONNECTION SUCCESSFUL!";

} catch (PDOException $e) {

    echo "DATABASE CONNECTION FAILED!";
    echo "<br>";
    echo $e->getMessage();

}

?>