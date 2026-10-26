"""檢查 work/cls_*.tsv 覆蓋全部規則行、mem 與 cls 的段一致。用法：python3 check.py [cls檔glob]"""
import glob, os, sys, json
from collections import Counter
ROOT = os.path.dirname(os.path.abspath(__file__)); SRC = os.path.dirname(ROOT); W = os.path.join(ROOT, 'work')
src = {}
for f in glob.glob(os.path.join(SRC, '*.md')):
    n = len(open(f, encoding='utf-8').read().rstrip('\n').split('\n'))
    for i in range(1, n + 1): src[(os.path.basename(f), i)] = 1
cnt = Counter(); segs = set(); bad = []
for p in sorted(glob.glob(os.path.join(W, sys.argv[1] if len(sys.argv) > 1 else 'cls_*.tsv'))):
    for raw in open(p, encoding='utf-8'):
        raw = raw.rstrip('\n')
        if not raw: continue
        c = raw.split('\t')
        if len(c) != 5: bad.append((p, raw[:80])); continue
        k = (c[0], int(c[1])); cnt[k] += 1
        for g, s in zip(c[2].split('|'), c[3].split('|')): segs.add((c[0], s, g))
mem = set()
for p in glob.glob(os.path.join(W, 'mem_*.tsv')):
    for raw in open(p, encoding='utf-8'):
        c = raw.rstrip('\n').split('\t')
        if len(c) >= 3: mem.add((c[0], c[1], c[2]))
miss = [k for k in src if k not in cnt]; extra = [k for k in cnt if k not in src]; dup = [k for k, v in cnt.items() if v > 1]
r = dict(source_lines=len(src), covered=len(src) - len(miss), missing=len(miss), extra=len(extra), dup=len(dup), bad_rows=len(bad),
         seg_without_mem=len(segs - mem), mem_without_seg=len(mem - segs))
print(json.dumps(r, ensure_ascii=False))
for name, xs in [('missing', miss), ('extra', extra), ('dup', dup), ('bad', bad), ('seg_without_mem', sorted(segs - mem)), ('mem_without_seg', sorted(mem - segs))]:
    for x in xs[:20]: print(name, x)
