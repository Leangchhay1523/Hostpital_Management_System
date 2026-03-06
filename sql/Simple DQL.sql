-- Use Database
USE HOSPITAL;

-- 1. Select all data from all tables
	-- Department
SELECT * FROM DEPARTMENT;
	-- Patient
SELECT * FROM PATIENT;
	-- Appointment
SELECT * FROM APPOINTMENT;
	-- Doctor
SELECT * FROM DOCTOR;
	-- Medical Record
SELECT * FROM MEDICAL_RECORD;
	-- Staff
SELECT * FROM STAFF;
	-- Billing
SELECT * FROM BILLING;

-- 2. Select Specific Column
	-- Select first name and last name from doctor
SELECT FIRST_NAME, LAST_NAME FROM DOCTOR;
	-- Select first name, last name and contact for all patients
SELECT FIRST_NAME, LAST_NAME, CONTACT FROM PATIENT;
	-- Select billing details
SELECT TREATMENT_FEE, MEDICATION_FEE, LAB_TEST_FEE, CONSULTATION_FEE, PATIENT_ID FROM BILLING;
	-- Select doctor's name and their specialization
SELECT CONCAT(LAST_NAME, " ", FIRST_NAME), SPECIALIZATION FROM DOCTOR;
	-- Select patient first name, last name and DOB
SELECT FIRST_NAME, LAST_NAME, DATE_OF_BIRTH FROM PATIENT;

-- 3. Filtering Data
	-- Doctor specialized in Cardiology
SELECT * FROM DOCTOR
WHERE SPECIALIZATION = "Cardiologist";
	-- Select patient who are over 60 years old
SELECT *, TIMESTAMPDIFF(YEAR, DATE_OF_BIRTH, NOW()) AS AGE FROM PATIENT
WHERE TIMESTAMPDIFF(YEAR, DATE_OF_BIRTH, NOW()) > 60 and DATE_OF_BIRTH IS NOT NULL;
	-- Patient with active appointment
SELECT * FROM PATIENT
JOIN APPOINTMENT USING (PATIENT_ID)
WHERE STATUS = "Not Completed";
	-- Select patient assigned to doctor with id 15
SELECT * FROM PATIENT
WHERE DOCTOR_ID = 15;
	-- Select all staffs with role nurse
SELECT * FROM STAFF
WHERE ROLE = "Nurse";
	-- Select appointment schedule for today
SELECT * FROM APPOINTMENT
WHERE DATE(DATE_TIME) = DATE(NOW());
	-- Select staff working on department with id = 1
SELECT * FROM STAFF
WHERE DEPARTMENT_ID = 1;

-- 4. JOINS
	-- Doctor and department name
SELECT d.*, de.DEPARTMENT_NAME  FROM DOCTOR d
JOIN DEPARTMENT de USING (DEPARTMENT_ID); 
	-- Select all patient with their assigned doctor name
SELECT p.*, CONCAT(d.LAST_NAME, " ", d.FIRST_NAME) AS DOCTOR_NAME FROM PATIENT p
JOIN DOCTOR d USING (DOCTOR_ID);
	-- Select appointment including name of patient and doctor
SELECT a.*, CONCAT(p.FIRST_NAME, " ", p.LAST_NAME) AS PATIENT_NAME, CONCAT(d.FIRST_NAME, " ", d.LAST_NAME) AS DOCTOR_NAME FROM APPOINTMENT a
JOIN PATIENT p ON a.PATIENT_ID = p.PATIENT_ID
JOIN DOCTOR d ON a.DOCTOR_ID = d.DOCTOR_ID;
	-- Select medical record with patient name and appointment purpose
SELECT m.*, CONCAT(p.FIRST_NAME, " ", p.LAST_NAME) AS PATIENT_NAME, a.PURPOSE FROM MEDICAL_RECORD m
JOIN PATIENT p ON m.PATIENT_ID = p.PATIENT_ID
JOIN APPOINTMENT a ON a.APPOINTMENT_ID = m.APPOINTMENT_ID;
	-- Select staff with their doctor and department name
SELECT s.*, CONCAT(d.FIRST_NAME, " ", d.LAST_NAME) AS DOCTOR_NAME, de.DEPARTMENT_NAME FROM STAFF s
JOIN DOCTOR d ON s.DOCTOR_ID = d.DOCTOR_ID
JOIN DEPARTMENT de ON de.DEPARTMENT_ID = s.DEPARTMENT_ID;
	-- Select billing info along with patient and receptionist name
SELECT b.*, CONCAT(p.FIRST_NAME, " ", p.LAST_NAME) AS PATIENT_NAME, CONCAT(s.FIRST_NAME, " ", s.LAST_NAME) AS RECEPTIONIST_NAME FROM BILLING b
JOIN STAFF s ON s.STAFF_ID = b.RECEPTIONIST_ID
JOIN PATIENT p ON p.PATIENT_ID = b.PATIENT_ID;

-- 5. Aggregate Function
	-- Find average weight of all patients
SELECT AVG(WEIGHT) AS PATIENT_AVG_WEIGHT FROM PATIENT;
	-- Calculate total treatment fee for all patient
SELECT SUM(TREATMENT_FEE) AS TOTAL_TREATMENT_FEE FROM BILLING;
	-- Get total number of doctos woking in the hospital
SELECT COUNT(*) TOTAL_DOCTOR FROM DOCTOR;
	-- Find average height of all patients
SELECT AVG(HEIGHT) AS PATIENT_AVG_HEIGHT FROM PATIENT; 
	-- Find the number of appointments in a specific time period (group by month/year).
SELECT COUNT(*) AS NUMBER_OF_APPOINTMENT, YEAR(DATE_TIME) AS YEAR, MONTH(DATE_TIME) AS MONTH FROM APPOINTMENT
GROUP BY YEAR(DATE_TIME), MONTH(DATE_TIME);
	-- Find total of patient assigned to each doctor
SELECT COUNT(*) AS TOTAL_PATIENT, DOCTOR_ID FROM PATIENT
GROUP BY DOCTOR_ID;
	
-- 6. Sorting Data
	-- Select all doctors sort by last name asending
SELECT * FROM DOCTOR
ORDER BY LAST_NAME;
	-- Select all patient's name order by date_of_birth from young to older
SELECT CONCAT(p.LAST_NAME, " ", P.FIRST_NAME) PATIENT_NAME, DATE_OF_BIRTH FROM PATIENT p
ORDER BY DATE_OF_BIRTH DESC;
	-- Show appointment sort by date and time ascending
SELECT * FROM APPOINTMENT
ORDER BY DATE_TIME;
	-- Sort billing records  by total amount in descending
SELECT * FROM BILLING
ORDER BY TOTAL_AMOUNT DESC;

-- 7. Grouping Data
	-- Count number of billing group by status
SELECT COUNT(*) AS BILLING_AMOUNT, PAYMENT_STATUS FROM BILLING
GROUP BY PAYMENT_STATUS;
	-- count number of appointment group by status
SELECT COUNT(*) AS APPOINTMENT_AMOUNT, STATUS FROM APPOINTMENT
GROUP BY STATUS;
	-- Group the patients by their doctor’s department and get the count of patients per department.
SELECT COUNT(*) NUMBER_OF_PATIENT, d.DEPARTMENT_ID FROM PATIENT
JOIN DOCTOR d USING (DOCTOR_ID)
GROUP BY d.DEPARTMENT_ID; 
	-- Group the patients by doctor's specialization and calculate the average weight per specialization.
SELECT AVG(WEIGHT), d.SPECIALIZATION FROM PATIENT
JOIN DOCTOR d USING (DOCTOR_ID)
GROUP BY d.SPECIALIZATION;

-- 8. Sub Query
	-- Find all patients who have an appointment with a doctor specializing in Neurology 
SELECT * FROM PATIENT
WHERE DOCTOR_ID = (
	SELECT DOCTOR_ID FROM DOCTOR
    WHERE SPECIALIZATION = "Neurology"
);
	-- Retrieve the doctor’s name who has the highest number of appointments in the last month
SELECT CONCAT(FIRST_NAME, " ", LAST_NAME) DOCTOR_NAME FROM DOCTOR
WHERE DOCTOR_ID = (
	SELECT DOCTOR_ID FROM APPOINTMENT
    WHERE MONTH(DATE_SUB(NOW(), INTERVAL 1 MONTH)) = MONTH(DATE_TIME)
    AND YEAR(DATE_TIME) = YEAR(DATE_SUB(NOW(), INTERVAL 1 MONTH))
    GROUP BY DOCTOR_ID
    ORDER BY COUNT(*) DESC
    LIMIT 1
);
	-- Get the departments that have more than 5 doctors 
SELECT * FROM DEPARTMENT
WHERE DEPARTMENT_ID IN (
	SELECT DEPARTMENT_ID FROM DEPARTMENT
    JOIN DOCTOR USING (DEPARTMENT_ID)
    GROUP BY DEPARTMENT_ID
    HAVING COUNT(*) > 5
);
	-- Find the patients who have a billing record where the total amount is greater than a specific value. e.g. 500
SELECT * FROM PATIENT
JOIN BILLING b USING (PATIENT_ID)
WHERE b.BILLING_ID IN (
	SELECT BILLING_ID FROM BILLING
    WHERE TOTAL_AMOUNT > 500
);

-- 9. Pattern Matching
	-- Find patient where last name starts with S
SELECT * FROM PATIENT
WHERE LAST_NAME LIKE "S%";
	-- Retrieve all doctors whose specialization contains the word "Pediatrics".
SELECT * FROM DOCTOR
WHERE SPECIALIZATION LIKE "%Pediatrics%";
	-- Get staff members whose contact number starts with a specific area  code (e.g., "555").
SELECT * FROM STAFF
WHERE CONTACT LIKE "555%";