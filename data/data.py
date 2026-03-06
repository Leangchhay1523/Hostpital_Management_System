import csv
import random
import os
from faker import Faker
from faker.providers import BaseProvider
from zipfile import ZipFile

# ==== Total Records Summarization ====
"""
7 Tables:
- Department: 5
- Staff: 200 (80 doctors, 90 nurses, 30 receptionists)
- Patients: 1,000,000
- Patient-Doctor: 1,000,000 (each patient has a doctor)
- Appointments: 1,000,000 (each appointment has a doctor and a patient
- Medical Records: 1,000,000 (each record has a patient and an appointment)
- Billing: 1,000,000 (each billing has a patient and a receptionist)
"""

# ==== 1) Tiny PhysicalProvider for height & weight ====
class PhysicalProvider(BaseProvider):
    def height(self):
        return f"{random.randint(140, 200)}"
    def weight(self):
        return f"{random.randint(45, 120)}"

# ==== 2) Bootstrap Faker & register our provider ====
fake = Faker()
fake.add_provider(PhysicalProvider)
random.seed(42)

# ==== 3) Create output directory ====
output_dir = 'generated_data'
os.makedirs(output_dir, exist_ok=True)

# Global variables to store IDs for foreign key relationships
doctor_ids = []
receptionist_ids = []
nurse_ids = []
patient_ids = list(range(1, 1_000_001))  # All patient IDs from 1 to 1,000,000
appointment_ids = list(range(1, 1_000_001))  # All appointment IDs from 1 to 1,000,000
departments = {}  # Will store department_id -> department_name mapping

def generate_departments():
    """Generate 5 departments"""
    global departments
    departments.clear()
    
    file_path = os.path.join(output_dir, 'departments.csv')
    dept_names = ['Cardiology','Neurology','Oncology','Pediatrics','Emergency']
    
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['department_id', 'department_name', 'location'])
        for i, name in enumerate(dept_names, start=1):
            departments[i] = name
            writer.writerow([
                i,
                name,
                fake.city()
            ])
    print(f"Generated departments.csv")

def generate_staff():
    """Generate 200 staff members: 80 doctors, 90 nurses, 30 receptionists"""
    global doctor_ids, receptionist_ids, nurse_ids, departments
    doctor_ids.clear()
    receptionist_ids.clear()
    nurse_ids.clear()
    
    # Ensure departments are available
    if not departments:
        print("Warning: No departments found. Please generate departments first.")
        return
    
    file_path = os.path.join(output_dir, 'staff.csv')
    
    # Define exact counts for each role
    staff_roles = (
        ['Doctor'] * 80 +
        ['Nurse'] * 90 +
        ['Receptionist'] * 30
    )
    
    # Specializations mapping to departments
    specializations = {
        'Cardiology': ['Cardiologist', 'Cardiac Surgeon', 'Interventional Cardiologist'],
        'Neurology': ['Neurologist', 'Neurosurgeon', 'Neuropsychologist'],
        'Oncology': ['Oncologist', 'Radiation Oncologist', 'Surgical Oncologist'],
        'Pediatrics': ['Pediatrician', 'Pediatric Surgeon', 'Neonatologist'],
        'Emergency': ['Emergency Medicine Physician', 'Trauma Surgeon', 'Critical Care Specialist']
    }
    
    # Track doctors by department for proper nurse assignment
    doctors_by_dept = {dept_id: [] for dept_id in departments.keys()}
    
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'staff_id','last_name','first_name','gender',
            'role','contact','specialization','department_id','doctor_id'
        ])
        for sid in range(1, 201):  # 200 staff members total
            role = staff_roles[sid - 1]  # Get role from predefined list
            last = fake.last_name()
            first = fake.first_name()
            gender = random.choice(['Male','Female'])
            contact = fake.phone_number()
            dept_id = random.randint(1,5)
            dept_name = departments[dept_id]
            
            if role == 'Doctor':
                spec = random.choice(specializations[dept_name])  # Only doctors have specializations
                doctor_ids.append(sid)
                doctors_by_dept[dept_id].append(sid)  # Track doctors by department
                doc_fk = ''  # Doctors don't have a doctor_id (they are not assigned to other doctors)
            elif role == 'Nurse':
                spec = ''  # Nurses don't have specializations
                nurse_ids.append(sid)
                # Assign nurse to a doctor in the same department
                if doctors_by_dept[dept_id]:  # If there are doctors in this department
                    doc_fk = random.choice(doctors_by_dept[dept_id])  # Nurses get assigned to a doctor
                elif doctor_ids:  # Fallback to any doctor if none in department
                    doc_fk = random.choice(doctor_ids)
                else:  # No doctors exist yet
                    doc_fk = ''
            else:  # Receptionist
                spec = ''  # Receptionists don't have specializations
                receptionist_ids.append(sid)
                doc_fk = ''  # Receptionists are not assigned to doctors
            
            writer.writerow([
                sid, last, first, gender,
                role, contact, spec, dept_id, doc_fk
            ])
    
    print(f"Generated staff.csv (80 doctors, 90 nurses, 30 receptionists = 200 total)")

def get_doctor_department(doctor_id):
    """Helper function to get department of a doctor (simplified for this example)"""
    # In a real scenario, you'd read from the CSV or maintain a mapping
    # For now, we'll use a simple hash to distribute doctors across departments
    return ((doctor_id - 1) % 5) + 1

def generate_patients():
    """Generate 1 million patients without gender column"""
    file_path = os.path.join(output_dir, 'patients.csv')
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'patient_id','last_name','first_name',
            'height','weight','date_of_birth',
            'address','contact','email'
        ])
        for pid in range(1,1_000_001):
            writer.writerow([
                pid,
                fake.last_name(),
                fake.first_name(),
                fake.height(),
                fake.weight(),
                fake.date_of_birth(minimum_age=0,maximum_age=100),
                fake.address().replace('\n',' '),
                fake.phone_number(),
                fake.email()
            ])
            if pid % 100000 == 0:
                print(f"   Generated {pid:,} patients...")
    print(f"Generated patients.csv (1,000,000 records) - Gender column removed")

def generate_patient_doctor():
    """Generate 1 million patient-doctor relationships with valid doctor IDs"""
    if not doctor_ids:
        print("Warning: No doctors found. Please generate staff first.")
        return
    
    file_path = os.path.join(output_dir, 'patient_doctor.csv')
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'patient_doctor_id','patient_id','doctor_id'
        ])
        for pd_id in range(1,1_000_001):
            # Use sequential patient IDs and valid doctor IDs
            patient_id = pd_id  # Sequential patient IDs from 1 to 1,000,000
            doctor_id = random.choice(doctor_ids)  # Random valid doctor from the 80 doctors
            
            writer.writerow([
                pd_id,
                patient_id,
                doctor_id
            ])
            if pd_id % 100000 == 0:
                print(f"   Generated {pd_id:,} patient-doctor relationships...")
    print("Generated patient_doctor.csv (1,000,000 records) - Using valid doctor IDs only")

def generate_appointments():
    """Generate 1 million appointments with valid doctor and patient IDs"""
    if not doctor_ids:
        print("Warning: No doctors found. Please generate staff first.")
        return
    
    file_path = os.path.join(output_dir, 'appointments.csv')
    purposes = ['General Care','Follow Up','Diagnostic & Testing','Consultation']
    statuses = ['Cancelled','Completed','Scheduled']
    
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'appointment_id','purpose','date_time','status','doctor_id','patient_id'
        ])
        for aid in range(1,1_000_001):
            # Use sequential appointment and patient IDs, valid doctor IDs
            appointment_id = aid
            patient_id = aid  # Sequential patient IDs from 1 to 1,000,000
            doctor_id = random.choice(doctor_ids)  # Random valid doctor from the 80 doctors
            
            writer.writerow([
                appointment_id,
                random.choice(purposes),
                fake.date_time_between(start_date='-1y', end_date='+1y'),
                random.choice(statuses),
                doctor_id,
                patient_id
            ])
            if aid % 100000 == 0:
                print(f"   Generated {aid:,} appointments...")
    print("Generated appointments.csv (1,000,000 records) - Using valid foreign keys")

def generate_medical_records():
    """Generate 1 million medical records with valid patient and appointment IDs"""
    file_path = os.path.join(output_dir, 'medical_records.csv')
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'record_id','prescription','diagnosis',
            'lab_result','treatment','patient_id','appointment_id'
        ])
        for rid in range(1,1_000_001):
            # Use sequential IDs to ensure all foreign keys exist
            record_id = rid
            patient_id = rid  # Sequential patient IDs from 1 to 1,000,000
            appointment_id = rid  # Sequential appointment IDs from 1 to 1,000,000
            
            writer.writerow([
                record_id,
                fake.sentence(nb_words=5),
                fake.sentence(nb_words=4),
                random.choice(['Normal','Abnormal','Pending']),
                fake.sentence(nb_words=6),
                patient_id,
                appointment_id
            ])
            if rid % 100000 == 0:
                print(f"   Generated {rid:,} medical records...")
    print("Generated medical_records.csv (1,000,000 records) - Using valid foreign keys")

def generate_billing():
    """Generate 1 million billing records with valid receptionist and patient IDs"""
    if not receptionist_ids:
        print("Warning: No receptionists found. Please generate staff first.")
        return
    
    file_path = os.path.join(output_dir, 'billing.csv')
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'billing_id','treatment_fee','medication_fee',
            'lab_test_fee','consultation_fee','total_amount',
            'payment_status','receptionist_id','patient_id'
        ])
        for bid in range(1,1_000_001):
            # Calculate fees
            tf = round(random.uniform(100.00,1000.00),2)
            mf = round(random.uniform(20.00,500.00),2)
            lf = round(random.uniform(10.00,300.00),2)
            cf = round(random.uniform(50.00,600.00),2)
            total = round(tf+mf+lf+cf,2)
            
            # Use sequential billing and patient IDs, valid receptionist IDs
            billing_id = bid
            patient_id = bid  # Sequential patient IDs from 1 to 1,000,000
            receptionist_id = random.choice(receptionist_ids)  # Random valid receptionist from the 30 receptionists
            
            writer.writerow([
                billing_id, tf, mf, lf, cf, total,
                random.choice(['Paid','Unpaid']),
                receptionist_id,
                patient_id
            ])
            if bid % 100000 == 0:
                print(f"   Generated {bid:,} billing records...")
    print("Generated billing.csv (1,000,000 records) - Using valid foreign keys")

def create_zip():
    """Create a zip file with all CSV files"""
    zip_path = os.path.join(output_dir, 'hospital_dataset.zip')
    csv_files = [f for f in os.listdir(output_dir) if f.endswith('.csv')]
    
    with ZipFile(zip_path, 'w') as zipf:
        for csv_file in csv_files:
            file_path = os.path.join(output_dir, csv_file)
            zipf.write(file_path, arcname=csv_file)
    
    print(f"Created zip file: {zip_path}")

def generate_all():
    """Generate all tables in the correct order"""
    print("Starting hospital data generation...\n")
    
    generate_departments()
    generate_staff()
    generate_patients()
    generate_patient_doctor()
    generate_appointments()
    generate_medical_records()
    generate_billing()
    create_zip()
    
    print(f"\nAll data generated successfully in '{output_dir}' folder!")

# Example usage:
if __name__ == "__main__":
    generate_all()