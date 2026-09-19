import numpy as np

def _a(x):
    return np.asarray(x, dtype=float).reshape(-1)

def _shape(o, h, l, c, method, only_color):
    r = h - l
    if not np.isfinite(r) or r <= 0:
        return False, False
    body = abs(c - o)
    up = h - max(o, c)
    lo = min(o, c) - l
    m = method.strip().lower()
    if m.startswith('broad'):
        hammer = (o - l) / r > .5 and (c - l) / r > .5
        shooter = (o - l) / r < .5 and (c - l) / r < .5
    elif m.startswith('classic'):
        bp = body / r
        hammer = bp <= .3 and lo / (body if body > .001 else np.inf) >= 3 and up / r <= .35 and (h - (o + c) / 2) / r <= .33 and (h - c) / r <= .25
        shooter = bp <= .3 and up / (body if body > .001 else np.inf) >= 3 and lo / r <= .35 and ((o + c) / 2 - l) / r <= .33 and (c - l) / r <= .25
    else:
        hammer = (h - c) / r <= .25 and (h - o) / r <= .25
        shooter = (c - l) / r <= .25 and (o - l) / r <= .25
    if only_color:
        hammer = hammer and c > o
        shooter = shooter and c <= o
    return bool(hammer), bool(shooter)

def _exh(hs, ls, i):
    if i <= 50:
        return np.nan, np.nan
    mh, ml = hs[i - 1], ls[i - 1]
    hi = lo = np.nan
    mh = mh if np.isfinite(mh) else -np.inf
    ml = ml if np.isfinite(ml) else np.inf
    for d in range(2, 49):
        p = i - d
        if np.isfinite(hs[p - 1]) and np.isfinite(hs[p]) and np.isfinite(hs[p + 1]) and np.isnan(hi) and hs[p] > hs[p - 1] and hs[p] > hs[p + 1] and mh < hs[p]:
            hi = hs[p]
        if np.isfinite(ls[p - 1]) and np.isfinite(ls[p]) and np.isfinite(ls[p + 1]) and np.isnan(lo) and ls[p] < ls[p - 1] and ls[p] < ls[p + 1] and ml > ls[p]:
            lo = ls[p]
        if np.isfinite(hs[p]):
            mh = max(mh, hs[p])
        if np.isfinite(ls[p]):
            ml = min(ml, ls[p])
        if np.isfinite(hi) and np.isfinite(lo):
            break
    return hi, lo

def _targets(values, side):
    return sorted({float(x) for x in values if np.isfinite(x)}, reverse=side < 0)

def generate_signals(features, signal_params):
    mkt = features.market
    n = int(mkt.size)
    le = np.zeros(n, dtype=np.bool_)
    lx = np.zeros(n, dtype=np.bool_)
    se = np.zeros(n, dtype=np.bool_)
    sx = np.zeros(n, dtype=np.bool_)
    o, h, l, c = map(_a, (mkt.opens, mkt.highs, mkt.lows, mkt.closes))
    if min(map(len, (o, h, l, c))) < n:
        return le, lx, se, sx
    p = signal_params or {}
    method = str(p.get('pattern_method', 'Broad'))
    color = bool(p.get('only_color', False))
    cont = bool(p.get('continuation', False))
    ref = str(p.get('stop_reference', 'CC')).upper()
    ref = ref if ref in {'CC', 'C1'} else 'CC'
    be = bool(p.get('break_even', False))
    for t in range(2, n):
        v = (o[t - 2], h[t - 2], l[t - 2], c[t - 2], o[t - 1], h[t - 1], l[t - 1], c[t - 1], h[t], l[t])
        if not np.all(np.isfinite(v)):
            continue
        o2, h2, l2, c2, o1, h1, l1, c1, hc, lc = v
        inside = h1 <= h2 and l1 >= l2
        u = h1 > h2 and l1 >= l2
        d = l1 < l2 and h1 <= h2
        ham, sho = _shape(o1, h1, l1, c1, method, color)
        lr = d or (inside and c2 <= o2) or (not inside and not u and not d)
        sr = u or (inside and c2 >= o2) or (not inside and not u and not d)
        lm = u or (inside and c2 > o2)
        sm = d or (inside and c2 < o2)
        le[t] = ham and (lr or cont and lm) and hc > h1 and lc >= l1
        se[t] = sho and (sr or cont and sm) and lc < l1 and hc <= h1
    pos = 0
    stop = entry = np.nan
    targets = []
    ti = 0
    for t in range(n):
        exited = False
        if pos == 1:
            hit_stop = np.isfinite(stop) and l[t] < stop
            hit_target = ti < len(targets) and np.isfinite(h[t]) and h[t] >= targets[ti]
            if hit_stop:
                lx[t] = True
                pos = 0
                exited = True
            elif hit_target:
                if be and ti + 1 < len(targets):
                    ti += 1
                    stop = entry
                else:
                    lx[t] = True
                    pos = 0
                    exited = True
        elif pos == -1:
            hit_stop = np.isfinite(stop) and h[t] > stop
            hit_target = ti < len(targets) and np.isfinite(l[t]) and l[t] <= targets[ti]
            if hit_stop:
                sx[t] = True
                pos = 0
                exited = True
            elif hit_target:
                if be and ti + 1 < len(targets):
                    ti += 1
                    stop = entry
                else:
                    sx[t] = True
                    pos = 0
                    exited = True
        if pos == 0 and not exited:
            if le[t] and not se[t]:
                eh, _ = _exh(h, l, t)
                targets = _targets((h[t - 2], eh), 1)
                pos, stop, entry, ti = 1, (l[t] if ref == 'CC' else l[t - 1]), h[t - 1], 0
            elif se[t] and not le[t]:
                _, el = _exh(h, l, t)
                targets = _targets((l[t - 2], el), -1)
                pos, stop, entry, ti = -1, (h[t] if ref == 'CC' else h[t - 1]), l[t - 1], 0
    return le, lx, se, sx

def iter_signal_parameter_sets():
    return [
        {'pattern_method': method, 'only_color': color, 'continuation': cont, 'stop_reference': ref, 'break_even': be}
        for method in ('Broad', 'Classic', 'Pin Bar')
        for color in (False, True)
        for cont in (False, True)
        for ref in ('CC', 'C1')
        for be in (False, True)
    ]

STRATEGY = {
    'strategy_id': 'hammer_shooter_breakout',
    'hypothesis': 'Hammer/Shooter rejection followed by a C1-range breakout captures reversal or enabled continuation moves toward C2 and exhaustion targets.',
    'position': 'both',
    'generate_signals': generate_signals,
    'signal_parameter_names': ['pattern_method', 'only_color', 'continuation', 'stop_reference', 'break_even'],
    'signal_parameter_sets': iter_signal_parameter_sets,
}