<?php

function handleStock($pdo, $method) {

    header("Content-Type: application/json");

    try {

        if ($method === 'GET') {

            $stmt = $pdo->query("
                SELECT p.product_name, sm.movement_type, sm.quantity, sm.created_at
                FROM stock_movements sm
                JOIN products p ON sm.product_id = p.product_id
            ");

            echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        }

        elseif ($method === 'POST') {

            $data = json_decode(file_get_contents("php://input"), true);

            //  Validation
            if (
                empty($data['product_id']) ||
                empty($data['movement_type']) ||
                empty($data['quantity'])
            ) {
                http_response_code(400);
                echo json_encode(["message" => "Required fields are missing"]);
                return;
            }

            //  Validate movement type
            if (!in_array($data['movement_type'], ['IN', 'OUT'])) {
                http_response_code(400);
                echo json_encode(["message" => "Invalid movement type"]);
                return;
            }

            //  Optional: Check stock before OUT
            if ($data['movement_type'] === 'OUT') {
                $check = $pdo->prepare("SELECT stock FROM products WHERE product_id = ?");
                $check->execute([$data['product_id']]);
                $product = $check->fetch(PDO::FETCH_ASSOC);

                if ($product && $product['stock'] < $data['quantity']) {
                    http_response_code(400);
                    echo json_encode(["message" => "Insufficient stock"]);
                    return;
                }
            }

            $stmt = $pdo->prepare("
                INSERT INTO stock_movements (product_id, movement_type, quantity, remarks, created_at)
                VALUES (?, ?, ?, ?, NOW())
            ");

            $stmt->execute([
                $data['product_id'],
                $data['movement_type'],
                $data['quantity'],
                $data['remarks'] ?? null
            ]);

            echo json_encode(["message" => "Stock updated"]);
        }

        else {
            http_response_code(405);
            echo json_encode(["message" => "Method not allowed"]);
        }

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            "message" => "Server error",
            "error" => $e->getMessage()
        ]);
    }
}