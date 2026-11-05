#!/usr/bin/env python3
"""Offline validation only. Does not execute Laravel/MySQL or browser flows."""
from pathlib import Path
import json, subprocess, re, sys
root=Path(__file__).resolve().parents[1]
fail=[]
def check(ok,message):
 if not ok:fail.append(message)
 print(('PASS' if ok else 'FAIL'),message)

php_files=sorted(p for p in root.rglob('*.php') if 'vendor' not in p.parts)
errors=[]
for p in php_files:
 out=subprocess.run(['php','-l',str(p)],capture_output=True,text=True)
 if out.returncode:errors.append((str(p.relative_to(root)),out.stderr or out.stdout))
check(not errors,f'PHP syntax: {len(php_files)} files ({len(errors)} errors)')
for path,error in errors[:10]:print('  ',path,error)

d=json.loads((root/'database/seeders/data/sms_demo_fixtures.json').read_text())
check(len(d['institutions'])==3,'Three fictional demo institutions')
check(sum(map(len,d.values()))>=590,'Sample data contains >=590 records')
inst={r['id']:r for r in d['institutions']}
acc={(r['institution_id'],r['id']):r for r in d['chart_of_accounts']}
for h in d['fee_heads']:
 check(acc[(h['institution_id'],h['revenue_account_id'])]['account_type']=='income',f"{h['institution_id']} revenue mapped to income account")
for b in d['bank_accounts']:
 check(acc[(b['institution_id'],b['account_id'])]['account_type']=='asset',f"{b['institution_id']} bank mapped to asset account")
for j in d['ledger_journals']:
 lines=[x for x in d['ledger_lines'] if x['ledger_journal_id']==j['id'] and x['institution_id']==j['institution_id']]
 a=sum(int(round(float(x['debit'])*100)) for x in lines)
 b=sum(int(round(float(x['credit'])*100)) for x in lines)
 check(a==b and a>0,f"Balanced sample journal {j['journal_no']}")

module=(root/'app/Support/ModuleCatalog.php').read_text()
workflow=(root/'app/Support/SmsWorkflowCatalog.php').read_text()
m=re.search(r'public const ITEMS=\[(.*?)\n    \];',module,re.S)
mod_count=len(re.findall(r"'\w+'=>\['name'",m.group(1))) if m else 0
flow_count=len(re.findall(r"^        '[a-z-]+'=>\[",workflow,re.M))
check(mod_count==20,f'20 module definition entries ({mod_count})')
check(flow_count>=25,f'Guided workflows ({flow_count})')
editor=(root/'app/Support/EditableRegisters.php').read_text()
edit_count=len(re.findall(r"^        '[a-z_]+' => \[",editor,re.M))
check(edit_count>=45,f'Allowed master registers ({edit_count})')
for unsafe in ['ledger_journals','ledger_lines','student_payments','payment_refunds','published_results','sms_audit_logs']:
 check(not re.search("^        '"+unsafe+"' =>",editor,re.M),f'{unsafe} protected from generic edit')

r=(root/'routes/web.php').read_text()
check("Route::middleware('auth')" in r and "Route::middleware('sms.institution')" in r, 'Authenticated tenant-scoped route group')
for prefix in ['/operations/{flow}','/register/{slug}/{table}','/security/users','/reports/{report}']:
 check(prefix in r,f'Route available: {prefix}')

php_test=subprocess.run(['php','-r',"require '"+str(root/'app/Support/SmsMoney.php')+"'; if (\\App\\Support\\SmsMoney::decimal(\\App\\Support\\SmsMoney::cents('123.40'))!=='123.40')exit(4);"],capture_output=True,text=True)
check(php_test.returncode==0,'Exact PHP money helper smoke test')

out={'php_files':len(php_files),'php_lint_errors':errors,'sample_records':sum(map(len,d.values())),'module_count':mod_count,'workflows':flow_count,'editable_registers':edit_count,'offline_pass':len(fail)==0,'failures':fail}
(root/'qa/OFFLINE_EXPANDED_VALIDATION.json').write_text(json.dumps(out,indent=2))
print('\n',json.dumps({k:v for k,v in out.items() if k not in ['php_lint_errors']},indent=2))
sys.exit(bool(fail))
