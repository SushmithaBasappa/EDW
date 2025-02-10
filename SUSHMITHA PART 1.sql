create database OnlineDB;
use OnlineDB;

CREATE TABLE Clients (
    ClientID INT PRIMARY KEY AUTO_INCREMENT,
    ClientName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierName VARCHAR(255) NOT NULL
);

-- Items Table (Not in 3NF: SupplierName is duplicated, leading to redundancy)
CREATE TABLE Items (
    ItemID INT PRIMARY KEY AUTO_INCREMENT,
    ItemName VARCHAR(255) NOT NULL,
    SupplierName VARCHAR(255) NOT NULL -- Redundant Data (Not in 3NF)
);

CREATE TABLE Purchases (
    PurchaseID INT PRIMARY KEY AUTO_INCREMENT,
    ClientID INT,
    PurchaseDate DATE NOT NULL,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID)
);

CREATE TABLE PurchaseDetails (
    PurchaseID INT,
    ItemID INT,
    Quantity INT CHECK (Quantity > 0),
    Price DECIMAL(10,2) CHECK (Price > 0),
    PRIMARY KEY (PurchaseID, ItemID),
    FOREIGN KEY (PurchaseID) REFERENCES Purchases(PurchaseID),
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
    );
    
    
    -- Insert Clients
INSERT INTO Clients (ClientName, Email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Brown', 'charlie@example.com');

-- Insert Suppliers
INSERT INTO Suppliers (SupplierName) VALUES
('Supplier A'),
('Supplier B'),
('Supplier C');

-- Insert Items (Before 3NF)
INSERT INTO Items (ItemName, SupplierName) VALUES
('Laptop', 'Supplier A'),
('Smartphone', 'Supplier B'),
('Tablet', 'Supplier C');


-- Insert Purchases
INSERT INTO Purchases (ClientID, PurchaseDate) VALUES
(1, '2024-02-01'),
(2, '2024-02-02'),
(3, '2024-02-03');

-- Insert Purchase Details
INSERT INTO PurchaseDetails (PurchaseID, ItemID, Quantity, Price) VALUES
(1, 1, 2, 1500.00),
(2, 2, 1, 800.00),
(3, 3, 3, 500.00);


## Normalisation

ALTER TABLE Items DROP COLUMN SupplierName;  -- Remove redundant column

ALTER TABLE Items ADD COLUMN SupplierID INT;  -- Add the correct foreign key
ALTER TABLE Items ADD FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID);

SET SQL_SAFE_UPDATES = 0;

UPDATE Items SET SupplierID = 1 WHERE ItemName = 'Laptop';
UPDATE Items SET SupplierID = 2 WHERE ItemName = 'Smartphone';
UPDATE Items SET SupplierID = 3 WHERE ItemName = 'Tablet';

SET SQL_SAFE_UPDATES = 1;


## Objectives
#"Which items have the highest total sales revenue?"

#"Which suppliers provide the most purchased items?"

#"What is the relationship between client purchase frequency and total spending?"

SELECT i.ItemName, SUM(pd.Quantity * pd.Price) AS TotalRevenue
FROM PurchaseDetails pd
JOIN Items i ON pd.ItemID = i.ItemID
GROUP BY i.ItemName
ORDER BY TotalRevenue DESC;

SELECT s.SupplierName, SUM(pd.Quantity) AS TotalItemsSold
FROM PurchaseDetails pd
JOIN Items i ON pd.ItemID = i.ItemID
JOIN Suppliers s ON i.SupplierID = s.SupplierID
GROUP BY s.SupplierName
ORDER BY TotalItemsSold DESC;

SELECT c.ClientName, COUNT(p.PurchaseID) AS PurchaseFrequency, SUM(pd.Quantity * pd.Price) AS TotalSpending
FROM Clients c
JOIN Purchases p ON c.ClientID = p.ClientID
JOIN PurchaseDetails pd ON p.PurchaseID = pd.PurchaseID
GROUP BY c.ClientName
ORDER BY TotalSpending DESC;

CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY AUTO_INCREMENT,
    ClientID INT,
    ItemID INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5), -- Constraint for valid ratings
    ReviewText TEXT,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID) ON DELETE CASCADE,
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID) ON DELETE CASCADE
);

-- Insert valid reviews
INSERT INTO Reviews (ClientID, ItemID, Rating, ReviewText) VALUES
(1, 1, 5, 'Excellent quality and performance!'),
(2, 2, 4, 'Good value for the price, but battery life could be better.'),
(3, 3, 3, 'Average product, meets expectations but nothing special.'),
(1, 2, 2, 'Not satisfied with the performance.'),
(2, 3, 1, 'Poor build quality and slow processing.'),
(3, 1, 4, 'Fast delivery, works great for my needs.'),
(1, 3, 5, 'Amazing tablet, very responsive and lightweight.'),
(2, 1, 3, 'Decent laptop but had some heating issues.'),
(3, 2, 2, 'Expected better performance for the price.'),
(1, 1, 4, 'Satisfied with the purchase, good for work and gaming.');


## Create a Trigger to Enforce Rating Validation
DELIMITER //

CREATE TRIGGER ValidateRatingBeforeInsert
BEFORE INSERT ON Reviews
FOR EACH ROW
BEGIN
    IF NEW.Rating < 1 OR NEW.Rating > 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Rating must be between 1 and 5';
    END IF;
END;
//

DELIMITER ;

## Step 3: Create a Trigger for Updates (To Prevent Invalid Modifications)
DELIMITER //

CREATE TRIGGER ValidateRatingBeforeUpdate
BEFORE UPDATE ON Reviews
FOR EACH ROW
BEGIN
    IF NEW.Rating < 1 OR NEW.Rating > 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Rating must be between 1 and 5';
    END IF;
END;
//

DELIMITER ;

INSERT INTO Reviews (ClientID, ItemID, Rating, ReviewText)
VALUES (2, 2, 7, 'Too good to be true!'); -- Error: Rating must be between 1 and 5










