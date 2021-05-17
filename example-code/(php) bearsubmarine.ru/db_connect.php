<?php
    $mysqli = new mysqli("127.0.0.1", "bear", "pa$$word", "bearsubmarine");

    if ($mysqli->connect_errno) {
	printf("Соединение не удалось: %s\n", $mysqli->connect_error);
	exit();
    }

    $mysqli->set_charset("utf8");
?>