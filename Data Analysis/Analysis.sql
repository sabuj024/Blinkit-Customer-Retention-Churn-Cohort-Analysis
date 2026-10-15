use blinkit_analytics;

-- to check the column details in the table
describe blinkit_data;

-- check few rows
select * from blinkit_data limit 10;

-- check overall bsuiness performance
select count(distinct order_id) as total_order,
       count(distinct customer_id) as total_customers,
       sum(case when lower(trim(order_status)) = "Delivered" then 1 else 0 end) as delivered_orders,
      sum(case when lower(trim(order_status)) = "cancelled" then 1 else 0 end) as cancelled_orders,
   round(sum(case when lower(order_status) = 'delivered' then final_amount else 0 end), 2) as total_revenue
from blinkit_data;

-- Monthly revenue trend
select date_format(order_date, '%Y-%m') as order_month,
       count(distinct order_id) as total_orders,
       round(sum(final_amount),2) as monthly_revenue
from   blinkit_data where lower(order_status) = "delivered"
group by date_format(order_date, '%Y-%m') order by order_month;

-- Customers who ordered more than once
select customer_id, count(distinct order_id) as total_orders
from blinkit_data where order_status = "Delivered"
group by customer_id having count(distinct order_id) >1;

-- Cancellation Reason
Select cancel_reason, count(distinct order_id) as cancelled_orders
from blinkit_data
where lower(order_status) = "cancelled"
group by cancel_reason  order by cancelled_orders desc;

-- Customers mark as churn
Select churn_flag, count(distinct customer_id) as total_customers
from blinkit_data group by churn_flag;

-- Group customers by their first delivered order month
select date_format(first_order_date, '%Y-%m') as chorot_month,
       count(*) as customers_aquired,
	   sum(case when total_orders > 1 then 1 else 0 end)
       as customers_who_ordered_again
from (
select customer_id, min(order_date) as first_order_date,
      count(distinct order_id) as total_orders
      from blinkit_data
      where lower(order_status) = "Delivered" group by customer_id
) as customer_summary
      group by date_format(first_order_date, '%Y-%m')
      order by chorot_month;
      
-- Citis with the most churn
select city,count(distinct customer_id) as churned_customers
from blinkit_data where churn_flag = 1
group by city order by churned_customers desc;
