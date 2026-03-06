-- ============================================
-- HOSPITAL MANAGEMENT SYSTEM - DDL
-- Database: PostgreSQL
-- ============================================

-- DATABASE
CREATE DATABASE hospital;

-- Connect to hospital database
\c hospital;

-- DEPARTMENT TABLE
CREATE TABLE department (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL, 
    location VARCHAR(255),
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- STAFF TABLE
CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,        
    first_name VARCHAR(50) NOT NULL,  
    gender VARCHAR(50),
    role VARCHAR(100) NOT NULL,                     
    contact VARCHAR(50),
    specialization VARCHAR(50) DEFAULT NULL,
    department_id INT,  
    doctor_id INT DEFAULT NULL,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_staff_department FOREIGN KEY (department_id)
        REFERENCES department (department_id) ON DELETE CASCADE,
    CONSTRAINT fk_staff_doctor FOREIGN KEY (doctor_id)
        REFERENCES staff (staff_id) ON DELETE CASCADE,
    CONSTRAINT chk_staff_role CHECK (role IN ('Doctor', 'Nurse', 'Receptionist'))
);

-- PATIENT TABLE
CREATE TABLE patient (
    patient_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,       
    first_name VARCHAR(50) NOT NULL,    
    height NUMERIC(10,2),                 
    weight NUMERIC(10,2),                 
    date_of_birth DATE NOT NULL,          
    address VARCHAR(255),                 
    contact VARCHAR(50),                  
    email VARCHAR(50),
    doctor_id INT,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_patient_doctor FOREIGN KEY (doctor_id)
        REFERENCES staff (staff_id) ON DELETE SET NULL,
    CONSTRAINT chk_patient_height CHECK (height IS NULL OR (height > 0 AND height < 300)),
    CONSTRAINT chk_patient_weight CHECK (weight IS NULL OR (weight > 0 AND weight < 500))
);

-- PATIENT_DOCTOR JUNCTION TABLE (Many-to-Many relationship)
CREATE TABLE patient_doctor (
    patient_doctor_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_patient_doctor_patient FOREIGN KEY (patient_id)
        REFERENCES patient (patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_patient_doctor_doctor FOREIGN KEY (doctor_id)
        REFERENCES staff (staff_id) ON DELETE CASCADE,
    CONSTRAINT uk_patient_doctor UNIQUE (patient_id, doctor_id)
);

-- APPOINTMENT TABLE
CREATE TABLE appointment (
    appointment_id SERIAL PRIMARY KEY,
    purpose VARCHAR(255),                  
    date_time TIMESTAMP NOT NULL,          
    status VARCHAR(50) DEFAULT 'Scheduled' NOT NULL, 
    doctor_id INT NOT NULL,                
    patient_id INT NOT NULL,               
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id)
        REFERENCES staff (staff_id) ON DELETE CASCADE,
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id)
        REFERENCES patient (patient_id) ON DELETE CASCADE,
    CONSTRAINT chk_appointment_status CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'No Show'))
);

-- MEDICAL RECORD TABLE
CREATE TABLE medical_record (
    record_id SERIAL PRIMARY KEY,
    prescription TEXT,                     
    diagnosis TEXT,
    lab_result VARCHAR(255),
    treatment VARCHAR(255),
    patient_id INT NOT NULL,               
    appointment_id INT NOT NULL,           
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_record_patient FOREIGN KEY (patient_id)
        REFERENCES patient (patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_record_appointment FOREIGN KEY (appointment_id)
        REFERENCES appointment (appointment_id) ON DELETE CASCADE
);

-- BILLING TABLE
CREATE TABLE billing (
    billing_id SERIAL PRIMARY KEY,
    treatment_fee NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,     
    medication_fee NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    lab_test_fee NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    consultation_fee NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    total_amount NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,       
    payment_status VARCHAR(10) DEFAULT 'Unpaid' NOT NULL,   
    receptionist_id INT NOT NULL,                           
    patient_id INT NOT NULL,                                
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_billing_staff FOREIGN KEY (receptionist_id)
        REFERENCES staff (staff_id) ON DELETE CASCADE,
    CONSTRAINT fk_billing_patient FOREIGN KEY (patient_id)
        REFERENCES patient (patient_id) ON DELETE CASCADE,
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('Paid', 'Unpaid', 'Partial')),
    CONSTRAINT chk_fees_positive CHECK (
        treatment_fee >= 0 AND 
        medication_fee >= 0 AND 
        lab_test_fee >= 0 AND 
        consultation_fee >= 0 AND
        total_amount >= 0
    )
);

-- ROLE TABLE
CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(20) NOT NULL UNIQUE,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- USERS TABLE
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role FOREIGN KEY (role_id)
        REFERENCES role (role_id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX idx_staff_role ON staff(role);
CREATE INDEX idx_staff_department ON staff(department_id);
CREATE INDEX idx_staff_doctor ON staff(doctor_id);
CREATE INDEX idx_patient_doctor ON patient(doctor_id);
CREATE INDEX idx_appointment_doctor ON appointment(doctor_id);
CREATE INDEX idx_appointment_patient ON appointment(patient_id);
CREATE INDEX idx_appointment_status ON appointment(status);
CREATE INDEX idx_appointment_datetime ON appointment(date_time);
CREATE INDEX idx_medical_record_patient ON medical_record(patient_id);
CREATE INDEX idx_medical_record_appointment ON medical_record(appointment_id);
CREATE INDEX idx_billing_patient ON billing(patient_id);
CREATE INDEX idx_billing_receptionist ON billing(receptionist_id);
CREATE INDEX idx_billing_payment_status ON billing(payment_status);
CREATE INDEX idx_billing_total_amount ON billing(total_amount);
