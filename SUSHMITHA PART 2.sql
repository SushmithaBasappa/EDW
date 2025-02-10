create database retailstoredb;
Use retailstoredb;

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL
);

-- Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(255) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0)
);


-- Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT CHECK (Quantity > 0),
    OrderDate DATE NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);
SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Products;
SELECT COUNT(*) AS OrderCount FROM Orders;


#JOIN Operation (INNER JOIN)
#Find the top 5 best-selling products
SELECT p.ProductName, SUM(o.Quantity) AS TotalQuantitySold
FROM Orders o
INNER JOIN Products p ON o.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalQuantitySold DESC
LIMIT 5;

#Filtering (WHERE)
#Find customers who ordered a specific product (e.g., 'Laptop')

SELECT DISTINCT c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Products p ON o.ProductID = p.ProductID
WHERE p.ProductName = 'Agent';

#Aggregation (GROUP BY + COUNT)
#Find the number of orders placed by each customer
SELECT c.CustomerName, COUNT(o.OrderID) AS TotalOrders
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerName
ORDER BY TotalOrders DESC;

##Combine Two Different Queries (Customers + Products Ordered)
SELECT c.CustomerID, c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.ProductID = 213
UNION
SELECT c.CustomerID, c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.ProductID = 496;


 #Window Function (RANK OVER)
 #Rank months by total revenue
SELECT 
    DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
    SUM(p.Price * o.Quantity) AS TotalRevenue,
    RANK() OVER (ORDER BY SUM(p.Price * o.Quantity) DESC) AS RevenueRank
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
GROUP BY Month;


### Stored Procedure ###
DELIMITER $$

CREATE PROCEDURE monthly_report(IN report_month VARCHAR(7))
BEGIN
    DECLARE total_revenue DECIMAL(10,2) DEFAULT 0;
    DECLARE assumed_costs DECIMAL(10,2) DEFAULT 0;
    DECLARE profit DECIMAL(10,2) DEFAULT 0;
    DECLARE total_orders INT DEFAULT 0;

    -- Calculate total revenue (fixing column name for ProductID)
    SELECT COALESCE(SUM(o.Quantity * p.Price), 0) INTO total_revenue
    FROM Orders o
    JOIN Products p ON o.ProductID = p.ProductID  -- Fixed column name
    WHERE DATE_FORMAT(o.OrderDate, '%Y-%m') = report_month;

    -- Calculate total number of orders for the given month
    SELECT COALESCE(COUNT(o.OrderID), 0) INTO total_orders
    FROM Orders o
    WHERE DATE_FORMAT(o.OrderDate, '%Y-%m') = report_month;

    -- Assume costs as a percentage (e.g., 60%) of total revenue
    SET assumed_costs = total_revenue * 0.6;

    -- Calculate profit
    SET profit = total_revenue - assumed_costs;

    -- Output the report
    SELECT 
        report_month AS Report_Month,
        total_revenue AS Total_Revenue,
        assumed_costs AS Assumed_Costs,
        profit AS Profit,
        total_orders AS Total_Orders;
END$$

DELIMITER ;


CALL monthly_report('2024-12');










CREATE TABLE UserPreferences (
    PreferenceID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    Category VARCHAR(255) NOT NULL,
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

CREATE TABLE Recommendations (
    RecommendationID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    Reason VARCHAR(255) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);

DELIMITER $$

CREATE TRIGGER after_order_insert
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    -- Insert or update user preferences based on product ID
    INSERT INTO UserPreferences (CustomerID, LastUpdated)
    VALUES (NEW.CustomerID, NOW())
    ON DUPLICATE KEY UPDATE LastUpdated = NOW();
END $$

DELIMITER ;

DROP EVENT IF EXISTS DailyRecommendationUpdate;

DELIMITER $$

INSERT INTO Recommendations (CustomerID, ProductID, RecommendationReason, DateGenerated)
SELECT 
    up.CustomerID, 
    p.ProductID, 
    'Recommended based on your previous purchases', 
    NOW()
FROM UserPreferences up
JOIN Orders o ON up.CustomerID = o.CustomerID
JOIN Products p ON p.ProductID != o.ProductID  -- Exclude already purchased products
WHERE p.ProductID NOT IN (SELECT ProductID FROM Orders WHERE CustomerID = up.CustomerID)
ORDER BY RAND()
LIMIT 5;


DELIMITER ;

INSERT INTO Orders (CustomerID, ProductID, OrderDate, Quantity)
VALUES (512, 25, '2024-02-07', 1);

SELECT * FROM UserPreferences WHERE CustomerID = 512;

SELECT * FROM Recommendations;













































