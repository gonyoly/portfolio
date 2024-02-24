--1. Identifying Orphan Products: Uncovering unused inventory

SELECT p.ProductID, p.Name, p.Color, p.ListPrice, p.Size
FROM Production.Product p LEFT JOIN Sales.SalesOrderDetail sod
	ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL
ORDER BY p.ProductID;

--2. Unveiling Hidden Customers: Discovering uncontacted clients

SELECT c.CustomerID, COALESCE(p.LastName, 'Unknown'), COALESCE(p.FirstName, 'Unknown')
FROM Sales.Customer c LEFT JOIN Person.Person p
	ON c.CustomerID = p.BusinessEntityID
	LEFT JOIN Sales.SalesOrderHeader soh
	ON c.CustomerID = soh.CustomerID
WHERE soh.CustomerID IS NULL
ORDER BY c.CustomerID;

--3. Top Customers Revealed: Analyzing top spenders by order 

SELECT TOP 10 soh.CustomerID, p.LastName, p.FirstName, COUNT(*) CountOfOrders
FROM Sales.SalesOrderHeader soh JOIN Person.Person p
	ON soh.CustomerID = p.BusinessEntityID
GROUP BY soh.CustomerID, p.LastName, p.FirstName
ORDER BY CountOfOrders DESC;

--4. Employee Job Title Analysis: Exploring career paths and trends

SELECT p.FirstName, p.LastName, e1.JobTitle, e1.HireDate,	(SELECT COUNT(*)
															FROM HumanResources.Employee e2
															WHERE e2.JobTitle = e1.JobTitle) CountOfTitle
FROM HumanResources.Employee e1 JOIN HumanResources.Employee e2
	ON e1.BusinessEntityID = e2.BusinessEntityID
	JOIN Person.Person p
	ON e1.BusinessEntityID = p.BusinessEntityID;

--5. Customer Order History: Tracking and comparing purchases 

WITH ord
AS
(
SELECT soh.SalesOrderID, soh.CustomerID, p.LastName, p.FirstName, soh.OrderDate,
		ROW_NUMBER () OVER (PARTITION BY soh.CustomerID ORDER BY soh.OrderDate DESC) AS rn
FROM Sales.SalesOrderHeader soh JOIN Sales.Customer c
	ON c.CustomerID = soh.CustomerID
	JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
)
SELECT ord.SalesOrderID, ord.CustomerID, ord.LastName, ord.FirstName,
		(CASE WHEN ord1.rn = 1 THEN ord1.OrderDate END) LastOrder,
		(CASE WHEN ord2.rn = 2 THEN ord2.OrderDate END) PreviousOrder
FROM ord INNER JOIN (SELECT * FROM ord WHERE rn = 1) ord1 ON ord.CustomerID = ord1.CustomerID
		INNER JOIN (SELECT * FROM ord WHERE rn = 2) ord2 ON ord.CustomerID = ord2.CustomerID
WHERE ord.rn = 1
ORDER BY LastName;

--6. Top Annual Sales: Uncovering highest-grossing orders

WITH tot (SalesOrderID, Total) 
AS
(
SELECT sod.SalesOrderID, SUM(sod.UnitPrice * (1 - sod.UnitPriceDiscount) * sod.OrderQty) AS Total
FROM Sales.SalesOrderDetail sod
GROUP BY sod.SalesOrderID
),
tbl (Year, SalesOrder, LastName, FirstName, Total, rn)
AS
(
SELECT YEAR(soh.OrderDate), soh.SalesOrderID, p.LastName, p.FirstName, tot.Total,	
		ROW_NUMBER() OVER(PARTITION BY YEAR(soh.OrderDate) ORDER BY tot.Total DESC) rn
FROM Sales.SalesOrderDetail sod
	JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
	JOIN Sales.Customer c ON c.CustomerID = soh.CustomerID
	JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
	JOIN tot ON sod.SalesOrderID = tot.SalesOrderID
)
SELECT Year, SalesOrder, LastName, FirstName, TRIM('0' FROM FORMAT(ROUND(Total, 1), 'N'))
FROM tbl
WHERE rn = 1;

--7. Sales Trend Analysis: Visualizing monthly order patterns

WITH tbl
AS
(
SELECT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, COUNT(*) AS cnt
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT Month, COALESCE([2011], 0) AS [2011], COALESCE([2012], 0) AS [2012],
				COALESCE([2013], 0) AS [2013], COALESCE([2014], 0) AS [2014]
FROM tbl
PIVOT (SUM(cnt) FOR Year IN ([2011], [2012], [2013], [2014])) AS pvt
ORDER BY Month;

--8. Sales Revenue Breakdown: Tracking monthly and cumulative sales

WITH tbl
AS
(
SELECT YEAR(soh.OrderDate) AS Year, MONTH(soh.OrderDate) AS Month,
		ROUND(SUM(sod.UnitPrice), 2) AS Sum_Price,
        ROUND(SUM(SUM(sod.UnitPrice)) OVER (PARTITION BY YEAR(OrderDate) ORDER BY MONTH(OrderDate)), 2) CumSum
FROM Sales.SalesOrderHeader soh JOIN Sales.SalesOrderDetail sod
	ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
tbl1 
AS
(
SELECT Year, CAST(Month AS VARCHAR) AS Month, Sum_Price, CumSum
FROM tbl

UNION ALL

SELECT Year, 'grand Total', NULL, MAX(CumSum)
FROM tbl
GROUP BY Year
)
SELECT *
FROM tbl1
ORDER BY Year, CASE WHEN Month = 'grand Total' THEN 13 ELSE CAST(Month AS INT) END;

--9. Employee Career History: Uncovering department moves and tenure

WITH tbl (DepartmentName, EmpID, Emp_FullName, HireDate, Seniority, rn)
AS
(
SELECT d.Name AS DepartmentName, e.BusinessEntityID EmpID,
		p.FirstName + ' ' + p.LastName AS Emp_FullName,
		e.HireDate HireDate, DATEDIFF(dd, e.HireDate, GETDATE()) Seniority, 
		ROW_NUMBER () OVER (PARTITION BY d.Name ORDER BY e.Hiredate) rn
FROM HumanResources.Department d JOIN HumanResources.EmployeeDepartmentHistory edh ON d.DepartmentID = edh.DepartmentID
								JOIN HumanResources.Employee e ON edh.BusinessEntityID = e.BusinessEntityID
								JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
)
SELECT DepartmentName, EmpID, Emp_FullName, HireDate, Seniority,
		CASE WHEN rn = 1
		THEN NULL
		ELSE LAG(Emp_FullName) OVER (PARTITION BY DepartmentName ORDER BY HireDate)
		END PrevEmpName,
		CASE WHEN rn = 1
		THEN NULL
		ELSE LAG(HireDate) OVER (PARTITION BY DepartmentName ORDER BY HireDate)
		END PrevEmpHdate,
		DATEDIFF(dd, LAG(HireDate) OVER (PARTITION BY DepartmentName ORDER BY HireDate), HireDate) DayDiff
FROM tbl
ORDER BY DepartmentName, HireDate DESC;

--10. Team Composition Tracking: Monitoring department staffing history 

SELECT e.HireDate, d.DepartmentID, STRING_AGG((CONVERT(VARCHAR(4), p.BusinessEntityID) + ' ' + p.LastName + ' ' + p.FirstName), ', ') TeamEmployees
FROM HumanResources.Department d JOIN HumanResources.EmployeeDepartmentHistory edh ON d.DepartmentID = edh.DepartmentID
								JOIN HumanResources.Employee e ON edh.BusinessEntityID = e.BusinessEntityID
								JOIN Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
GROUP BY e.HireDate, d.DepartmentID
ORDER BY e.HireDate DESC