-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 07, 2026 at 04:38 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `inventory_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `product_name` varchar(150) NOT NULL,
  `price` decimal(10,2) DEFAULT 0.00,
  `stock` int(11) DEFAULT 0,
  `supplier_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `product_name`, `price`, `stock`, `supplier_id`, `created_at`) VALUES
(1, 'T-shirt', 250.00, 15, 5, '2026-03-21 09:23:23'),
(2, 'Jeans', 800.00, 12, 2, '2026-03-21 09:23:23'),
(3, 'Jacket', 1200.00, 8, 3, '2026-03-21 09:23:23'),
(4, 'Shorts', 300.00, 25, 1, '2026-03-21 09:23:23'),
(5, 'Dress', 950.00, 30, 4, '2026-03-21 09:23:23');

-- --------------------------------------------------------

--
-- Table structure for table `stock_movements`
--

CREATE TABLE `stock_movements` (
  `movement_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `movement_type` enum('IN','OUT') NOT NULL,
  `quantity` int(11) NOT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stock_movements`
--

INSERT INTO `stock_movements` (`movement_id`, `product_id`, `movement_type`, `quantity`, `remarks`, `created_at`) VALUES
(1, 1, 'IN', 20, 'Initial stock', '2026-03-21 09:23:23'),
(2, 1, 'OUT', 5, 'Sold items', '2026-03-21 09:23:23'),
(3, 2, 'IN', 15, 'Initial stock', '2026-03-21 09:23:23'),
(4, 3, 'IN', 10, 'Supplier delivery', '2026-03-21 09:23:23'),
(5, 4, 'IN', 25, 'Initial stock', '2026-03-21 09:23:23'),
(6, 5, 'IN', 30, 'Initial stock', '2026-03-21 09:23:23'),
(7, 2, 'OUT', 3, 'Sold items', '2026-03-21 09:23:23'),
(8, 3, 'OUT', 2, 'Sold items', '2026-03-21 09:23:23');

--
-- Triggers `stock_movements`
--
DELIMITER $$
CREATE TRIGGER `trg_stock_after_delete` AFTER DELETE ON `stock_movements` FOR EACH ROW BEGIN
    IF OLD.movement_type = 'IN' THEN
        UPDATE products
        SET stock = stock - OLD.quantity
        WHERE product_id = OLD.product_id;
    ELSE
        UPDATE products
        SET stock = stock + OLD.quantity
        WHERE product_id = OLD.product_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_stock_after_insert` AFTER INSERT ON `stock_movements` FOR EACH ROW BEGIN
    IF NEW.movement_type = 'IN' THEN
        UPDATE products
        SET stock = stock + NEW.quantity
        WHERE product_id = NEW.product_id;
    ELSE
        UPDATE products
        SET stock = stock - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_stock_after_update` AFTER UPDATE ON `stock_movements` FOR EACH ROW BEGIN
    -- Reverse OLD value
    IF OLD.movement_type = 'IN' THEN
        UPDATE products
        SET stock = stock - OLD.quantity
        WHERE product_id = OLD.product_id;
    ELSE
        UPDATE products
        SET stock = stock + OLD.quantity
        WHERE product_id = OLD.product_id;
    END IF;

    -- Apply NEW value
    IF NEW.movement_type = 'IN' THEN
        UPDATE products
        SET stock = stock + NEW.quantity
        WHERE product_id = NEW.product_id;
    ELSE
        UPDATE products
        SET stock = stock - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `supplier_id` int(11) NOT NULL,
  `supplier_name` varchar(150) NOT NULL,
  `contact` varchar(150) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`supplier_id`, `supplier_name`, `contact`, `phone`, `email`, `address`, `created_at`) VALUES
(1, 'Hana Trading', 'Hana', '09123456789', 'hana@gmail.com', 'Davao City', '2026-03-21 09:23:22'),
(2, 'Metro Supplies', 'John Cruz', '09111111111', 'metro@gmail.com', 'Cebu City', '2026-03-21 09:23:22'),
(3, 'Global Source Co.', 'Maria Santos', '09222222222', 'global@gmail.com', 'Manila', '2026-03-21 09:23:22'),
(4, 'QuickMart Supplier', 'Pedro Reyes', '09333333333', 'quickmart@gmail.com', 'Davao City', '2026-03-21 09:23:22'),
(5, 'Prime Goods Inc.', 'Ana Lopez', '09444444444', 'prime@gmail.com', 'Tagum City', '2026-03-21 09:23:22');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`);

--
-- Indexes for table `stock_movements`
--
ALTER TABLE `stock_movements`
  ADD PRIMARY KEY (`movement_id`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`supplier_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `stock_movements`
--
ALTER TABLE `stock_movements`
  MODIFY `movement_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `supplier_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
