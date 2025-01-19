-- Question 3
select count(*) as "Less than 1 mile"
from green_taxi_data
where DATE(lpep_pickup_datetime) >= '2019-10-01'
    and DATE(lpep_dropoff_datetime) < '2019-11-01'
    and trip_distance <= 1;
select count(*) as "Between 1 and 3 miles"
from green_taxi_data
where DATE(lpep_pickup_datetime) >= '2019-10-01'
    and DATE(lpep_dropoff_datetime) < '2019-11-01'
    and trip_distance > 1
    and trip_distance <= 3;
select count(*) as "Between 3 and 7 miles"
from green_taxi_data
where DATE(lpep_pickup_datetime) >= '2019-10-01'
    and DATE(lpep_dropoff_datetime) < '2019-11-01'
    and trip_distance > 3
    and trip_distance <= 7;
select count(*) as "Between 7 and 10 miles"
from green_taxi_data
where DATE(lpep_pickup_datetime) >= '2019-10-01'
    and DATE(lpep_dropoff_datetime) < '2019-11-01'
    and trip_distance > 7
    and trip_distance <= 10;
select count(*) as "Less than 10 miles"
from green_taxi_data
where DATE(lpep_pickup_datetime) >= '2019-10-01'
    and DATE(lpep_dropoff_datetime) < '2019-11-01'
    and trip_distance > 10;
-- Question 4
select lpep_pickup_datetime,
    trip_distance
from green_taxi_data
where trip_distance = (
        select max(trip_distance)
        from green_taxi_data
    );
-- Question 5
select "Zone"
from public.zone_data
where "LocationID" in (
        select "PULocationID"
        from green_taxi_data
        where DATE(lpep_pickup_datetime) = '2019-10-18'
        group by "PULocationID"
        having sum(total_amount) > 13000
        order by 1 desc
        limit 3
    );
-- Question 6    
select zdd."Zone",
    tip_amount
from public.green_taxi_data as gtd
    join public.zone_data as zdp on gtd."PULocationID" = zdp."LocationID"
    join public.zone_data as zdd on gtd."DOLocationID" = zdd."LocationID"
where DATE(lpep_pickup_datetime) >= '2019-10-01'
    and DATE(lpep_pickup_datetime) <= '2019-10-31'
    and zdp."Zone" = 'East Harlem North'
order by 2 desc
limit 1;