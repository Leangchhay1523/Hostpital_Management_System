-- Create Role
CREATE ROLE admin_role SUPERUSER;

	-- Receptionist Role
CREATE ROLE receptionist_role; 

		-- Grant access to database and schema
GRANT CONNECT ON DATABASE hospital TO receptionist_role;
GRANT USAGE ON SCHEMA public TO receptionist_role;

		-- Grant access to table
GRANT SELECT, INSERT ON public.PATIENT TO receptionist_role;
GRANT SELECT, INSERT, UPDATE ON public.BILLING TO receptionist_role;
GRANT SELECT, INSERT ON public.APPOINTMENT TO receptionist_role;

	-- Doctor Role
CREATE ROLE doctor_role;

		-- Grant access to database and schema
GRANT CONNECT ON DATABASE hospital TO doctor_role;
GRANT USAGE ON SCHEMA public TO doctor_role;

		-- Grant access to table
GRANT SELECT ON public.PATIENT to doctor_role;
GRANT SELECT, INSERT, UPDATE ON public.APPOINTMENT TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON public.MEDICAL_RECORD TO doctor_role;

	-- Nurse Role
CREATE ROLE nurse_role;

		-- Grant access to database and schema
GRANT CONNECT ON DATABASE hospital TO nurse_role;
GRANT USAGE ON SCHEMA public TO nurse_role; 

		-- Grant access to table
GRANT USAGE ON SCHEMA public TO nurse_role;
GRANT SELECT, UPDATE ON public.PATIENT TO nurse_role;
GRANT SELECT ON APPOINTMENT TO nurse_role;
GRANT SELECT ON MEDICAL_RECORD TO nurse_role;

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