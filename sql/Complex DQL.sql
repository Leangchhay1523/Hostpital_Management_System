-- ============================================
-- HOSPITAL MANAGEMENT SYSTEM - COMPLEX DQL
-- Database: PostgreSQL
-- ============================================

-- 1. List all appointments along with the full name of the doctor and the patient, including department name
SELECT a.*, s.first_name || ' ' || s.last_name AS doctor_name, 
       p.first_name || ' ' || p.last_name AS patient_name, d.department_name 
FROM appointment a
JOIN staff s ON a.doctor_id = s.staff_id
JOIN patient p USING (patient_id)
JOIN department d ON d.department_id = s.department_id;

-- 2. Get all patients along with their latest appointment date and the doctor they saw, including doctor's specialization
SELECT 
    p.*,
    a.date_time AS latest_appointment,
    s.first_name || ' ' || s.last_name AS doctor_name,
    s.specialization
FROM patient p
JOIN appointment a ON p.patient_id = a.patient_id
JOIN staff s ON a.doctor_id = s.staff_id
WHERE a.date_time = (
    SELECT MAX(date_time)
    FROM appointment
    WHERE patient_id = p.patient_id
);

-- 3. List all nurses along with the doctor they report to (use doctor_id in staff)
SELECT
    nurse.staff_id AS nurse_id,
    nurse.first_name || ' ' || nurse.last_name AS nurse_name,
    doc.staff_id AS doctor_id,
    doc.first_name || ' ' || doc.last_name AS doctor_name
FROM staff nurse
JOIN staff doc ON nurse.doctor_id = doc.staff_id
WHERE nurse.doctor_id IS NOT NULL;

-- 4. Display all patients who have at least one medical record, including diagnosis and related doctor's name
SELECT DISTINCT
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    mr.diagnosis,
    d.first_name || ' ' || d.last_name AS doctor_name
FROM patient p
JOIN medical_record mr ON p.patient_id = mr.patient_id
JOIN appointment a ON mr.appointment_id = a.appointment_id
JOIN staff d ON a.doctor_id = d.staff_id;

-- 5. Find patients who have never had an appointment
SELECT *
FROM patient p
WHERE NOT EXISTS (
    SELECT 1 FROM appointment a WHERE a.patient_id = p.patient_id
);

-- 6. Get doctors who have more than 5 patients
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS doctor_name,
    COUNT(p.patient_id) AS patient_count
FROM staff s
JOIN patient p ON s.staff_id = p.doctor_id
WHERE s.role = 'Doctor'
GROUP BY s.staff_id
HAVING COUNT(p.patient_id) > 5;

-- 7. List all staff members who work in the department with the highest number of appointments
WITH dept_appointment_counts AS (
    SELECT
        s.department_id,
        COUNT(a.appointment_id) AS appointment_count
    FROM appointment a
    JOIN staff s ON a.doctor_id = s.staff_id
    GROUP BY s.department_id
),
max_dept AS (
    SELECT department_id
    FROM dept_appointment_counts
    ORDER BY appointment_count DESC
    LIMIT 1
)
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS staff_name,
    d.department_name
FROM staff s
JOIN department d ON s.department_id = d.department_id
WHERE s.department_id = (SELECT department_id FROM max_dept);

-- 8. Find patients whose total billing amount exceeds the average billing amount of all patients
WITH patient_totals AS (
    SELECT
        patient_id,
        SUM(total_amount) AS total_billing
    FROM billing
    GROUP BY patient_id
),
avg_billing AS (
    SELECT AVG(total_billing) AS avg_total FROM patient_totals
)
SELECT
    pt.patient_id,
    pt.total_billing
FROM patient_totals pt, avg_billing ab
WHERE pt.total_billing > ab.avg_total;

-- 9. For each doctor, show the total number of appointments and total billed amount
SELECT
    s.staff_id AS doctor_id,
    s.first_name || ' ' || s.last_name AS doctor_name,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    COALESCE(SUM(b.consultation_fee + b.treatment_fee + b.medication_fee + b.lab_test_fee), 0) AS total_billed_amount
FROM staff s
LEFT JOIN appointment a ON s.staff_id = a.doctor_id
LEFT JOIN billing b ON a.patient_id = b.patient_id
WHERE s.role = 'Doctor'
GROUP BY s.staff_id;

-- 10. Display the number of appointments per day in the past 30 days
SELECT
    DATE(date_time) AS appointment_date,
    COUNT(*) AS appointment_count
FROM appointment
WHERE date_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(date_time)
ORDER BY appointment_date;

-- 11. Calculate the average, max, and min consultation fee across all patients
SELECT
    AVG(consultation_fee) AS avg_consultation_fee,
    MAX(consultation_fee) AS max_consultation_fee,
    MIN(consultation_fee) AS min_consultation_fee
FROM billing;

-- 12. Function that returns the total bill amount for a given patient_id
CREATE OR REPLACE FUNCTION get_total_bill(patient_id_param INT)
RETURNS NUMERIC AS $$
DECLARE
    total NUMERIC;
BEGIN
    SELECT SUM(treatment_fee + medication_fee + lab_test_fee + consultation_fee)
    INTO total
    FROM billing
    WHERE patient_id = patient_id_param;
    
    RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;

-- 13. Function that returns the number of patients assigned to a specific doctor
CREATE OR REPLACE FUNCTION get_patient_count(doctor_id_param INT)
RETURNS INT AS $$
DECLARE
    count_patients INT;
BEGIN
    SELECT COUNT(*)
    INTO count_patients
    FROM patient
    WHERE doctor_id = doctor_id_param;
    
    RETURN COALESCE(count_patients, 0);
END;
$$ LANGUAGE plpgsql;

-- 14. Trigger function that updates the last_modified column (defined in TRIGGERS.sql)
-- Note: This function is defined in TRIGGERS.sql, do not recreate here
-- CREATE OR REPLACE FUNCTION update_last_modified() ...

-- 15. Stored procedure that returns patient's full billing summary along with appointment count and doctor's name
CREATE OR REPLACE PROCEDURE get_patient_billing_summary(IN p_patient_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT 
        p.patient_id,
        p.first_name || ' ' || p.last_name AS patient_name,
        s.first_name || ' ' || s.last_name AS doctor_name,
        COUNT(DISTINCT a.appointment_id) AS appointment_count,
        SUM(b.treatment_fee + b.medication_fee + b.lab_test_fee + b.consultation_fee) AS total_billed
    FROM patient p
    LEFT JOIN appointment a ON p.patient_id = a.patient_id
    LEFT JOIN staff s ON a.doctor_id = s.staff_id
    LEFT JOIN billing b ON p.patient_id = b.patient_id
    WHERE p.patient_id = p_patient_id
    GROUP BY p.patient_id, p.first_name, p.last_name, s.first_name, s.last_name;
END;
$$;
