import {readFileSync,existsSync} from 'node:fs';
const file='qa-results/browser-results.json';
if(!existsSync(file)) {console.error('No browser test results found at '+file);process.exit(2)}
const data=JSON.parse(readFileSync(file,'utf8'));
const summary=data.stats || {};
console.log(JSON.stringify({
  status: (summary.unexpected || 0) + (summary.flaky || 0) === 0 && (summary.expected || 0) > 0 ? 'BROWSER_TESTS_FINISHED' : 'BROWSER_TESTS_FAILED_OR_NOT_RUN',
  stats:summary,
  disclaimer:'Automated browser checks do not constitute a signed, real-user pilot or production approval.'
},null,2));
if((summary.unexpected||0)>0 || (summary.expected||0)===0) process.exit(1);
