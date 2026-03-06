-- ============================================
-- HOSPITAL MANAGEMENT SYSTEM - TRIGGERS
-- Database: PostgreSQL
-- ============================================

-- ============================================
-- TRIGGER FUNCTIONS
-- ============================================

-- Function to calculate total billing
CREATE OR REPLACE FUNCTION calc_total_billing()
RETURNS TRIGGER AS $$
BEGIN
    NEW.total_amount := COALESCE(NEW.treatment_fee, 0) +
                        COALESCE(NEW.medication_fee, 0) +
                        COALESCE(NEW.lab_test_fee, 0) +
                        COALESCE(NEW.consultation_fee, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update last_modified timestamp
CREATE OR REPLACE FUNCTION update_last_modified()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_modified = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- BILLING TRIGGERS
-- ============================================

-- Trigger to calculate total_amount before INSERT
CREATE TRIGGER calc_total_amount_before_insert
BEFORE INSERT ON billing
FOR EACH ROW
EXECUTE FUNCTION calc_total_billing();

-- Trigger to calculate total_amount before UPDATE
CREATE TRIGGER calc_total_amount_before_update
BEFORE UPDATE ON billing
FOR EACH ROW
EXECUTE FUNCTION calc_total_billing();

-- ============================================
-- LAST_MODIFIED TRIGGERS (All tables)
-- ============================================

-- Department table
CREATE TRIGGER trg_update_last_modified_department
BEFORE UPDATE ON department
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- Staff table
CREATE TRIGGER trg_update_last_modified_staff
BEFORE UPDATE ON staff
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- Patient table
CREATE TRIGGER trg_update_last_modified_patient
BEFORE UPDATE ON patient
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- Appointment table
CREATE TRIGGER trg_update_last_modified_appointment
BEFORE UPDATE ON appointment
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- Medical record table
CREATE TRIGGER trg_update_last_modified_medical_record
BEFORE UPDATE ON medical_record
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- Billing table
CREATE TRIGGER trg_update_last_modified_billing
BEFORE UPDATE ON billing
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- Role table
CREATE TRIGGER trg_update_last_modified_role
BEFORE UPDATE ON role
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- Users table
CREATE TRIGGER trg_update_last_modified_users
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();
