#!/usr/bin/env python3
"""CampusSphere pilot UAT evidence tracker, standard library only.

Does not modify Laravel, contact external services, or approve real institutions.
Initializes an honest NOT RUN checklist; fail-closed approval validation.
"""
import argparse
import csv
import datetime as dt
import json
import pathlib
import shutil
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
TEMPLATE = ROOT / 'qa' / 'PILOT_CASES_TEMPLATE.csv'
SIGNOFF_TEMPLATE = ROOT / 'qa' / 'PILOT_SIGNOFF_TEMPLATE.json'
DEFAULT_OUT = ROOT / 'qa-results' / 'pilot'
REQUIRED_ROLES = {'Institution Administrator', 'Teacher', 'Admissions Officer', 'Accountant',
                  'HR/Payroll Officer', 'Parent/Student', 'Security Reviewer', 'IT/Operations'}


def initialize(folder):
    folder.mkdir(parents=True, exist_ok=True)
    files = [(TEMPLATE, folder / 'cases.csv'), (SIGNOFF_TEMPLATE, folder / 'signoff.json')]
    for source, target in files:
        if target.exists():
            print(f'Preserved existing {target}')
        else:
            shutil.copy2(source, target)
            print(f'Created {target}')
    print('No tests were marked PASS and no pilot sign-off was issued.')


def check(folder):
    result_file = folder / 'cases.csv'
    signoff_file = folder / 'signoff.json'
    problems = []
    rows = []
    if not result_file.exists() or not signoff_file.exists():
        problems.append('Missing pilot cases.csv or signoff.json. Run --init first.')
    else:
        with result_file.open(newline='', encoding='utf-8-sig') as handle:
            rows = list(csv.DictReader(handle))
        if not rows:
            problems.append('No pilot cases were found.')
        ids = set()
        for row in rows:
            case_id = (row.get('Case_ID') or '').strip()
            if not case_id or case_id in ids:
                problems.append(f'Missing or duplicate Case_ID: {case_id!r}')
            ids.add(case_id)
            status = (row.get('Status') or '').strip().upper()
            if status not in {'NOT RUN', 'PASS', 'FAIL', 'BLOCKED'}:
                problems.append(f'{case_id}: unexpected Status {status!r}')
            if status != 'PASS':
                problems.append(f'{case_id}: {status or "NO STATUS"} (pilot acceptance blocked)')
            else:
                for field in ['Evidence', 'Tester', 'Executed_On']:
                    if not (row.get(field) or '').strip():
                        problems.append(f'{case_id}: PASS missing {field}')
                date = (row.get('Executed_On') or '').strip()
                try:
                    dt.date.fromisoformat(date)
                except ValueError:
                    problems.append(f'{case_id}: Executed_On must be ISO YYYY-MM-DD')
        missing_roles = REQUIRED_ROLES - {(r.get('Role') or '').strip() for r in rows}
        if missing_roles:
            problems.append('Missing required pilot roles: ' + ', '.join(sorted(missing_roles)))
    data = {}
    if signoff_file.exists():
        try:
            data = json.loads(signoff_file.read_text(encoding='utf-8'))
        except (ValueError, OSError):
            problems.append('Signoff JSON is invalid.')
        if data.get('decision') != 'APPROVED':
            problems.append('Authorized pilot decision is not APPROVED.')
        if not data.get('approved_by') or not data.get('approved_at'):
            problems.append('Approver identity and date/time missing.')
        signers = data.get('role_signoffs') or {}
        for role in REQUIRED_ROLES:
            if not isinstance(signers.get(role), dict) or not signers[role].get('tester') or not signers[role].get('approved_at'):
                problems.append(f'No signed role acceptance for {role}.')
        if data.get('open_p0_count') != 0:
            problems.append('Open P0 issues not resolved.')
        if data.get('restore_drill') != 'PASS':
            problems.append('Restore drill has not passed.')
        if data.get('security_review') != 'PASS':
            problems.append('Security review has not passed.')
    report = {
        'gate': 'REAL_HUMAN_PILOT_UAT', 'status': 'BLOCKED' if problems else 'EVIDENCE_RECORDED_REQUIRES_INDEPENDENT_REVIEW',
        'executed_cases': len(rows), 'passed_cases': sum((r.get('Status') or '').strip().upper() == 'PASS' for r in rows),
        'blocker_count': len(problems), 'blockers': problems,
        'note': 'This validates operator-provided evidence, not the truth of test results. Signatures must be from actual authorized testers.'
    }
    folder.mkdir(parents=True, exist_ok=True)
    (folder / 'pilot_gate_report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report, indent=2))
    return 1 if problems else 0


def main():
    parser = argparse.ArgumentParser(description='Initialize or validate CampusSphere pilot UAT evidence')
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument('--init', action='store_true')
    action.add_argument('--check', action='store_true')
    parser.add_argument('--folder', type=pathlib.Path, default=DEFAULT_OUT)
    args = parser.parse_args()
    if args.init:
        initialize(args.folder)
        return 0
    return check(args.folder)


if __name__ == '__main__':
    sys.exit(main())
