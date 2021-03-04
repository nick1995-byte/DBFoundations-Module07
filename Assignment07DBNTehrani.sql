--*************************************************************************--
-- Title: Assignment07
-- Author: Nariman Tehrani
-- Desc: This file demonstrates how to use Functions
-- Change Log: 2021-02-27, Nariman_Tehrani, Created File
-- Change Log: 2021-02-28, Nariman_Tehrani, Created database
-- Change Log: 2021-02-28, Nariman_Tehrani, Created tables
-- Change Log: 2021-02-28, Nariman_Tehrani, Added constraints and data to tables
-- Change Log: 2021-02-28, Nariman_Tehrani, Created Views and a uder-defined function
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_Nariman_Tehrani')
	 Begin 
	  Alter Database [Assignment07DB_Nariman_Tehrani] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_Nariman_Tehrani;
	 End
	Create Database Assignment07DB_Nariman_Tehrani;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_Nariman_Tehrani;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
/*
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
*/
-- Question 1 (5% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, and the price of each product, with the price formatted as US dollars?
-- Order the result by the product!

Select 
	ProductName,
	FORMAT (UnitPrice, 'C', 'en-US') AS UnitPrice
From
	vProducts
Order by 
	1
go

-- Question 2 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Category and Product names, and the price of each product, 
-- with the price formatted as US dollars?
-- Order the result by the Category and Product!

Select 
	vCategories.CategoryName,
	vProducts.ProductName,
	FORMAT (vProducts.UnitPrice, 'C', 'en-US') as UnitPrice
From
	vCategories Left Join vProducts on vCategories.CategoryID = vProducts.CategoryID
Order by
	1,2
go

-- Question 3 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, each Inventory Date, and the Inventory Count,
-- with the date formatted like "January, 2017?" 
-- Order the results by the Product, Date, and Count!

Select 
	vProducts.ProductName,
	InventoryDate = DATENAME(mm, vInventories.InventoryDate) + ', ' + DATENAME(yy, vInventories.InventoryDate),
	SUM(vInventories.Count) as InventoryCount
From
	vProducts Left Join vInventories on vProducts.ProductID = vInventories.ProductID
Group by
	vProducts.ProductName,
	InventoryDate 
Order by 
	1,2,3 Desc
go

-- Question 4 (10% of pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017? Order the results by the Product, Date,
-- and Count!

go
Create
	View vProductInventories
	AS
		Select
			TOP 1000000 
			ProductName = vProducts.ProductName,
			InventoryDate = DATENAME(mm, vInventories.InventoryDate) + ', ' + DATENAME(yy, vInventories.InventoryDate),
			InventoryCount = SUM(vInventories.Count)
		From
			vProducts Left Join vInventories on vProducts.ProductID = vInventories.ProductID
		Group by
			ProductName,
			InventoryDate 
		Order by
			ProductName,
			CAST(InventoryDate as Date)
go

--Drop View vProductInventories

-- Check that it works: 
Select * From vProductInventories;
go

-- Question 5 (10% of pts): How can you CREATE A VIEW called vCategoryInventories 
-- that shows a list of Category names, Inventory Dates, 
-- and a TOTAL Inventory Count BY CATEGORY, with the date FORMATTED like January, 2017?

go
Create
	View vCategoryInventories
	AS
		Select
			TOP 1000000
			CategoryName = vCategories.CategoryName,		   		
			InventoryDate = DATENAME(mm, vInventories.InventoryDate) + ', ' + DATENAME(yy, vInventories.InventoryDate),
			InventoryCountByCategory = SUM(vInventories.Count)
		From
			vCategories Left Join vProducts on vCategories.CategoryID = vProducts.CategoryID
						LEFT Join vInventories on vProducts.ProductID = vInventories.ProductID
		Group by
			CategoryName,
			InventoryDate 
		Order by
			1
go
-- Check that it works: 
Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): How can you CREATE ANOTHER VIEW called 
-- vProductInventoriesWithPreviouMonthCounts to show 
-- a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month
-- Count? Use a functions to set any null counts or 1996 counts to zero. Order the
-- results by the Product, Date, and Count. This new view must use your
-- vProductInventories view!


go
Create
	View vProductInventoriesWithPreviouMonthCounts
	AS
		Select
			TOP 1000000
			ProductName = vProductInventories.ProductName,
			InventoryDate = vProductInventories.InventoryDate,

			CASE 
				WHEN vProductInventories.InventoryCount IS NULL THEN 0
				WHEN YEAR(InventoryDate) = 1996 THEN 0
				ELSE vProductInventories.InventoryCount
			END AS InventoryCount,

			CASE 
				WHEN InventoryCount IS NULL THEN 0
				WHEN YEAR(InventoryDate) = 1996 THEN 0
				ELSE IIF(MONTH(vProductInventories.InventoryDate) = 1, 0, 
				LAG(vProductInventories.InventoryCount) Over (Order by vProductInventories.ProductName, MONTH(vProductInventories.InventoryDate)))
			END AS PreviousMonthCount

		From
			vProductInventories
		Order by
			ProductName,
			CAST(InventoryDate as Date)	
go
-- Check that it works: 
Select * From vProductInventoriesWithPreviouMonthCounts;
go

-- Question 7 (20% of pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month 
-- Count and a KPI that displays an increased count as 1, 
-- the same count as 0, and a decreased count as -1? Order the results by the 
-- Product, Date, and Count!

go
Create
	View vProductInventoriesWithPreviousMonthCountsWithKPIs
	AS
		Select
			TOP 1000000
			ProductName = vProductInventoriesWithPreviouMonthCounts.ProductName,
			InventoryDate = vProductInventoriesWithPreviouMonthCounts.InventoryDate,
			InventoryCount = vProductInventoriesWithPreviouMonthCounts.InventoryCount,
			PreviousMonthCount = vProductInventoriesWithPreviouMonthCounts.PreviousMonthCount,

			CASE 
				WHEN InventoryCount > PreviousMonthCount THEN 1
				WHEN InventoryCount < PreviousMonthCount THEN -1
				ELSE 0
			END AS CountVsPreviousCountKPI
		
		From vProductInventoriesWithPreviouMonthCounts
		Order by
			ProductName,
			CAST(InventoryDate as Date),
			InventoryCount
go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): How can you CREATE a User Defined Function (UDF) 
-- called fProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month
-- Count and a KPI that displays an increased count as 1, the same count as 0, and a
-- decreased count as -1 AND the result can show only KPIs with a value of either 1, 0,
-- or -1? This new function must use you
-- ProductInventoriesWithPreviousMonthCountsWithKPIs view!
-- Include an Order By clause in the function using this code: 
-- Year(Cast(v1.InventoryDate as Date))
-- and note what effect it has on the results.

Create Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI Float)
RETURNS TABLE
AS
	RETURN
		(Select 
			TOP 1000000
			*
			From 
				vProductInventoriesWithPreviousMonthCountsWithKPIs as V1
			Where
				CountVsPreviousCountKPI = @KPI
			Order By
				Year(Cast(v1.InventoryDate as Date))
		)	
go

--Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);

go

/***************************************************************************************/