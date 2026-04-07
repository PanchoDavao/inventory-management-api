<?php

function handleSuppliers($pdo, $method) {

    header("Content-Type: application/json");

    try {

        if ($method === 'GET') {
            $stmt = $pdo->query("SELECT * FROM suppliers");
            echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        }

        elseif ($method === 'POST') {
            $data = json_decode(file_get_contents("php://input"), true);

            // ✅ Validation
            if (
                empty($data['supplier_name']) ||
                empty($data['contact']) ||
                empty($data['phone']) ||
                empty($data['email']) ||
                empty($data['address'])
            ) {
                http_response_code(400);
                echo json_encode(["message" => "All fields are required"]);
                return;
            }

            $stmt = $pdo->prepare("
                INSERT INTO suppliers (supplier_name, contact, phone, email, address, created_at)
                VALUES (?, ?, ?, ?, ?, NOW())
            ");

            $stmt->execute([
                $data['supplier_name'],
                $data['contact'],
                $data['phone'],
                $data['email'],
                $data['address']
            ]);

            echo json_encode(["message" => "Supplier created"]);
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