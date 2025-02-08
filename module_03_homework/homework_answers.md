## BIG QUERY SETUP:
Create an external table using the Yellow Taxi Trip Records.

```sql
CREATE OR REPLACE EXTERNAL TABLE 
    `excellent-camp-448020-t0.zoomcamp.external_yellow_tripdata`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://de_zoomcamp_yello_taxi_dc/*.parquet'] -- Wildcard for multiple files
);
```



Create a (regular/materialised) table in BQ using the Yellow Taxi Trip Records (do not partition or cluster this table). 

```sql
CREATE OR REPLACE TABLE 
    `excellent-camp-448020-t0.zoomcamp.yellow_tripdata_non_partitoned` 
AS 
SELECT * 
FROM `excellent-camp-448020-t0.zoomcamp.external_yellow_tripdata`;
```

## Question 1:

Question 1: What is count of records for the 2024 Yellow Taxi Data?

- 65,623
- 840,402
- 20,332,093
- 85,431,289

## Answer 1:

`20,332,093`



## Question 2:

Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.
What is the **estimated amount** of data that will be read when this query is executed on the External Table and the Table?

- 18.82 MB for the External Table and 47.60 MB for the Materialized Table
- 0 MB for the External Table and 155.12 MB for the Materialized Table
- 2.14 GB for the External Table and 0MB for the Materialized Table
- 0 MB for the External Table and 0MB for the Materialized Table

## Answer 2:

0 MB for the External Table and 155.12 MB for the Materialized Table

```sql
SELECT DISTINCT PULocationID
FROM `excellent-camp-448020-t0.zoomcamp.external_yellow_tripdata`;

SELECT DISTINCT PULocationID
FROM `excellent-camp-448020-t0.zoomcamp.yellow_tripdata_non_partitoned`;
```



## Question 3:

Write a query to retrieve the PULocationID form the table (not the external table) in BigQuery. Now write a query to retrieve the PULocationID and DOLocationID on the same table. Why are the estimated number of Bytes different?

- BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires  reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.
- BigQuery duplicates data across multiple storage partitions, so selecting two columns instead of one requires scanning the table twice, doubling the estimated bytes processed.
- BigQuery automatically caches the first queried column, so adding a second column increases processing time but does not affect the estimated bytes scanned.
- When selecting multiple columns, BigQuery performs an implicit join operation between them, increasing the estimated bytes processed

## Answer 3:

BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires  reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.

`155.12 MB` vs `310.24 MB`

```sql
ELECT DISTINCT PULocationID
FROM `excellent-camp-448020-t0.zoomcamp.yellow_tripdata_non_partitoned`;

SELECT DISTINCT PULocationID, DOLocationID
FROM `excellent-camp-448020-t0.zoomcamp.yellow_tripdata_non_partitoned`;
```



## Question 4:

How many records have a fare_amount of 0?

- 128,210
- 546,578
- 20,188,016
- 8,333

## Answer 4:

`8,333`

```sql
SELECT COUNT(*)
FROM `excellent-camp-448020-t0.zoomcamp.yellow_tripdata_non_partitoned`
WHERE fare_amount = 0;
```



## Question 5:

What is the best strategy to make an optimized table in Big Query if your query will always filter based on tpep_dropoff_timedate and order the results by VendorID (Create a new table with this strategy)

- Partition by tpep_dropoff_timedate and Cluster on VendorID
- Cluster on by tpep_dropoff_timedate and Cluster on VendorID
- Cluster on tpep_dropoff_timedate Partition by VendorID
- Partition by tpep_dropoff_timedate and Partition by VendorID

## Answer 5:

Partition by tpep_dropoff_datetime and Cluster on VendorID

> ### When to Use Partitioning & Clustering Together?
>
> If queries filter by date and another column, use both.
>
> Example:
>
> - Partition by `event_date`
> - Cluster by `customer_id`
>
> This speeds up queries that filter by date AND customer ID.
>
> **If unsure, start with partitioning (it's more  impactful on query performance and cost). Add clustering later if  additional optimization is needed.**

```sql
CREATE OR REPLACE TABLE 
    `excellent-camp-448020-t0.zoomcamp.yellow_tripdata_partitoned_clustered`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `excellent-camp-448020-t0.zoomcamp.external_yellow_tripdata`;
```



## Question 6:

Write a query to retrieve the distinct VendorIDs between tpep_dropoff_datetime
03/01/2024 and 03/15/2024 (inclusive)

Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 5 and note the estimated bytes processed. What are these values? 

Choose the answer which most closely matches.

- 12.47 MB for non-partitioned table and 326.42 MB for the partitioned table
- 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table
- 5.87 MB for non-partitioned table and 0 MB for the partitioned table
- 310.31 MB for non-partitioned table and 285.64 MB for the partitioned table

## Answer 6:

310.24 MB for non-partitioned table and 26.84 MB for the partitioned table

```sql
SELECT DISTINCT VendorID
FROM `excellent-camp-448020-t0.zoomcamp.yellow_tripdata_non_partitoned`
WHERE DATE(tpep_dropoff_datetime) BETWEEN '2024-03-01' AND '2024-03-15';

SELECT DISTINCT VendorID
FROM `excellent-camp-448020-t0.zoomcamp.yellow_tripdata_partitoned_clustered`
WHERE DATE(tpep_dropoff_datetime) BETWEEN '2024-03-01' AND '2024-03-15';
```



## Question 7: 

Where is the data stored in the External Table you created?

- Big Query
- Container Registry
- GCP Bucket
- Big Table

## Answer 7:

`GCP Bucket`



## Question 8:

It is best practice in Big Query to always cluster your data:

- True
- False

## Answer 8:

`False`

> While clustering is often beneficial in BigQuery, it's not a *universal* best practice to *always* cluster your data.  There are situations where clustering might not be the best approach or might even be detrimental.
>
> Here's a more nuanced view:
>
> **When Clustering is Highly Recommended:**
>
> - **Large Tables:** Clustering is most effective on large tables (terabytes in size and above).  The performance gains are more significant as the table size increases.
>
> - Frequently Filtered/Aggregated Data:
>
>    If you frequently filter or aggregate your data based on specific columns, clustering on those columns can drastically improve query performance.
>
>   BigQuery can prune partitions and blocks more efficiently, reducing the amount of data scanned.
>
> - Data Warehousing/Analytics:
>
>    In data warehousing and analytical workloads where you're often querying large datasets with filters, clustering is usually a very good idea.
>
> **When Clustering Might Not Be Necessary or Advisable:**
>
> - **Small Tables:** For very small tables (gigabytes or smaller), the overhead of clustering might outweigh the benefits.  BigQuery is already very fast at querying small tables.
>
> - **Infrequently Queried Tables:** If a table is rarely queried, clustering might not be worth the cost (there is a small cost associated with clustering).
>
> - **Tables with Random Access Patterns:** If your queries access data randomly across the table and don't involve filtering on specific columns, clustering might not provide much benefit.
>
> - Write-Heavy Workloads:
>
>     Clustering can slightly increase the cost of data ingestion because BigQuery needs to maintain the clustered order.
>
>    If you have a very write-heavy workload and read performance is less of a concern, you might consider skipping clustering.
>
> - **Data that is already naturally clustered:** Sometimes data arrives in a way that it is already naturally clustered by time or another column. In these cases, clustering might just add overhead with no actual performance gain.
>
> **Best Practices for Clustering:**
>
> - **Choose the Right Clustering Columns:** Select the columns that are most frequently used in `WHERE` clauses, `JOIN` conditions, or `GROUP BY` clauses.  These are the columns that will provide the most benefit from clustering.
>
> - Consider Multiple Clustering Columns:
>
>    You can cluster on multiple columns (up to four).  The order of the columns matters.
>
>     The first column is the primary clustering key, the second is the secondary, and so on.
>
> - **Test and Monitor:**  It's always a good idea to test the performance of your queries with and without clustering to see the actual impact.  Monitor query performance over time and adjust your clustering strategy if needed.
>
> - Partitioning and Clustering:
>
>   Clustering works very well in conjunction with partitioning.
>
>     Partitioning divides the table into smaller, manageable chunks, and clustering further optimizes the data within each partition. This is often an excellent strategy for large tables.
>
> **In Summary:**
>
> Clustering is a powerful technique for optimizing query performance in BigQuery, especially for large, frequently queried tables. However, it's not a "one-size-fits-all" solution.  Consider your specific workload, table size, and query patterns to determine if clustering is the right choice.  When in doubt, test and monitor!
