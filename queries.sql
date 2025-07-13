/*SQL ASSIGNMENT:*/

/*1. Sales Performance by Region 
● Question: What is the total sales amount by region? 
● Hint: Use the sales and customer tables to join the data based on customer_id.*/
select a.region,sum(b.sales) as total_sales 
from customer as a
join sales as b
on a.customer_id = b.customer_id
group by 1;

/*2. Top-Selling Products 
● Question: Which products generated the most sales?
 ● Hint: Join the sales and product tables on product_id and sum the sales column.*/
select a.product_name,sum(b.sales) as total_sales
from product as a
join sales as b
on a.product_id = b.product_id
group by 1
order by 2 desc;

/*3. Discount Impact on Profit
 ● Question: How does the discount affect profit?
 ● Hint: Query the sales table to compare profit and discount.*/
select discount, sum(profit) as total_profit from sales
group by 1
order by 1 desc;

/*4. Sales by Customer Segment 
● Question: How much sales does each customer segment contribute?
 ● Hint: Use the sales and customer tables, grouping the data by segment*/
select a.segment, sum(b.sales) as total_sales
from customer as a
join sales as b
on a.customer_id = b.customer_id
group by 1;

/*5. Product Category Sales 
● Question: What are the total sales for each product category?
 ● Hint: Join the sales and product tables, grouping by category*/
select a.category, sum(b.sales) as total_sales
from product as a
join sales as b
on a.product_id=b.product_id
group by 1
order by 2 desc;

/*6. Customer Orders by Ship Mode 
● Question: How many orders were shipped by each shipping mode? 
● Hint: Use the sales table and group by ship_mode*/
select count(order_id) as total_orders, ship_mode from sales
group by 2;

/*7. Sales by Date 
● Question: What are the total sales for each month? 
● Hint: Use the order_date column from the sales table to group the data by month.*/
select sum(sales) as total_sales, extract('month' from order_date) as month from sales
group by 2
order by month;

/*8. Customer Distribution by State 
● Question: How many customers are there in each state? 
● Hint: Query the customer table and group the data by state.*/
select count(customer_id) as customer_count, state from customer
group by 2
order by 1 desc;

/*9. Top 5 Customers by Sales 
● Question: Who are the top 5 customers in terms of total sales? 
● Hint: Use the sales and customer tables to sum sales per customer, then sort by sales.*/
select a.customer_name, sum(b.sales) as totalsales
from customer as a
join sales as b
on a.customer_id = b.customer_id
group by 1
order by 2 desc
limit 5;

/*10. Product Performance in Subcategories 
● Question: What is the total sales for each product subcategory? 
● Hint: Join the sales and product tables, grouping by sub_category.*/
select a.sub_category as subcategory, sum(b.sales) as totalsales
from product as a
join sales as b
on a.product_id = b.product_id
group by 1
order by 2 desc;

/*11. Rank Products by Sales 
● Question: How can we rank products by their total sales within each product category? 
● Hint: Use the RANK() window function. You'll need to partition the data by category and order by total sales for each product*/
select a.category,a.product_name,sum(b.sales) as totalsales,
rank() over(partition by a.category order by sum(b.sales) desc) as sales_rank
from product as a
join sales as b
on a.product_id = b.product_id
group by a.category, a.product_name
order by a.category, totalsales DESC;

/*12. Cumulative Sales by Date 
● Question: How can we calculate cumulative sales over time (running total) for each product? 
● Hint: Use the SUM() window function with an ORDER BY clause on order_date to create a running total for each product.*/
select a.product_name,b.order_date, sum(b.sales) as dailysales,
sum(sum(b.sales)) over(partition by a.product_name order by b.order_date) as runningtotal
from product as a
join sales as b
on a.product_id = b.product_id
group by a.product_name, b.order_date
order by runningtotal desc;

/*13. Find Top 3 Customers by Profit 
● Question: How can we find the top 3 customers based on profit within each region? 
● Hint: Use RANK() or DENSE_RANK() to assign ranks within each region based on total profit, and filter for the top 3 using HAVING.*/
select * from(
select a.customer_name,a.region,sum(b.profit) as totalprofit,
dense_rank() over(partition by a.region order by sum(b.profit) desc) as profit_rank
from customer as a
join sales as b
on a.customer_id = b.customer_id
group by a.customer_name,a.region)
as ranked_cust
where profit_rank <=3
order by region, profit_rank;

/*14. Average Sales by Segment with Row Number 
● Question: How can we find the average sales for each segment and assign a row number to each customer based on their sales? 
● Hint: Use the AVG() window function to calculate average sales for each segment, and ROW_NUMBER() to assign a number to each row within the segment.*/
select customer_name,segment,avg_sales,
row_number() over(partition by segment order by avg_sales desc) as row_num 
from (
select a.customer_name,a.segment, avg(b.sales) as avg_sales
from customer as a
join sales as b
on a.customer_id = b.customer_id
group by 1,2)
as avg_data
order by segment,row_num;

/*15. Difference in Sales Between Consecutive Days 
● Question: How can we calculate the difference in sales between consecutive days for each product? 
● Hint: Use LAG() to access the sales value from the previous day and subtract it from the current day’s sales*/
select a.product_name,sum(b.sales) as daily_sales,b.order_date,
lag (sum(b.sales)) over(partition by a.product_name order by b.order_date)
as previous_day_sales,
sum(b.sales) - lag (sum(b.sales)) over(partition by a.product_name order by b.order_date) as sales_diff
from product as a
join sales as b
on a.product_id = b.product_id
group by a.product_name, b.order_date
order by a.product_name desc;

/*16. Find Percent of Total Sales by Region 
● Question: How can we calculate the percentage of total sales contributed by each region? 
● Hint: Use the SUM() window function to calculate the total sales for all regions and then divide individual region sales by the total.*/
select a.region,(sum(b.sales)) as totalsales, Round(sum(b.sales)*100/sum(sum(b.sales)) over () ) as percent_total
from customer as a
join sales as b
on a.customer_id = b.customer_id
group by 1
order by 2 desc;

/*17. Calculate Moving Average of Sales
 ● Question: How can we calculate the moving average of sales over the last 3 orders for each product? 
● Hint: Use AVG() with the ROWS BETWEEN clause to calculate the moving average over the previous 2 rows and the current row*/
select a.product_name, b.order_date,b.sales,
avg(b.sales) over (partition by a.product_name order by b.order_date rows between 2 preceding and current row )
as moving_avg_sales
from product as a 
join sales as b
on a.product_id = b.product_id
group by 1,2,3
order by 1 desc;

/*18. Find Largest and Smallest Order by Customer 
● Question: How can we find the largest and smallest order (by sales) for each customer?
 ● Hint: Use MAX() and MIN() window functions to find the largest and smallest sales amounts for each customer*/
select a.customer_name,b.order_id,b.sales,
max(b.sales) over (partition by a.customer_name) as Large_order_by_cust,
min(b.sales) over (partition by a.customer_name) as small_order_by_cust
from customer as a
join sales as b
on a.customer_id = b.customer_id
order by a.customer_name, b.sales desc;

/*19. Running Total of Profit by Customer 
● Question: How can we calculate the running total of profit for each customer? 
● Hint: Use SUM() with the ORDER BY clause to calculate the running total of profit for each customer based on their order date.
select a.customer_name,b.order_date,
sum(b.profit) over (partition by a.customer_name order by b.order_date) as running_total
from customer as a
join sales as b
on a.customer_id = b.customer_id
order by 1;

/*20. Calculate Dense Rank of Sales by Ship Mode 
● Question: How can we assign a dense rank to each sale based on total sales, grouped by ship mode? 
● Hint: Use the DENSE_RANK() function to assign ranks based on sales within each ship_mode*/
select ship_mode,total_sales,
dense_rank() over(order by total_sales desc) as rank_tsales
from (
select ship_mode, sum(sales) as total_sales
from sales
group by ship_mode)
as ship_sales;
