#!/usr/people/douglas/programs/ksh.exe

# Set the backup directory
backup_dir="$HOME/backup"

# Create the backup directory if it doesn't exist
if [ ! -d "$backup_dir" ]; then
  mkdir "$backup_dir"
fi

# Check if an argument is provided and is a directory
if [ -n "$1" ] && [ -d "$1" ]; then
  # Backup the provided directory to the backup directory,
  # excluding the backup directory itself
  rsync -a --exclude 'backup' "$1" "$backup_dir"
else
  echo "Usage: $0 <directory>"
fi
