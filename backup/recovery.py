import subprocess
import psycopg2
import json
import os
from dotenv import load_dotenv

load_dotenv()

# Load environment variables
db_name = os.getenv('DB_NAME')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
db_host = os.getenv('DB_HOST')
db_port = os.getenv('DB_PORT')

def get_last_full_backup_timestamp():
    with open("last_full_backup_timestamp.txt", "r") as f:
        return f.read().strip()

def get_last_incremental_backup_timestamp():
    with open("last_incremental_backup_timestamp.txt", "r") as f:
        return f.read().strip()

def restore_full_backup(backup_file):
    cmd = [
        "pg_restore",
        "-h", db_host,
        "-p", db_port,
        "-U", db_user,
        "-d", db_name,
        "-c",  # clean: drop before recreate
        backup_file
    ]
    try:
        subprocess.run(cmd, check=True)
        print(f"Full backup restored: {backup_file}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to restore full backup: {e}")

def restore_incremental_backup(backup_file, db_config):
    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()

        with open(backup_file, 'r') as f:
            backup_data = json.load(f)

        for table, data in backup_data.items():
            columns = data['columns']
            rows = data['rows']

            for row in rows:
                col_names = ', '.join(columns)
                placeholders = ', '.join(['%s'] * len(columns))
                update_cols = ', '.join([f"{col} = EXCLUDED.{col}" for col in columns if col != 'id'])

                query = f"""
                    INSERT INTO {table} ({col_names})
                    VALUES ({placeholders})
                    ON CONFLICT (id) DO UPDATE SET {update_cols};
                """
                cursor.execute(query, row)

        conn.commit()
        print(f"Incremental backup restored: {backup_file}")
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Failed to restore incremental backup {backup_file}: {e}")

def restore_all(full_backup_path, incremental_backup_dir, db_config):
    restore_full_backup(full_backup_path)

    files = [f for f in os.listdir(incremental_backup_dir) if f.endswith('.json')]
    files.sort()  # Chronological order by filename

    for file in files:
        backup_file = os.path.join(incremental_backup_dir, file)
        restore_incremental_backup(backup_file, db_config)

# Main
if __name__ == "__main__":
    db_config = {
        "dbname": db_name,
        "user": db_user,
        "password": db_password,
        "host": db_host,
        "port": db_port
    }

    full_backup_folder = "./database/backup_and_recovery/full_backup"
    incremental_backup_folder = "./database/backup_and_recovery/incremental_backup"

    last_full_backup_timestamp = get_last_full_backup_timestamp()  # Already string
    full_backup_path = os.path.join(full_backup_folder, f"full_backup_{last_full_backup_timestamp}.backup")

    restore_all(full_backup_path, incremental_backup_folder, db_config)
