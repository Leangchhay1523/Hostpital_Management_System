-- ============================================
-- HOSPITAL MANAGEMENT SYSTEM - DML (Data Manipulation Language)
-- Database: PostgreSQL
-- ============================================

-- NOTE: To import data from CSV files, use the \copy command in psql:
-- \copy table_name(column1, column2, ...) FROM '/path/to/file.csv' DELIMITER ',' CSV HEADER

-- ============================================
-- SAMPLE DATA FOR TESTING
-- ============================================

-- Sample Departments
INSERT INTO department (department_name, location) VALUES
    ('Cardiology', 'Building A, Floor 2'),
    ('Pediatrics', 'Building B, Floor 1'),
    ('Neurology', 'Building A, Floor 3'),
    ('Orthopedics', 'Building C, Floor 1'),
    ('Dermatology', 'Building B, Floor 2');

-- Sample Staff (Doctors, Nurses, Receptionists)
-- Doctors (staff_id 1-5)
INSERT INTO staff (last_name, first_name, gender, role, contact, specialization, department_id) VALUES
    ('Kong', 'Sitha', 'Male', 'Doctor', '012345678', 'Cardiologist', 1),
    ('Phan', 'Daliss', 'Female', 'Doctor', '098765432', 'Pediatrician', 2),
    ('Chea', 'Ratana', 'Male', 'Doctor', '097777777', 'Neurologist', 3),
    ('Sok', 'Monika', 'Female', 'Doctor', '096666666', 'Orthopedic Surgeon', 4),
    ('Heng', 'Vuthy', 'Male', 'Doctor', '095555555', 'Dermatologist', 5);

-- Nurses (staff_id 6-10)
INSERT INTO staff (last_name, first_name, gender, role, contact, department_id, doctor_id) VALUES
    ('Neang', 'Srey', 'Female', 'Nurse', '093123456', 1, 1),
    ('Mao', 'Phirun', 'Male', 'Nurse', '092234567', 2, 2),
    ('Khiev', 'Chenda', 'Female', 'Nurse', '097987654', 3, 3),
    ('Chan', 'Dara', 'Male', 'Nurse', '091122334', 4, 4),
    ('Keo', 'Malis', 'Female', 'Nurse', '098877665', 5, 5);

-- Receptionists (staff_id 11-13)
INSERT INTO staff (last_name, first_name, gender, role, contact, department_id) VALUES
    ('Yim', 'Lina', 'Female', 'Receptionist', '094455667', 1),
    ('Nhem', 'Rith', 'Male', 'Receptionist', '093344556', 2),
    ('Touch', 'Sophea', 'Female', 'Receptionist', '092233445', 3);

-- Sample Patients
INSERT INTO patient (last_name, first_name, height, weight, date_of_birth, address, contact, email, doctor_id) VALUES
    ('Chan', 'Sokha', 165.0, 58.5, '1992-03-15', '123 Street, Phnom Penh', '011122233', 'sokha.chan@email.com', 1),
    ('Yim', 'Dara', 172.3, 75.2, '1988-07-29', '456 Avenue, Siem Reap', '012233445', 'dara.yim@email.com', 2),
    ('Touch', 'Lina', 160.5, 53.1, '1996-11-04', '789 Road, Battambang', '013344556', 'lina.touch@email.com', 3),
    ('Nhem', 'Rith', 178.4, 80.7, '1985-01-19', '321 Lane, Kampong Cham', '014455667', 'rith.nhem@email.com', 4),
    ('Keo', 'Malis', 168.2, 60.0, '1993-09-12', '654 Street, Sihanoukville', '015566778', 'malis.keo@email.com', 5);

-- Sample Appointments
INSERT INTO appointment (purpose, date_time, status, doctor_id, patient_id) VALUES
    ('General Checkup', '2025-06-20 09:00:00', 'Scheduled', 1, 1),
    ('Follow-up', '2025-06-21 10:30:00', 'Scheduled', 2, 2),
    ('Diagnostic & Testing', '2025-06-22 14:00:00', 'Scheduled', 3, 3),
    ('Consultation', '2025-06-23 11:00:00', 'Scheduled', 4, 4),
    ('General Checkup', '2025-06-24 15:30:00', 'Scheduled', 5, 5);

-- Sample Medical Records
INSERT INTO medical_record (prescription, diagnosis, lab_result, treatment, patient_id, appointment_id) VALUES
    ('Take medicine twice daily', 'Hypertension Stage 1', 'Normal', 'Medication and lifestyle changes', 1, 1),
    ('Rest and hydration', 'Viral Infection', 'Pending', 'Supportive care', 2, 2),
    ('Insulin injection', 'Type 2 Diabetes', 'High glucose', 'Insulin therapy', 3, 3),
    ('Physical therapy', 'Knee injury', 'X-ray shows minor tear', 'PT and pain management', 4, 4),
    ('Topical cream', 'Eczema', 'Normal', 'Steroid cream application', 5, 5);

-- Sample Billing Records
-- Note: total_amount will be calculated automatically by the trigger
INSERT INTO billing (treatment_fee, medication_fee, lab_test_fee, consultation_fee, receptionist_id, patient_id, payment_status) VALUES
    (100.00, 50.00, 30.00, 80.00, 11, 1, 'Unpaid'),
    (80.00, 40.00, 25.00, 60.00, 12, 2, 'Paid'),
    (150.00, 70.00, 45.00, 90.00, 13, 3, 'Unpaid'),
    (200.00, 30.00, 50.00, 100.00, 11, 4, 'Partial'),
    (90.00, 45.00, 20.00, 70.00, 12, 5, 'Paid');

-- Sample Roles
INSERT INTO role (role_name) VALUES
    ('admin'),
    ('receptionist'),
    ('doctor'),
    ('nurse');

-- Sample Users (passwords should be hashed in production!)
-- Note: These users require the roles to be created first (see RBAC.sql)
-- INSERT INTO users (username, password, role_id) VALUES
--     ('admin_user', '$2b$12$hashed_password_here', 1),
--     ('receptionist_user', '$2b$12$hashed_password_here', 2),
--     ('doctor_user', '$2b$12$hashed_password_here', 3),
--     ('nurse_user', '$2b$12$hashed_password_here', 4);
