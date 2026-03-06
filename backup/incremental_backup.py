import psycopg2
import datetime as dt
import os
import json
from dotenv import load_dotenv

load_dotenv()

# Load environment variables
db_name = os.getenv("DB_NAME")
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST", "localhost")
db_port = os.getenv("DB_PORT", "5432")

# Timestamp file path
TIMESTAMP_FILE = "last_incremental_backup_timestamp.txt"

def get_last_backup_time():
    try:
        with open(TIMESTAMP_FILE, "r") as f:
            return f.read().strip()
    except FileNotFoundError:
        # Default to 1 day ago if no previous backup
        return (dt.datetime.now() - dt.timedelta(days=1)).strftime("%Y-%m-%d %H:%M:%S")

def save_last_backup_time(timestamp_str):
    with open(TIMESTAMP_FILE, "w") as f:
        f.write(timestamp_str)

def incremental_backup(backup_dir="./database/backup_and_recovery/incremental_backup"):
    try:
        os.makedirs(backup_dir, exist_ok=True)

        last_backup_time = get_last_backup_time()
        print(f"Last incremental backup time: {last_backup_time}")

        timestamp = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = os.path.join(backup_dir, f"incremental_backup_{timestamp}.json")

        conn = psycopg2.connect(
            dbname=db_name, user=db_user, password=db_password, host=db_host, port=db_port
        )
        cursor = conn.cursor()

        cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';")
        tables = [row[0] for row in cursor.fetchall()]

        backup_data = {}
        for table in tables:
            try:
                query = f"SELECT * FROM {table} WHERE last_modified > %s"
                cursor.execute(query, (last_backup_time,))
                rows = cursor.fetchall()
                if rows:
                    columns = [desc[0] for desc in cursor.description]
                    backup_data[table] = {"columns": columns, "rows": rows}
            except Exception as table_err:
                print(f"Skipping table '{table}' due to error: {table_err}")

        if backup_data:
            with open(backup_file, "w") as f:
                json.dump(backup_data, f, default=str)
            print(f"Incremental backup created: {backup_file}")
            save_last_backup_time(dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
            return backup_file
        else:
            print("No changes detected. No backup file created.")
            return None

    except Exception as e:
        print(f"Incremental backup failed: {e}")
        return None
