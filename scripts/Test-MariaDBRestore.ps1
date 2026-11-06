<#
  Operator-controlled, STAGING-ONLY backup + restore verification.
  Prerequisite: mysql and mysqldump on PATH; an existing empty DB named scm_restore_test_*;
  a mysql CLI [client] option file with credentials stored OUTSIDE this repository.
  Test with a dedicated backup operator. NEVER run on live production credentials.
#>
param(
 [Parameter(Mandatory=$true)][string]$SourceDatabase,
 [Parameter(Mandatory=$true)][string]$RestoreDatabase,
 [Parameter(Mandatory=$true)][string]$DefaultsFile,
 [string]$BackupFile = ".\scm-backup-drill.sql"
)
$ErrorActionPreference='Stop'
if($SourceDatabase -notmatch '^[A-Za-z0-9_-]{1,64}$' -or
   $RestoreDatabase -notmatch '^scm_restore_test_[A-Za-z0-9_]{1,38}$' -or
   $RestoreDatabase -eq $SourceDatabase){throw 'Database names invalid or restore DB does not use scm_restore_test_ prefix.'}
if(!(Test-Path -LiteralPath $DefaultsFile)){throw 'Credential file not found.'}
$cred=(Resolve-Path -LiteralPath $DefaultsFile).Path
if($cred -match '\s'){throw 'Use a credentials file path without spaces for portability.'}
function RunMySQL([string]$database,[string]$sql){
 $lines=& mysql "--defaults-extra-file=$cred" "--database=$database" --batch --skip-column-names "--execute=$sql"
 if($LASTEXITCODE -ne 0){throw "mysql failed for $database"}
 return ($lines | Out-String).Trim()
}
$existing = RunMySQL $RestoreDatabase 'SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE();'
if([int]$existing -ne 0){throw 'Restore database must already exist and be EMPTY; refusing to overwrite tables.'}
$backuppath=[System.IO.Path]::GetFullPath($BackupFile)
if(Test-Path -LiteralPath $backuppath){throw 'Backup target exists; refusing overwrite. Provide a new filename.'}
& mysqldump "--defaults-extra-file=$cred" --single-transaction --quick --hex-blob --default-character-set=utf8mb4 --skip-add-drop-table "--result-file=$backuppath" $SourceDatabase
if($LASTEXITCODE -ne 0){throw 'mysqldump failed.'}
if((Get-Item -LiteralPath $backuppath).Length -lt 2048){throw 'Backup unexpectedly small.'}
$sha=(Get-FileHash -LiteralPath $backuppath -Algorithm SHA256).Hash
$sourceCounts=@{}
foreach($tbl in @('institutions','users','institution_memberships','sms_permissions','students','student_invoices','ledger_journals')){
 $sourceCounts[$tbl] = RunMySQL $SourceDatabase "SELECT COUNT(*) FROM ``$tbl``;"
}
$srcPath=$backuppath.Replace('\','/')
if($srcPath -match '\s'){throw 'Move SQL backup to a path without spaces before restore.'}
$null=RunMySQL $RestoreDatabase "source $srcPath"
$targetCounts=@{}
foreach($tbl in $sourceCounts.Keys){
 $targetCounts[$tbl] = RunMySQL $RestoreDatabase "SELECT COUNT(*) FROM ``$tbl``;"
 if($sourceCounts[$tbl] -ne $targetCounts[$tbl]){throw "RESTORE MISMATCH: $tbl source=$($sourceCounts[$tbl]) target=$($targetCounts[$tbl])"}
}
Write-Host 'RESTORE DRILL PASS — sampled table counts match.' -ForegroundColor Green
Write-Host "Backup path: $backuppath"
Write-Host "SHA256: $sha"
Write-Host "Restored only into: $RestoreDatabase"
Write-Warning 'A successful count check is not a complete application-level disaster recovery test. Run php artisan sms:qa against the restored DB too.'
