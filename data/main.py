import csv
import random
import os
from faker import Faker
from faker.providers import BaseProvider
from zipfile import ZipFile

# ==== Configuration: Set record counts for each table ====
CONFIG = {
    'departments': 5,
    'staff': 200,              # Total staff count
    'staff_doctors': 80,       # Number of doctors
    'staff_nurses': 90,        # Number of nurses
    'staff_receptionists': 30, # Number of receptionists
    'patients': 1_000_000,
    'patient_doctor': 1_000_000,
    'appointments': 1_000_000,
    'medical_records': 1_000_000,
    'billing': 1_000_000,
}

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
departments = {}  # Will store department_id -> department_name mapping

def generate_departments():
    """Generate departments based on CONFIG['departments']"""
    global departments
    departments.clear()
    
    file_path = os.path.join(output_dir, 'departments.csv')
    dept_names = ['Cardiology','Neurology','Oncology','Pediatrics','Emergency']
    
    # Limit to configured count
    dept_names = dept_names[:CONFIG['departments']]
    
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
    print(f"Generated departments.csv ({len(dept_names)} records)")

def generate_staff():
    """Generate staff members based on CONFIG"""
    global doctor_ids, receptionist_ids, nurse_ids, departments
    doctor_ids.clear()
    receptionist_ids.clear()
    nurse_ids.clear()
    
    # Ensure departments are available
    if not departments:
        print("Warning: No departments found. Please generate departments first.")
        return
    
    file_path = os.path.join(output_dir, 'staff.csv')
    
    # Define exact counts for each role from CONFIG
    staff_roles = (
        ['Doctor'] * CONFIG['staff_doctors'] +
        ['Nurse'] * CONFIG['staff_nurses'] +
        ['Receptionist'] * CONFIG['staff_receptionists']
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
        for sid in range(1, CONFIG['staff'] + 1):
            role = staff_roles[sid - 1]  # Get role from predefined list
            last = fake.last_name()
            first = fake.first_name()
            gender = random.choice(['Male','Female'])
            contact = fake.phone_number()
            dept_id = random.randint(1, len(departments))
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
    
    print(f"Generated staff.csv ({CONFIG['staff_doctors']} doctors, {CONFIG['staff_nurses']} nurses, {CONFIG['staff_receptionists']} receptionists = {CONFIG['staff']} total)")

def generate_patients():
    """Generate patients based on CONFIG['patients']"""
    file_path = os.path.join(output_dir, 'patients.csv')
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'patient_id','last_name','first_name',
            'height','weight','date_of_birth',
            'address','contact','email'
        ])
        for pid in range(1, CONFIG['patients'] + 1):
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
    print(f"Generated patients.csv ({CONFIG['patients']:,} records)")

def generate_patient_doctor():
    """Generate patient-doctor relationships based on CONFIG['patient_doctor']"""
    if not doctor_ids:
        print("Warning: No doctors found. Please generate staff first.")
        return
    
    file_path = os.path.join(output_dir, 'patient_doctor.csv')
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'patient_doctor_id','patient_id','doctor_id'
        ])
        for pd_id in range(1, CONFIG['patient_doctor'] + 1):
            # Use sequential patient IDs and valid doctor IDs
            patient_id = pd_id  # Sequential patient IDs
            doctor_id = random.choice(doctor_ids)  # Random valid doctor
            
            writer.writerow([
                pd_id,
                patient_id,
                doctor_id
            ])
            if pd_id % 100000 == 0:
                print(f"   Generated {pd_id:,} patient-doctor relationships...")
    print(f"Generated patient_doctor.csv ({CONFIG['patient_doctor']:,} records)")

def generate_appointments():
    """Generate appointments based on CONFIG['appointments']"""
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
        for aid in range(1, CONFIG['appointments'] + 1):
            # Use sequential appointment and patient IDs, valid doctor IDs
            appointment_id = aid
            patient_id = aid  # Sequential patient IDs
            doctor_id = random.choice(doctor_ids)  # Random valid doctor
            
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
    print(f"Generated appointments.csv ({CONFIG['appointments']:,} records)")

def generate_medical_records():
    """Generate medical records based on CONFIG['medical_records']"""
    file_path = os.path.join(output_dir, 'medical_records.csv')
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            'record_id','prescription','diagnosis',
            'lab_result','treatment','patient_id','appointment_id'
        ])
        for rid in range(1, CONFIG['medical_records'] + 1):
            # Use sequential IDs to ensure all foreign keys exist
            record_id = rid
            patient_id = rid  # Sequential patient IDs
            appointment_id = rid  # Sequential appointment IDs
            
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
    print(f"Generated medical_records.csv ({CONFIG['medical_records']:,} records)")

def generate_billing():
    """Generate billing records based on CONFIG['billing']"""
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
        for bid in range(1, CONFIG['billing'] + 1):
            # Calculate fees
            tf = round(random.uniform(100.00,1000.00),2)
            mf = round(random.uniform(20.00,500.00),2)
            lf = round(random.uniform(10.00,300.00),2)
            cf = round(random.uniform(50.00,600.00),2)
            total = round(tf+mf+lf+cf,2)
            
            # Use sequential billing and patient IDs, valid receptionist IDs
            billing_id = bid
            patient_id = bid  # Sequential patient IDs
            receptionist_id = random.choice(receptionist_ids)  # Random valid receptionist
            
            writer.writerow([
                billing_id, tf, mf, lf, cf, total,
                random.choice(['Paid','Unpaid']),
                receptionist_id,
                patient_id
            ])
            if bid % 100000 == 0:
                print(f"   Generated {bid:,} billing records...")
    print(f"Generated billing.csv ({CONFIG['billing']:,} records)")

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
    print(f"Configuration: {CONFIG}\n")
    
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
