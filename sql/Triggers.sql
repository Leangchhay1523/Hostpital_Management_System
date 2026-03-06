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