<?php

function handleProducts($pdo, $method) {

    if ($method === 'GET') {

        if (isset($_GET['id'])) {

            $stmt = $pdo->prepare("SELECT * FROM products WHERE product_id = ?");
            $stmt->execute([$_GET['id']]);
            $product = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$product) {
                echo json_encode(["message" => "Product not found"]);
                return;
            }

            echo json_encode($product);

        } else {
            $stmt = $pdo->query("SELECT * FROM products");
            echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        }

    } elseif ($method === 'POST') {

        $data = json_decode(file_get_contents("php://input"), true);

        //  Validate BEFORE insert
        if (empty($data['product_name']) || empty($data['price']) || empty($data['supplier_id'])) {
            echo json_encode(["message" => "Missing required fields"]);
            return;
        }

        $stmt = $pdo->prepare("
            INSERT INTO products (product_name, price, stock, supplier_id, created_at)
            VALUES (?, ?, 0, ?, NOW())
        ");

        $stmt->execute([
            $data['product_name'],
            $data['price'],
            $data['supplier_id']
        ]);

        echo json_encode(["message" => "Product created"]);

    } elseif ($method === 'PUT') {

        //  Validate ID first
        if (!isset($_GET['id'])) {
            echo json_encode(["message" => "Product ID is required"]);
            return;
        }

        $data = json_decode(file_get_contents("php://input"), true);

        $stmt = $pdo->prepare("
            UPDATE products 
            SET product_name=?, price=?, supplier_id=? 
            WHERE product_id=?
        ");

        $stmt->execute([
            $data['product_name'],
            $data['price'],
            $data['supplier_id'],
            $_GET['id']
        ]);

        echo json_encode(["message" => "Product updated"]);

    } elseif ($method === 'DELETE') {

        //  Validate ID first
        if (!isset($_GET['id'])) {
            echo json_encode(["message" => "Product ID is required"]);
            return;
        }

        $stmt = $pdo->prepare("DELETE FROM products WHERE product_id=?");
        $stmt->execute([$_GET['id']]);

        echo json_encode(["message" => "Product deleted"]);
    }
}


function getProductsWithSuppliers($pdo) {

    $stmt = $pdo->query("
        SELECT 
            p.product_id,
            p.product_name,
            p.price,
            s.supplier_name,
            s.email,
            SUM(
                CASE 
                    WHEN sm.movement_type = 'IN' THEN sm.quantity
                    ELSE -sm.quantity
                END
            ) AS current_stock
        FROM products p
        JOIN suppliers s ON p.supplier_id = s.supplier_id
        LEFT JOIN stock_movements sm ON p.product_id = sm.product_id
        GROUP BY p.product_id
    ");

    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}