import numpy as np
from numba import njit

import numpy as np
from numba import njit

@njit
def _drop_col(a, count, j):
    for k in range(j, count - 1):
        for r in range(a.shape[0]):
            a[r, k] = a[r, k + 1]
    return count - 1

@njit
def _strategy_run(op, hi, lo, cl, atr, ph, pl, pivot_len, wick_mult, merge_mult, break_mult, body_mult, retest_mult, retest_exp, max_each, drift_mult, max_ob, overlap_pct, ob_max_retest, ob_hold, ob_vol_mult, max_fvg, min_fvg_atr, point_size, sr_tol_pts, max_open):
    n = cl.size
    le = np.zeros(n, dtype=np.bool_)
    se = np.zeros(n, dtype=np.bool_)
    sr = np.empty((8, max(16, 2 * max_each + 8)), dtype=np.float64)
    ns = 0
    ob = np.empty((12, max(16, max_ob + 4)), dtype=np.float64)
    no = 0
    fvg = np.empty((3, max(16, max_fvg + 4)), dtype=np.float64)
    nf = 0
    pend = np.empty((3, max(2, max_open + 2)), dtype=np.float64)
    npend = 0
    cand = np.empty((3, 4), dtype=np.float64)
    for i in range(n):
        nc = 0
        for which in range(2):
            w = ph[i] if which == 0 else pl[i]
            if not np.isnan(w):
                j = i - pivot_len
                if j >= 0:
                    if which == 0:
                        b = max(op[j], cl[j])
                        p = b if w - b > atr[i] * wick_mult and wick_mult > 0.0 else w
                        typ = -1.0
                    else:
                        b = min(op[j], cl[j])
                        p = b if b - w > atr[i] * wick_mult and wick_mult > 0.0 else w
                        typ = 1.0
                    found = -1
                    for q in range(ns):
                        if sr[3, q] == typ and sr[4, q] == 0.0 and (abs(sr[0, q] - p) <= atr[i] * merge_mult):
                            found = q
                            break
                    if found >= 0:
                        cp = min(sr[0, found], p) if typ == 1.0 else max(sr[0, found], p)
                        if drift_mult <= 0.0:
                            sr[0, found] = cp
                        elif typ == 1.0:
                            sr[0, found] = max(cp, sr[2, found] - atr[i] * drift_mult)
                        else:
                            sr[0, found] = min(cp, sr[2, found] + atr[i] * drift_mult)
                        sr[1, found] = min(sr[1, found], b) if typ == 1.0 else max(sr[1, found], b)
                    elif ns < sr.shape[1]:
                        sr[0, ns] = p
                        sr[1, ns] = b
                        sr[2, ns] = p
                        sr[3, ns] = typ
                        sr[4, ns] = 0.0
                        sr[5, ns] = np.nan
                        sr[6, ns] = 0.0
                        sr[7, ns] = i - pivot_len
                        ns += 1
        sr_del = np.zeros(ns, dtype=np.bool_)
        body = abs(cl[i] - op[i])
        for q in range(ns - 1, -1, -1):
            typ = sr[3, q]
            state = sr[4, q]
            p = sr[0, q]
            b = sr[1, q]
            pr = (p + b) * 0.5
            if state == 0.0:
                rb = typ == -1.0 and cl[i] > pr + atr[i] * break_mult and (atr[i] > 0.0) and (body >= atr[i] * body_mult)
                sb = typ == 1.0 and cl[i] < pr - atr[i] * break_mult and (atr[i] > 0.0) and (body >= atr[i] * body_mult)
                if rb or sb:
                    if sr[6, q] != 0.0:
                        sr_del[q] = True
                    else:
                        sr[4, q] = 1.0
                        sr[5, q] = i
            elif i - sr[5, q] > retest_exp:
                sr_del[q] = True
            elif i > sr[5, q]:
                touch = lo[i] <= b + atr[i] * retest_mult and hi[i] >= b - atr[i] * retest_mult
                if typ == -1.0 and touch and (cl[i] > pr):
                    sr[3, q] = 1.0
                    sr[4, q] = 0.0
                    sr[6, q] = 1.0
                    sr[7, q] = i
                elif typ == 1.0 and touch and (cl[i] < pr):
                    sr[3, q] = -1.0
                    sr[4, q] = 0.0
                    sr[6, q] = 1.0
                    sr[7, q] = i
        for q in range(ns - 1, -1, -1):
            if sr_del[q]:
                ns = _drop_col(sr, ns, q)
        for typ in (1.0, -1.0):
            while True:
                cnt = 0
                oldest = -1
                oldest_created = np.inf
                for q in range(ns):
                    if sr[3, q] == typ:
                        cnt += 1
                        if sr[7, q] < oldest_created:
                            oldest_created = sr[7, q]
                            oldest = q
                if cnt <= max_each or oldest < 0:
                    break
                ns = _drop_col(sr, ns, oldest)
        bull_ob = i >= 2 and cl[i - 2] < op[i - 2] and (cl[i - 1] > op[i - 1]) and (lo[i] > hi[i - 2])
        bear_ob = i >= 2 and cl[i - 2] > op[i - 2] and (cl[i - 1] < op[i - 1]) and (hi[i] < lo[i - 2])
        for side in range(2):
            is_bull = side == 0
            valid = bull_ob if is_bull else bear_ob
            if valid:
                t = hi[i - 2]
                b = lo[i - 2]
                if t > b and t - b < atr[i] * ob_vol_mult:
                    last = -1
                    for q in range(no):
                        earned = ob[3, q] != 0.0 or ob[4, q] > 0.0 or ob[5, q] != 0.0
                        ov = max(min(t, ob[0, q]) - max(b, ob[1, q]), 0.0)
                        sm = min(t - b, ob[0, q] - ob[1, q])
                        if not earned and sm > 0.0 and (ov / sm * 100.0 >= overlap_pct):
                            last = q
                    allowed = last < 0 or i - 2 > ob[11, last]
                    if allowed:
                        for q in range(no):
                            if ob[10, q] == 0.0:
                                ov = max(min(t, ob[0, q]) - max(b, ob[1, q]), 0.0)
                                sm = min(t - b, ob[0, q] - ob[1, q])
                                if sm > 0.0 and ov / sm * 100.0 >= overlap_pct and (i - 3 > ob[11, q]):
                                    ob[10, q] = 1.0
                        if no < ob.shape[1]:
                            ob[0, no] = t
                            ob[1, no] = b
                            ob[2, no] = 1.0 if is_bull else 0.0
                            ob[3, no] = 0.0
                            ob[4, no] = 0.0
                            ob[5, no] = 0.0
                            ob[6, no] = 1.0
                            ob[7, no] = 0.0
                            ob[8, no] = i
                            ob[9, no] = np.nan
                            ob[10, no] = 0.0
                            ob[11, no] = i - 2
                            no += 1
                            cand[0, nc] = t
                            cand[1, nc] = b
                            cand[2, nc] = 1.0 if is_bull else 0.0
                            nc += 1
        while no > max_ob:
            victim = -1
            for q in range(no):
                if ob[10, q] != 0.0:
                    victim = q
                    break
            if victim < 0:
                for q in range(no):
                    if ob[3, q] != 0.0:
                        victim = q
                        break
            if victim < 0:
                for q in range(no):
                    if ob[4, q] > 0.0 or ob[5, q] != 0.0:
                        victim = q
                        break
            if victim < 0:
                victim = 0
            no = _drop_col(ob, no, victim)
        for q in range(no - 1, -1, -1):
            old_bull = ob[2, q]
            old_breaker = ob[3, q]
            old_wasin = ob[5, q]
            old_left = ob[7, q]
            old_used = ob[9, q]
            old_frozen = ob[10, q]
            live = np.isnan(old_used) and old_frozen == 0.0
            touched = live and lo[i] <= ob[0, q] and (hi[i] >= ob[1, q])
            if not np.isnan(old_used) and old_frozen == 0.0 and (i - old_used >= ob_hold):
                ob[10, q] = 1.0
            if touched and old_wasin == 0.0:
                ob[4, q] += 1.0
            ob[5, q] = 1.0 if touched else 0.0
            if i > ob[8, q] and (not touched):
                ob[7, q] = 1.0
            invalid = cl[i] < ob[1, q] if old_bull != 0.0 else cl[i] > ob[0, q]
            too_many = ob_max_retest > 0 and ob[4, q] > ob_max_retest
            if live and invalid and (old_left != 0.0):
                if old_breaker == 0.0:
                    ob[2, q] = 1.0 - old_bull
                    ob[3, q] = 1.0
                    ob[4, q] = 0.0
                    ob[5, q] = 0.0
                    ob[7, q] = 0.0
                else:
                    ob[9, q] = i
            elif live and too_many:
                ob[9, q] = i
        bull_fvg = i >= 2 and lo[i] > hi[i - 2] and (lo[i] - hi[i - 2] >= atr[i] * min_fvg_atr)
        bear_fvg = i >= 2 and hi[i] < lo[i - 2] and (lo[i - 2] - hi[i] >= atr[i] * min_fvg_atr)
        for side in range(2):
            valid = bull_fvg if side == 0 else bear_fvg
            if valid and nf < fvg.shape[1]:
                if side == 0:
                    t = lo[i]
                    b = hi[i - 2]
                    bull = 1.0
                else:
                    t = lo[i - 2]
                    b = hi[i]
                    bull = 0.0
                fvg[0, nf] = t
                fvg[1, nf] = b
                fvg[2, nf] = bull
                nf += 1
                cand[0, nc] = t
                cand[1, nc] = b
                cand[2, nc] = bull
                nc += 1
        while nf > max_fvg:
            nf = _drop_col(fvg, nf, 0)
        fdel = np.zeros(nf, dtype=np.bool_)
        for q in range(nf - 1, -1, -1):
            t = fvg[0, q]
            b = fvg[1, q]
            if fvg[2, q] != 0.0:
                if lo[i] < t and lo[i] > b:
                    fvg[0, q] = lo[i]
                elif lo[i] <= b:
                    fdel[q] = True
            elif hi[i] > b and hi[i] < t:
                fvg[1, q] = hi[i]
            elif hi[i] >= t:
                fdel[q] = True
        for q in range(nf - 1, -1, -1):
            if fdel[q]:
                nf = _drop_col(fvg, nf, q)
        tol = sr_tol_pts * point_size
        for c in range(nc):
            zt = cand[0, c]
            zb = cand[1, c]
            zbull = cand[2, c]
            bandlo = zt if zbull != 0.0 else cl[i]
            bandhi = cl[i] if zbull != 0.0 else zb
            fok = False
            for q in range(nf):
                if fvg[0, q] >= bandlo and fvg[1, q] <= bandhi:
                    fok = True
                    break
            sok = False
            for q in range(ns):
                if sr[4, q] == 0.0 and sr[0, q] >= zb - tol and (sr[0, q] <= zt + tol):
                    sok = True
                    break
            if zt > zb and fok and sok:
                entry = zt if zbull != 0.0 else zb
                if npend < pend.shape[1]:
                    pend[0, npend] = zbull
                    pend[1, npend] = entry
                    pend[2, npend] = i
                    npend += 1
                while npend > max_open:
                    npend = _drop_col(pend, npend, 0)
        for q in range(npend - 1, -1, -1):
            entry = pend[1, q]
            if lo[i] <= entry and hi[i] >= entry:
                if pend[0, q] != 0.0:
                    le[i] = True
                else:
                    se[i] = True
                npend = _drop_col(pend, npend, q)
    return (le, se)

def generate_entries(features, signal_params):
    n = features.market.size
    op = np.asarray(features.market.opens, dtype=np.float64)
    hi = np.asarray(features.market.highs, dtype=np.float64)
    lo = np.asarray(features.market.lows, dtype=np.float64)
    cl = np.asarray(features.market.closes, dtype=np.float64)
    atr = np.asarray(features.atr(14), dtype=np.float64)
    pivot_len = int(signal_params['srPivotLen'])
    ph = np.asarray(features.pivot_high(pivot_len, pivot_len), dtype=np.float64)
    pl = np.asarray(features.pivot_low(pivot_len, pivot_len), dtype=np.float64)
    le, se = _strategy_run(op, hi, lo, cl, atr, ph, pl, pivot_len, float(signal_params['srWickGuardATR']), float(signal_params['srMergeATR']), float(signal_params['srBreakATR']), float(signal_params['srBreakBodyATR']), float(signal_params['srRetestATR']), int(signal_params['srRetestExp']), int(signal_params['srMaxEach']), float(signal_params['srMaxDriftATR']), int(signal_params['maxOB']), float(signal_params['obOverlapPct']), int(signal_params['obMaxRetest']), int(signal_params['obBkbHold']), float(signal_params['obVolMult']), int(signal_params['maxFVG']), float(signal_params['minFVGATR']), float(signal_params['entPointSize']), float(signal_params['lzSRTolPts']), int(signal_params['lzMaxOpen']))
    return (le, se)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'fvg_sr_limit_zone_retest_0__reversion', 'hypothesis': '只有當 OB 或 FVG 候選區同時符合既存 FVG 與 S/R 條件時才建立待成交區，價格觸及候選區邊界便依方向進場。', 'position': 'both', 'signal_parameter_names': ['srPivotLen', 'srWickGuardATR', 'srMergeATR', 'srBreakATR', 'srBreakBodyATR', 'srRetestATR', 'srRetestExp', 'srMaxEach', 'srMaxDriftATR', 'maxOB', 'obOverlapPct', 'obMaxRetest', 'obBkbHold', 'obVolMult', 'maxFVG', 'minFVGATR', 'entPointSize', 'lzSRTolPts', 'lzMaxOpen'], 'signal_parameter_specs': [{'name': 'srPivotLen', 'family': 'lookback', 'anchor': 7}, {'name': 'srWickGuardATR', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'srMergeATR', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'srBreakATR', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'srBreakBodyATR', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'srRetestATR', 'family': 'multiplier', 'anchor': 0.15}, {'name': 'srRetestExp', 'family': 'count', 'anchor': 25}, {'name': 'srMaxEach', 'family': 'count', 'anchor': 4}, {'name': 'srMaxDriftATR', 'family': 'multiplier', 'anchor': 1.0}, {'name': 'maxOB', 'family': 'count', 'anchor': 50}, {'name': 'obOverlapPct', 'family': 'fraction', 'anchor': 0.5}, {'name': 'obMaxRetest', 'family': 'count', 'anchor': 2}, {'name': 'obBkbHold', 'family': 'count', 'anchor': 3}, {'name': 'obVolMult', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'maxFVG', 'family': 'count', 'anchor': 100}, {'name': 'minFVGATR', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'entPointSize', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'lzSRTolPts', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'lzMaxOpen', 'family': 'count', 'anchor': 8}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'srPivotLen': [7, 4, 14], 'srWickGuardATR': [2.0, 1.4, 2.8], 'srMergeATR': [0.2, 0.13999999999999999, 0.27999999999999997], 'srBreakATR': [0.1, 0.06999999999999999, 0.13999999999999999], 'srBreakBodyATR': [0.2, 0.13999999999999999, 0.27999999999999997], 'srRetestATR': [0.15, 0.105, 0.21], 'srRetestExp': [25, 12, 50], 'srMaxEach': [4, 2, 8], 'srMaxDriftATR': [1.0, 0.7, 1.4], 'maxOB': [50, 25, 100], 'obOverlapPct': [0.5, 0.25, 1.0], 'obMaxRetest': [2, 1, 4], 'obBkbHold': [3, 2, 6], 'obVolMult': [2.0, 1.4, 2.8], 'maxFVG': [100, 50, 200], 'minFVGATR': [0.2, 0.13999999999999999, 0.27999999999999997], 'entPointSize': [2.0, 1.0, 1.5, 3.0], 'lzSRTolPts': [2.0, 1.0, 1.5, 3.0], 'lzMaxOpen': [8, 4, 16]}}, 'generate_signals': generate_signals}
