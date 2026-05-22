-- 1. Total number of customers.
select count(*) as Number_Of_Customer
from customers

-- 2. Total number of orders.
select count(*) as Number_Of_Orders
from orders

-- 3. Total number of products.
select count(*) as Number_Of_products
from products

-- 4. Total number of categories.
select count(*) as Number_Of_categories
from Categories

-- 5. Total revenue from all orders.
select SUM(UnitPrice * Quantity * (1 - Discount)) as Total_Revenue
from [Order Details]

-- 6. List all orders with customer company name and order date.
select 
    CompanyName,
    OrderDate
from Orders o
join Customers c
on o.CustomerID = c.CustomerID

-- 7. Show order details with product name, quantity, and unit price.
select 
    p.ProductName,
    od.Quantity,
    od.UnitPrice
from Products p
join [Order Details] od
on p.ProductID = od.ProductID

-- 8. Show customer company name, order id, and total order amount.
select 
    c.CompanyName,
    o.OrderID,
    sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as Total_Amount
from Customers c
join Orders o
    on c.CustomerID = o.CustomerID
join [Order Details] od
    on o.OrderID = od.OrderID
group by    c.CompanyName,
    o.OrderID

-- 9. Show all products with their category names.
select 
    p.ProductName,
    c.CategoryName
from Products p
join Categories c
    on p.CategoryID = c.CategoryID

-- 10. Show orders with shipper company name.
select 
    o.OrderID,
    s.CompanyName as ShipperName
from Orders o
join Shippers s
    on o.ShipVia = s.ShipperID

-- 11. Show employees and the orders they handled.
select 
    e.FirstName,
    e.LastName,
    o.OrderID
from Employees e
join Orders o
      on e.EmployeeID = o.EmployeeID

-- 12. Show customers who did not place any orders.
select 
    c.CustomerID,
    c.CompanyName
from Customers c
left join Orders o
    on c.CustomerID = o.CustomerID
where o.OrderID is null

-- 13. Total revenue per category.
select 
    c.CategoryName,
    sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as Total_Revenue
from Categories c
join Products p
    on c.CategoryID = p.CategoryID
join [Order Details] od
    on p.ProductID = od.ProductID
group by 
    c.CategoryName

-- 14. Total revenue per customer.
select 
    c.CompanyName,
    sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as Total_Revenue
from Customers c
join Orders o
    on c.CustomerID = o.CustomerID
join [Order Details] od
    on o.OrderID = od.OrderID
group by 
    c.CompanyName

-- 15. Number of orders per country.
select 
    c.Country,
    count(o.OrderID) as Number_Of_Orders
from Customers c
join Orders o
    on c.CustomerID = o.CustomerID
group by 
    c.Country
order by 
    Number_Of_Orders desc

-- 16. Top 5 customers by total spending.
select top 5
    c.CompanyName,
    sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as Total_Spending
from Customers c
join Orders o
    on c.CustomerID = o.CustomerID
join [Order Details] od
    on o.OrderID = od.OrderID
group by c.CompanyName
order by Total_Spending desc

-- 17. Top 5 products by revenue.
select top 5
    p.ProductName,
    sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as Total_Revenue
from Products p
join [Order Details] od
    on p.ProductID = od.ProductID
group by p.ProductName
order by Total_Revenue desc

-- 18. Customers who spent more than the average customer spending.
select 
    c.CompanyName,
    sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as Total_Spending
from Customers c
join Orders o
    on c.CustomerID = o.CustomerID
join [Order Details] od
    on o.OrderID = od.OrderID
group by 
    c.CompanyName
having 
    sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) >
    (
        select avg(CustomerTotal)
        from (
            select 
                sum(od2.UnitPrice * od2.Quantity * (1 - od2.Discount)) as CustomerTotal
            from Customers c2
            join Orders o2
                on c2.CustomerID = o2.CustomerID
            join [Order Details] od2
                on o2.OrderID = od2.OrderID
            group by c2.CustomerID
        ) as AvgTable
    )

-- 19. Products with unit price higher than average product price.
select 
    ProductName,
    UnitPrice
from Products
where UnitPrice > (
    select avg(UnitPrice)
    from Products
)

-- 20. Orders with total amount greater than the average order amount.
select
    o.OrderID,
    sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as Total_Amount
from Orders o
join [Order Details] od
    on o.OrderID = od.OrderID
group by 
    o.OrderID
having 
    sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) > (
        select avg(OrderTotal)
        from (
            select 
                sum(od2.UnitPrice * od2.Quantity * (1 - od2.Discount)) as OrderTotal
            from Orders o2
            join [Order Details] od2
                on o2.OrderID = od2.OrderID
            group by o2.OrderID
        ) as AvgOrders
    )

-- 21. Use a common table expression to calculate total order amount per order, then select orders above average order value.
with OrderTotals as (
    select 
        o.OrderID,
        sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as TotalAmount
    from Orders o
    join [Order Details] od
        on o.OrderID = od.OrderID
    group by o.OrderID
)

select 
    OrderID,
    TotalAmount
from OrderTotals
where TotalAmount > (
    select avg(TotalAmount)
    from OrderTotals
)

-- 22. Create a view called customer_total_spending.
create view customer_total_spending as
SELECT 
    c.CustomerID,
    c.CompanyName,
    sum(od.UnitPrice * od.Quantity * (1 - od.Discount)) as Total_Spending
from Customers c
join Orders o
    on c.CustomerID = o.CustomerID
join [Order Details] od
    on o.OrderID = od.OrderID
group by 
    c.CustomerID,
    c.CompanyName

select * 
from customer_total_spending

-- 23. Create a view called product_revenue.
create view product_revenue as
select 
    p.productid,
    p.productname,
    sum(od.unitprice * od.quantity * (1 - od.discount)) as total_revenue
from products p
join [order details] od
    on p.productid = od.productid
group by 
    p.productid,
    p.productname

select * 
from product_revenue

-- 24. Create a stored procedure that returns all orders for a given customer id, and use it.
CREATE PROCEDURE GetCustomerOrders
    @CustomerID NVARCHAR(10)
AS
BEGIN
    SELECT 
        OrderID,
        CustomerID,
        OrderDate,
        ShipCountry
    FROM Orders
    WHERE CustomerID = @CustomerID;
END;

-- 25. Create a stored procedure that returns total revenue for a given year, and use it.
CREATE PROCEDURE GetTotalRevenueByYear
    @Year INT
AS
BEGIN
    SELECT 
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS Total_Revenue
    FROM Orders o
    JOIN [Order Details] od
        ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = @Year;
END;