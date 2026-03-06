# Hospital Management System Database

A comprehensive PostgreSQL-based Hospital Management System with role-based access control, backup/recovery mechanisms, and optimized query performance.

---

## Table of Contents

- [Hospital Management System Database](#hospital-management-system-database)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Features](#features)
  - [Database Schema](#database-schema)
  - [Prerequisites](#prerequisites)
    - [Verify Installations](#verify-installations)
  - [Installation](#installation)
    - [Step 1: Clone the Repository](#step-1-clone-the-repository)
    - [Step 2: Install Python Dependencies](#step-2-install-python-dependencies)
    - [Step 3: Create Database and Schema](#step-3-create-database-and-schema)
      - [Option A: Using psql Command Line](#option-a-using-psql-command-line)
      - [Option B: Using psql with File Input](#option-b-using-psql-with-file-input)
      - [Option C: Using pgAdmin](#option-c-using-pgadmin)
    - [Step 4: Generate Synthetic Data](#step-4-generate-synthetic-data)
      - [Configure Data Volume](#configure-data-volume)
      - [Run Data Generation](#run-data-generation)
    - [Step 5: Insert Data into Database](#step-5-insert-data-into-database)
      - [Option A: Using the INSERT Script](#option-a-using-the-insert-script)
      - [Option B: Using \\copy for CSV Import (Recommended for Large Datasets)](#option-b-using-copy-for-csv-import-recommended-for-large-datasets)
      - [Reset Sequences After Import](#reset-sequences-after-import)
      - [Verify Data Insertion](#verify-data-insertion)
  - [Usage](#usage)
    - [Run Queries](#run-queries)
      - [Example: Run Individual Queries](#example-run-individual-queries)
    - [Stored Procedures](#stored-procedures)
      - [Example: Call a Procedure](#example-call-a-procedure)
    - [Role-Based Access Control](#role-based-access-control)
      - [Apply RBAC](#apply-rbac)
      - [Login as Specific User](#login-as-specific-user)
  - [Backup and Recovery](#backup-and-recovery)
    - [Setup Environment](#setup-environment)
    - [Perform Backup](#perform-backup)
      - [Automatic Backup (Recommended)](#automatic-backup-recommended)
      - [Manual Full Backup](#manual-full-backup)
      - [Manual Incremental Backup](#manual-incremental-backup)
      - [Backup Output](#backup-output)
    - [Restore from Backup](#restore-from-backup)
      - [Full Restore](#full-restore)
      - [Manual Restore (Specific Backup)](#manual-restore-specific-backup)
  - [Database Optimization](#database-optimization)
    - [Indexes](#indexes)
    - [Apply Indexes](#apply-indexes)
    - [Query Performance Tips](#query-performance-tips)
  - [Project Structure](#project-structure)
  - [Troubleshooting](#troubleshooting)
    - [Common Issues](#common-issues)
      - [1. "psql: command not found"](#1-psql-command-not-found)
      - [2. "Connection refused" Error](#2-connection-refused-error)
      - [3. "permission denied" Error](#3-permission-denied-error)
      - [4. Backup Fails with "pg_dump not found"](#4-backup-fails-with-pg_dump-not-found)
      - [5. CSV Import Errors](#5-csv-import-errors)
  - [Contact](#contact)
  - [License](#license)

---

## Overview

This project implements a complete Hospital Management System database using PostgreSQL. It includes:

- Relational database design with normalized tables
- Automatic data generation for testing with large datasets
- Role-based access control (RBAC) for security
- Automated backup and recovery procedures
- Optimized queries with proper indexing

---

## Features

- **7 Core Tables**: department, staff, patient, patient_doctor, appointment, medical_record, billing
- **User Management**: Admin, Doctor, Nurse, and Receptionist roles with granular permissions
- **Automated Backups**: Full backup (weekly) and incremental backup (daily)
- **Data Generation**: Python script to generate up to 1 million+ records for performance testing
- **Optimized Queries**: Indexed columns and pre-written complex DQL queries
- **Triggers & Procedures**: Automatic total calculation, timestamp updates, and reusable procedures

---

## Database Schema

| Table Name         | Description                                         | Key Columns                                                             |
| ------------------ | --------------------------------------------------- | ----------------------------------------------------------------------- |
| **department**     | Hospital departments                                | department_id (PK), department_name, location                           |
| **staff**          | All hospital staff (doctors, nurses, receptionists) | staff_id (PK), role, specialization, department_id (FK), doctor_id (FK) |
| **patient**        | Patient information                                 | patient_id (PK), doctor_id (FK), height, weight, date_of_birth          |
| **patient_doctor** | Many-to-many relationship                           | patient_doctor_id (PK), patient_id (FK), doctor_id (FK)                 |
| **appointment**    | Patient appointments                                | appointment_id (PK), doctor_id (FK), patient_id (FK), status            |
| **medical_record** | Medical records per visit                           | record_id (PK), appointment_id (FK), patient_id (FK), diagnosis         |
| **billing**        | Billing records                                     | billing_id (PK), patient_id (FK), receptionist_id (FK), total_amount    |
| **role**           | User roles for RBAC                                 | role_id (PK), role_name                                                 |
| **users**          | System users                                        | user_id (PK), username, password, role_id (FK)                          |

![Relational Schema](public/Relational%20Schema.jpg)

---

## Prerequisites

Before you begin, ensure you have the following installed:

| Software       | Version                 | Download Link                                          |
| -------------- | ----------------------- | ------------------------------------------------------ |
| **PostgreSQL** | 12+                     | [postgresql.org](https://www.postgresql.org/download/) |
| **Python**     | 3.8+                    | [python.org](https://www.python.org/downloads/)        |
| **Git**        | Latest                  | [git-scm.com](https://git-scm.com/downloads)           |
| **pg_dump**    | (comes with PostgreSQL) | Required for backups                                   |

### Verify Installations

```bash
# Check PostgreSQL
psql --version

# Check Python
python --version

# Check Git
git --version
```

---

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/Leangchhay1523/Hospital_Management_System.git
cd Hospital_Management_System
```

---

### Step 2: Install Python Dependencies

```bash
# Install dependencies for data generation
cd data
pip install -r requirements.txt

# Install dependencies for backup scripts
cd ../backup
pip install -r requirements.txt

# Return to project root
cd ..
```

**Requirements include:**

- `faker` - For generating realistic synthetic data
- `psycopg2-binary` - PostgreSQL adapter for Python
- `python-dotenv` - For environment variable management

---

### Step 3: Create Database and Schema

#### Option A: Using psql Command Line

```bash
# Connect to PostgreSQL
psql -U postgres

# Run the DDL script
\i sql/DDL\ \(Data\ Definition\ Language\).sql

# Exit psql
\q
```

#### Option B: Using psql with File Input

```bash
# Create database and run all schema scripts
psql -U postgres -f sql/DDL\ \(Data\ Definition\ Language\).sql
psql -U postgres -d hospital -f sql/TRIGGERS.sql
psql -U postgres -d hospital -f sql/RBAC.sql
psql -U postgres -d hospital -f sql/INDEX.sql
```

#### Option C: Using pgAdmin

1. Open pgAdmin and connect to your PostgreSQL server
2. Right-click on **Databases** → **Create** → **Database**
3. Name it `hospital`
4. Open **Query Tool** for the `hospital` database
5. Open and execute `sql/DDL (Data Definition Language).sql`
6. Execute `sql/TRIGGERS.sql`, `sql/RBAC.sql`, and `sql/INDEX.sql` in order

---

### Step 4: Generate Synthetic Data

The Python script can generate from small test datasets to millions of records.

#### Configure Data Volume

Edit `data/main.py` to set your desired record counts:

```python
CONFIG = {
    'departments': 5,           # Number of departments (max 5)
    'staff': 200,               # Total staff count
    'staff_doctors': 80,        # Number of doctors
    'staff_nurses': 90,         # Number of nurses
    'staff_receptionists': 30,  # Number of receptionists
    'patients': 1000000,        # Number of patients (1 million)
    'patient_doctor': 1000000,  # Patient-doctor relationships
    'appointments': 1000000,    # Appointment records
    'medical_records': 1000000, # Medical records
    'billing': 1000000,         # Billing records
}
```

#### Run Data Generation

```bash
cd data
python main.py
```

This generates CSV files in `data/generated_data/`:

- `departments.csv`
- `staff.csv`
- `patients.csv`
- `patient_doctor.csv`
- `appointments.csv`
- `medical_records.csv`
- `billing.csv`

---

### Step 5: Insert Data into Database

#### Option A: Using the INSERT Script

```bash
# Connect to hospital database and run INSERT script
psql -U postgres -d hospital -f data/INSERT.sql
```

#### Option B: Using \copy for CSV Import (Recommended for Large Datasets)

```bash
psql -U postgres -d hospital << EOF
\copy department(department_id, department_name, location) FROM 'data/generated_data/departments.csv' DELIMITER ',' CSV HEADER;
\copy staff(staff_id, last_name, first_name, gender, role, contact, specialization, department_id, doctor_id) FROM 'data/generated_data/staff.csv' DELIMITER ',' CSV HEADER;
\copy patient(patient_id, last_name, first_name, height, weight, date_of_birth, address, contact, email) FROM 'data/generated_data/patients.csv' DELIMITER ',' CSV HEADER;
\copy patient_doctor(patient_doctor_id, patient_id, doctor_id) FROM 'data/generated_data/patient_doctor.csv' DELIMITER ',' CSV HEADER;
\copy appointment(appointment_id, purpose, date_time, status, doctor_id, patient_id) FROM 'data/generated_data/appointments.csv' DELIMITER ',' CSV HEADER;
\copy medical_record(record_id, prescription, diagnosis, lab_result, treatment, patient_id, appointment_id) FROM 'data/generated_data/medical_records.csv' DELIMITER ',' CSV HEADER;
\copy billing(billing_id, treatment_fee, medication_fee, lab_test_fee, consultation_fee, receptionist_id, patient_id) FROM 'data/generated_data/billing.csv' DELIMITER ',' CSV HEADER;
EOF
```

#### Reset Sequences After Import

```bash
psql -U postgres -d hospital -f sql/SETVAL.sql
```

#### Verify Data Insertion

```bash
psql -U postgres -d hospital -c "SELECT COUNT(*) FROM patient;"
psql -U postgres -d hospital -c "SELECT COUNT(*) FROM appointment;"
```

---

## Usage

### Run Queries

Execute pre-written queries from the `sql/` directory:

```bash
# Simple queries (SELECT, filtering, sorting)
psql -U postgres -d hospital -f sql/Simple\ DQL.sql

# Complex queries (JOINs, subqueries, CTEs)
psql -U postgres -d hospital -f sql/Complex\ DQL.sql

# Run stored procedures
psql -U postgres -d hospital -f sql/PROCEDURES.sql
```

#### Example: Run Individual Queries

```bash
# View all patients
psql -U postgres -d hospital -c "SELECT * FROM patient LIMIT 10;"

# View appointments for today
psql -U postgres -d hospital -c "SELECT * FROM appointment WHERE DATE(date_time) = CURRENT_DATE;"

# Get billing summary
psql -U postgres -d hospital -c "SELECT payment_status, COUNT(*), SUM(total_amount) FROM billing GROUP BY payment_status;"
```

---

### Stored Procedures

Available procedures for common operations:

| Procedure                   | Description                   |
| --------------------------- | ----------------------------- |
| `AddAppointmentRecord()`    | Create new appointment        |
| `UpdateAppointmentStatus()` | Change appointment status     |
| `InsertNewPatient()`        | Register new patient          |
| `AddMedicalRecord()`        | Create medical record         |
| `InsertBillingRecord()`     | Generate billing              |
| `GetPatientsByDoctor()`     | List doctor's patients        |
| `GetBillingByPatient()`     | Get patient's billing history |

#### Example: Call a Procedure

```bash
psql -U postgres -d hospital -c "CALL InsertNewPatient('Doe', 'John', 175.5, 70.0, '1990-05-15', '123 Main St', '012345678', 'john@email.com', 1);"
```

---

### Role-Based Access Control

The system defines 4 roles with specific permissions:

| Role                  | Permissions                                             |
| --------------------- | ------------------------------------------------------- |
| **admin_role**        | Full database access (SUPERUSER)                        |
| **doctor_role**       | View/update appointments, medical records, patient info |
| **nurse_role**        | View patients, update vitals, view appointments         |
| **receptionist_role** | Insert patients, manage billing, schedule appointments  |

#### Apply RBAC

```bash
psql -U postgres -d hospital -f sql/RBAC.sql
```

#### Login as Specific User

```bash
# Login as doctor
psql -U doctor -d hospital

# Login as receptionist
psql -U receptionist -d hospital
```

---

## Backup and Recovery

### Setup Environment

1. **Configure Database Connection**

   Edit `backup/.env`:

   ```
   DB_NAME=hospital
   DB_USER=postgres
   DB_PASSWORD=your_password
   DB_HOST=localhost
   DB_PORT=5432
   ```

2. **Verify Backup Directory Structure**

   ```
   backup/
   ├── backup_and_recovery/
   │   ├── full_backup/
   │   └── incremental_backup/
   ├── full_backup.py
   ├── incremental_backup.py
   ├── recovery.py
   └── main.py
   ```

---

### Perform Backup

#### Automatic Backup (Recommended)

The `main.py` script runs full backup on Sundays and incremental backup on other days:

```bash
cd backup
python main.py
```

#### Manual Full Backup

```bash
cd backup
python full_backup.py
```

#### Manual Incremental Backup

```bash
cd backup
python incremental_backup.py
```

#### Backup Output

Backups are stored in:

- `backup/backup_and_recovery/full_backup/full_backup_YYYYMMDD_HHMMSS.backup`
- `backup/backup_and_recovery/incremental_backup/incremental_backup_YYYYMMDD_HHMMSS.json`

---

### Restore from Backup

#### Full Restore

```bash
cd backup
python recovery.py
```

This will:

1. Find the latest full backup
2. Restore all incremental backups in chronological order
3. Verify data integrity

#### Manual Restore (Specific Backup)

```bash
# Restore full backup only
pg_restore -h localhost -U postgres -d hospital -c --if-exists backup/backup_and_recovery/full_backup/full_backup_20250101_120000.backup

# Then restore incremental backups
python recovery.py  # Will apply incremental backups
```

---

## Database Optimization

### Indexes

Indexes are automatically created when running `sql/INDEX.sql`. Key indexes include:

| Index                           | Table          | Columns          | Purpose              |
| ------------------------------- | -------------- | ---------------- | -------------------- |
| `idx_billing_patient_fees`      | billing        | patient_id, fees | Billing queries      |
| `idx_appointment_patient`       | appointment    | patient_id       | Patient appointments |
| `idx_medical_record_patient_id` | medical_record | patient_id       | Patient records      |
| `idx_staff_role`                | staff          | role             | Staff filtering      |

### Apply Indexes

```bash
psql -U postgres -d hospital -f sql/INDEX.sql
```

### Query Performance Tips

1. **Use EXPLAIN ANALYZE** to check query plans:

   ```bash
   psql -U postgres -d hospital -c "EXPLAIN ANALYZE SELECT * FROM patient WHERE doctor_id = 5;"
   ```

2. **Vacuum and Analyze** regularly:

   ```bash
   psql -U postgres -d hospital -c "VACUUM ANALYZE;"
   ```

3. **Use prepared statements** for repeated queries

4. **Avoid SELECT \*** - specify only needed columns

---

## Project Structure

```
Hospital_Management_System/
├── sql/
│   ├── DDL (Data Definition Language).sql   # Database schema
│   ├── DML (Data Manipulation Language).sql # Sample INSERT statements
│   ├── Simple DQL.sql                       # Basic queries
│   ├── Complex DQL.sql                      # Advanced queries
│   ├── PROCEDURES.sql                       # Stored procedures
│   ├── TRIGGERS.sql                         # Triggers and functions
│   ├── RBAC.sql                             # Role-based access control
│   ├── INDEX.sql                            # Index definitions
│   └── SETVAL.sql                           # Sequence reset
├── data/
│   ├── main.py                              # Data generation script
│   ├── requirements.txt                     # Python dependencies
│   ├── INSERT.sql                           # Sample data inserts
│   └── generated_data/                      # Generated CSV files
├── backup/
│   ├── main.py                              # Backup scheduler
│   ├── full_backup.py                       # Full backup script
│   ├── incremental_backup.py                # Incremental backup script
│   ├── recovery.py                          # Recovery script
│   ├── .env                                 # Database credentials
│   └── backup_and_recovery/                 # Backup storage
├── public/
│   └── Relational Schema.jpg                # ERD diagram
└── README.md                                # This file
```

---

## Troubleshooting

### Common Issues

#### 1. "psql: command not found"

**Solution:** Add PostgreSQL to PATH:

```bash
# Windows
setx PATH "%PATH%;C:\Program Files\PostgreSQL\15\bin"

# Linux/Mac
export PATH=$PATH:/usr/lib/postgresql/15/bin
```

#### 2. "Connection refused" Error

**Solution:** Ensure PostgreSQL service is running:

```bash
# Windows
net start postgresql

# Linux
sudo systemctl start postgresql
```

#### 3. "permission denied" Error

**Solution:** Run as postgres user or grant permissions:

```bash
psql -U postgres
```

#### 4. Backup Fails with "pg_dump not found"

**Solution:** Ensure pg_dump is in PATH (comes with PostgreSQL installation)

#### 5. CSV Import Errors

**Solution:** Ensure CSV files use correct delimiters and encoding:

```bash
# Check file encoding
file data/generated_data/patients.csv
```

---

## Contact

- **GitHub:** [leangchhay1523](https://github.com/leangchhay1523)
- **LinkedIn:** [Kimleangchhay Song](https://www.linkedin.com/in/leang-chhay-9a1b4a1b2)

---

## License

This project is for educational purposes. Feel free to use and modify as needed.
