#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/home/zaid/flask_app_portfolio"
DB_FILE="$APP_DIR/instance/comments.db"
BACKUP_DIR="$APP_DIR/backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/comments_${TIMESTAMP}.db"

mkdir -p "$BACKUP_DIR"

if [ ! -f "$DB_FILE" ]; then
    echo "Error: database file not found at $DB_FILE"
    exit 1
fi

cp "$DB_FILE" "$BACKUP_FILE"

echo "Backup created:"
echo "$BACKUP_FILE"

echo "Removing backups older than 7 days..."
find "$BACKUP_DIR" -type f -name "comments_*.db" -mtime +7 -delete

echo "Done."
