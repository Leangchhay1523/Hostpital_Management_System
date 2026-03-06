# Hospital Management System Database

## Overview

In healthcare facilities, efficient data management is crucial. Patient records, doctor information, appointments, staff details, and billing data must be organized and easily accessible. Without a structured database system, managing large volumes of medical and operational data becomes difficult.

This project designs and implements a relational database for a Hospital Management System (HMS). The database organizes hospital data into structured tables and relationships, enabling efficient storage, retrieval, and management of hospital records.

The project also explores database performance and query optimization by working with a large dataset and analyzing query execution behavior.

---

## Objectives

The main objectives of this project are:

- Design a relational database schema for a hospital management system.
- Model the system using **Entity-Relationship Diagrams (ERD)**.
- Implement the schema using **SQL Data Definition Language (DDL)**.
- Develop and test **complex SQL queries** for data retrieval and analysis.
- Generate and work with **large synthetic datasets** to evaluate database performance.
- Apply **indexing strategies** to improve query efficiency.

---

## Database Architecture

The database consists of several core entities representing hospital operations:

- **Department** – Organizational units within the hospital
- **Staff** – Doctors, nurses, and administrative staff
- **Patient** – Personal and medical information of patients
- **Appointment** – Scheduled consultations between patients and doctors
- **Medical_Record** – Diagnosis, prescriptions, and treatment information
- **Billing** – Financial transactions for patient services
- **Patient_Doctor** – Junction table representing many-to-many relationships between patients and doctors

These entities and their relationships model key hospital workflows including patient care, appointment scheduling, and billing management.

---

## Implementation

### Entity Relationship Diagram

The ER diagram illustrates the relationships between the main entities in the system.

<img src="public/Entity-Relationship Diagram.jpg" alt="Entity-Relationship Diagram">

---

### Relational Schema

The relational schema is derived from the ER diagram and implemented using normalized tables with appropriate constraints.

Key design features include:

- **Primary keys** for entity identification
- **Foreign keys** to maintain referential integrity
- **Many-to-many relationships** implemented through junction tables
- Structured schema supporting efficient query operations

<img src="public/Relational Schema.jpg" alt="Relational Schema">

---

## Dataset

To study database performance and query optimization, the system uses **synthetic datasets generated using Python (NumPy)**.

The dataset simulates realistic hospital data and includes large tables with **more than 1 million records**.

Example dataset scale:

- Patient: ~1,000,000 records
- Appointment: ~1,000,000 records
- Medical_Record: ~1,000,000 records
- Billing: ~1,000,000 records

Using large datasets allows evaluation of query performance, indexing strategies, and database scalability.

---

## Query Optimization

Performance testing was conducted using complex SQL queries involving:

- Multiple table joins
- Aggregations
- Subqueries
- Common Table Expressions (CTEs)

To improve query performance, indexing strategies were applied to frequently accessed columns, significantly reducing execution time for several queries.

---

## Technologies Used

- PostgreSQL
- SQL
- Python (NumPy for synthetic data generation)
