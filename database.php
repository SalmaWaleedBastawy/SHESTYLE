<?php

function db_get_connect()
{
    try
    {
        $con = new PDO(
            "sqlsrv:Server=localhost\SQLEXPRESS;Database=Shestyle;TrustServerCertificate=true"
        );

        $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $con->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

        return $con;
    }
    catch (PDOException $e)
    {
        die($e->getMessage());
    }
}

?>