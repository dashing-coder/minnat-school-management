import csv
import datetime
import json
import pathlib
import tempfile
import unittest
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
import qa_pilot_gate


class PilotGateTests(unittest.TestCase):
    def test_empty_pilot_evidence_is_blocked(self):
        with tempfile.TemporaryDirectory() as tmp:
            folder = pathlib.Path(tmp)
            qa_pilot_gate.initialize(folder)
            self.assertEqual(qa_pilot_gate.check(folder), 1)
            report = json.loads((folder/'pilot_gate_report.json').read_text())
            self.assertEqual(report['status'], 'BLOCKED')
            self.assertEqual(report['passed_cases'], 0)

    def test_unsigned_and_unevidenced_passes_do_not_certify_pilot(self):
        with tempfile.TemporaryDirectory() as tmp:
            folder = pathlib.Path(tmp)
            qa_pilot_gate.initialize(folder)
            with (folder/'cases.csv').open(newline='', encoding='utf-8') as handle:
                rows = list(csv.DictReader(handle))
            for row in rows:
                row['Status'] = 'PASS'
                row['Tester'] = 'Synthetic unit test'
                row['Executed_On'] = str(datetime.date.today())
            with (folder/'cases.csv').open('w', newline='', encoding='utf-8') as handle:
                writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
                writer.writeheader(); writer.writerows(rows)
            self.assertEqual(qa_pilot_gate.check(folder), 1)
            report = json.loads((folder/'pilot_gate_report.json').read_text())
            self.assertTrue(any('missing Evidence' in problem for problem in report['blockers']))

    def test_reviewer_cannot_approve_with_open_p0_issues(self):
        with tempfile.TemporaryDirectory() as tmp:
            folder = pathlib.Path(tmp)
            qa_pilot_gate.initialize(folder)
            with (folder/'cases.csv').open(newline='', encoding='utf-8') as handle:
                rows = list(csv.DictReader(handle))
            for row in rows:
                row.update(Status='PASS', Tester='Synthetic test only', Executed_On='2026-11-09', Evidence='QA-FAKE-REF')
            with (folder/'cases.csv').open('w', newline='', encoding='utf-8') as handle:
                writer = csv.DictWriter(handle, fieldnames=list(rows[0])); writer.writeheader(); writer.writerows(rows)
            document = json.loads((folder/'signoff.json').read_text())
            document.update(decision='APPROVED', approved_by='Synthetic reviewer', approved_at='2026-11-09',
                            open_p0_count=1, restore_drill='PASS', security_review='PASS')
            for value in document['role_signoffs'].values():
                value.update(tester='Synthetic signer', approved_at='2026-11-09')
            (folder/'signoff.json').write_text(json.dumps(document))
            self.assertEqual(qa_pilot_gate.check(folder), 1)
            report = json.loads((folder/'pilot_gate_report.json').read_text())
            self.assertTrue(any('Open P0 issues' in problem for problem in report['blockers']))


if __name__ == '__main__':
    unittest.main()
