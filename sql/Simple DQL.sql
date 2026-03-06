-- ============================================
-- HOSPITAL MANAGEMENT SYSTEM - SIMPLE DQL
-- Database: PostgreSQL
-- ============================================

-- Note: In PostgreSQL, use \c to change database
-- \c hospital;

-- 1. Select all data from all tables
    -- Department
SELECT * FROM department;
    -- Patient
SELECT * FROM patient;
    -- Appointment
SELECT * FROM appointment;
    -- Staff (includes doctors, nurses, receptionists)
SELECT * FROM staff;
    -- Medical Record
SELECT * FROM medical_record;
    -- Billing
SELECT * FROM billing;

-- 2. Select Specific Columns
    -- Select first name and last name for doctors
SELECT first_name, last_name FROM staff WHERE role = 'Doctor';
    -- Select first name, last name and contact for all patients
SELECT first_name, last_name, contact FROM patient;
    -- Select billing details
SELECT treatment_fee, medication_fee, lab_test_fee, consultation_fee, patient_id FROM billing;
    -- Select doctor's name and their specialization
SELECT last_name || ' ' || first_name AS doctor_name, specialization FROM staff WHERE role = 'Doctor';
    -- Select patient first name, last name and DOB
SELECT first_name, last_name, date_of_birth FROM patient;

-- 3. Filtering Data
    -- Doctor specialized in Cardiology
SELECT * FROM staff 
WHERE role = 'Doctor' AND specialization = 'Cardiologist';
    -- Select patients who are over 60 years old
SELECT *, EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) AS age FROM patient
WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) > 60 AND date_of_birth IS NOT NULL;
    -- Patient with active appointment
SELECT * FROM patient
JOIN appointment USING (patient_id)
WHERE status = 'Scheduled';
    -- Select patient assigned to doctor with id 15
SELECT * FROM patient
WHERE doctor_id = 15;
    -- Select all staff with role Nurse
SELECT * FROM staff
WHERE role = 'Nurse';
    -- Select appointment schedule for today
SELECT * FROM appointment
WHERE DATE(date_time) = CURRENT_DATE;
    -- Select staff working in department with id = 1
SELECT * FROM staff
WHERE department_id = 1;

-- 4. JOINS
    -- Staff and department name
SELECT s.*, d.department_name FROM staff s
JOIN department d ON s.department_id = d.department_id; 
    -- Select all patients with their assigned doctor name
SELECT p.*, s.last_name || ' ' || s.first_name AS doctor_name FROM patient p
JOIN staff s ON p.doctor_id = s.staff_id;
    -- Select appointment including name of patient and doctor
SELECT a.*, p.first_name || ' ' || p.last_name AS patient_name, 
       s.first_name || ' ' || s.last_name AS doctor_name 
FROM appointment a
JOIN patient p ON a.patient_id = p.patient_id
JOIN staff s ON a.doctor_id = s.staff_id;
    -- Select medical record with patient name and appointment purpose
SELECT m.*, p.first_name || ' ' || p.last_name AS patient_name, a.purpose 
FROM medical_record m
JOIN patient p ON m.patient_id = p.patient_id
JOIN appointment a ON a.appointment_id = m.appointment_id;
    -- Select staff with their supervising doctor and department name
SELECT s.*, d.first_name || ' ' || d.last_name AS doctor_name, dept.department_name 
FROM staff s
LEFT JOIN staff d ON s.doctor_id = d.staff_id
JOIN department dept ON dept.department_id = s.department_id;
    -- Select billing info along with patient and receptionist name
SELECT b.*, p.first_name || ' ' || p.last_name AS patient_name, 
       s.first_name || ' ' || s.last_name AS receptionist_name 
FROM billing b
JOIN staff s ON s.staff_id = b.receptionist_id
JOIN patient p ON p.patient_id = b.patient_id;

-- 5. Aggregate Functions
    -- Find average weight of all patients
SELECT AVG(weight) AS patient_avg_weight FROM patient;
    -- Calculate total treatment fee for all patients
SELECT SUM(treatment_fee) AS total_treatment_fee FROM billing;
    -- Get total number of doctors working in the hospital
SELECT COUNT(*) AS total_doctors FROM staff WHERE role = 'Doctor';
    -- Find average height of all patients
SELECT AVG(height) AS patient_avg_height FROM patient; 
    -- Find the number of appointments in a specific time period (group by month/year)
SELECT COUNT(*) AS number_of_appointments, 
       EXTRACT(YEAR FROM date_time) AS year, 
       EXTRACT(MONTH FROM date_time) AS month 
FROM appointment
GROUP BY EXTRACT(YEAR FROM date_time), EXTRACT(MONTH FROM date_time);
    -- Find total number of patients assigned to each doctor
SELECT COUNT(*) AS total_patients, doctor_id FROM patient
WHERE doctor_id IS NOT NULL
GROUP BY doctor_id;
    
-- 6. Sorting Data
    -- Select all doctors sorted by last name ascending
SELECT * FROM staff WHERE role = 'Doctor'
ORDER BY last_name;
    -- Select all patient names ordered by date_of_birth from young to older
SELECT last_name || ' ' || first_name AS patient_name, date_of_birth FROM patient
ORDER BY date_of_birth DESC;
    -- Show appointment schedule sorted by date and time ascending
SELECT * FROM appointment
ORDER BY date_time;
    -- Sort billing records by total amount in descending order
SELECT * FROM billing
ORDER BY total_amount DESC;

-- 7. Grouping Data
    -- Count number of billing records grouped by status
SELECT COUNT(*) AS billing_amount, payment_status FROM billing
GROUP BY payment_status;
    -- Count number of appointments grouped by status
SELECT COUNT(*) AS appointment_amount, status FROM appointment
GROUP BY status;
    -- Group patients by their doctor's department and get count of patients per department
SELECT COUNT(*) AS number_of_patients, d.department_id 
FROM patient p
JOIN staff d ON p.doctor_id = d.staff_id
GROUP BY d.department_id; 
    -- Group patients by doctor's specialization and calculate average weight per specialization
SELECT AVG(p.weight) AS avg_weight, d.specialization 
FROM patient p
JOIN staff d ON p.doctor_id = d.staff_id
GROUP BY d.specialization;

-- 8. Sub Queries
    -- Find all patients who have an appointment with a doctor specializing in Neurology 
SELECT * FROM patient
WHERE doctor_id IN (
    SELECT staff_id FROM staff
    WHERE role = 'Doctor' AND specialization = 'Neurology'
);
    -- Retrieve the doctor's name who has the highest number of appointments in the last month
SELECT first_name || ' ' || last_name AS doctor_name FROM staff
WHERE staff_id = (
    SELECT doctor_id FROM appointment
    WHERE EXTRACT(MONTH FROM date_time) = EXTRACT(MONTH FROM CURRENT_DATE - INTERVAL '1 month')
    AND EXTRACT(YEAR FROM date_time) = EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '1 month')
    GROUP BY doctor_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);
    -- Get departments that have more than 5 doctors 
SELECT * FROM department
WHERE department_id IN (
    SELECT department_id FROM staff
    WHERE role = 'Doctor'
    GROUP BY department_id
    HAVING COUNT(*) > 5
);
    -- Find patients who have a billing record where total amount is greater than 500
SELECT * FROM patient
JOIN billing b USING (patient_id)
WHERE b.billing_id IN (
    SELECT billing_id FROM billing
    WHERE total_amount > 500
);

-- 9. Pattern Matching
    -- Find patients where last name starts with 'S'
SELECT * FROM patient
WHERE last_name ILIKE 'S%';
    -- Retrieve all doctors whose specialization contains the word "Pediatrics"
SELECT * FROM staff
WHERE role = 'Doctor' AND specialization ILIKE '%Pediatrics%';
    -- Get staff members whose contact number starts with a specific area code (e.g., "555")
SELECT * FROM staff
WHERE contact LIKE '555%';
