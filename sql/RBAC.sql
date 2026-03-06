-- Create Role
CREATE ROLE admin_role SUPERUSER;

	-- Receptionist Role
CREATE ROLE receptionist_role; 

		-- Grant access to database and schema
GRANT CONNECT ON DATABASE hospital TO receptionist_role;
GRANT USAGE ON SCHEMA public TO receptionist_role;

		-- Grant access to table
GRANT SELECT, INSERT ON public.PATIENT TO receptionist_role;
GRANT SELECT, INSERT ON public.BILLING TO receptionist_role;
GRANT SELECT ON public.APPOINTMENT TO receptionist_role;

		-- Grant execute on procedures
GRANT EXECUTE ON PROCEDURE InsertBillingRecord(
    IN INPUT_TREATMENT_FEE DECIMAL(10,2),
    IN INPUT_MEDICATION_FEE DECIMAL(10,2),
    IN INPUT_LAB_TEST_FEE DECIMAL(10,2),
    IN INPUT_CONSULTATION_FEE DECIMAL(10,2),
    IN INPUT_RECEPTIONIST_ID INT,
    IN INPUT_PATIENT_ID INT
) TO receptionist_role;
GRANT EXECUTE ON PROCEDURE UpdateBillingStatus(
    IN INPUT_STATUS VARCHAR(10),
    IN INPUT_BILLING_ID INT
) TO receptionist_role;
GRANT EXECUTE ON PROCEDURE GetBillingByStatus(
    IN INPUT_STATUS VARCHAR(20)
) TO receptionist_role;
GRANT EXECUTE ON PROCEDURE GetBillingByPatient(
    IN INPUT_PATIENT_ID INT
) TO receptionist_role;
GRANT EXECUTE ON PROCEDURE UpdatePatientInfo(
    IN INPUT_ADDRESS VARCHAR(255),
    IN INPUT_EMAIL VARCHAR(50),
    IN INPUT_CONTACT VARCHAR(50),
    IN INPUT_PATIENT_ID INT
) TO receptionist_role;
GRANT EXECUTE ON PROCEDURE InsertNewPatient(
	IN INPUT_LAST_NAME VARCHAR(50),
    IN INPUT_FIRST_NAME VARCHAR(50),
	IN INPUT_HEIGHT DECIMAL(10, 2),
	IN INPUT_WEIGHT DECIMAL(10, 2),
	IN INPUT_DATE_OF_BIRTH DATE,
	IN INPUT_ADDRESS VARCHAR(255),
	IN INPUT_CONTACT VARCHAR(50),
	IN INPUT_EMAIL VARCHAR(50),
	IN INPUT_DOCTOR_ID INT
) TO receptionist_role;
GRANT EXECUTE ON PROCEDURE AddAppointmentRecord(
    IN INPUT_PURPOSE VARCHAR(255), 
    IN INPUT_DATE_TIME TIMESTAMP, 
    IN INPUT_STATUS VARCHAR(50), 
    IN INPUT_DOCTOR_ID INT, 
    IN INPUT_PATIENT_ID INT
) TO receptionist_role;
GRANT EXECUTE ON PROCEDURE ViewAppointmentByDate(IN INPUT_DATE DATE) TO nurse_role;

	-- Doctor Role
CREATE ROLE doctor_role;

		-- Grant access to database and schema
GRANT CONNECT ON DATABASE hospital TO doctor_role;
GRANT USAGE ON SCHEMA public TO doctor_role;

		-- Grant access to table
GRANT SELECT, INSERT, UPDATE ON public.APPOINTMENT TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON public.MEDICAL_RECORD TO doctor_role;
GRANT SELECT ON public.PATIENT TO doctor_role;

		-- Grant execute on procedures
GRANT EXECUTE ON PROCEDURE AddAppointmentRecord(
    IN INPUT_PURPOSE VARCHAR(255), 
    IN INPUT_DATE_TIME TIMESTAMP, 
    IN INPUT_STATUS VARCHAR(50), 
    IN INPUT_DOCTOR_ID INT, 
    IN INPUT_PATIENT_ID INT
) TO doctor_role;
GRANT EXECUTE ON PROCEDURE UpdateAppointmentStatus(
    IN INPUT_STATUS VARCHAR(50),
    IN INPUT_APPOINTMENT_ID INT
) TO doctor_role;
GRANT EXECUTE ON PROCEDURE ViewAppointmentByDate(IN INPUT_DATE DATE) TO doctor_role;
GRANT EXECUTE ON PROCEDURE ViewAppointmentByDoctorID(
    IN INPUT_DOCTOR_ID INT
) TO doctor_role;
GRANT EXECUTE ON PROCEDURE AddMedicalRecord(
    IN INPUT_PRESCRIPTION TEXT,
    IN INPUT_DIAGNOSIS TEXT,
    IN INPUT_LAB_RESULT VARCHAR(255),
    IN INPUT_TREATMENT VARCHAR(255),
    IN INPUT_PATIENT_ID INT,
    IN INPUT_APPOINTMENT_ID INT
) TO doctor_role;
GRANT EXECUTE ON PROCEDURE UpdateMedicalRecordDetails(
    IN INPUT_PRESCRIPTION TEXT,
    IN INPUT_DIAGNOSIS TEXT,
    IN INPUT_LAB_RESULT VARCHAR(255),
    IN INPUT_TREATMENT VARCHAR(255),
    IN INPUT_RECORD_ID INT
) TO doctor_role;
GRANT EXECUTE ON PROCEDURE GetMedicalRecordByPatient(IN INPUT_PATIENT_ID INT) TO doctor_role;
GRANT EXECUTE ON PROCEDURE GetPatientsByDoctor(IN INPUT_DOCTOR_ID INT) TO doctor_role;

	-- Nurse Role
CREATE ROLE nurse_role;

		-- Grant access to database and schema
GRANT CONNECT ON DATABASE hospital TO nurse_role;
GRANT USAGE ON SCHEMA public TO nurse_role; 

		-- Grant access to table
GRANT SELECT, UPDATE ON public.PATIENT TO nurse_role;
GRANT SELECT ON public.APPOINTMENT TO nurse_role;
GRANT SELECT ON public.MEDICAL_RECORD TO nurse_role;

		-- Grant execute on procedures
GRANT EXECUTE ON PROCEDURE UpdatePatientVitals(
    IN INPUT_HEIGHT DECIMAL(10,2),
    IN INPUT_WEIGHT DECIMAL(10,2),
    IN INPUT_PATIENT_ID INT
) TO nurse_role;
GRANT EXECUTE ON PROCEDURE GetPatientsByDoctor(IN INPUT_DOCTOR_ID INT) TO nurse_role;
GRANT EXECUTE ON PROCEDURE GetMedicalRecordByDoctor(IN INPUT_DOCTOR_ID INT) TO nurse_role;
GRANT EXECUTE ON PROCEDURE ViewAppointmentByDoctorID(
    IN INPUT_DOCTOR_ID INT
) TO nurse_role;
GRANT EXECUTE ON PROCEDURE ViewAppointmentByDate(IN INPUT_DATE DATE) TO nurse_role;

-- Create User
	-- Admin
CREATE USER admin WITH LOGIN PASSWORD 'adminPass';
GRANT admin_role TO admin;

CREATE USER receptionist WITH LOGIN PASSWORD 'receptionistPass';
GRANT receptionist_role TO receptionist;

CREATE USER doctor WITH LOGIN PASSWORD 'doctorPass';
GRANT doctor_role TO doctor;

CREATE USER nurse WITH LOGIN PASSWORD 'nursePass';
GRANT nurse_role TO nurse;