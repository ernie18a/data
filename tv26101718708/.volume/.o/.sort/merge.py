"""合併 work/cls_*、mem_*，套用 map_new.tsv 與 reassign_*.tsv，寫出 work/segs.tsv、work/lines.tsv。
用法：python3 merge.py            合併
      python3 merge.py review N   另依代號切出複審批次 work/review_in_*.tsv（每批段數上限 N）
"""
import glob, os, sys
from collections import defaultdict, OrderedDict
ROOT = os.path.dirname(os.path.abspath(__file__)); W = os.path.join(ROOT, 'work')


def tsv(pat):
    for p in sorted(glob.glob(os.path.join(W, pat))):
        for raw in open(p, encoding='utf-8'):
            raw = raw.rstrip('\n')
            if raw: yield raw.split('\t')


cmap = {c[0]: c[1] for c in tsv('map_new.tsv')}
seg_map = {}  # (file, seg) -> code，複審改派
for c in tsv('reassign_*.tsv'):
    seg_map[(c[0], c[1])] = c[3]


def code(f, s, g):
    g = cmap.get(g, g)
    return seg_map.get((f, s), g)


segs = OrderedDict()
for c in tsv('mem_*.tsv'):
    f, s, g = c[:3]
    segs[(f, s)] = [f, s, code(f, s, g)] + c[3:7]
lines = []
for c in tsv('cls_*.tsv'):
    f, n, gs, ss, why = c
    gs = '|'.join(code(f, s, g) for g, s in zip(gs.split('|'), ss.split('|')))
    lines.append([f, n, gs, ss, why])
lines.sort(key=lambda x: (x[0], int(x[1])))
with open(os.path.join(W, 'segs.tsv'), 'w', encoding='utf-8') as o:
    o.write('file\tseg\tgroup\tsummary\tflt\texit\tdiff\n')
    for v in segs.values(): o.write('\t'.join(v) + '\n')
with open(os.path.join(W, 'lines.tsv'), 'w', encoding='utf-8') as o:
    for v in lines: o.write('\t'.join(v) + '\n')
by = defaultdict(list)
for v in segs.values(): by[v[2]].append(v)
print(len(segs), 'segs', len(lines), 'lines', len(by), 'groups')
if len(sys.argv) > 2 and sys.argv[1] == 'review':
    cap = int(sys.argv[2]); bins = []
    for g in sorted(by, key=lambda g: -len(by[g])):
        for b in bins:
            if b[0] + len(by[g]) <= cap: b[0] += len(by[g]); b[1].append(g); break
        else: bins.append([len(by[g]), [g]])
    for i, (n, gs) in enumerate(bins):
        with open(os.path.join(W, f'review_in_{i:02d}.tsv'), 'w', encoding='utf-8') as o:
            for g in gs:
                for v in by[g]: o.write('\t'.join(v) + '\n')
        print(i, n, ' '.join(gs))
