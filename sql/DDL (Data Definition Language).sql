-- DATABASE
CREATE DATABASE HOSPITAL;

-- DEPARTMENT TABLE
CREATE TABLE department (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL, 
    location VARCHAR(255)                  
);

ALTER TABLE department ADD last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- STAFF TABLE
CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,        
    first_name VARCHAR(50) NOT NULL,  
	gender VARCHAR(50),
    role VARCHAR(100),                     
    contact VARCHAR(50),
	specialization VARCHAR(50) DEFAULT NULL, -- Only for doctor
    department_id INT,  
    doctor_id INT DEFAULT NULL, -- Only for nurse
    CONSTRAINT fk_staff_department FOREIGN KEY (department_id)
        REFERENCES department (department_id) ON DELETE CASCADE,
    CONSTRAINT fk_staff_doctor FOREIGN KEY (doctor_id)
        REFERENCES staff (staff_id) ON DELETE CASCADE
);

ALTER TABLE staff ADD last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

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
    email VARCHAR(50)                     
);

ALTER TABLE patient ADD last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- PATIENT_DOCTOR JUNCTION TABLE (Many-to-Many relationship)
CREATE TABLE patient_doctor (
    patient_doctor_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    CONSTRAINT fk_patient_doctor_patient FOREIGN KEY (patient_id)
        REFERENCES patient (patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_patient_doctor_doctor FOREIGN KEY (doctor_id)
        REFERENCES staff (staff_id) ON DELETE CASCADE,
);

ALTER TABLE patient_doctor ADD last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- APPOINTMENT TABLE
CREATE TABLE appointment (
    appointment_id SERIAL PRIMARY KEY,
    purpose VARCHAR(255),                  
    date_time TIMESTAMP NOT NULL,          
    status VARCHAR(50) DEFAULT 'Not Completed' NOT NULL, 
    doctor_id INT NOT NULL,                
    patient_id INT NOT NULL,               
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id)
        REFERENCES staff (staff_id) ON DELETE CASCADE,
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id)
        REFERENCES patient (patient_id) ON DELETE CASCADE
);

ALTER TABLE appointment ADD last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- MEDICAL RECORD TABLE
CREATE TABLE medical_record (
    record_id SERIAL PRIMARY KEY,
    prescription TEXT,                     
    diagnosis TEXT,
    lab_result VARCHAR(255),
    treatment VARCHAR(255),
    patient_id INT NOT NULL,               
    appointment_id INT NOT NULL,           
    CONSTRAINT fk_record_patient FOREIGN KEY (patient_id)
        REFERENCES patient (patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_record_appointment FOREIGN KEY (appointment_id)
        REFERENCES appointment (appointment_id) ON DELETE CASCADE
);

ALTER TABLE medical_record ADD last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

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
    CONSTRAINT fk_billing_staff FOREIGN KEY (receptionist_id)
        REFERENCES staff (staff_id) ON DELETE CASCADE,
    CONSTRAINT fk_billing_patient FOREIGN KEY (patient_id)
        REFERENCES patient (patient_id) ON DELETE CASCADE
);

ALTER TABLE billing ADD last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Role Table
CREATE TABLE role (
  role_id SERIAL PRIMARY KEY,
  role_name VARCHAR(20) NOT NULL,
  last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Table
CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(255) NOT NULL,
  role_id INT NOT NULL,
  last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT user_role_id FOREIGN KEY (role_id)
    REFERENCES role (role_id) ON DELETE CASCADE
);
