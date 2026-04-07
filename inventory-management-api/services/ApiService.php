<?php

function getExternalProducts() {

    $response = file_get_contents("https://fakestoreapi.com/products");

    if (!$response) {
        echo json_encode(["error" => "API request failed"]);
        return;
    }

    echo $response;
}