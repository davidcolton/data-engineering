## Question 1. Understanding docker first run 

Run docker with the `python:3.12.8` image in an interactive mode, use the entrypoint `bash`.

What's the version of `pip` in the image?

- 24.3.1
- 24.2.1
- 23.3.1
- 23.2.1

## Answer 1.

`24.3.1`

```bash
podman run -it --entrypoint=bash python:3.12.8
root@5abc3f8aaa0a:/# pip --version
pip 24.3.1 from /usr/local/lib/python3.12/site-packages/pip (python 3.12)
```

---

## Question 2. Understanding Docker networking and docker-compose

Given the following `docker-compose.yaml`, what is the `hostname` and `port` that **pgadmin** should use to connect to the postgres database?

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin  

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```

- postgres:5433
- localhost:5432
- db:5433
- postgres:5432
- db:5432

## Answer 2.

`postgres:5432`

---

## Question 3. Trip Segmentation Count

During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, **respectively**, happened:

1. Up to 1 mile
2. In between 1 (exclusive) and 3 miles (inclusive),
3. In between 3 (exclusive) and 7 miles (inclusive),
4. In between 7 (exclusive) and 10 miles (inclusive),
5. Over 10 miles 

Answers:

- 104,802;  197,670;  110,612;  27,831;  35,281
- 104,802;  198,924;  109,603;  27,678;  35,189
- 104,793;  201,407;  110,612;  27,831;  35,281
- 104,793;  202,661;  109,603;  27,678;  35,189
- 104,838;  199,013;  109,645;  27,688;  35,202

## Answer 3.

`104,802;  198,924;  109,603;  27,678;  35,189`

``` sql
select count(*) as "Less than 1 mile"
from   green_taxi_data 
where  DATE(lpep_pickup_datetime) >= '2019-10-01'
and    DATE(lpep_dropoff_datetime) < '2019-11-01'
and    trip_distance <= 1;

select count(*) as "Between 1 and 3 miles"
from   green_taxi_data
where  DATE(lpep_pickup_datetime) >= '2019-10-01'
and    DATE(lpep_dropoff_datetime) < '2019-11-01'
and    trip_distance > 1
and    trip_distance <= 3;

select count(*) as "Between 3 and 7 miles"
from   green_taxi_data
where  DATE(lpep_pickup_datetime) >= '2019-10-01'
and    DATE(lpep_dropoff_datetime) < '2019-11-01'
and    trip_distance > 3
and    trip_distance <= 7;

select count(*) as "Between 7 and 10 miles"
from   green_taxi_data
where  DATE(lpep_pickup_datetime) >= '2019-10-01'
and    DATE(lpep_dropoff_datetime) < '2019-11-01'
and    trip_distance > 7
and    trip_distance <= 10;

select count(*) as "Less than 10 miles"
from   green_taxi_data
where  DATE(lpep_pickup_datetime) >= '2019-10-01'
and    DATE(lpep_dropoff_datetime) < '2019-11-01'
and    trip_distance > 10;
```

---

## Question 4. Longest trip for each day

Which was the pick up day with the longest trip distance?
Use the pick up time for your calculations.

Tip: For every day, we only care about one single trip with the longest distance. 

- 2019-10-11
- 2019-10-24
- 2019-10-26
- 2019-10-31

## Answer 4.

Pickup Day:`"2019-10-31 23:23:41"`

Trip Distance: `515.89` miles

```sql
select   lpep_pickup_datetime, trip_distance
from     green_taxi_data
where    trip_distance = ( 
  select max(trip_distance)
  from   green_taxi_data
);
```

---

## Question 5. Three biggest pickup zones

Which were the top pickup locations with over 13,000 in
`total_amount` (across all trips) for 2019-10-18?

Consider only `lpep_pickup_datetime` when filtering by date.

- East Harlem North, East Harlem South, Morningside Heights
- East Harlem North, Morningside Heights
- Morningside Heights, Astoria Park, East Harlem South
- Bedford, East Harlem North, Astoria Park

## Answer 5.

```
"East Harlem North"
"East Harlem South"
"Morningside Heights"
```

```sql
select "Zone"
from   public.zone_data
where  "LocationID" in (
	select		"PULocationID"
	from			green_taxi_data
	where			DATE(lpep_pickup_datetime) = '2019-10-18'
	group by	"PULocationID"
	having 		sum(total_amount) > 13000
	order by 	1 desc
	limit 		3
)
```

---

## Question 6. Largest tip

For the passengers picked up in October 2019 in the zone
name "East Harlem North" which was the drop off zone that had
the largest tip?

Note: it's `tip` , not `trip`

We need the name of the zone, not the ID.

- Yorkville West
- JFK Airport
- East Harlem North
- East Harlem South

## Answer 6.

Drop Off Zone: `"JFK Airport"`

Tip Amount: `87.3`

```sql
select 		zdd."Zone", tip_amount
from			public.green_taxi_data as gtd
join			public.zone_data as zdp
on				gtd."PULocationID" = zdp."LocationID"
join			public.zone_data as zdd
on				gtd."DOLocationID" = zdd."LocationID"
where			DATE(lpep_pickup_datetime) >= '2019-10-01'
and				DATE(lpep_pickup_datetime) <= '2019-10-31'
and				zdp."Zone" = 'East Harlem North'
order by	2 desc
limit 1;
```

---

## Question 7. Terraform Workflow

Which of the following sequences, **respectively**, describes the workflow for: 

1. Downloading the provider plugins and setting up backend,
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform`

Answers:

- terraform import, terraform apply -y, terraform destroy
- teraform init, terraform plan -auto-apply, terraform rm
- terraform init, terraform run -auto-approve, terraform destroy
- terraform init, terraform apply -auto-approve, terraform destroy
- terraform import, terraform apply -y, terraform rm

## Answer 7.

`terraform init, terraform apply -auto-approve, terraform destroy`

