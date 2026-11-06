#!/usr/bin/env bash
# STAGING ONLY. Database target must exist and contain zero tables. Requires
# a separate external defaults file in a protected location (chmod 600).
set -euo pipefail
if [[ $# -ne 4 ]]; then echo 'Usage: bash test_mariadb_restore.sh SOURCE_DB scm_restore_test_NAME /secure/client.cnf /secure/backup-fresh.sql' >&2; exit 2; fi
SOURCE="$1" TARGET="$2" CRED="$3" BACKUP="$4"
[[ "$SOURCE" =~ ^[A-Za-z0-9_-]{1,64}$ ]] || exit 2
[[ "$TARGET" =~ ^scm_restore_test_[A-Za-z0-9_]{1,38}$ ]] || exit 2
[[ "$SOURCE" != "$TARGET" ]] || exit 2
[[ -f "$CRED" && ! -e "$BACKUP" ]] || { echo 'Missing credentials or backup filename already exists.';exit 2; }
set -o noclobber
EMPTY="$(mysql "--defaults-extra-file=$CRED" "--database=$TARGET" -N -s -e 'SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE()')"
[[ "$EMPTY" == 0 ]] || { echo 'Target restore database must be EMPTY.';exit 2; }
umask 077
mysqldump "--defaults-extra-file=$CRED" --single-transaction --quick --hex-blob --skip-add-drop-table "--result-file=$BACKUP" "$SOURCE"
[[ $(wc -c < "$BACKUP") -gt 2048 ]] || { echo 'Backup unexpectedly small.';exit 1; }
mysql "--defaults-extra-file=$CRED" "--database=$TARGET" < "$BACKUP"
for tab in institutions users institution_memberships sms_permissions students student_invoices ledger_journals; do
  src=$(mysql "--defaults-extra-file=$CRED" "--database=$SOURCE" -N -s -e "SELECT COUNT(*) FROM \`$tab\`")
  dst=$(mysql "--defaults-extra-file=$CRED" "--database=$TARGET" -N -s -e "SELECT COUNT(*) FROM \`$tab\`")
  [[ "$src" == "$dst" ]] || { echo "FAIL: $tab count mismatch";exit 1; }
done
printf 'PASS: separate restore database sampled row counts match. SHA256: '
sha256sum "$BACKUP"
echo 'IMPORTANT: This does not replace application-level smoke tests or actual recovery drill sign-off.'
