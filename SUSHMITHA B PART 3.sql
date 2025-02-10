Use retailstoredb;

SELECT c.CustomerID, c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.ProductID = 213

UNION All

SELECT c.CustomerID, c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.ProductID = 496;

EXPLAIN
SELECT c.CustomerID, c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.ProductID = 213

UNION ALL

SELECT c.CustomerID, c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.ProductID = 496;




CREATE INDEX idx_product_id ON Orders (ProductID);
CREATE INDEX idx_customer_id ON Customers (CustomerID);
CREATE INDEX idx_order_date ON Orders (OrderDate);



SET profiling = 1;


SELECT c.CustomerID, c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.ProductID = 213

UNION All

SELECT c.CustomerID, c.CustomerName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.ProductID = 496;

SHOW PROFILE FOR QUERY 1;
SET profiling = 0;



