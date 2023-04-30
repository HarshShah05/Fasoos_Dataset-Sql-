
use Fasoos
drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2020 21:30:45','25km','25mins',null),
(8,2,'01-10-2020 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2020 18:50:20','10km','10minutes',null);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;


--1 How many roles were ordered?

select sum(rolls_ordered_per_person) as total_rolls_ordered from
(select customer_id, count(order_id) as rolls_ordered_per_person
from customer_orders
group by customer_id)a

--alternative
select count(roll_id) as total_rolls_ordered
from customer_orders


--2.How many unique customer order were made?
select customer_id, count(order_id) as rolls_ordered_per_person
from customer_orders
group by customer_id

--alternative
select count(distinct customer_id) as total_customers
from customer_orders


--3 How many successfull orders were delivered by each driver ?
--one was cancelled by driver 3, other by driver 2
--driver one had all 4 deliveries proper.
select driver_id,sum(Succesful_deliveries) as Total_successful_deliveries
from (
select driver_id,cancellation, count(distinct(order_id)) as Orders_delivered,
case when cancellation='Cancellation' or cancellation='Customer Cancellation' then count(order_id) -1 
when  cancellation!='Cancellation' or cancellation!='Customer Cancellation'  then count(order_id)
when cancellation IS NULL or cancellation='' then count(order_id)
end as Succesful_deliveries
from driver_order
group by driver_id,cancellation) a
group by driver_id


--4 How many of each type of roll was ordered

select roll_id,count(roll_id) as Count,
case when roll_id=2 then 'VegRoll'
when roll_id=1 then 'Non-veg-roll'
end as Roll_type
from customer_orders
group by roll_id

--5 How many of each type of roll was delivered

select roll_id,sum(Status) as Delivered_rolls ,
case when roll_id=1 then 'Non-veg-Roll'
when roll_id=2 then 'Veg-roll'
end as Roll_type 
from
(select a.roll_id,b.cancellation,count(a.roll_id) as Count,
case when cancellation='Cancellation' or cancellation='Customer Cancellation' then count(a.roll_id) -1 
when  cancellation!='Cancellation' or cancellation!='Customer Cancellation'  then count(a.roll_id)
when cancellation IS NULL or cancellation='' then count(a.roll_id)
end as Status
from customer_orders a
inner join driver_order b on a.order_id=b.order_id
group by roll_id,cancellation)a
group by roll_id


--6 How many veg and non_veg rolls were ordered by each customer
--insight--all customers ordered Non-veg more than Veg as roll_id 1 is Non-veg
select * from customer_orders;
select * from rolls;


select *,rank() over(partition by customer_id order by No_of_times_Ordered desc) rank from
(select a.customer_id,a.roll_id,b.roll_name,count(a.roll_id) as No_of_times_Ordered
from customer_orders a
inner join rolls b on a.roll_id=b.roll_id
group by customer_id,a.roll_id,b.roll_name)c

--7 What are maximum no_of_rolls ordered in single order
--already ek baar group by kardiya so dont do it again ...so no need of writing partition again coz if we write all will be treated indivually and sabka rank 1 aayega
--but zomato_wale mai toh aisa kuch nhi hua tha
select*,rank() over( order by Order1 desc) rank from
(select order_id,count(roll_id) as Order1
from customer_orders
group by order_id)a



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Cleaning Data for further queries.
--Using cte to make temporary tables

---Cleaning customer data
--Cleaning driver data
--0 stands for cancelation
--1 stands for not cancelled



--write 0 as  a string because varchar is defined while defining schema....so we need to write 0 as string.

--8 For each customer , how many delivered rolls had at least 1 change and how many had no changes ?
with temp_cust_orders (order_id,customer_id,roll_id,new_not_include_items,new_extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items=' ' then '0' else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included =' 'or extra_items_included='Nan'  then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
)
,
 temp_driver_data  (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,distance,duration,
case when cancellation in ('Cancellation','Customer Cancellation') then 0 else 1 end as new_cancellation
from driver_order
)

select customer_id,Status,count(Status)as Count from
(select * ,
case when new_not_include_items='0' and new_extra_items_included ='0' then 'No change' else 'Change'
end as Status 
from temp_cust_orders 
where order_id in
(select order_id from temp_driver_data where new_cancellation!=0))a
group by customer_id,Status


--9 How many rolls had both inclusions and exclusions
with temp_cust_orders (order_id,customer_id,roll_id,new_not_include_items,new_extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items=' ' then '0' else not_include_items end as new_not_include_items,
case when extra_items_included is null or extra_items_included =' 'or extra_items_included='Nan'  then '0' else extra_items_included end as new_extra_items_included,
order_date from customer_orders
)
,
 temp_driver_data  (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,distance,duration,
case when cancellation in ('Cancellation','Customer Cancellation') then 0 else 1 end as new_cancellation
from driver_order
)


select Status,count(Status) as Count from
(select * ,
case when new_not_include_items!='0' and new_extra_items_included !='0' then 'Both Changes' 
 when new_not_include_items!='0' and new_extra_items_included ='0' then 'Exclusion Change'
 when new_not_include_items='0' and new_extra_items_included !='0' then 'Inclusion Change'
 when new_not_include_items='0' and new_extra_items_included ='0' then 'No Change'
end as Status 
from temp_cust_orders 
where order_id in
(select order_id from temp_driver_data where new_cancellation!=0))a
group by Status



--10 What were total roles ordered for each hour of day of day
select* from customer_orders


select hour,count(order_id) as Count from
(select *, DATEPART(hour,order_date) hour
from customer_orders)a
group by hour
order by Count desc

--Bucket-size
select Hour_Bucket,count(Hour_Bucket) Bucket_Size from
(select*, concat(cast(datepart(hour, order_date)as varchar) ,'-',  cast(datepart(hour,order_date)+1 as varchar)) as Hour_Bucket
from customer_orders)a
group by Hour_Bucket


--11 What were orders for each day of week

--SELECT DATEPART(year, '12:10:30.123')  
   -- ,DATEPART(month, '12:10:30.123')  
   -- ,DATEPART(day, '12:10:30.123')  
   -- ,DATEPART(dayofyear, '12:10:30.123')  
   -- ,DATEPART(weekday, '12:10:30.123');


select Day_of_week,count(distinct order_id) Bucket_Size from
(select*, datename(DW, order_date)as Day_of_week
from customer_orders)a
group by Day_of_week
order by Bucket_Size desc


---Driver and customer metrics
--12 What is average time in minutes for each driver to arrive at the fasoos HQ to pickup order.(Hq--headquater)


select a.*,b.pickup_time, DATEDIFF(minute,a.order_date,b.pickup_time) as Time_they_reached
from customer_orders a 
inner join driver_order b on a.order_id=b.order_id




--13.Is there any relationship between number of rolls and how long the order takes to prepare.
--We can say average role making time is 10 min.

select order_id,count(roll_id)as No_of_rolls, sum(Time_they_reached)/count(roll_id) as Total_time from
(select a.*,b.pickup_time, DATEDIFF(minute,a.order_date,b.pickup_time) as Time_they_reached
from customer_orders a
inner join driver_order b on a.order_id=b.order_id)a
group by order_id



--14 Average distance travelled for each customer
select* from customer_orders
select* from driver_order


select a.customer_id,sum(New_distance)/count(distinct(order_id)) as Averag_time_per_order,count(distinct(order_id)) as total_order_placed,sum(New_distance) as total_distance from
(select a.*, cast(trim(replace(b.distance,'km',' '))as decimal(4,2))as New_distance
from customer_orders a
inner join driver_order b on a.order_id=b.order_id
where a.order_id in
(
select order_id 
from driver_order 
where cancellation not in ('Cancellation','Customer Cancellation') or cancellation is null or cancellation=' ' 
))a
group by a.customer_id

--15 What was difference between largest and shortest delivery times for all orders


--First clean the data
--Step 0 --We will need to write case like %min% ie which contains minutes only check for those
--Step 1---Get the index of m
--Step 2--Do -1 to get just one index 
--Step3--Now we can use left function to only extract digits
--Step4--use cast to convert to integer


select duration from
driver_order

select max(New_duration) -min(New_duration)as Difference from
(select duration ,
cast(case when duration like '%min%'  then left(duration, CHARINDEX('m',duration)-1) else duration
end as integer )as New_duration
from driver_order)a


--16.What was average speed for each driver and do you notice any trend from these values?

--calculating indivsual speed

select driver_id,count(order_id) as total_orders, sum(Speed)/count(order_id) as Average_speed from
(select *,(New_distance/New_duration) as Speed from
(select*,cast(trim(replace(distance,'km',' ')) as decimal(4,2))as New_distance,
cast(case when duration like '%min%'  then left(duration, CHARINDEX('m',duration)-1) else duration
end as integer )as New_duration
from driver_order where pickup_time is not null)a)b
group by driver_id


--17..What is successfull delivery percentage  for each driver

--1.0 for getting 3/4 as 0.75 and 1/2 as 0.5

select driver_id ,count(new_status) as total_delivery , sum(new_status) as  good_delivery, (sum(new_status)*1.0/count(new_status))*100 as Percentage from
(select*,
case when cancellation in('Cancellation' , 'Customer Cancellation') then 0 else 1
end as new_status
from driver_order)a
group by driver_id
