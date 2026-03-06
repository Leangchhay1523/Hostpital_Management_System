-- Index on patient_id and fees in billing table
CREATE INDEX idx_billing_patient_fees 
  ON billing(patient_id, consultation_fee, treatment_fee, medication_fee, lab_test_fee);

-- Index on doctor_id in patient_doctor table
CREATE INDEX idx_patient_doctor_doctor_id 
  ON patient_doctor(doctor_id);

-- Index on patient_id in medical_record table
CREATE INDEX idx_medical_record_patient_id 
  ON medical_record(patient_id);

-- Index on appointment_id in medical_record table
CREATE INDEX idx_medical_record_appointment_id 
  ON medical_record(appointment_id);

-- Index on patient_id in appointment table
CREATE INDEX idx_appointment_patient
  ON appointment(patient_id);