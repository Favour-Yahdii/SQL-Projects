---Get to know the dataset
SELECT *
FROM [Hotel Reservations]
--- Data has 36,275 rows

---Check for duplicates based on booking ID
SELECT Booking_ID, COunt(Booking_ID)
FROM [Hotel Reservations]
GROUP BY Booking_ID
HAVING COUNT(Booking_ID) >1
---No duplicate values

---Check for missing values
SELECT Booking_ID
FROM [Hotel Reservations]
WHERE Booking_ID IS Null
---No missing values

---Total number of adults and children
SELECT SUM(no_of_adults)
from [Hotel Reservations]
---There are 66926 adults

SElect sum(no_of_children)
from [Hotel Reservations]
---3819 children

---There are 63,107 more adults than children Ratio: 0.9:0.005

---Ratio of weekend vs week night stays
SELECT SUM(no_of_weekend_nights)+SUM(no_of_week_nights) AS Total_nights
FROM [Hotel Reservations]
---109,370 total nights

---save the above as a view for future calculations
CREATE or alter view Total_nights
AS 
SELECT SUM(no_of_weekend_nights)+SUM(no_of_week_nights) AS Total_nights, 
Sum(no_of_weekend_nights) as weekends, sum(no_of_week_nights) as weekdays
FROM [Hotel Reservations];
GO

---Ratio of total nights that were weekends
Select * from Total_nights
---29409 were weekends
---79961 were weekdays
---Unexpected insight, more  information beyond the scope of this dataset is required to find out why, are there any weekday discounts? large offices nearby etc?

---average lead time
select AVG(lead_time)
from [Hotel Reservations]
---85 days on average pass from booking till actual stay, what can be done to reduce this time?

---average leaad time by market segment
select AVG(lead_time)
from [Hotel Reservations]
group by market_segment_type
---segment 5 has the least lead time, segment 4 has the highest. What demographic belong to these segments?

---number of guests that are repeated
select sum(cast (repeated_guest as int)) as repeat_guests
from [Hotel Reservations]
---out of 36,275 reservations only 930 are repeat guests, measures need to be put in place to ensure customer retention and reduce churn.

---meal plan types available
Select distinct type_of_meal_plan
from [Hotel Reservations]
---3 types of meal plans are available
---should we cancel the meal plan completely, is it worth it? 
select count(type_of_meal_plan)
from [Hotel Reservations]
where type_of_meal_plan = 'Not Selected'
---5130 reservations which is 14% of reservations did not select a meal plan.

---is average room price higher where a meal plan has been selected?
---first thing would be to add a new column for meal plan or no meal plan
alter table [Hotel Reservations]
add meal_plan int;

---when type of meal plan is not selected then meal plan would be 0, otherwise it would be 1.
update [Hotel Reservations]
set meal_plan =
case
when type_of_meal_plan = 'Meal Plan 1' then 1
when type_of_meal_plan = 'Meal Plan 2' then 1
when type_of_meal_plan = 'Meal Plan 3' then 1
else 0 end;

---back to the original question, is average room price higher when a meal plan is included? Let's find out!
select meal_plan, AVG(avg_price_per_room) as average_by_mealplan
from [Hotel Reservations]
group by meal_plan, booking_status
having booking_status = 'Not_Canceled'
---There is a slight difference in prices ($5 on average) between reservations that have a meal plan included and those that do not. 
---This could be an indication to make the hotel a bed and breakfast and make meal plans compulsory.

---What is the hotels busiest month?
with cte_busymonths as (
select arrival_month, count(arrival_month) as count
from [Hotel Reservations]
group by arrival_month
)
select arrival_month
from cte_busymonths
where count = (select max(count) from cte_busymonths)
---The hotel is busiest in the month of October. 
---This might mean the hotel may want to hire more staff for this month to ensure smooth running of activities.