-- CREATE DATABASE 
CREATE DATABASE suit_store;
USE suit_store;

-- Table: Customers
CREATE TABLE Customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(20),
  password_hash VARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Categories (for suit styles)
CREATE TABLE Categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT
);

-- Table: Suppliers
CREATE TABLE Suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  contact_email VARCHAR(100),
  phone VARCHAR(20),
  address VARCHAR(255)
);

-- Table: Products (suit models)
CREATE TABLE Products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  category_id INT NOT NULL,
  base_price DECIMAL(10,2) NOT NULL,
  style VARCHAR(100),
  material VARCHAR(100),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES Categories(category_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

-- Table: Product_Variants (specific suit variant e.g. size, color)
CREATE TABLE Product_Variants (
  variant_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  sku VARCHAR(100) NOT NULL UNIQUE,
  size VARCHAR(20) NOT NULL,    -- e.g., "S", "M", "L", or numeric sizes
  color VARCHAR(50) NOT NULL,
  material VARCHAR(100),        -- specific fabric/fabric finish if variant differs
  price DECIMAL(10,2) NOT NULL,  -- may override base_price
  stock_quantity INT NOT NULL DEFAULT 0,
  supplier_id INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

-- Table: Orders
CREATE TABLE Orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(50) NOT NULL DEFAULT 'pending',  -- e.g., pending, shipped, delivered, cancelled
  total_amount DECIMAL(10,2) NOT NULL,
  shipping_address VARCHAR(255),
  billing_address VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

-- Table: Order_Items
CREATE TABLE Order_Items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  variant_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  price_per_unit DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES Orders(order_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (variant_id) REFERENCES Product_Variants(variant_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

-- Table: Reviews (fixed to keep reviews even if customer is removed)
CREATE TABLE Reviews (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  product_id INT NOT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Table: Payments
CREATE TABLE Payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  payment_method VARCHAR(50) NOT NULL,  -- e.g. 'credit_card', 'paypal', etc
  payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(50) DEFAULT 'processing',  -- e.g. processing, completed, failed
  FOREIGN KEY (order_id) REFERENCES Orders(order_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Table: Product_Images
CREATE TABLE Product_Images (
  image_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  alt_text VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

--------------------------------------
-- Sample data inserts
--------------------------------------

-- Categories
INSERT INTO Categories (name, description) VALUES
  ('Classic', 'Traditional cut suits with timeless style'),
  ('Slim Fit', 'Modern slim fit suits'),
  ('Tuxedos', 'Formal evening suits'),
  ('Blazers', 'Suit jackets for semi-formal occasions');

-- Suppliers
INSERT INTO Suppliers (name, contact_email, phone, address) VALUES
  ('SuitCraft Ltd', 'info@suitcraft.com', '123-456-7890', '123 Suit St, Nairobi'),
  ('Elegant Tailors', 'sales@eleganttailors.com', '987-654-3210', '456 Fashion Ave, Nairobi');

-- Products
INSERT INTO Products (name, description, category_id, base_price, style, material) VALUES
  ('Regal Classic Suit', 'Three-piece classic suit with two buttons', 1, 250.00, 'Classic', 'Wool'),
  ('Midnight Tuxedo', 'Formal tuxedo with satin lapels', 3, 400.00, 'Tuxedo', 'Velvet Blend'),
  ('Slim Fit Navy Suit', 'Slim cut, modern style', 2, 300.00, 'Slim Fit', 'Poly Wool Blend');

-- Product Variants
INSERT INTO Product_Variants (product_id, sku, size, color, material, price, stock_quantity, supplier_id) VALUES
  (1, 'RC-REG-38-BLK', '38', 'Black', 'Wool', 260.00, 10, 1),
  (1, 'RC-REG-40-GRY', '40', 'Grey', 'Wool', 260.00, 5, 1),
  (2, 'MT-TUX-40-BLK', '40', 'Black', 'Velvet Blend', 420.00, 3, 2),
  (3, 'SF-NVY-38-BLU', '38', 'Navy', 'Poly Wool Blend', 310.00, 7, 2);

-- Customers
INSERT INTO Customers (first_name, last_name, email, phone, password_hash) VALUES
  ('Alice', 'Mumo', 'alice@example.com', '0712000000', 'hash1'),
  ('Bob', 'Ochieng', 'bob@example.com', '0712111111', 'hash2');

-- Orders
INSERT INTO Orders (customer_id, status, total_amount, shipping_address, billing_address) VALUES
  (1, 'pending', 520.00, '24 Nairobi Lane, Nairobi', '24 Nairobi Lane, Nairobi'),
  (2, 'pending', 310.00, '55 Eldoret Road, Nairobi', '55 Eldoret Road, Nairobi');

-- Order Items
INSERT INTO Order_Items (order_id, variant_id, quantity, price_per_unit, total_price) VALUES
  (1, 1, 1, 260.00, 260.00),
  (1, 2, 1, 260.00, 260.00),
  (2, 4, 1, 310.00, 310.00);

-- Payments
INSERT INTO Payments (order_id, payment_method, amount, status) VALUES
  (1, 'credit_card', 520.00, 'completed'),
  (2, 'paypal', 310.00, 'processing');

-- Reviews
INSERT INTO Reviews (customer_id, product_id, rating, comment) VALUES
  (1, 1, 5, 'Excellent classic suit, great fit!'),
  (2, 3, 4, 'Slim fit navy suit looks good but sleeves are slightly long.');

-- Product Images
INSERT INTO Product_Images (product_id, image_url, alt_text) VALUES
  (1, 'https://example.com/images/regal_classic_black.jpg', 'Regal Classic Suit Black'),
  (1, 'https://example.com/images/regal_classic_grey.jpg', 'Regal Classic Suit Grey'),
  (3, 'https://example.com/images/slim_navy.jpg', 'Slim Fit Navy Suit');
