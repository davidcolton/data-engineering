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
