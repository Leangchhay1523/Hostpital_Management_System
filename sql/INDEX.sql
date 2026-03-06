-- ============================================
-- HOSPITAL MANAGEMENT SYSTEM - INDEXES
-- Database: PostgreSQL
-- ============================================

-- Note: Most indexes are already created in DDL.sql
-- This file contains additional indexes for specific query patterns

-- ============================================
-- COMPOSITE INDEXES FOR COMMON QUERIES
-- ============================================

-- Index for patient lookup by doctor and date of birth
CREATE INDEX IF NOT EXISTS idx_patient_doctor_dob 
    ON patient(doctor_id, date_of_birth);

-- Index for appointment queries by doctor and status
CREATE INDEX IF NOT EXISTS idx_appointment_doctor_status 
    ON appointment(doctor_id, status);

-- Index for appointment queries by patient and date
CREATE INDEX IF NOT EXISTS idx_appointment_patient_date 
    ON appointment(patient_id, date_time);

-- Index for billing queries by patient and payment status
CREATE INDEX IF NOT EXISTS idx_billing_patient_status 
    ON billing(patient_id, payment_status);

-- Index for medical record queries
CREATE INDEX IF NOT EXISTS idx_medical_record_patient_appointment 
    ON medical_record(patient_id, appointment_id);

-- Index for staff lookup by department and role
CREATE INDEX IF NOT EXISTS idx_staff_department_role 
    ON staff(department_id, role);

-- ============================================
-- INDEXES FOR REPORTING/ANALYTICS
-- ============================================

-- Index for date-based reporting on appointments
CREATE INDEX IF NOT EXISTS idx_appointment_date_range 
    ON appointment(date_time) WHERE status != 'Cancelled';

-- Index for billing amount analysis
CREATE INDEX IF NOT EXISTS idx_billing_amount 
    ON billing(total_amount DESC);

-- Index for patient age calculations
CREATE INDEX IF NOT EXISTS idx_patient_dob 
    ON patient(date_of_birth);

-- ============================================
-- PARTIAL INDEXES FOR COMMON FILTERS
-- ============================================

-- Index for active appointments only
CREATE INDEX IF NOT EXISTS idx_appointment_active 
    ON appointment(patient_id, doctor_id, date_time) 
    WHERE status IN ('Scheduled', 'Completed');

-- Index for unpaid bills
CREATE INDEX IF NOT EXISTS idx_billing_unpaid 
    ON billing(patient_id, total_amount) 
    WHERE payment_status = 'Unpaid';

-- Index for doctors only (staff with role = 'Doctor')
CREATE INDEX IF NOT EXISTS idx_staff_doctors_only 
    ON staff(department_id, specialization) 
    WHERE role = 'Doctor';
