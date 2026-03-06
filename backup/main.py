import datetime as dt
import subprocess
import os
from full_backup import full_backup
from incremental_backup import incremental_backup

# Base directory for backup storage
BACKUP_BASE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "backup_and_recovery")
FULL_BACKUP_DIR = os.path.join(BACKUP_BASE_DIR, "full_backup")
INCREMENTAL_BACKUP_DIR = os.path.join(BACKUP_BASE_DIR, "incremental_backup")

def main():
    today = dt.datetime.now().weekday()  
    # Monday = 0, Sunday = 6

    if today == 6:  # If Sunday, run full backup
        print("Running full backup...")
        full_backup(FULL_BACKUP_DIR) 
    else:  # If not Sunday, run incremental backup (Daily)
        print("Running incremental backup...")
        incremental_backup(INCREMENTAL_BACKUP_DIR)

if __name__ == "__main__":
    main()
