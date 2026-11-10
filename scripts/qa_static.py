from pathlib import Path
from bs4 import BeautifulSoup
from urllib.parse import urlparse
import xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
site=root/'site';views=root/'laravel/resources/views/school'
required=['index.html','about.html','academics.html','admissions.html','campus-life.html','contact.html']
errors=[]
for p in required:
 f=site/p
 if not f.is_file(): errors.append(f'Missing page {p}');continue
 soup=BeautifulSoup(f.read_text(encoding='utf-8'),'html.parser')
 for tag in ['title','nav','header','main','footer']:
  if not soup.find(tag):errors.append(f'{p}: missing {tag}')
 if not soup.find('html',attrs={'lang':'en'}):errors.append(f'{p}: missing HTML language')
 for a in soup.find_all(['a','img','script','link']):
  attr='href' if a.name in ('a','link') else 'src'
  src=a.get(attr)
  if not src or src.startswith(('#','mailto:','tel:','data:')):continue
  parsed=urlparse(src)
  if parsed.scheme or parsed.netloc:continue
  path=src.split('#')[0].split('?')[0]
  if path and not (site/path).exists():errors.append(f'{p}: missing local asset or page {path}')
 for img in soup.find_all('img'):
  if img.get('alt') is None:errors.append(f'{p}: missing image alt text')
for p in (site/'assets').glob('*.svg'):
 try:ET.parse(p)
 except Exception as e:errors.append(f'Invalid SVG {p.name}: {e}')
for name in ['home','about','academics','admissions','campus_life','contact']:
 if not (views/f'{name}.blade.php').exists():errors.append(f'Blade missing {name}')
if errors:
 print('FAILED', len(errors),'errors');print('\n'.join(errors));raise SystemExit(1)
print('PASS: 6 public HTML pages; navigation, local paths, assets and alt text; SVG; 6 Blade views')
