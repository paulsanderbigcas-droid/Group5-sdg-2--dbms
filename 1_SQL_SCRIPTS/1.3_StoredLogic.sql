USE SDG2_ZeroHungerDB;

DELIMITER //

-- 1. TRIGGER: Safety Check
DROP TRIGGER IF EXISTS Before_Distribution_Insert //
CREATE TRIGGER Before_Distribution_Insert
BEFORE INSERT ON Distributions
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    DECLARE expiry_date DATE;
    
    SELECT stock_quantity, expiration_date 
    INTO current_stock, expiry_date
    FROM FoodInventory 
    WHERE item_id = NEW.item_id;
    
    IF current_stock < NEW.quantity_given THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: Insufficient stock.';
    END IF;

    IF expiry_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: EXPIRED ITEM.';
    END IF;
END //

-- 2. PROCEDURE: Distribute Food (ACID Transaction)
DROP PROCEDURE IF EXISTS DistributeFood //
CREATE PROCEDURE DistributeFood(
    IN p_item_id INT,
    IN p_qty INT,
    IN p_beneficiary VARCHAR(100)
)
BEGIN
    START TRANSACTION;
    
    UPDATE FoodInventory SET stock_quantity = stock_quantity - p_qty WHERE item_id = p_item_id;
    
    INSERT INTO Distributions (item_id, beneficiary_name, quantity_given, date_given) 
    VALUES (p_item_id, p_beneficiary, p_qty, NOW());
    
    IF (SELECT stock_quantity FROM FoodInventory WHERE item_id = p_item_id) < 0 THEN
        ROLLBACK;
        SELECT 'Transaction Failed' AS Status;
    ELSE
        COMMIT;
        SELECT 'Transaction Successful' AS Status;
    END IF;
END //

-- 3. PROCEDURE: Receive Donation (Restocking)
DROP PROCEDURE IF EXISTS ReceiveDonation //
CREATE PROCEDURE ReceiveDonation(
    IN p_donor_id INT,
    IN p_item_id INT,
    IN p_qty INT
)
BEGIN
    UPDATE FoodInventory SET stock_quantity = stock_quantity + p_qty WHERE item_id = p_item_id;
    
    INSERT INTO DonationLogs (donor_id, item_id, qty_donated, donation_date)
    VALUES (p_donor_id, p_item_id, p_qty, NOW());
    
    SELECT CONCAT('Success: Restocked Item ', p_item_id) AS Status;    
END //

DELIMITER ;

-- 4. VIEW: Report 1 - Expiring Stock
CREATE OR REPLACE VIEW View_ExpiringStock AS
SELECT item_name, expiration_date, stock_quantity
FROM FoodInventory
WHERE DATEDIFF(expiration_date, CURDATE()) < 30;

-- 5. VIEW: Report 2 - Total Donations by Donor
CREATE OR REPLACE VIEW View_DonorImpact AS
SELECT 
    d.donor_name, 
    fi.category, 
    COUNT(dl.log_id) as total_donations_made, 
    SUM(dl.qty_donated) as total_items_donated
FROM Donors d
JOIN DonationLogs dl ON d.donor_id = dl.donor_id
JOIN FoodInventory fi ON dl.item_id = fi.item_id
GROUP BY d.donor_name, fi.category
ORDER BY total_items_donated DESC;
