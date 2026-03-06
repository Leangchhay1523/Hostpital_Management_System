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
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TIMESTAMP_FILE = os.path.join(SCRIPT_DIR, "last_incremental_backup_timestamp.txt")

# Tables to exclude from incremental backup (system tables or tables without last_modified)
EXCLUDED_TABLES = []

# Tables that have a last_modified column (for incremental backup)
# If empty, the script will attempt to detect columns automatically
TABLES_WITH_LAST_MODIFIED = []

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

def table_has_column(cursor, table_name, column_name):
    """Check if a table has a specific column."""
    cursor.execute("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = %s 
          AND column_name = %s
    """, (table_name, column_name))
    return cursor.fetchone() is not None

def get_table_primary_key(cursor, table_name):
    """Get the primary key column(s) for a table."""
    cursor.execute("""
        SELECT a.attname
        FROM pg_index i
        JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
        WHERE i.indrelid = %s::regclass
          AND i.indisprimary
    """, (table_name,))
    result = cursor.fetchall()
    return [row[0] for row in result] if result else None

def incremental_backup(backup_dir=None):
    if backup_dir is None:
        backup_dir = os.path.join(SCRIPT_DIR, "backup_and_recovery", "incremental_backup")
    
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
            # Skip excluded tables
            if table in EXCLUDED_TABLES:
                print(f"Skipping excluded table: {table}")
                continue
            
            try:
                # Check if table has last_modified column
                has_last_modified = table_has_column(cursor, table, "last_modified")
                
                if not has_last_modified:
                    print(f"Skipping table '{table}': No last_modified column")
                    continue
                
                # Get primary key for upsert operations during restore
                primary_key = get_table_primary_key(cursor, table)
                
                # Fetch modified rows
                query = f"SELECT * FROM {table} WHERE last_modified > %s"
                cursor.execute(query, (last_backup_time,))
                rows = cursor.fetchall()
                
                if rows:
                    columns = [desc[0] for desc in cursor.description]
                    backup_data[table] = {
                        "columns": columns,
                        "rows": [list(row) for row in rows],  # Convert tuples to lists for JSON
                        "primary_key": primary_key
                    }
                    print(f"  Backed up {len(rows)} row(s) from {table}")
                    
            except Exception as table_err:
                print(f"Skipping table '{table}' due to error: {table_err}")
                continue

        cursor.close()
        conn.close()

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

# Run incremental backup if executed directly
if __name__ == "__main__":
    backup_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "backup_and_recovery", "incremental_backup")
    incremental_backup(backup_dir)
