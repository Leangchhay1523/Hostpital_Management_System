-- ============================================
-- HOSPITAL MANAGEMENT SYSTEM - RBAC (Role-Based Access Control)
-- Database: PostgreSQL
-- ============================================

-- ============================================
-- CREATE ROLES
-- ============================================

-- Admin Role (Superuser)
CREATE ROLE admin_role SUPERUSER;

-- Receptionist Role
CREATE ROLE receptionist_role;

-- Doctor Role
CREATE ROLE doctor_role;

-- Nurse Role
CREATE ROLE nurse_role;

-- ============================================
-- RECEPTIONIST ROLE PERMISSIONS
-- ============================================

-- Grant access to database and schema
GRANT CONNECT ON DATABASE hospital TO receptionist_role;
GRANT USAGE ON SCHEMA public TO receptionist_role;

-- Grant access to tables
GRANT SELECT, INSERT ON public.patient TO receptionist_role;
GRANT SELECT, INSERT, UPDATE ON public.billing TO receptionist_role;
GRANT SELECT ON public.appointment TO receptionist_role;
GRANT SELECT ON public.department TO receptionist_role;
GRANT SELECT ON public.staff TO receptionist_role;

-- Grant execute on procedures
GRANT EXECUTE ON PROCEDURE InsertBillingRecord(
    IN input_treatment_fee DECIMAL,
    IN input_medication_fee DECIMAL,
    IN input_lab_test_fee DECIMAL,
    IN input_consultation_fee DECIMAL,
    IN input_receptionist_id INT,
    IN input_patient_id INT
) TO receptionist_role;

GRANT EXECUTE ON PROCEDURE UpdateBillingStatus(
    IN input_status VARCHAR,
    IN input_billing_id INT
) TO receptionist_role;

GRANT EXECUTE ON PROCEDURE GetBillingByStatus(
    IN input_status VARCHAR
) TO receptionist_role;

GRANT EXECUTE ON PROCEDURE GetBillingByPatient(
    IN input_patient_id INT
) TO receptionist_role;

GRANT EXECUTE ON PROCEDURE FilterViewBilling(
    IN input_billing_id INT,
    IN input_payment_status VARCHAR,
    IN input_receptionist_id INT,
    IN input_patient_id INT
) TO receptionist_role;

GRANT EXECUTE ON PROCEDURE UpdatePatientInfo(
    IN input_address VARCHAR,
    IN input_email VARCHAR,
    IN input_contact VARCHAR,
    IN input_patient_id INT
) TO receptionist_role;

GRANT EXECUTE ON PROCEDURE InsertNewPatient(
    IN input_last_name VARCHAR,
    IN input_first_name VARCHAR,
    IN input_height DECIMAL,
    IN input_weight DECIMAL,
    IN input_date_of_birth DATE,
    IN input_address VARCHAR,
    IN input_contact VARCHAR,
    IN input_email VARCHAR,
    IN input_doctor_id INT
) TO receptionist_role;

GRANT EXECUTE ON PROCEDURE AddAppointmentRecord(
    IN input_purpose VARCHAR,
    IN input_date_time TIMESTAMP,
    IN input_status VARCHAR,
    IN input_doctor_id INT,
    IN input_patient_id INT
) TO receptionist_role;

GRANT EXECUTE ON PROCEDURE FilterViewAppointment(
    IN input_appointment_id INT,
    IN input_status VARCHAR,
    IN input_doctor_id INT,
    IN input_patient_id INT
) TO receptionist_role;

GRANT EXECUTE ON PROCEDURE FilterViewPatient(
    IN input_patient_id INT,
    IN input_last_name VARCHAR,
    IN input_first_name VARCHAR,
    IN input_doctor_id INT
) TO receptionist_role;

GRANT EXECUTE ON PROCEDURE FilterViewDepartment(
    IN input_department_id INT,
    IN input_department_name VARCHAR,
    IN input_location VARCHAR
) TO receptionist_role;

-- ============================================
-- DOCTOR ROLE PERMISSIONS
-- ============================================

-- Grant access to database and schema
GRANT CONNECT ON DATABASE hospital TO doctor_role;
GRANT USAGE ON SCHEMA public TO doctor_role;

-- Grant access to tables
GRANT SELECT, INSERT, UPDATE ON public.appointment TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON public.medical_record TO doctor_role;
GRANT SELECT ON public.patient TO doctor_role;
GRANT SELECT ON public.staff TO doctor_role;
GRANT SELECT ON public.department TO doctor_role;
GRANT SELECT ON public.billing TO doctor_role;

-- Grant execute on procedures
GRANT EXECUTE ON PROCEDURE AddAppointmentRecord(
    IN input_purpose VARCHAR,
    IN input_date_time TIMESTAMP,
    IN input_status VARCHAR,
    IN input_doctor_id INT,
    IN input_patient_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE UpdateAppointmentStatus(
    IN input_status VARCHAR,
    IN input_appointment_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE ViewAppointmentByDate(
    IN input_date DATE
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE ViewAppointmentByDoctorID(
    IN input_doctor_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE FilterViewAppointment(
    IN input_appointment_id INT,
    IN input_status VARCHAR,
    IN input_doctor_id INT,
    IN input_patient_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE AddMedicalRecord(
    IN input_prescription TEXT,
    IN input_diagnosis TEXT,
    IN input_lab_result VARCHAR,
    IN input_treatment VARCHAR,
    IN input_patient_id INT,
    IN input_appointment_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE UpdateMedicalRecordDetails(
    IN input_prescription TEXT,
    IN input_diagnosis TEXT,
    IN input_lab_result VARCHAR,
    IN input_treatment VARCHAR,
    IN input_record_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE GetMedicalRecordByPatient(
    IN input_patient_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE GetMedicalRecordByDoctor(
    IN input_doctor_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE FilterViewMedicalRecord(
    IN input_record_id INT,
    IN input_patient_id INT,
    IN input_appointment_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE GetPatientsByDoctor(
    IN input_doctor_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE ViewPatientByID(
    IN input_patient_id INT
) TO doctor_role;

GRANT EXECUTE ON PROCEDURE FilterViewPatient(
    IN input_patient_id INT,
    IN input_last_name VARCHAR,
    IN input_first_name VARCHAR,
    IN input_doctor_id INT
) TO doctor_role;

-- ============================================
-- NURSE ROLE PERMISSIONS
-- ============================================

-- Grant access to database and schema
GRANT CONNECT ON DATABASE hospital TO nurse_role;
GRANT USAGE ON SCHEMA public TO nurse_role;

-- Grant access to tables
GRANT SELECT, UPDATE ON public.patient TO nurse_role;
GRANT SELECT ON public.appointment TO nurse_role;
GRANT SELECT ON public.medical_record TO nurse_role;
GRANT SELECT ON public.staff TO nurse_role;
GRANT SELECT ON public.department TO nurse_role;

-- Grant execute on procedures
GRANT EXECUTE ON PROCEDURE UpdatePatientVitals(
    IN input_height DECIMAL,
    IN input_weight DECIMAL,
    IN input_patient_id INT
) TO nurse_role;

GRANT EXECUTE ON PROCEDURE GetPatientsByDoctor(
    IN input_doctor_id INT
) TO nurse_role;

GRANT EXECUTE ON PROCEDURE GetMedicalRecordByDoctor(
    IN input_doctor_id INT
) TO nurse_role;

GRANT EXECUTE ON PROCEDURE ViewAppointmentByDoctorID(
    IN input_doctor_id INT
) TO nurse_role;

GRANT EXECUTE ON PROCEDURE ViewAppointmentByDate(
    IN input_date DATE
) TO nurse_role;

GRANT EXECUTE ON PROCEDURE FilterViewAppointment(
    IN input_appointment_id INT,
    IN input_status VARCHAR,
    IN input_doctor_id INT,
    IN input_patient_id INT
) TO nurse_role;

GRANT EXECUTE ON PROCEDURE FilterViewPatient(
    IN input_patient_id INT,
    IN input_last_name VARCHAR,
    IN input_first_name VARCHAR,
    IN input_doctor_id INT
) TO nurse_role;

GRANT EXECUTE ON PROCEDURE FilterViewMedicalRecord(
    IN input_record_id INT,
    IN input_patient_id INT,
    IN input_appointment_id INT
) TO nurse_role;

-- ============================================
-- CREATE USERS
-- ============================================

-- Admin User
CREATE USER admin WITH LOGIN PASSWORD 'adminPass123!';
GRANT admin_role TO admin;

-- Receptionist User
CREATE USER receptionist WITH LOGIN PASSWORD 'receptionistPass123!';
GRANT receptionist_role TO receptionist;

-- Doctor User
CREATE USER doctor WITH LOGIN PASSWORD 'doctorPass123!';
GRANT doctor_role TO doctor;

-- Nurse User
CREATE USER nurse WITH LOGIN PASSWORD 'nursePass123!';
GRANT nurse_role TO nurse;

-- ============================================
-- USAGE NOTES
-- ============================================
-- To grant a role to a user: GRANT role_name TO user_name;
-- To revoke a role from a user: REVOKE role_name FROM user_name;
-- To check user roles: SELECT usename, usecreatedb, usesuper FROM pg_user;
-- To check role permissions: \du in psql
