import datetime as dt
import subprocess
from Full_Backup import full_backup
from Incremental_Backup import incremental_backup

def main():
    today = dt.datetime.now().weekday()  
    full_backup_dir = ".\\backup\\backup_and_recovery\\full_backup"
    incremental_backup_dir = ".\\backup\\backup_and_recovery\\incremental_backup"
    # Monday = 0, Sunday = 6

    if today == 6: # If sunday, run full backup
        print("Running full backup...")
        full_backup(full_backup_dir) 
    else: # If not sunday, run incremental backup (Daily)
        print("Running incremental backup...")
        incremental_backup(incremental_backup_dir)

if __name__ == "__main__":
    main()