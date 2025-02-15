## **Question 1: dlt Version**

1. **Install dlt**:

```
!pip install dlt[duckdb]
```

> Or choose a different bracket—`bigquery`, `redshift`, etc.—if you prefer another primary destination. For this assignment, we’ll still do a quick test with DuckDB.

2. **Check** the version:

```
!dlt --version
```

or:

```py
import dlt
print("dlt version:", dlt.__version__)
```

Provide the **version** you see in the output.

## Answer 1: dlt Version

```bash
▶ dlt --version
dlt 1.6.1

▶ python dlt_version.py
dlt version: 1.6.1
```

```python
import dlt
print("dlt version:", dlt.__version__)
```



## **Question 2: Define & Run the Pipeline (NYC Taxi API)**

Use dlt to extract all pages of data from the API.

Steps:

1️⃣ Use the `@dlt.resource` decorator to define the API source.

2️⃣ Implement automatic pagination using dlt's built-in REST client.

3️⃣ Load the extracted data into DuckDB for querying.

```py
import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.paginators import PageNumberPaginator

# your code is here

pipeline = dlt.pipeline(
    pipeline_name="ny_taxi_pipeline",
    destination="duckdb",
    dataset_name="ny_taxi_data"
)
```

Load the data into DuckDB to test:

```py
load_info = pipeline.run(ny_taxi)
print(load_info)
```

Start a connection to your database using native `duckdb` connection and look what tables were generated:"""

```py
import duckdb
from google.colab import data_table
data_table.enable_dataframe_formatter()

# A database '<pipeline_name>.duckdb' was created in working directory so just connect to it

# Connect to the DuckDB database
conn = duckdb.connect(f"{pipeline.pipeline_name}.duckdb")

# Set search path to the dataset
conn.sql(f"SET search_path = '{pipeline.dataset_name}'")

# Describe the dataset
conn.sql("DESCRIBE").df()

```

How many tables were created?

## Answer 2: How many tables were created?

`4`

```python
import dlt
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.paginators import PageNumberPaginator

import duckdb
import pandas as pd
import numpy as np

base_url = "https://us-central1-dlthub-analytics.cloudfunctions.net"


# Define the API resource for NYC taxi data
@dlt.resource(name="rides")
def ny_taxi():
    client = RESTClient(
        base_url=base_url,
        paginator=PageNumberPaginator(base_page=1, total_path=None),
    )

    for page in client.paginate("data_engineering_zoomcamp_api"):
        yield page


pipeline = dlt.pipeline(
    pipeline_name="ny_taxi_pipeline",
    destination="duckdb",
    dataset_name="ny_taxi_data",
)

load_info = pipeline.run(ny_taxi, write_disposition="replace")
print(load_info)

# Connect to the DuckDB database
conn = duckdb.connect(f"{pipeline.pipeline_name}.duckdb")

# Set search path to the dataset
conn.sql(f"SET search_path = '{pipeline.dataset_name}'")

# Describe the dataset (Question 02 Answer)
print(f'There are {conn.sql("DESCRIBE").df().shape[0]} tables.')

# Explore the loaded Data (Question 03 Answer)
df = pipeline.dataset(dataset_type="default").rides.df()
print(f"The are {df.shape[0]} rows in the rides database.")

# Trip Duration Analysis (Question 04 Answer)
with pipeline.sql_client() as client:
    res = client.execute_sql(
        """
            SELECT
            AVG(date_diff('minute', trip_pickup_date_time, trip_dropoff_date_time))
            FROM rides;
        """
    )
    # Prints column values of the first row
    print(f"The average trip duration is {res[0][0]} minutes.")

```

| database         | schema       | name                | column_names                                                 | column_types                                                 | temporary |
| ---------------- | ------------ | ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | --------- |
| ny_taxi_pipeline | ny_taxi_data | _dlt_loads          | ['load_id' 'schema_name' 'status' 'inserted_at' 'schema_version_hash'] | ['VARCHAR' 'VARCHAR' 'BIGINT' 'TIMESTAMP WITH TIME ZONE' 'VARCHAR'] | False     |
| ny_taxi_pipeline | ny_taxi_data | _dlt_pipeline_state | ['version' 'engine_version' 'pipeline_name' 'state' 'created_at'  'version_hash' '_dlt_load_id' '_dlt_id'] | ['BIGINT' 'BIGINT' 'VARCHAR' 'VARCHAR' 'TIMESTAMP WITH TIME ZONE'  'VARCHAR' 'VARCHAR' 'VARCHAR'] | False     |
| ny_taxi_pipeline | ny_taxi_data | _dlt_version        | ['version' 'engine_version' 'inserted_at' 'schema_name' 'version_hash'  'schema'] | ['BIGINT' 'BIGINT' 'TIMESTAMP WITH TIME ZONE' 'VARCHAR' 'VARCHAR'  'VARCHAR'] | False     |
| ny_taxi_pipeline | ny_taxi_data | rides               | ['end_lat' 'end_lon' 'fare_amt' 'passenger_count' 'payment_type'  'start_lat' 'start_lon' 'tip_amt' 'tolls_amt' 'total_amt' 'trip_distance'  'trip_dropoff_date_time' 'trip_pickup_date_time' 'surcharge'  'vendor_name' '_dlt_load_id' '_dlt_id' 'store_and_forward'] | ['DOUBLE' 'DOUBLE' 'DOUBLE' 'BIGINT' 'VARCHAR' 'DOUBLE' 'DOUBLE' 'DOUBLE'  'DOUBLE' 'DOUBLE' 'DOUBLE' 'TIMESTAMP WITH TIME ZONE'  'TIMESTAMP WITH TIME ZONE' 'DOUBLE' 'VARCHAR' 'VARCHAR' 'VARCHAR'  'DOUBLE'] | False     |



## **Question 3: Explore the loaded data**

Inspect the table `ride`:

```py
df = pipeline.dataset(dataset_type="default").rides.df()
df
```

What is the total number of records extracted?

* 2500
* 5000
* 7500
* 10000

## Answer 3: Number of records extracted

`10000`

See the python for this answer in Question 2 above



## **Question 4: Trip Duration Analysis**

Run the SQL query below to:

* Calculate the average trip duration in minutes.

```py
with pipeline.sql_client() as client:
    res = client.execute_sql(
            """
            SELECT
            AVG(date_diff('minute', trip_pickup_date_time, trip_dropoff_date_time))
            FROM rides;
            """
        )
    # Prints column values of the first row
    print(res)
```

What is the average trip duration?

`12.3049`

```bash
▶ python dlt_homework.py
There are 4 tables.
The are 10000 rows in the rides database.
The average trip duration is 12.3049 minutes.
```

