import subprocess
import psycopg2
import json
import os
import glob
from dotenv import load_dotenv

load_dotenv()

# Load environment variables
db_name = os.getenv('DB_NAME')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
db_host = os.getenv('DB_HOST')
db_port = os.getenv('DB_PORT')

# Script directory for timestamp files
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
FULL_BACKUP_TIMESTAMP_FILE = os.path.join(SCRIPT_DIR, "last_full_backup_timestamp.txt")
INCREMENTAL_BACKUP_TIMESTAMP_FILE = os.path.join(SCRIPT_DIR, "last_incremental_backup_timestamp.txt")

def get_last_full_backup_timestamp():
    """Get the last full backup timestamp from file."""
    try:
        with open(FULL_BACKUP_TIMESTAMP_FILE, "r") as f:
            return f.read().strip()
    except FileNotFoundError:
        print(f"Warning: Full backup timestamp file not found: {FULL_BACKUP_TIMESTAMP_FILE}")
        return None

def get_last_incremental_backup_timestamp():
    """Get the last incremental backup timestamp from file."""
    try:
        with open(INCREMENTAL_BACKUP_TIMESTAMP_FILE, "r") as f:
            return f.read().strip()
    except FileNotFoundError:
        print(f"Warning: Incremental backup timestamp file not found: {INCREMENTAL_BACKUP_TIMESTAMP_FILE}")
        return None

def get_latest_full_backup(backup_dir):
    """Get the most recent full backup file from the directory."""
    pattern = os.path.join(backup_dir, "full_backup_*.backup")
    files = glob.glob(pattern)
    if files:
        return max(files, key=os.path.getctime)
    return None

def restore_full_backup(backup_file):
    """Restore a full backup using pg_restore."""
    if not os.path.exists(backup_file):
        print(f"Error: Full backup file not found: {backup_file}")
        return False
    
    os.environ["PGPASSWORD"] = db_password
    cmd = [
        "pg_restore",
        "-h", db_host,
        "-p", db_port,
        "-U", db_user,
        "-d", db_name,
        "-c",  # clean: drop before recreate
        "--if-exists",
        backup_file
    ]
    try:
        subprocess.run(cmd, check=True)
        print(f"Full backup restored: {backup_file}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed to restore full backup: {e}")
        return False
    finally:
        os.environ.pop("PGPASSWORD", None)

def restore_incremental_backup(backup_file, db_config):
    """Restore an incremental backup from JSON file."""
    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

        with open(backup_file, 'r') as f:
            backup_data = json.load(f)

        for table, data in backup_data.items():
            columns = data['columns']
            rows = data['rows']
            primary_key = data.get('primary_key')

            if not rows:
                continue

            col_names = ', '.join(columns)
            placeholders = ', '.join(['%s'] * len(columns))
            
            if primary_key:
                # Use ON CONFLICT for tables with primary key
                pk_col = primary_key[0] if primary_key else None
                if pk_col:
                    update_cols = ', '.join([f"{col} = EXCLUDED.{col}" for col in columns if col != pk_col])
                    query = f"""
                        INSERT INTO {table} ({col_names})
                        VALUES ({placeholders})
                        ON CONFLICT ({pk_col}) DO UPDATE SET {update_cols}
                    """
                else:
                    query = f"""
                        INSERT INTO {table} ({col_names})
                        VALUES ({placeholders})
                        ON CONFLICT DO NOTHING
                    """
            else:
                # No primary key, simple insert
                query = f"""
                    INSERT INTO {table} ({col_names})
                    VALUES ({placeholders})
                """

            for row in rows:
                cursor.execute(query, row)

        conn.commit()
        print(f"Incremental backup restored: {backup_file}")
        cursor.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"Failed to restore incremental backup {backup_file}: {e}")
        return False

def restore_all(full_backup_path, incremental_backup_dir, db_config):
    """Restore full backup first, then all incremental backups in order."""
    print(f"Restoring full backup from: {full_backup_path}")
    if not restore_full_backup(full_backup_path):
        print("Full backup restore failed. Aborting.")
        return False

    # Restore incremental backups in chronological order
    if os.path.exists(incremental_backup_dir):
        files = [f for f in os.listdir(incremental_backup_dir) if f.endswith('.json')]
        files.sort()  # Chronological order by filename (timestamp-based)

        if files:
            print(f"Found {len(files)} incremental backup(s) to restore.")
            for file in files:
                backup_file = os.path.join(incremental_backup_dir, file)
                restore_incremental_backup(backup_file, db_config)
        else:
            print("No incremental backups found.")
    
    print("Restore completed.")
    return True

# Main
if __name__ == "__main__":
    db_config = {
        "dbname": db_name,
        "user": db_user,
        "password": db_password,
        "host": db_host,
        "port": db_port
    }

    # Backup directories
    backup_base_dir = os.path.join(SCRIPT_DIR, "backup_and_recovery")
    full_backup_folder = os.path.join(backup_base_dir, "full_backup")
    incremental_backup_folder = os.path.join(backup_base_dir, "incremental_backup")

    # Try to get timestamp from file, otherwise find latest backup
    last_full_backup_timestamp = get_last_full_backup_timestamp()
    
    if last_full_backup_timestamp:
        full_backup_path = os.path.join(full_backup_folder, f"full_backup_{last_full_backup_timestamp}.backup")
        if not os.path.exists(full_backup_path):
            print(f"Backup file not found: {full_backup_path}")
            print("Searching for latest full backup...")
            full_backup_path = get_latest_full_backup(full_backup_folder)
    else:
        print("No timestamp file found. Searching for latest full backup...")
        full_backup_path = get_latest_full_backup(full_backup_folder)

    if not full_backup_path:
        print("Error: No full backup found. Cannot proceed with restore.")
    else:
        print(f"Using full backup: {full_backup_path}")
        restore_all(full_backup_path, incremental_backup_folder, db_config)
