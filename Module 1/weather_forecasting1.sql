SELECT * FROM weather_forecasting.weather;

#1 Give the count of the minimum number of days for the me when temperature reduced
SELECT COUNT(*)
FROM (
  SELECT temperature, dates,
         LAG(temperature) OVER (ORDER BY dates) AS prev_temp
  FROM  weather_forecasting.weather
) AS t
WHERE temperature < prev_temp;

#2.Find the temperature as Cold / hot by using the case and avg of values of the given data set
select temperature, case when Temperature < 
(select round(avg(Temperature),2) 
from  weather_forecasting.weather) 
then "cold" else "hot" end as result from weather_forecasting.weather;
-- subquery for comparing each and every value with temperature column

#3.	Can you check for all 4 consecutive days when the temperature was below 30 Fahrenheit?
SELECT FQ.DATES,FQ.DAY_PLUS_1, FQ.DAY_PLUS_2, FQ.DAY_PLUS_3, FQ.TEMPERATURE
FROM
(SELECT X1.*
FROM
(
  SELECT 
    T.DATES,
    DATE_ADD(T.DATES,INTERVAL 1 DAY) AS DAY_PLUS_1,
    LEAD(DATES,1) OVER(PARTITION BY YEARS ORDER BY DATES ) AS date_lead_1,
    DATE_ADD(T.DATES,INTERVAL 2 DAY) AS DAY_PLUS_2FQ,
    LEAD(DATES,2) OVER(PARTITION BY YEARS ORDER BY DATES ) AS date_lead_2,
    DATE_ADD(T.DATES,INTERVAL 3 DAY) AS DAY_PLUS_3,
    LEAD(DATES,3) OVER(PARTITION BY YEARS ORDER BY DATES ) AS date_lead_3,
    T.TEMPERATURE
  FROM
  (
    SELECT
	  YEARS,
      DATES,
      Maximum_temperature__°F as Temperature
      FROM weather_forecasting.weather
      WHERE Maximum_temperature__°F < 30
) AS T
) AS X1
WHERE X1.DAY_PLUS_1 = X1.date_lead_1 AND X1.DAY_PLUS_2 = X1.date_lead_2 AND X1.DAY_PLUS_3 = X1.date_lead_3) AS FQ;

#4.Give the count of the minimum number of days for the time when temperature reduced
select count(*)as max_days 
from 
(select w.Temperature as a,
lead(w.Temperature,1) over(partition by w.Years,w.Months order by w.Days 
) as b,
case when w.Temperature > lead(w.Temperature,1) over(partition by w.Years,w.Months order by w.Days ) then "p" else "q" end as result
from weather_forecasting.weather as w) as l 
where l.result = "p";

 #5.Can you find the average of average humidity from the dataset ---
SELECT months,avg(Average_humidity) 
FROM weather_forecasting.weather
group by months
order by months;

#6.Use the GROUP BY clause on the Date column and make a query to fetch details for average windspeed
delimiter $$
create procedure weather_forecasting(IN var1 float)
begin 
	select * from weather_forecasting.weather group by Dates;
end $$
delimiter ;
call weather_forecasting(41.4);

#Question8.	If the maximum gust speed increases from 55mph, fetch the details for the next 4 days
SELECT t.*
FROM (
  SELECT *, @prev_date := date prev_date,
         @prev_max_gust_speed := Maximum_gust_speed__mph prev_max_gust_speed
  FROM weather_forecasting.weather
) t
WHERE Maximum_gust_speed__mph = 55 AND @prev_max_gust_speed > 55
LIMIT 5;
#Note: There is no data more than 55 in DB that's why output is blank.

#Question9.	Find the number of days when the temperature went below 0 degrees Celsius 
SELECT count(distinct(dates)) FROM  weather_forecasting.weather where temperature<32;
