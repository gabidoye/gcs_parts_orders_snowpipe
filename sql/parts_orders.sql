-- Switch to the role with administrative privileges
-- The 'accountadmin' role is required to perform account-level operations such as creating databases and tables.
use role accountadmin;

-- Create a new database named 'snowpipe_demo'
-- This command creates a new database in Snowflake where data can be stored and managed. The 'snowpipe_demo' database will be used for the demonstration or experimentation purposes related to Snowpipe or other data ingestion methods.
create or replace database snowpipe_demo;


-- Create a new table named 'orders_data_lz'
-- The 'orders_data_lz' table is used to store order-related information for a manufacturing or e-commerce business.
-- The structure of the table includes the following columns:
--   - order_id: A unique identifier for each order (integer type).
--   - product: The name or identifier of the product being ordered (string type with a maximum length of 20 characters).
--   - quantity: The number of units of the product being ordered (integer type).
--   - order_status: The current status of the order (e.g., "Pending", "Shipped", "Delivered") (string type with a maximum length of 30 characters).
--   - order_date: The date the order was placed (date type).
create or replace table orders_data_lz(
    order_id int,                  -- Integer type for the order identifier
    product varchar(20),           -- String type with a max length of 20 for product name/ID
    quantity int,                  -- Integer type for the quantity of the product ordered
    order_status varchar(30),      -- String type with a max length of 30 for order status
    order_date date                -- Date type to store the date the order was placed
);


-- Create a Cloud Storage Integration in Snowflake
-- This integration allows Snowflake to securely access an external cloud storage location.
-- It creates a configuration that grants Snowflake the necessary permissions to read from the specified GCS bucket.
create or replace storage integration gcs_bucket_read_int
 type = external_stage             -- Type of the integration, external stage indicates access to an external location.
 storage_provider = gcs            -- Specifies the cloud storage provider (Google Cloud Storage in this case).
 enabled = true                    -- Enables the integration after creation.
 storage_allowed_locations = ('gcs://data_for_snowpipe_demo/');  -- Specifies the allowed location(s) in the external cloud storage.

-- Optional: Drop integration if needed
-- drop integration gcs_bucket_read_int;

-- Retrieve the Cloud Storage Service Account for your Snowflake account
-- The 'desc' command provides metadata and details about the created storage integration.
desc storage integration gcs_bucket_read_int;

-- Service account info for storage integration
-- This is the service account associated with the storage integration.
-- kkni00000@gcpuscentral1-1dfa.iam.gserviceaccount.com

-- A stage in Snowflake refers to an external or internal location where data is stored before being loaded into Snowflake tables.
-- Here, a stage is created for accessing data stored in GCS.
create or replace stage snowpipe_stage
  url = 'gcs://data_for_snowpipe_demo/'    -- URL of the external GCS bucket to be used for data ingestion.
  storage_integration = gcs_bucket_read_int;  -- The storage integration created earlier, providing access to GCS.

-- Show stages to list all available stages
show stages;

-- List files in the specified stage, useful for verifying data availability
list @snowpipe_stage;

-- Create PUB-SUB Topic and Subscription
-- Google Cloud Storage events are sent to a Pub/Sub topic. This command triggers event notifications.
-- Example command: gsutil notification create -t snowpipe_pubsub_topic -f json gs://data_for_snowpipe_demo/

-- Create a notification integration that connects Snowflake to the GCP Pub/Sub system for event-driven data ingestion
create or replace notification integration notification_from_pubsub_int
 type = queue                         -- Type of the integration; queue indicates a notification system using Pub/Sub.
 notification_provider = gcp_pubsub    -- Specifies that Google Cloud Pub/Sub is used for notifications.
 enabled = true                        -- Enables the integration after creation.
 gcp_pubsub_subscription_name = 'projects/amiable-anagram-446201-h1/subscriptions/snowpipe_pubsub_topic-sub';  -- GCP Pub/Sub subscription name to listen for notifications.

-- Describe the created notification integration to check its details
desc integration notification_from_pubsub_int;

-- Service account for PUB-SUB
-- The service account associated with the Pub/Sub notification integration.
-- kypi00000@gcpuscentral1-1dfa.iam.gserviceaccount.com

-- Create Snow Pipe to load data automatically into Snowflake when new files arrive in the external stage
-- Snowpipe is a serverless, continuous data ingestion service in Snowflake. It loads data automatically based on notifications from the cloud storage or other event sources.
Create or replace pipe gcs_to_snowflake_pipe
auto_ingest = true                             -- Automatically ingest data from the stage when new files arrive.
integration = notification_from_pubsub_int     -- Use the notification integration created earlier to trigger data loading.
as
copy into orders_data_lz                      -- The target table where data will be loaded.
from @snowpipe_stage                           -- The external stage that contains the data to be ingested.
file_format = (type = 'CSV');                  -- Specifies that the file format is CSV.

-- Show pipes to list all existing pipes in Snowflake
show pipes;

-- Check the status of the pipe to ensure data loading is working correctly
select system$pipe_status('gcs_to_snowflake_pipe');

-- Retrieve historical information about the copy operations performed by Snowpipe
Select * 
from table(information_schema.copy_history(table_name=>'orders_data_lz', start_time=> dateadd(hours, -1, current_timestamp())));

-- Check the current contents of the target table
select * from orders_data_lz;

-- Stop Snowpipe temporarily to pause automatic ingestion
ALTER PIPE gcs_to_snowflake_pipe SET PIPE_EXECUTION_PAUSED = true;

-- Start Snowpipe to resume automatic ingestion of new files
ALTER PIPE gcs_to_snowflake_pipe SET PIPE_EXECUTION_PAUSED = false;

-- Terminate (drop) the Snowpipe once it is no longer needed
drop pipe gcs_snowpipe;
