-- Reset department_id sequence
SELECT setval('department_department_id_seq', (SELECT MAX(department_id) FROM department), true);

-- Reset staff_id sequence
SELECT setval('staff_staff_id_seq', (SELECT MAX(staff_id) FROM staff), true);

-- Reset patient_id sequence
SELECT setval('patient_patient_id_seq', (SELECT MAX(patient_id) FROM patient), true);

-- Reset patient_doctor_id sequence
SELECT setval('patient_doctor_patient_doctor_id_seq', (SELECT MAX(patient_doctor_id) FROM patient_doctor), true);

-- Reset appointment_id sequence
SELECT setval('appointment_appointment_id_seq', (SELECT MAX(appointment_id) FROM appointment), true);

-- Reset record_id sequence
SELECT setval('medical_record_record_id_seq', (SELECT MAX(record_id) FROM medical_record), true);

-- Reset billing_id sequence
SELECT setval('billing_billing_id_seq', (SELECT MAX(billing_id) FROM billing), true);

-- Reset role_id sequence
SELECT setval('role_role_id_seq', (SELECT MAX(role_id) FROM role), true);

-- Reset user_id sequence
SELECT setval('users_user_id_seq', (SELECT MAX(user_id) FROM users), true);
