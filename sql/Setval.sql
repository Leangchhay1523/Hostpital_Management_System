-- ============================================
-- HOSPITAL MANAGEMENT SYSTEM - SEQUENCE RESET
-- Database: PostgreSQL
-- ============================================

-- This file resets all sequences to match the maximum ID values in each table
-- Run this after importing data from CSV files

-- Reset department_id sequence
SELECT setval('department_department_id_seq', COALESCE((SELECT MAX(department_id) FROM department), 1), true);

-- Reset staff_id sequence
SELECT setval('staff_staff_id_seq', COALESCE((SELECT MAX(staff_id) FROM staff), 1), true);

-- Reset patient_id sequence
SELECT setval('patient_patient_id_seq', COALESCE((SELECT MAX(patient_id) FROM patient), 1), true);

-- Reset patient_doctor_id sequence
SELECT setval('patient_doctor_patient_doctor_id_seq', COALESCE((SELECT MAX(patient_doctor_id) FROM patient_doctor), 1), true);

-- Reset appointment_id sequence
SELECT setval('appointment_appointment_id_seq', COALESCE((SELECT MAX(appointment_id) FROM appointment), 1), true);

-- Reset record_id sequence
SELECT setval('medical_record_record_id_seq', COALESCE((SELECT MAX(record_id) FROM medical_record), 1), true);

-- Reset billing_id sequence
SELECT setval('billing_billing_id_seq', COALESCE((SELECT MAX(billing_id) FROM billing), 1), true);

-- Reset role_id sequence
SELECT setval('role_role_id_seq', COALESCE((SELECT MAX(role_id) FROM role), 1), true);

-- Reset user_id sequence
SELECT setval('users_user_id_seq', COALESCE((SELECT MAX(user_id) FROM users), 1), true);
