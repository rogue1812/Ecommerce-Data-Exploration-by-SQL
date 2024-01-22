-- Data understanding 
-- 3 tables 
-- List of Orders-This dataset contains purchase information. The information includes ID, Date of Purchase and customer details
-- Order Details- This dataset contains order ID, with the order price, quantity,profit, category and subcategory of product
-- Sales target-This dataset contains sales target amount and date for each product category
SELECT COUNT(*)
From listoforders 
-- (560)
SELECT COUNT(state), count(city)
From listoforders 
where not state = ''
-- 500 => 60 giá trị null, tương tự với orderID, OrderDate, CustomerName, City cũng có 60 giá trị = NULL

SELECT count(distinct l.state) as Numberofstate ,count(distinct city) as Numberofcity,
count(distinct l.customername) as Numberofcustomer , count( distinct o.category) as NumberofCategory 
, count(distinct o.subcategory) as NumberofSubCategory 
from  orderdetails o 
join listoforders l on o.OrderID = l.OrderID
-- Data exploration by MySQL 
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views

-- Tổng lợi nhuận theo thành phố
SELECT  l.City  , sum(o.profit) as TotalProfit 
From listoforders l
Join orderdetails o on l.OrderID = o.OrderID
group by l.city
order by sum(o.profit) desc 


-- State profitr per total profit percentage 
SELECT  substring(l.orderdate,7,4) as Year,State ,Category,Profit,
		SUM(profit) OVER() AS TotalProfit,
		SUM(profit) OVER(PARTITION BY state order by substring(l.orderdate,7,4) ) AS StateProfit,
        concat(round((SUM(profit) OVER(PARTITION BY state))/(SUM(profit) OVER()),2)*100,'%') as StateProfitPer
From listoforders l
Join orderdetails o on l.OrderID = o.OrderID
order by StateProfit  desc


-- Lợi nhuận từng ngành hàng theo năm 
-- Shows Percentage of Profit  
select substring(l.orderdate,7,4) as Year, o.Category, sum(o.Amount) as Amount, sum(o.profit) as TotalProfit,
round((sum(profit)/sum(amount)*100),2) as ProfitPercentage
from  orderdetails o 
join listoforders l on o.OrderID = l.OrderID
group by o.Category,year 
order by year desc , sum(o.profit) desc 

-- Top 10 khách hàng có nhiều đơn hàng nhất
select customername, count(orderid)
from listoforders 
where not customername = ''
group by customername
order by count(orderid) desc  limit 10

-- top 10 khách hàng có lượng mua nhiều nhất 
select l.CustomerName, sum(o.quantity) as TopQuantity
from listoforders l 
Join orderdetails o on l.OrderID = o.OrderID
where not l.customername = ''
group by customername
order by sum(quantity) desc  limit 10
-- Top 10 sản phẩm có doanh thu lớn nhất
CREATE table sub 
(
Year text ,
SubCategory nvarchar(255) ,
Amount numeric,
Profit numeric
)
  
Insert into sub
select  substring(l.orderdate,7,4) as Year, SubCategory, Amount ,Profit
from orderdetails o  
join listoforders l on o.OrderID = l.OrderID  

SELECT year, subcategory, sum(amount)as TotalAmount
FROM portfolio.sub
group by Year, SubCategory
order by sum(amount) desc limit 10

-- Sản phẩm có số lượng bán tốt nhất theo năm 
with quantity_year (Year, SubCategory, SLquantity)
as 
(select substring(l.orderdate,7,4) as Year, o.SubCategory, sum(o.quantity) 
from  orderdetails o 
join listoforders l on o.OrderID = l.OrderID
group by o.SubCategory,year 
order by year, sum(o.quantity) desc )
select  Year,SubCategory, max(SLquantity)
from quantity_year
group by  year

-- Sản phẩm có số lượng bán kém nhất theo năm 
with quantity_year (Year, subCategory, SLquantity)
as 
(select substring(l.orderdate,7,4) as Year, o.subCategory, sum(o.quantity) 
from  orderdetails o 
join listoforders l on o.OrderID = l.OrderID
group by o.subCategory,year 
order by year, sum(o.quantity) )
select  Year, subCategory, SLquantity
from quantity_year
group by  year

-- Actual and target sales 
With
sub(Year,Category,TotalAmount,Totalprofit)
as 
(select  substring(l.orderdate,9,2) as Year, o.Category, sum(o.Amount) ,sum(Profit) 
from orderdetails o  
join listoforders l on o.OrderID = l.OrderID  
group by category, year )
 select Year,sub.Category,TotalAmount,TotalProfit, sum(s.target) as Target, concat(round(TotalAmount/sum(s.target),2)*100, '%') as TargetsalesPercentage 
 from sub  
 join salestarget s on sub.category = s.Category  and  Year  = substring(s.MonthofOrderDate,5,2) 
 group by Year,TotalAmount,TotalProfit 
 order by year
  
-- Creating View to store data for later visualizations
Create View vis  as
SELECT  substring(l.orderdate,7,4) as Year,State ,Category,Profit,
		SUM(profit) OVER() AS TotalProfit,
		SUM(profit) OVER(PARTITION BY state order by substring(l.orderdate,7,4) ) AS StateProfit,
        concat(round((SUM(profit) OVER(PARTITION BY state))/(SUM(profit) OVER()),2)*100,'%') as StateProfitPer

From listoforders l
Join orderdetails o on l.OrderID = o.OrderID
order by StateProfit  desc
