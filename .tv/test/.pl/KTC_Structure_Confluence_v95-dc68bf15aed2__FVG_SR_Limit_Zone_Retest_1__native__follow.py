import numpy as np
from numba import njit

import numpy as np
from numba import njit

@njit
def _read_ob_core(o, h, l, c, atr, ph, pl, scan, vol_mult, min_fvg_mult, sr_mult, point_size, sl_mult, tp1_mult, tp2_mult, tp3_mult, be_mult):
    n = c.size
    le = np.zeros(n, dtype=np.bool_)
    lx = np.zeros(n, dtype=np.bool_)
    se = np.zeros(n, dtype=np.bool_)
    sx = np.zeros(n, dtype=np.bool_)
    sd = np.full(n, np.nan, dtype=np.float64)
    td = np.full(n, np.nan, dtype=np.float64)
    last_hi = np.nan
    last_lo = np.nan
    zt = np.nan
    zb = np.nan
    zdir = 0
    zborn = -1
    zused = False
    ftop = np.nan
    fbot = np.nan
    fdir = 0
    sr_hi = np.nan
    sr_lo = np.nan
    in_pos = 0
    entry = 0.0
    risk = 0.0
    stop = 0.0
    target = 0.0
    be = 0.0
    tp1 = 0.0
    tp2 = 0.0
    got_tp1 = False
    for t in range(n):
        a = atr[t]
        if np.isfinite(ph[t]):
            last_hi = ph[t]
            sr_hi = ph[t]
        if np.isfinite(pl[t]):
            last_lo = pl[t]
            sr_lo = pl[t]
        if t >= 2 and np.isfinite(a):
            if l[t] > h[t - 2] and l[t] - h[t - 2] >= a * min_fvg_mult:
                ftop = l[t]
                fbot = h[t - 2]
                fdir = 1
            elif h[t] < l[t - 2] and l[t - 2] - h[t] >= a * min_fvg_mult:
                ftop = l[t - 2]
                fbot = h[t]
                fdir = -1
        if fdir == 1 and l[t] <= fbot:
            fdir = 0
        elif fdir == -1 and h[t] >= ftop:
            fdir = 0
        if in_pos != 0:
            if in_pos == 1:
                if not got_tp1 and h[t] >= entry + tp1:
                    got_tp1 = True
                    stop = entry + be
                if l[t] <= stop or h[t] >= entry + target:
                    in_pos = 0
                else:
                    sd[t] = max(abs(entry - stop), 1e-12)
                    td[t] = target
            else:
                if not got_tp1 and l[t] <= entry - tp1:
                    got_tp1 = True
                    stop = entry - be
                if h[t] >= stop or l[t] <= entry - target:
                    in_pos = 0
                else:
                    sd[t] = max(abs(entry - stop), 1e-12)
                    td[t] = target
        bos_up = np.isfinite(last_hi) and t > 0 and (c[t] > last_hi) and (c[t - 1] <= last_hi)
        bos_dn = np.isfinite(last_lo) and t > 0 and (c[t] < last_lo) and (c[t - 1] >= last_lo)
        ob_up = t >= 2 and c[t - 2] < o[t - 2] and (c[t - 1] > o[t - 1]) and (l[t] > h[t - 2])
        ob_dn = t >= 2 and c[t - 2] > o[t - 2] and (c[t - 1] < o[t - 1]) and (h[t] < l[t - 2])
        cand_dir = 0
        cand_top = 0.0
        cand_bot = 0.0
        cand_src = False
        if ob_up and np.isfinite(a) and (h[t - 2] - l[t - 2] < a * vol_mult):
            cand_dir = 1
            cand_top = h[t - 2]
            cand_bot = l[t - 2]
        elif ob_dn and np.isfinite(a) and (h[t - 2] - l[t - 2] < a * vol_mult):
            cand_dir = -1
            cand_top = h[t - 2]
            cand_bot = l[t - 2]
        elif bos_up and np.isfinite(a):
            for k in range(1, scan + 1):
                j = t - k
                if j >= 0 and c[j] < o[j] and (h[j] - l[j] < a * vol_mult):
                    cand_dir = 1
                    cand_top = h[j]
                    cand_bot = l[j]
                    break
        elif bos_dn and np.isfinite(a):
            for k in range(1, scan + 1):
                j = t - k
                if j >= 0 and c[j] > o[j] and (h[j] - l[j] < a * vol_mult):
                    cand_dir = -1
                    cand_top = h[j]
                    cand_bot = l[j]
                    break
        if cand_dir == 0 and fdir != 0 and np.isfinite(ftop) and np.isfinite(fbot):
            cand_dir = fdir
            cand_top = ftop
            cand_bot = fbot
            cand_src = True
        if cand_dir != 0 and cand_top > cand_bot and (not zused):
            fvg_ok = cand_src or (fdir == cand_dir and fbot <= c[t] and (ftop >= c[t]))
            sr = sr_hi if cand_dir == 1 else sr_lo
            sr_ok = np.isfinite(sr) and sr >= cand_bot - a * sr_mult and (sr <= cand_top + a * sr_mult)
            if fvg_ok and sr_ok and (zdir == 0):
                zt = cand_top
                zb = cand_bot
                zdir = cand_dir
                zborn = t
                zused = False
        if zdir != 0 and (not zused) and (t > zborn) and (in_pos == 0):
            if l[t] <= zt and h[t] >= zb:
                px = zt if zdir == 1 else zb
                buf = a * sl_mult
                if zdir == 1:
                    sl = zb - buf
                else:
                    sl = zt + buf
                r = abs(px - sl)
                if np.isfinite(r) and r > 0.0:
                    in_pos = zdir
                    entry = px
                    risk = r
                    stop = sl
                    target = r * tp3_mult
                    tp1 = r * tp1_mult
                    tp2 = r * tp2_mult
                    be = a * be_mult
                    got_tp1 = False
                    zused = True
                    if zdir == 1:
                        le[t] = True
                    else:
                        se[t] = True
                    sd[t] = r
                    td[t] = target
    return (le, lx, se, sx, sd, td)

def generate_signals(features, signal_params):
    n = features.market.size
    atr = features.atr(22)
    ph = features.pivot_high(3, 3)
    pl = features.pivot_low(3, 3)
    scan = int(signal_params['ob_ict_scan'])
    vol_mult = float(signal_params['ob_vol_mult'])
    min_fvg_mult = float(signal_params['min_fvg_atr'])
    sr_mult = float(signal_params['lz_sr_tol_atr_mult'])
    point_size = float(signal_params['ent_point_size'])
    sl_mult = float(signal_params['lz_sl_buf_atr_mult'])
    tp1_mult = float(signal_params['tp1_risk_mult'])
    tp2_mult = float(signal_params['tp2_risk_mult'])
    tp3_mult = float(signal_params['tp3_risk_mult'])
    be_mult = float(signal_params['be_offset_atr_mult'])
    _ = point_size
    return _read_ob_core(features.market.opens, features.market.highs, features.market.lows, features.market.closes, atr, ph, pl, scan, vol_mult, min_fvg_mult, sr_mult, point_size, sl_mult, tp1_mult, tp2_mult, tp3_mult, be_mult)

STRATEGY = {**{'strategy_id': 'FVG_SR_Limit_Zone_Retest_1__native__follow', 'hypothesis': '以 OB 與 FVG 區域及鄰近 S/R 建立候選交易區，價格回測區域入口時進場，並以區域邊界設止損、按風險倍數分批止盈。', 'position': 'both', 'signal_parameter_names': ['ob_ict_scan', 'ob_vol_mult', 'min_fvg_atr', 'lz_sr_tol_atr_mult', 'ent_point_size', 'lz_sl_buf_atr_mult', 'tp1_risk_mult', 'tp2_risk_mult', 'tp3_risk_mult', 'be_offset_atr_mult'], 'signal_parameter_specs': [{'name': 'ob_ict_scan', 'family': 'lookback', 'anchor': 20}, {'name': 'ob_vol_mult', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'min_fvg_atr', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'lz_sr_tol_atr_mult', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'ent_point_size', 'family': 'multiplier', 'anchor': 0.01}, {'name': 'lz_sl_buf_atr_mult', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'tp1_risk_mult', 'family': 'multiplier', 'anchor': 1.0}, {'name': 'tp2_risk_mult', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'tp3_risk_mult', 'family': 'multiplier', 'anchor': 3.0}, {'name': 'be_offset_atr_mult', 'family': 'multiplier', 'anchor': 2.0}], 'signal_parameter_relations': [['tp1_risk_mult', 'lt', 'tp2_risk_mult'], ['tp2_risk_mult', 'lt', 'tp3_risk_mult']], 'signal_parameter_candidates': {'ob_ict_scan': [20, 5, 10, 40, 80], 'ob_vol_mult': [2.0, 1.0, 1.5, 3.0], 'min_fvg_atr': [0.2, 0.13999999999999999, 0.27999999999999997], 'lz_sr_tol_atr_mult': [2.0, 1.0, 1.5, 3.0], 'ent_point_size': [0.01, 0.006999999999999999, 0.013999999999999999], 'lz_sl_buf_atr_mult': [2.0, 1.0, 1.5, 3.0], 'tp1_risk_mult': [1.0, 0.7, 1.4], 'tp2_risk_mult': [2.0, 1.4, 2.8], 'tp3_risk_mult': [3.0, 2.0999999999999996, 4.199999999999999], 'be_offset_atr_mult': [2.0, 1.0, 1.5, 3.0]}}, 'generate_signals': generate_signals}
