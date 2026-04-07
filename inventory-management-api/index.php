<?php

require 'config/database.php';
require 'controllers/ProductController.php';
require 'controllers/SupplierController.php';
require 'controllers/StockController.php';
require 'services/ApiService.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

switch ($action) {

    // PRODUCTS
    case 'products':
        handleProducts($pdo, $method);
        break;

    case 'products-with-suppliers':
        getProductsWithSuppliers($pdo);
        break;

    // SUPPLIERS
    case 'suppliers':
        handleSuppliers($pdo, $method);
        break;

    // STOCK
    case 'stock':
        handleStock($pdo, $method);
        break;

    // SUMMARY
    case 'summary-total-products':
        getTotalProducts($pdo);
        break;

    case 'summary-stock':
        getStockSummary($pdo);
        break;

    // API INTEGRATION
    case 'external-products':
        getExternalProducts();
        break;

    default:
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Invalid endpoint"
        ]);
}
function getTotalProducts($pdo) {
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM products");
    echo json_encode($stmt->fetch(PDO::FETCH_ASSOC));
}

function getStockSummary($pdo) {
    $stmt = $pdo->query("
        SELECT product_id,
        SUM(CASE WHEN movement_type='IN' THEN quantity ELSE -quantity END) as stock
        FROM stock_movements
        GROUP BY product_id
    ");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}