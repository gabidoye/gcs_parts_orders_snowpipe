# Snowflake Parts Orders Pipeline (Event-Driven Snowpipe)

This project demonstrates an event-driven data ingestion pipeline for managing **parts orders** in a manufacturing company using Snowflake's **Snowpipe**. The pipeline is integrated with **Google Cloud Storage (GCS)** and **Google Pub/Sub** for automated data ingestion into Snowflake tables. The objective of this project is to showcase a real-world implementation of Snowflake in a production-like environment.

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [How It Works](#how-it-works)
- [Technologies Used](#technologies-used)
- [Future Enhancements](#future-enhancements)

---

## Overview
The pipeline handles automated ingestion of **parts orders data** stored as CSV files in Google Cloud Storage into a Snowflake table. It uses Snowpipe to continuously load data into the table when new files are uploaded to the storage bucket. The pipeline is triggered by Google Pub/Sub notifications, ensuring real-time data processing.

## Architecture
The high-level architecture is illustrated below:

![Architecture Diagram](docs/architecture_diagram.png)

1. **Google Cloud Storage**: Stores CSV files for parts orders data.
2. **Object Notifications**: Sends events to Google Pub/Sub when new files are added to the bucket.
3. **Google Pub/Sub**: Acts as a message queue for event-driven integration.
4. **Snowflake Snowpipe**: Automatically ingests the data into a Snowflake table using the pipeline configuration.

---

## Features
- **Automated Data Ingestion**: Uses Snowpipe for continuous and automated data loading.
- **Event-Driven Architecture**: Utilizes Google Pub/Sub for near real-time event handling.
- **Secure Integration**: Leverages storage and notification integrations between Snowflake and GCP.
- **Scalability**: Supports high-volume data loads with minimal latency.

---

## Project Structure
```plaintext
snowflake-parts-orders-snowpipe-event-driven/
├── README.md                        # High-level project overview
├── docs/                            # Documentation folder
│   ├── technical_implementation.md  # Detailed technical steps and SQL scripts
│   ├── architecture_diagram.png     # System architecture diagram
│   ├── artifacts.png                # screenshots of expected outputs
├── sql/                             # SQL scripts folder
│   ├── parts_orders.sql             # Script for database and table creation
│   └── schedule_task.sql            # SQl script for setting up task and schedulling
├── data/                            # Example data folder (for testing only)
│   ├── sample_orders.csv            # Sample CSV file for testing the pipeline
├── .gitignore                       # Ignore unnecessary files in version control
└── LICENSE                          # Licensing information (if applicable)
```

## Setup Instructions

Follow these steps to set up the pipeline:

## Prerequisites

- **Google Cloud Platform (GCP)**:
  - Ensure Pub/Sub and Cloud Storage are enabled.
- **Snowflake**:
  - Ensure you have an active account with sufficient permissions.

---

## Step 1: Create Storage Integration

- Use the provided SQL script located at `sql/create_stage.sql` to create the integration between Snowflake and GCS.
  
---

## Step 2: Setup Notification Integration

- Configure Google Pub/Sub to send notifications on file upload events to the Snowflake pipe.
- Use the automation script `scripts/setup_pubsub.sh` for quick setup.

---

## Step 3: Create Snowpipe

- Use the SQL script located at `sql/create_pipe.sql` to create the Snowpipe for data ingestion.

---

## Step 4: Test the Pipeline

- Upload a sample CSV file to the GCS bucket.
- Use the SQL queries in `sql/queries.sql` to verify that the data has been ingested into Snowflake successfully.

---

# How It Works

1. **File Upload**:
   - CSV files (e.g., `orders-yyyy-mm-dd.csv`) are uploaded to the GCS bucket.

2. **Event Notification**:
   - Google Cloud triggers an event via Pub/Sub when a new file is uploaded.

3. **Snowpipe Activation**:
   - Snowpipe listens for Pub/Sub events and automatically loads the data into the Snowflake table (`orders_data_lz`).

4. **Data Availability**:
   - Ingested data is available in Snowflake for querying or further processing.

---

# Technologies Used

### **Snowflake**:
- Storage Integration
- Snowpipe
- SQL for data ingestion and querying

### **Google Cloud Platform**:
- Cloud Storage
- Pub/Sub

### **CI/CD Tools**:
- GitHub Actions (or similar tools for automated deployment)

### **Languages**:
- SQL
- Bash (for automation scripts)

---

# Future Enhancements

- **Partitioning and Clustering**:
  - Implement partitioning and clustering for optimized querying in Snowflake.
  
- **Schema Validation**:
  - Add schema validation to ensure data consistency before ingestion.
  
- **Monitoring Dashboard**:
  - Integrate a dashboard to track pipeline performance metrics.
  
- **File Format Support**:
  - Expand the pipeline to support additional file formats (e.g., JSON, Parquet).

---

# License

This project is licensed under the **MIT License**.

---

# Acknowledgments

Special thanks to the Snowflake and GCP documentation for providing detailed insights into integration and pipeline design.


