-- Connect to database
\c hospital

-- 1. Department
\copy department(department_id, department_name, location)
FROM '/path/to/department.csv'
DELIMITER ',' CSV HEADER;

-- 2. Staff
\copy staff(staff_id, last_name, first_name, gender, role, contact, specialization, department_id, doctor_id)
FROM '/path/to/staff.csv'
DELIMITER ',' CSV HEADER;

-- 3. Patient
\copy patient(patient_id, last_name, first_name, height, weight, date_of_birth, address, contact, email)
FROM '/path/to/patient.csv'
DELIMITER ',' CSV HEADER;

-- 4. Patient_Doctor (junction table)
\copy patient_doctor(patient_doctor_id, patient_id, doctor_id)
FROM '/path/to/patient_doctor.csv'
DELIMITER ',' CSV HEADER;

-- 5. Appointment
\copy appointment(appointment_id, purpose, date_time, status, doctor_id, patient_id)
FROM '/path/to/appointment.csv'
DELIMITER ',' CSV HEADER;

-- 6. Medical Record
\copy medical_record(record_id, prescription, diagnosis, lab_result, treatment, patient_id, appointment_id)
FROM '/path/to/medical_record.csv'
DELIMITER ',' CSV HEADER;

-- 7. Billing
\copy billing(billing_id, treatment_fee, medication_fee, lab_test_fee, consultation_fee, total_amount, payment_status, receptionist_id, patient_id)
FROM '/path/to/billing.csv'
DELIMITER ',' CSV HEADER;

-- 8. Role
\copy role(role_id, role_name)
FROM '/path/to/role.csv'
DELIMITER ',' CSV HEADER;

-- 9. Users
\copy users(user_id, username, password, role_id)
FROM '/path/to/users.csv'
DELIMITER ',' CSV HEADER;

-- Reset SERIAL sequences after manual ID insertion
SELECT setval('department_department_id_seq', (SELECT MAX(department_id) FROM department));
SELECT setval('staff_staff_id_seq', (SELECT MAX(staff_id) FROM staff));
SELECT setval('patient_patient_id_seq', (SELECT MAX(patient_id) FROM patient));
SELECT setval('patient_doctor_patient_doctor_id_seq', (SELECT MAX(patient_doctor_id) FROM patient_doctor));
SELECT setval('appointment_appointment_id_seq', (SELECT MAX(appointment_id) FROM appointment));
SELECT setval('medical_record_record_id_seq', (SELECT MAX(record_id) FROM medical_record));
SELECT setval('billing_billing_id_seq', (SELECT MAX(billing_id) FROM billing));
SELECT setval('role_role_id_seq', (SELECT MAX(role_id) FROM role));
SELECT setval('users_user_id_seq', (SELECT MAX(user_id) FROM users));