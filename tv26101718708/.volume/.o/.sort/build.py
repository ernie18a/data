"""產出 groups.tsv、members.tsv、groups.md，並檢查全部規則行都在 groups.tsv、每個群組都有說明。
前置：python3 merge.py（套用 map_new 與 reassign）。"""
import glob, json, os, re
from collections import defaultdict, OrderedDict
ROOT = os.path.dirname(os.path.abspath(__file__)); SRC = os.path.dirname(ROOT); W = os.path.join(ROOT, 'work')


def tsv(p, header=False):
    rows = [r.rstrip('\n').split('\t') for r in open(p, encoding='utf-8') if r.strip()]
    return rows[1:] if header else rows


segs = tsv(os.path.join(W, 'segs.tsv'), True)
lines = tsv(os.path.join(W, 'lines.tsv'))
why = {}
for p in sorted(glob.glob(os.path.join(W, 'reassign_*.tsv'))):
    for c in tsv(p): why[(c[0], c[1])] = c[4] if len(c) > 4 else ''

# 群組說明（desc_*.md 以「## 代號 名稱」分節）
desc = OrderedDict()
for p in sorted(glob.glob(os.path.join(W, 'desc_*.md'))):
    cur = None
    for l in open(p, encoding='utf-8').read().split('\n'):
        m = re.match(r'^##\s+(\S+)\s*(.*)$', l)
        if m: cur = m.group(1); desc[cur] = [m.group(2).strip(), []]; continue
        if cur: desc[cur][1].append(l)

# groups.tsv
with open(os.path.join(ROOT, 'groups.tsv'), 'w', encoding='utf-8') as o:
    o.write('file\tline\tgroup\tbasis\n')
    for f, n, gs, ss, b in lines:
        extra = '；'.join(f'段{s}複審改派：{why[(f, s)]}' for s in ss.split('|') if (f, s) in why)
        o.write('\t'.join([f, n, gs, b + (f'（{extra}）' if extra else '')]) + '\n')
with open(os.path.join(ROOT, 'members.tsv'), 'w', encoding='utf-8') as o:
    o.write('file\tseg\tgroup\tsummary\tflt\texit\tdiff\n')
    for c in segs: o.write('\t'.join(c) + '\n')

by = defaultdict(list)
for c in segs: by[c[2]].append(c)
nlines = defaultdict(int)
for f, n, gs, ss, b in lines:
    for g in set(gs.split('|')): nlines[g] += 1
fam = lambda g: g.split('.')[0]
order = sorted(by, key=lambda g: (fam(g), g))
out = ['# 群組說明（/bulk 1 分類體系歸納）', '',
       '階層：族（代號第一段）→ 核心邏輯葉（族.名）→ 複審拆出的子群（族.名.子名）。每群列核心邏輯、可選濾網、出場變體、常見小異，以及成員與各自小異。', '',
       '## 總覽', '', '| 代號 | 名稱 | 檔案數 | 段數 | 規則行數 |', '|---|---|---|---|---|']
for g in order:
    out.append(f'| [{g}](#{g.lower().replace(".", "")}) | {desc.get(g, ["（缺說明）"])[0]} | {len({c[0] for c in by[g]})} | {len(by[g])} | {nlines[g]} |')
prev = None
for g in order:
    if fam(g) != prev: out += ['', f'# 族 {fam(g)}']; prev = fam(g)
    name, body = desc.get(g, ['（缺說明）', []])
    out += ['', f'## {g}', '', f'名稱：{name}', ''] + [l for l in body if l.strip()] + ['', '成員（檔名#段｜段摘要｜濾網｜出場｜小異）：', '']
    for c in by[g]:
        out.append(f'- {c[0]}#{c[1]}｜{c[3]}｜{c[4]}｜{c[5]}｜{c[6]}')
open(os.path.join(ROOT, 'groups.md'), 'w', encoding='utf-8').write('\n'.join(out) + '\n')

# 檢查
src = set()
for p in glob.glob(os.path.join(SRC, '*.md')):
    n = len(open(p, encoding='utf-8').read().rstrip('\n').split('\n'))
    src |= {(os.path.basename(p), i) for i in range(1, n + 1)}
got = [(c[0], int(c[1])) for c in tsv(os.path.join(ROOT, 'groups.tsv'), True)]
seg_codes = {(c[0], c[1]): c[2] for c in segs}
line_seg_mismatch = sum(1 for f, n, gs, ss, b in lines for g, s in zip(gs.split('|'), ss.split('|')) if seg_codes.get((f, s)) != g)
r = dict(source_files=len({f for f, _ in src}), source_lines=len(src), groups_tsv_rows=len(got),
         missing=len(src - set(got)), extra=len(set(got) - src), dup=len(got) - len(set(got)),
         segments=len(segs), groups=len(by), groups_without_desc=sorted(g for g in by if g not in desc),
         desc_without_members=sorted(g for g in desc if g not in by), line_seg_mismatch=line_seg_mismatch)
json.dump(r, open(os.path.join(ROOT, 'check.json'), 'w'), ensure_ascii=False, indent=1)
print(json.dumps(r, ensure_ascii=False))
