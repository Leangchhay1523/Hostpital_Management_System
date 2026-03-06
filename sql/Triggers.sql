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

-- Trigger for Billing Table
	-- Insert Trigger
CREATE TRIGGER calc_total_amount_before_insert
BEFORE INSERT ON BILLING
FOR EACH ROW
EXECUTE FUNCTION calc_total_billing();

	-- Update Trigger
CREATE TRIGGER calc_total_amount_before_update
BEFORE UPDATE ON BILLING
FOR EACH ROW
EXECUTE FUNCTION calc_total_billing();

-- Add last modified column
CREATE OR REPLACE FUNCTION update_last_modified()
RETURNS TRIGGER AS $$
BEGIN
   NEW.last_modified = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- department table
CREATE TRIGGER trg_update_last_modified
BEFORE UPDATE ON department
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- staff table
CREATE TRIGGER trg_update_last_modified
BEFORE UPDATE ON staff
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- patient table
CREATE TRIGGER trg_update_last_modified
BEFORE UPDATE ON patient
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- appointment table
CREATE TRIGGER trg_update_last_modified
BEFORE UPDATE ON appointment
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- medical_record table
CREATE TRIGGER trg_update_last_modified
BEFORE UPDATE ON medical_record
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- billing table
CREATE TRIGGER trg_update_last_modified
BEFORE UPDATE ON billing
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();