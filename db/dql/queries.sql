-- 1. List all appointments along with the full name of the doctor and the patient, including department name
SELECT 
  a.*,
  s.first_name || ' ' || s.last_name AS doctor_name,
  p.first_name || ' ' || p.last_name AS patient_name,
  d.department_name
FROM appointment a
JOIN staff s ON a.doctor_id = s.staff_id
JOIN patient p ON a.patient_id = p.patient_id
JOIN department d ON s.department_id = d.department_id;

-- 2. Get all patients along with their latest appointment date and the doctor they saw, including doctor's specialization
-- Involves JOINs and filtering using MAX(date_time) per patient
SELECT DISTINCT ON (p.patient_id)
    p.*,
    a.date_time AS latest_appointment,
    s.first_name || ' ' || s.last_name AS doctor_name,
    s.specialization
FROM patient p
JOIN appointment a ON p.patient_id = a.patient_id
JOIN staff s ON a.doctor_id = s.staff_id
ORDER BY p.patient_id, a.date_time DESC;

-- 3. List all nurses along with the doctor they report to (use doctor_id in staff)
SELECT
    nurse.staff_id AS nurse_id,
    nurse.first_name || ' ' || nurse.last_name AS nurse_name,
    doc.staff_id AS doctor_id,
    doc.first_name || ' ' || doc.last_name AS doctor_name
FROM staff nurse
JOIN staff doc ON nurse.doctor_id = doc.staff_id
WHERE nurse.doctor_id IS NOT NULL;

-- 4. Display all patients who have at least one medical record, including diagnosis and related doctor’s name
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
    COUNT(DISTINCT pd.patient_id) AS patient_count
FROM staff s
JOIN patient_doctor pd ON s.staff_id = pd.doctor_id
GROUP BY s.staff_id
HAVING COUNT(DISTINCT pd.patient_id) > 5;

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

-- 9. For each doctor, show the total number of appointments and total billed amount (consultation + treatment + medication + lab)
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
GROUP BY appointment_date
ORDER BY appointment_date;

-- 11. Calculate the average, max, and min consultation fee across all patients
SELECT
    AVG(consultation_fee) AS avg_consultation_fee,
    MAX(consultation_fee) AS max_consultation_fee,
    MIN(consultation_fee) AS min_consultation_fee
FROM billing;

-- 12. Create a function that returns the total bill amount for a given patient_id
CREATE OR REPLACE FUNCTION get_total_bill(patient INT)
RETURNS NUMERIC AS $$
DECLARE
    total NUMERIC;
BEGIN
    SELECT SUM(treatment_fee + medication_fee + lab_test_fee + consultation_fee)
    INTO total
    FROM billing
    WHERE patient_id = patient;
    
    RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;

-- 13. Create a function that returns the number of patients assigned to a specific doctor
CREATE OR REPLACE FUNCTION get_patient_count(doctor INT)
RETURNS INT AS $$
DECLARE
    count_patients INT;
BEGIN
    SELECT COUNT(DISTINCT patient_id)
    INTO count_patients
    FROM patient_doctor
    WHERE doctor_id = doctor;
    
    RETURN COALESCE(count_patients, 0);
END;
$$ LANGUAGE plpgsql;

-- 14. Retrieves each doctor's average consultation fee and number of unique patients they’ve seenWITH doctor_patients AS (
    SELECT
        s.staff_id AS doctor_id,
        COUNT(DISTINCT a.patient_id) AS unique_patients
    FROM staff s
    JOIN appointment a ON s.staff_id = a.doctor_id
    WHERE s.role = 'Doctor'
    GROUP BY s.staff_id
),
doctor_billing AS (
    SELECT
        s.staff_id AS doctor_id,
        AVG(b.consultation_fee) AS avg_consultation_fee
    FROM staff s
    JOIN appointment a ON s.staff_id = a.doctor_id
    JOIN billing b ON a.patient_id = b.patient_id
    WHERE s.role = 'Doctor'
    GROUP BY s.staff_id
)
SELECT 
    s.staff_id,
    s.first_name || ' ' || s.last_name AS doctor_name,
    dp.unique_patients,
    db.avg_consultation_fee
FROM staff s
JOIN doctor_patients dp ON s.staff_id = dp.doctor_id
JOIN doctor_billing db ON s.staff_id = db.doctor_id
WHERE s.role = 'Doctor'
ORDER BY dp.unique_patients DESC;

-- 15. Returns each department's average patient weight and total medical records based on linked appointments.
WITH dept_patient_weights AS (
    SELECT 
        s.department_id,
        AVG(p.weight) AS avg_weight
    FROM appointment a
    JOIN patient p ON a.patient_id = p.patient_id
    JOIN staff s ON a.doctor_id = s.staff_id
    GROUP BY s.department_id
),
dept_medical_records AS (
    SELECT 
        s.department_id,
        COUNT(mr.record_id) AS total_medical_records
    FROM medical_record mr
    JOIN appointment a ON mr.appointment_id = a.appointment_id
    JOIN staff s ON a.doctor_id = s.staff_id
    GROUP BY s.department_id
)
SELECT 
    d.department_name,
    dpw.avg_weight,
    dmr.total_medical_records
FROM department d
LEFT JOIN dept_patient_weights dpw ON d.department_id = dpw.department_id
LEFT JOIN dept_medical_records dmr ON d.department_id = dmr.department_id
ORDER BY dpw.avg_weight DESC NULLS LAST;