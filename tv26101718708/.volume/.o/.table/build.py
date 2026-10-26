"""合併 work/out_*.tsv → rules.tsv；正規化、覆蓋檢查、原句檢查；列出需補抽的行。
用法：python3 build.py <round>   產出 work/miss_<round>.tsv（需補抽者）與 check.json
"""
import glob, json, os, re, sys
from collections import Counter, OrderedDict

ROOT = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.dirname(ROOT)
W = os.path.join(ROOT, 'work')

SIDE = {'long', 'short', 'both', 'none'}
CALC = {'indicator', 'state', 'score', 'level', 'pattern', 'risk', 'sizing', 'other'}
TRIG = {'cross', 'compare', 'breakout', 'retest', 'band_revert', 'divergence', 'candle', 'sequence', 'sweep',
        'score', 'state_flip', 'price_touch', 'time', 'level_grid', 'signal_ref', 'none'}
IND = set('ma macd rsi stoch stochrsi cci adx atr bb kc donchian supertrend psar vwap volume obv mfi cmf delta '
          'ichimoku alligator ao williams_r roc regression stdev swing fib pivot session_range sr_zone orderblock '
          'fvg structure candle heikin_ashi zscore percentile choppiness vix_fix wavetrend hma other none'.split())
FLT = set('trend_ma htf volume volatility adx osc_range session cooldown position candle_color rr_check '
          'date_range toggle none'.split())
EXIT = set('stop_fixed stop_atr stop_struct tp_fixed tp_atr tp_rr trailing breakeven partial reverse_signal '
           'indicator_exit time_exit bars_held none'.split())
INTENT = {'trend', 'mean_revert', 'breakout', 'reversal', 'mixed', 'unknown'}
MTF = {'yes', 'no'}
COLS = ['file', 'line', 'type', 'side', 'calc', 'trig', 'ind', 'flt', 'exit', 'intent', 'mtf', 'text']

log = Counter()
bad_vals = Counter()


def norm_one(v, dom, field, fallback):
    v = (v or '').strip().lower().replace(' ', '_')
    if v in ('', 'null', 'na', 'n/a', '-'):
        return 'null'
    if v in dom:
        return v
    bad_vals[(field, v)] += 1
    return fallback


def norm_multi(v, dom, field, fallback):
    v = (v or '').strip().lower()
    if v in ('', 'null'):
        return 'null'
    out = []
    for x in re.split(r'[|,，;；/]+', v):
        x = x.strip().replace(' ', '_')
        if not x:
            continue
        if x not in dom:
            bad_vals[(field, x)] += 1
            x = fallback
        if x and x not in out:
            out.append(x)
    if len(out) > 1 and 'none' in out:
        out.remove('none')
    return '|'.join(sorted(out)) if out else 'null'


def squash(s):
    return re.sub(r'\s+', '', s)


# 原始規則行
src = OrderedDict()
for f in sorted(glob.glob(os.path.join(SRC, '*.md'))):
    name = os.path.basename(f)
    for n, l in enumerate(open(f, encoding='utf-8').read().split('\n'), 1):
        src[(name, n)] = l

# 已接受列（跨輪累積）
acc_path = os.path.join(W, 'accepted.json')
acc = json.load(open(acc_path)) if os.path.exists(acc_path) else {}

rnd = int(sys.argv[1]) if len(sys.argv) > 1 else 0
outs = sorted(glob.glob(os.path.join(W, 'out_*.tsv')))
for p in outs:
    for raw in open(p, encoding='utf-8').read().split('\n'):
        if not raw.strip():
            continue
        c = raw.split('\t')
        if len(c) < 11:
            log['short_row_padded'] += 1
            c += ['null'] * (11 - len(c))
        if len(c) > 11:
            log['long_row_merged_anchor'] += 1
            c = c[:2] + ['\t'.join(c[2:len(c) - 8])] + c[len(c) - 8:]
        name = os.path.basename(c[0].strip())
        try:
            n = int(c[1].strip())
        except ValueError:
            log['bad_line_number'] += 1
            continue
        key = (name, n)
        if key not in src:
            log['row_not_in_source'] += 1
            continue
        k = f'{name}\t{n}'
        if k in acc:
            continue  # 已接受，不覆蓋
        text = src[key]
        typ, body = text.split('：', 1)
        anchor = c[2]
        if not squash(body).startswith(squash(anchor)[:10]) or (squash(body) and not squash(anchor)):
            log['anchor_mismatch_rejected'] += 1
            continue
        row = {
            'file': name, 'line': n, 'type': typ,
            'side': norm_one(c[3], SIDE, 'side', 'null'),
            'calc': norm_one(c[4], CALC, 'calc', 'other') if typ == '計算' else 'null',
            'trig': norm_one(c[5], TRIG, 'trig', 'null'),
            'ind': norm_multi(c[6], IND, 'ind', 'other'),
            'flt': norm_multi(c[7], FLT, 'flt', ''),
            'exit': norm_multi(c[8], EXIT, 'exit', ''),
            'intent': norm_one(c[9], INTENT, 'intent', 'unknown'),
            'mtf': norm_one(c[10], MTF, 'mtf', 'null'),
            'text': text,
        }
        acc[k] = row

json.dump(acc, open(acc_path, 'w'), ensure_ascii=False)

# 需補抽
miss = [k for k in src if f'{k[0]}\t{k[1]}' not in acc]
with open(os.path.join(W, f'miss_{rnd}.tsv'), 'w', encoding='utf-8') as o:
    for name, n in miss:
        o.write(f'{name}\t{n}\t{src[(name, n)]}\n')

# 寫 rules.tsv（依原始順序）
rows = [acc[f'{k[0]}\t{k[1]}'] for k in src if f'{k[0]}\t{k[1]}' in acc]
with open(os.path.join(ROOT, 'rules.tsv'), 'w', encoding='utf-8') as o:
    o.write('\t'.join(COLS) + '\n')
    for r in rows:
        o.write('\t'.join(str(r.get(c) if r.get(c) not in (None, '') else 'null') for c in COLS) + '\n')

# 原句檢查：重新讀 rules.tsv，確認每列原句存在於原檔且行號對應
ok = 0
lines_cache = {}
for raw in open(os.path.join(ROOT, 'rules.tsv'), encoding='utf-8').read().split('\n')[1:]:
    if not raw:
        continue
    c = raw.split('\t')
    f, n, text = c[0], int(c[1]), c[-1]
    if f not in lines_cache:
        lines_cache[f] = open(os.path.join(SRC, f), encoding='utf-8').read().split('\n')
    if text in lines_cache[f] and lines_cache[f][n - 1] == text:
        ok += 1

chk = {
    'round': rnd, 'source_files': len({k[0] for k in src}), 'source_lines': len(src),
    'table_rows': len(rows), 'table_files': len({r['file'] for r in rows}), 'missing_lines': len(miss),
    'text_check_pass': ok, 'events': dict(log),
    'out_of_domain_values': {f'{a}:{b}': v for (a, b), v in bad_vals.most_common()},
}
json.dump(chk, open(os.path.join(ROOT, f'check_{rnd}.json'), 'w'), ensure_ascii=False, indent=1)
print(json.dumps(chk, ensure_ascii=False, indent=1))
