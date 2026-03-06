-- NOTE : We actually used the command line to insert the data into each table, however the below code is just a sample of data insertion of each tables without command line.

-- Syntax : \copy table_name(column1, column2, ...) FROM '/path/file_name.csv' DELIMITER ',' CSV HEADER

-- Sample Departments
INSERT INTO department (department_id, department_name)
VALUES
  (1, 'Cardiology'),
  (2, 'Pediatrics'),
  (3, 'Neurology'),
  (4, 'Orthopedics'),
  (5, 'Dermatology');

-- Sample Doctors
INSERT INTO doctor (doctor_id, doctor_name, gender, department_id, phone_number)
VALUES
  (1, 'Dr. Sitha Kong', 'Male', 1, '012345678'),
  (2, 'Dr. Dalis Phan', 'Female', 2, '098765432'),
  (3, 'Dr. Ratana Chea', 'Male', 3, '097777777'),
  (4, 'Dr. Monika Sok', 'Female', 4, '096666666'),
  (5, 'Dr. Vuthy Heng', 'Male', 5, '095555555');

-- Sample Patients
INSERT INTO patient (patient_id, first_name, last_name, height, weight, date_of_birth)
VALUES
  (1, 'Sokha', 'Chan', 165.0, 58.5, '1992-03-15'),
  (2, 'Dara', 'Yim', 172.3, 75.2, '1988-07-29'),
  (3, 'Lina', 'Touch', 160.5, 53.1, '1996-11-04'),
  (4, 'Rith', 'Nhem', 178.4, 80.7, '1985-01-19'),
  (5, 'Malis', 'Keo', 168.2, 60.0, '1993-09-12');

-- Sample Appointments
INSERT INTO appointment (appointment_id, appointment_date, doctor_id, patient_id)
VALUES
  (1, '2025-06-20', 1, 1),
  (2, '2025-06-21', 2, 2),
  (3, '2025-06-22', 3, 3),
  (4, '2025-06-23', 4, 4),
  (5, '2025-06-24', 5, 5);

-- Sample Staff (receptionists)
INSERT INTO staff (staff_id, full_name, phone, email, gender, department_id)
VALUES
  (1, 'Srey Neang', '093123456', 'neang@hospital.com', 'Female', 1),
  (2, 'Phirun Mao', '092234567', 'phirun@hospital.com', 'Male', 2),
  (3, 'Chenda Khiev', '097987654', 'chenda@hospital.com', 'Female', 3);

-- Sample Billing
INSERT INTO billing (billing_id, appointment_id, receptionist_id, billing_date, amount)
VALUES
  (1, 1, 1, '2025-06-20', 45.00),
  (2, 2, 2, '2025-06-21', 60.00),
  (3, 3, 3, '2025-06-22', 50.00),
  (4, 4, 1, '2025-06-23', 70.00),
  (5, 5, 2, '2025-06-24', 65.00);
