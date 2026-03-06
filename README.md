# Hospital Management System Database

---

## Objectives

The main objectives of this project are:

- Design a relational database schema for a hospital management system.
- Model the system using **Entity-Relationship Diagrams (ERD)**.
- Implement the schema using **SQL Data Definition Language (DDL)**.
- Implement PostgreSQL role-based access control to manage user permissions and enhance security.
- Develop backand recovery plans to ensure data integrity and availability in case of failures.
- Develop and test **complex SQL queries** for data retrieval and analysis.
- Generate and work with **large synthetic datasets** to evaluate database performance.
- Apply **indexing strategies** to improve query efficiency.

--

## Database Overview

The database organizes hospital data into structured tables and relationships, enabling efficient storage, retrieval, and management of hospital records.
| Table Name | Description | Features |
| ------------------ | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| **doctor** | Stores information about doctors working in the hospital. | doctor_id (PK), first_name, last_name, gender, contact, email, specialization, department_id (FK) |
| **department** | Stores hospital department details. | department_id (PK), department_name, location |
| **patient** | Stores personal and health-related information about patients. | patient_id (PK), first_name, last_name, gender, height, weight, date_of_birth, address, contact, email, doctor_id (FK) |
| **appointment** | Records appointments scheduled between patients and doctors. | appointment_id (PK), purpose, date_time, status, doctor_id (FK), patient_id (FK) |
| **medical_record** | Stores diagnosis, treatment, and medical history related to patient visits. | record_id (PK), diagnosis, prescription, treatment, lab_result, patient_id (FK), appointment_id (FK) |
| **billing** | Stores payment and billing details for patient services. | billing_id (PK), treatment_fee, medication_fee, lab_test_fee, consultation_fee, total_amount, payment_status, receptionist_id (FK), patient_id (FK) |
| **staff** | Stores hospital staff information such as nurses and receptionists. | staff_id (PK), first_name, last_name, gender, role, contact, department_id (FK), doctor_id (FK) |

<img src="public/Relational Schema.jpg" alt="Relational Schema">

## How to Run the Project
### Perequisites:
  - PostgreSQ
  - Python 3.x installed for running SQL scripts and generating synthetic data.



## C

- GitHub: [leangchhay1523](https://github.com/leangchhay1523)
- Linkedin: [Kimleangchhay Song](https://www.linkedin.com/in/leang-chhay-9a1b4a1b2)
