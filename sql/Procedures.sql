-- ============================================
-- HOSPITAL MANAGEMENT SYSTEM - PROCEDURES
-- Database: PostgreSQL
-- ============================================

-- ============================================
-- APPOINTMENT PROCEDURES
-- ============================================

-- Add appointment record
CREATE OR REPLACE PROCEDURE AddAppointmentRecord(
    IN input_purpose VARCHAR(255), 
    IN input_date_time TIMESTAMP, 
    IN input_status VARCHAR(50), 
    IN input_doctor_id INT, 
    IN input_patient_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO appointment(purpose, date_time, status, doctor_id, patient_id)
    VALUES (input_purpose, input_date_time, input_status, input_doctor_id, input_patient_id);
END;
$$;

-- Modify appointment status
CREATE OR REPLACE PROCEDURE UpdateAppointmentStatus(
    IN input_status VARCHAR(50),
    IN input_appointment_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN 
    UPDATE appointment
    SET status = COALESCE(input_status, status)
    WHERE appointment_id = input_appointment_id;
END;
$$;

-- View appointment by date
CREATE OR REPLACE PROCEDURE ViewAppointmentByDate(IN input_date DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        a.appointment_id,
        a.date_time,
        a.purpose,
        a.status,
        p.first_name || ' ' || p.last_name AS patient_name
    FROM appointment a
    JOIN patient p ON a.patient_id = p.patient_id
    WHERE DATE(date_time) = input_date;
END;
$$;

-- View all appointments of a doctor
CREATE OR REPLACE PROCEDURE ViewAppointmentByDoctorID(
    IN input_doctor_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT 
        appointment_id,
        date_time,
        purpose,
        status,
        patient_id
    FROM appointment
    WHERE doctor_id = input_doctor_id;
END;
$$;

-- Filter view appointments
CREATE OR REPLACE PROCEDURE FilterViewAppointment(
    IN input_appointment_id INT, 
    IN input_status VARCHAR(50),
    IN input_doctor_id INT,
    IN input_patient_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM appointment
    WHERE
        (input_appointment_id IS NULL OR appointment_id = input_appointment_id)
        AND (input_status IS NULL OR input_status = '' OR status = input_status)
        AND (input_doctor_id IS NULL OR doctor_id = input_doctor_id)
        AND (input_patient_id IS NULL OR patient_id = input_patient_id);
END;
$$;

-- ============================================
-- MEDICAL RECORD PROCEDURES
-- ============================================

-- Add medical record
CREATE OR REPLACE PROCEDURE AddMedicalRecord(
    IN input_prescription TEXT,
    IN input_diagnosis TEXT,
    IN input_lab_result VARCHAR(255),
    IN input_treatment VARCHAR(255),
    IN input_patient_id INT,
    IN input_appointment_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO medical_record(
        prescription,
        diagnosis,
        lab_result,
        treatment,
        patient_id,
        appointment_id
    )
    VALUES
    (
        input_prescription,
        input_diagnosis,
        input_lab_result,
        input_treatment,
        input_patient_id,
        input_appointment_id
    );
END;
$$;

-- Modify medical record
CREATE OR REPLACE PROCEDURE UpdateMedicalRecordDetails(
    IN input_prescription TEXT,
    IN input_diagnosis TEXT,
    IN input_lab_result VARCHAR(255),
    IN input_treatment VARCHAR(255),
    IN input_record_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE medical_record
    SET 
        prescription = COALESCE(input_prescription, prescription),
        diagnosis = COALESCE(input_diagnosis, diagnosis),
        lab_result = COALESCE(input_lab_result, lab_result),
        treatment = COALESCE(input_treatment, treatment)
    WHERE record_id = input_record_id;
END;
$$;

-- View medical record by patient
CREATE OR REPLACE PROCEDURE GetMedicalRecordByPatient(IN input_patient_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM medical_record WHERE patient_id = input_patient_id;
END;
$$;

-- View medical records of a doctor's patients
CREATE OR REPLACE PROCEDURE GetMedicalRecordByDoctor(IN input_doctor_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT mr.* FROM medical_record mr
    JOIN patient p ON mr.patient_id = p.patient_id
    WHERE p.doctor_id = input_doctor_id;
END;
$$;

-- Filter view medical records
CREATE OR REPLACE PROCEDURE FilterViewMedicalRecord(
    IN input_record_id INT, 
    IN input_patient_id INT, 
    IN input_appointment_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM medical_record 
    WHERE 
        (input_record_id IS NULL OR record_id = input_record_id)
        AND (input_patient_id IS NULL OR patient_id = input_patient_id)
        AND (input_appointment_id IS NULL OR appointment_id = input_appointment_id);
END;
$$;

-- ============================================
-- PATIENT PROCEDURES
-- ============================================

-- Insert new patient
CREATE OR REPLACE PROCEDURE InsertNewPatient(
    IN input_last_name VARCHAR(50),
    IN input_first_name VARCHAR(50),
    IN input_height DECIMAL(10, 2),
    IN input_weight DECIMAL(10, 2),
    IN input_date_of_birth DATE,
    IN input_address VARCHAR(255),
    IN input_contact VARCHAR(50),
    IN input_email VARCHAR(50),
    IN input_doctor_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO patient(last_name, first_name, height, weight, date_of_birth, address, contact, email, doctor_id)
    VALUES (input_last_name, input_first_name, input_height, input_weight, input_date_of_birth, input_address, input_contact, input_email, input_doctor_id);
END;
$$;

-- View patients of a specific doctor
CREATE OR REPLACE PROCEDURE GetPatientsByDoctor(IN input_doctor_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM patient
    WHERE doctor_id = input_doctor_id;
END;
$$;

-- Update patient vitals (height and weight)
CREATE OR REPLACE PROCEDURE UpdatePatientVitals(
    IN input_height DECIMAL(10,2),
    IN input_weight DECIMAL(10,2),
    IN input_patient_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN 
    UPDATE patient
    SET 
        height = COALESCE(input_height, height),
        weight = COALESCE(input_weight, weight)
    WHERE patient_id = input_patient_id;
END;
$$;

-- Update patient info (address, email, contact)
CREATE OR REPLACE PROCEDURE UpdatePatientInfo(
    IN input_address VARCHAR(255),
    IN input_email VARCHAR(50),
    IN input_contact VARCHAR(50),
    IN input_patient_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN 
    UPDATE patient
    SET
        address = COALESCE(input_address, address),
        email = COALESCE(input_email, email),
        contact = COALESCE(input_contact, contact)
    WHERE patient_id = input_patient_id;
END;
$$;

-- View patient by ID
CREATE OR REPLACE PROCEDURE ViewPatientByID(IN input_patient_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM patient
    WHERE patient_id = input_patient_id;
END;
$$;

-- Filter view patients
CREATE OR REPLACE PROCEDURE FilterViewPatient(
    IN input_patient_id INT,
    IN input_last_name VARCHAR(50),
    IN input_first_name VARCHAR(50),
    IN input_doctor_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM patient
    WHERE
        (input_patient_id IS NULL OR patient_id = input_patient_id)
        AND (input_last_name IS NULL OR last_name = input_last_name)
        AND (input_first_name IS NULL OR first_name = input_first_name)
        AND (input_doctor_id IS NULL OR doctor_id = input_doctor_id);
END;
$$;

-- ============================================
-- BILLING PROCEDURES
-- ============================================

-- Insert new billing record
CREATE OR REPLACE PROCEDURE InsertBillingRecord(
    IN input_treatment_fee DECIMAL(10,2),
    IN input_medication_fee DECIMAL(10,2),
    IN input_lab_test_fee DECIMAL(10,2),
    IN input_consultation_fee DECIMAL(10,2),
    IN input_receptionist_id INT,
    IN input_patient_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN 
    INSERT INTO billing(
        treatment_fee,
        medication_fee,
        lab_test_fee,
        consultation_fee,
        receptionist_id,
        patient_id,
        payment_status
    ) VALUES (
        input_treatment_fee,
        input_medication_fee,
        input_lab_test_fee,
        input_consultation_fee,
        input_receptionist_id,
        input_patient_id,
        'Unpaid'
    );
END;
$$;

-- Update billing status
CREATE OR REPLACE PROCEDURE UpdateBillingStatus(
    IN input_status VARCHAR(10),
    IN input_billing_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE billing
    SET
        payment_status = COALESCE(input_status, payment_status)
    WHERE billing_id = input_billing_id;
END;
$$;

-- Get billing by status
CREATE OR REPLACE PROCEDURE GetBillingByStatus(
    IN input_status VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM billing
    WHERE payment_status = input_status;
END;
$$;

-- Get billing by patient
CREATE OR REPLACE PROCEDURE GetBillingByPatient(
    IN input_patient_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM billing
    WHERE patient_id = input_patient_id;
END;
$$;

-- Filter view billing
CREATE OR REPLACE PROCEDURE FilterViewBilling(
    IN input_billing_id INT,
    IN input_payment_status VARCHAR(10),
    IN input_receptionist_id INT,
    IN input_patient_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM billing
    WHERE
        (input_billing_id IS NULL OR billing_id = input_billing_id)
        AND (input_payment_status IS NULL OR input_payment_status = '' OR payment_status = input_payment_status)
        AND (input_receptionist_id IS NULL OR receptionist_id = input_receptionist_id)
        AND (input_patient_id IS NULL OR patient_id = input_patient_id);
END;
$$;

-- ============================================
-- DEPARTMENT PROCEDURES
-- ============================================

-- Add department
CREATE OR REPLACE PROCEDURE AddDepartment(
    IN input_department_name VARCHAR(100),
    IN input_location VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO department(department_name, location)
    VALUES (input_department_name, input_location);
END;
$$;

-- Update department name
CREATE OR REPLACE PROCEDURE UpdateDepartmentName(
    IN input_department_id INT,
    IN input_department_name VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN 
    UPDATE department
    SET department_name = COALESCE(input_department_name, department_name)
    WHERE department_id = input_department_id;
END;
$$;

-- Filter view departments
CREATE OR REPLACE PROCEDURE FilterViewDepartment(
    IN input_department_id INT,
    IN input_department_name VARCHAR(100),
    IN input_location VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN 
    SELECT * FROM department
    WHERE
        (input_department_id IS NULL OR department_id = input_department_id)
        AND (input_department_name IS NULL OR department_name = input_department_name)
        AND (input_location IS NULL OR location = input_location);
END;
$$;

-- ============================================
-- STAFF PROCEDURES
-- ============================================

-- Add new staff
CREATE OR REPLACE PROCEDURE AddNewStaff(
    IN input_last_name VARCHAR(50),
    IN input_first_name VARCHAR(50),
    IN input_role VARCHAR(100),
    IN input_contact VARCHAR(50),
    IN input_department_id INT,
    IN input_doctor_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN 
    INSERT INTO staff (last_name, first_name, role, contact, department_id, doctor_id)
    VALUES (input_last_name, input_first_name, input_role, input_contact, input_department_id, input_doctor_id);
END;
$$;

-- Update staff info
CREATE OR REPLACE PROCEDURE UpdateStaffInfo(
    IN input_staff_id INT,
    IN input_last_name VARCHAR(50),
    IN input_first_name VARCHAR(50),
    IN input_role VARCHAR(100),
    IN input_contact VARCHAR(50),
    IN input_department_id INT,
    IN input_doctor_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE staff
    SET
        last_name = COALESCE(input_last_name, last_name),
        first_name = COALESCE(input_first_name, first_name),
        role = COALESCE(input_role, role),
        contact = COALESCE(input_contact, contact),
        department_id = COALESCE(input_department_id, department_id),
        doctor_id = COALESCE(input_doctor_id, doctor_id)
    WHERE staff_id = input_staff_id;
END;
$$;

-- Filter view staff
CREATE OR REPLACE PROCEDURE FilterViewStaff(
    IN input_staff_id INT,
    IN input_last_name VARCHAR(50),
    IN input_first_name VARCHAR(50),
    IN input_role VARCHAR(100),
    IN input_contact VARCHAR(50),
    IN input_department_id INT,
    IN input_doctor_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN 
    SELECT * FROM staff
    WHERE
        (input_staff_id IS NULL OR staff_id = input_staff_id)
        AND (input_last_name IS NULL OR last_name = input_last_name)
        AND (input_first_name IS NULL OR first_name = input_first_name)
        AND (input_role IS NULL OR role = input_role)
        AND (input_contact IS NULL OR contact = input_contact)
        AND (input_department_id IS NULL OR department_id = input_department_id)
        AND (input_doctor_id IS NULL OR doctor_id = input_doctor_id);
END;
$$;
