# SDG 2 Project: Zero Hunger Food Bank System
SDG Alignment: UN Sustainable Development Goal 2 (Zero Hunger)  
Course: BS INFORMATION TECHNOLOGY 
Term: Finals 2025

-----

Project Description

This project is a Relational Database Management System (RDBMS) designed to manage the logistics of a Food Bank. The goal is to tackle SDG 2: Zero Hunger by efficiently tracking food donations, monitoring inventory levels, and recording distributions to beneficiaries.

The system solves the problem of "food leakage" and safety by ensuring that:

1.  Inventory is automatically updated when food goes in or out.
2.  Expired food is never distributed to people.
3.  We can easily report on who is donating the most and which items are running low.

Core DBMS Concepts Used (Justification)

  * Normalization (3NF): We designed the schema with 4 distinct tables (Donors, FoodInventory, Distributions, DonationLogs) to avoid repeating donor details and to ensure data integrity.
  * ACID Transactions (Stored Procedures): We used START TRANSACTION, COMMIT, and ROLLBACK in our distribution logic. This ensures that if the system crashes while recording a giveaway, the food inventory count doesn't get messed up.
  * Triggers & Constraints: We implemented a trigger to check expiration dates before distribution. This prevents human error and ensures food safety.
  * Complex Views (Reporting): We used SQL Views with JOINS and aggregate functions (COUNT, SUM) to generate dynamic reports without writing complex queries every time.

-----

Installation & Setup

To run this project, you need *MySQL Workbench* or a command-line MySQL client.

Step 1: Clone or Download this repository.
Step 2: Open your SQL editor.
Step 3: Execute the scripts in the 1_SQL_SCRIPTS folder in the exact order below:

1.  1.1_DDL_Schema.sql → Creates the database, tables, and constraints.
2.  1.2_DML_TestData.sql → Loads the 50+ sample records.
3.  1.3_StoredLogic.sql → Compiles the Procedures, Triggers, and Views.
4.  1.4_DCL_Users.sql → Sets up the admin user permissions.

Note: Each file already includes `USE SDG2_ZeroHungerDB;` at the top, so you don't need to select the database manually.


-----

Usage Instructions & Demonstration

1. Test the Transactional Stored Procedure (FR3)
Demonstrates ACID properties. We will safely distribute 10 units of Rice (Item 1) to a beneficiary. The system will automatically check stock, deduct it, and log the transaction.

SQL

-- Run the safe distribution procedure
CALL DistributeFood(1, 10, 'Barangay 123 Beneficiaries');

-- Verify the record was created
SELECT * FROM Distributions ORDER BY dist_id DESC LIMIT 1;

2. Test the Reports (FR4)
We created Views to make reporting easy and meet the "Complex SQL" requirement.

Report A: Check for expiring stock (Complex DQL) Identifies items expiring within 30 days.

SQL
SELECT * FROM View_ExpiringStock;

Report B: Total Impact per Donor (Complex JOINS) Aggregates data to show who donated the most.

SQL
SELECT * FROM View_DonorImpact;

3. Validation: Testing Constraints & Triggers
The system must fail gracefully to prevent data corruption or safety issues.

Test A: Try to distribute an expired item Item 11 (Eggs) is expired in our test data. This should return: "ERROR: EXPIRED ITEM."

SQL
`INSERT INTO Distributions (item_id, beneficiary_name, quantity_given) 
 VALUES (11, 'Illegal Distribution', 5);`

Test B: Try to over-distribute stock Trying to give more than we have. This should return: "ERROR: Insufficient stock."

SQL
CALL DistributeFood(1, 9999, 'Stress Test Group');

4. General SQL Commands (Utility)
Use these to inspect the database structure.

Show database and tables:

SQL
`SHOW DATABASES;
 USE SDG2_ZeroHungerDB;
 SHOW TABLES;
 Describe table structures:`

SQL
`DESCRIBE Donors;
 DESCRIBE FoodInventory;
 DESCRIBE DonationLogs;
 DESCRIBE Distributions;`

5. Sample Manual Queries (Data Inspection)
If you need to see raw data with readable names (Joins).

View Donation History (with Donor Names):

SQL
`SELECT dl.log_id, d.donor_name, fi.item_name, dl.qty_donated
 FROM DonationLogs dl
 JOIN Donors d ON dl.donor_id = d.donor_id
 JOIN FoodInventory fi ON dl.item_id = fi.item_id;
 View Distribution History (with Item Names):`

SQL
`SELECT dist.dist_id, fi.item_name, dist.beneficiary_name, dist.quantity_given
 FROM Distributions dist
 JOIN FoodInventory fi ON dist.item_id = fi.item_id;`

6. Adding Data (Manual)
How to add new records using standard SQL.

Add a new Donor:

SQL
`INSERT INTO Donors (donor_name, donor_email, join_date)
 VALUES ('ACME Philanthropy', 'contact@acme.org', CURDATE());
 Add a new Food Item:`

SQL
`INSERT INTO FoodInventory (item_name, category, expiration_date, stock_quantity)
 VALUES ('Canned Tuna', 'Protein', '2026-03-31', 0);`

Log a Manual Donation: (Note: It is better to use the ReceiveDonation procedure, but this is the manual method)

SQL
`INSERT INTO DonationLogs (donor_id, item_id, qty_donated, donation_date)
 VALUES (2, 1, 50, NOW());`


Contributors

  * GONZAGA: Database Schema Design (DDL), DOCUMENTATION, MAIN REPORT, GITHUB FILES, Repository Management
  * VIRAYO: TESTDATA (DML), DOCUMENTATION, MAIN REPORT, Repository Management
  * ARIONG: STOREDLOGIC, DOCUMENTATION, MAIN REPORT, ERD/TRANSACTION, Repository Management.
  * DELA CRUZ: USERS (DCL), DOCUMENTATION, MAIN REPORT, Repository Management.
  * BIGCAS: README, DOCUMENTATION, MAIN REPORT, Repository Management.

-----

File Structure

text
GROUP_NAME_SDG_PROJECT/
├── 1_SQL_SCRIPTS/
│   ├── 1.1_DDL_Schema.sql      (Run First)
│   ├── 1.2_DML_TestData.sql    (Run Second)
│   ├── 1.3_StoredLogic.sql     (Run Third)
│   └── 1.4_DCL_Users.sql       (Run Last)
├── 3_DOCUMENTATION/
│   ├── SDAD_Final.pdf
│   ├── ERD_Final.pdf
│   └── Transaction_Flowchart.png
└── README.md
