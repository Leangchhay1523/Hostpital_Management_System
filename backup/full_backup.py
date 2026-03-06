import subprocess
import datetime as dt
import os
from dotenv import load_dotenv

load_dotenv()

# Load environment variables
db_name = os.getenv('DB_NAME')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
db_host = os.getenv('DB_HOST')
db_port = os.getenv('DB_PORT')

def save_last_backup_time(timestamp_str):
    with open("last_full_backup_timestamp.txt", "w") as f:
        f.write(timestamp_str)

def full_backup(backup_dir="./database/backup_and_recovery/full_backup"):
    """Perform a full backup for PostgreSQL database using pg_dump."""
    try:
        os.makedirs(backup_dir, exist_ok=True)

        timestamp = dt.datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = os.path.join(backup_dir, f"full_backup_{timestamp}.backup")

        os.environ["PGPASSWORD"] = db_password
        cmd = [
            "pg_dump",
            "-h", db_host,
            "-p", db_port,
            "-U", db_user,
            "-Fc",
            db_name,
            "-f", backup_file
        ]
        subprocess.run(cmd, check=True)
        print(f"Full backup created: {backup_file}")

        # Save timestamp in the correct format
        save_last_backup_time(timestamp)
        return backup_file

    except subprocess.CalledProcessError as e:
        print(f"Full backup failed: {e}")
        return None

    finally:
        os.environ.pop("PGPASSWORD", None)

# Run full backup
backup_dir = "./database/backup_and_recovery/full_backup"
full_backup(backup_dir)
