DROP DATABASE IF EXISTS SDG2_ZeroHungerDB;
CREATE DATABASE SDG2_ZeroHungerDB;
USE SDG2_ZeroHungerDB;

-- 1. Table: Donors
CREATE TABLE Donors (
    donor_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_name VARCHAR(100) NOT NULL,
    donor_email VARCHAR(100) UNIQUE,
    join_date DATE NOT NULL
);

-- 2. Table: Inventory
CREATE TABLE FoodInventory (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    expiration_date DATE NOT NULL,
    stock_quantity INT DEFAULT 0,
    CONSTRAINT chk_positive_stock CHECK (stock_quantity >= 0)
); 

-- 3. Table: Distributions (Outgoing Food)
CREATE TABLE Distributions (
    dist_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    beneficiary_name VARCHAR(100) NOT NULL,
    quantity_given INT NOT NULL,
    date_given DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_dist_item FOREIGN KEY (item_id) REFERENCES FoodInventory(item_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 4. Table: DonationLogs (Incoming Food History)
CREATE TABLE DonationLogs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_id INT,
    item_id INT,
    qty_donated INT,
    donation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_donor FOREIGN KEY (donor_id) REFERENCES Donors(donor_id),
    CONSTRAINT fk_log_item FOREIGN KEY (item_id) REFERENCES FoodInventory(item_id)
);
