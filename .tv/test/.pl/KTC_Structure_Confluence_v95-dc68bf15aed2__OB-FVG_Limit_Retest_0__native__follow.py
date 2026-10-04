import numpy as np
from numba import njit

@njit
def _build_zone_entries(opens, highs, lows, closes, atr, pivot_highs, pivot_lows, left, right, ob_mult, overlap_fraction, fvg_mult, wick_mult, merge_mult, sr_tolerance, point_size, sl_buffer):
    n = closes.size
    long_entries = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    long_stops = np.full(n, np.nan, dtype=np.float64)
    short_stops = np.full(n, np.nan, dtype=np.float64)
    long_targets = np.full(n, np.nan, dtype=np.float64)
    short_targets = np.full(n, np.nan, dtype=np.float64)
    fvg_dir = np.zeros(n, dtype=np.int64)
    fvg_lo = np.zeros(n, dtype=np.float64)
    fvg_hi = np.zeros(n, dtype=np.float64)
    fvg_count = 0
    sr_dir = np.zeros(n, dtype=np.int64)
    sr_price = np.zeros(n, dtype=np.float64)
    sr_count = 0
    ob_dir = np.zeros(n, dtype=np.int64)
    ob_lo = np.zeros(n, dtype=np.float64)
    ob_hi = np.zeros(n, dtype=np.float64)
    ob_touched = np.zeros(n, dtype=np.bool_)
    ob_count = 0
    tolerance = sr_tolerance * point_size
    for t in range(n):
        i = 0
        while i < fvg_count:
            remove = False
            if fvg_dir[i] == 1:
                if lows[t] <= fvg_lo[i]:
                    remove = True
                elif lows[t] < fvg_hi[i]:
                    fvg_hi[i] = lows[t]
            elif highs[t] >= fvg_hi[i]:
                remove = True
            elif highs[t] > fvg_lo[i]:
                fvg_lo[i] = highs[t]
            if remove:
                fvg_count -= 1
                fvg_dir[i] = fvg_dir[fvg_count]
                fvg_lo[i] = fvg_lo[fvg_count]
                fvg_hi[i] = fvg_hi[fvg_count]
            else:
                i += 1
        i = 0
        while i < sr_count:
            broken = sr_dir[i] == -1 and closes[t] < sr_price[i] or (sr_dir[i] == 1 and closes[t] > sr_price[i])
            if broken:
                sr_count -= 1
                sr_dir[i] = sr_dir[sr_count]
                sr_price[i] = sr_price[sr_count]
            else:
                i += 1
        if not np.isnan(pivot_lows[t]):
            p = pivot_lows[t]
            if t >= right and lows[t - right] - p > atr[t] * wick_mult:
                p = lows[t - right]
            merged = False
            for j in range(sr_count):
                if sr_dir[j] == -1 and abs(sr_price[j] - p) <= atr[t] * merge_mult:
                    if p < sr_price[j]:
                        sr_price[j] = p
                    merged = True
                    break
            if not merged and sr_count < n:
                sr_dir[sr_count] = -1
                sr_price[sr_count] = p
                sr_count += 1
        if not np.isnan(pivot_highs[t]):
            p = pivot_highs[t]
            if t >= right and p - highs[t - right] > atr[t] * wick_mult:
                p = highs[t - right]
            merged = False
            for j in range(sr_count):
                if sr_dir[j] == 1 and abs(sr_price[j] - p) <= atr[t] * merge_mult:
                    if p > sr_price[j]:
                        sr_price[j] = p
                    merged = True
                    break
            if not merged and sr_count < n:
                sr_dir[sr_count] = 1
                sr_price[sr_count] = p
                sr_count += 1
        bull_fvg = t >= 2 and lows[t] > highs[t - 2] and (lows[t] - highs[t - 2] >= atr[t] * fvg_mult)
        bear_fvg = t >= 2 and highs[t] < lows[t - 2] and (lows[t - 2] - highs[t] >= atr[t] * fvg_mult)
        if bull_fvg and fvg_count < n:
            fvg_dir[fvg_count] = 1
            fvg_lo[fvg_count] = highs[t - 2]
            fvg_hi[fvg_count] = lows[t]
            fvg_count += 1
        if bear_fvg and fvg_count < n:
            fvg_dir[fvg_count] = -1
            fvg_lo[fvg_count] = highs[t]
            fvg_hi[fvg_count] = lows[t - 2]
            fvg_count += 1
        i = 0
        while i < ob_count:
            if ob_dir[i] == 1:
                if lows[t] <= ob_lo[i]:
                    ob_count -= 1
                    ob_dir[i] = ob_dir[ob_count]
                    ob_lo[i] = ob_lo[ob_count]
                    ob_hi[i] = ob_hi[ob_count]
                    ob_touched[i] = ob_touched[ob_count]
                    continue
                if lows[t] <= ob_hi[i] and highs[t] >= ob_lo[i]:
                    ob_touched[i] = True
            else:
                if highs[t] >= ob_hi[i]:
                    ob_count -= 1
                    ob_dir[i] = ob_dir[ob_count]
                    ob_lo[i] = ob_lo[ob_count]
                    ob_hi[i] = ob_hi[ob_count]
                    ob_touched[i] = ob_touched[ob_count]
                    continue
                if highs[t] >= ob_lo[i] and lows[t] <= ob_hi[i]:
                    ob_touched[i] = True
            i += 1
        if t >= 2:
            direction = 0
            if closes[t - 2] < opens[t - 2] and closes[t - 1] > opens[t - 1] and (lows[t] > highs[t - 2]):
                direction = 1
            elif closes[t - 2] > opens[t - 2] and closes[t - 1] < opens[t - 1] and (highs[t] < lows[t - 2]):
                direction = -1
            if direction != 0 and highs[t - 2] - lows[t - 2] < atr[t] * ob_mult:
                zlo = lows[t - 2]
                zhi = highs[t - 2]
                area = zhi - zlo
                overlap = False
                for j in range(ob_count):
                    if ob_dir[j] == direction and (not ob_touched[j]):
                        inter = min(zhi, ob_hi[j]) - max(zlo, ob_lo[j])
                        if inter > 0.0 and area > 0.0 and (inter / area > overlap_fraction):
                            overlap = True
                            break
                if not overlap:
                    has_sr = False
                    for j in range(sr_count):
                        if direction == 1 and sr_dir[j] == -1 and (sr_price[j] >= zlo - tolerance) and (sr_price[j] <= zhi + tolerance):
                            has_sr = True
                            break
                        if direction == -1 and sr_dir[j] == 1 and (sr_price[j] >= zlo - tolerance) and (sr_price[j] <= zhi + tolerance):
                            has_sr = True
                            break
                    path_lo = zhi if direction == 1 else closes[t]
                    path_hi = closes[t] if direction == 1 else zlo
                    has_fvg = False
                    for j in range(fvg_count):
                        if fvg_hi[j] >= path_lo and fvg_lo[j] <= path_hi:
                            has_fvg = True
                            break
                    if has_sr and has_fvg and (ob_count < n):
                        ob_dir[ob_count] = direction
                        ob_lo[ob_count] = zlo
                        ob_hi[ob_count] = zhi
                        ob_touched[ob_count] = False
                        ob_count += 1
        for j in range(ob_count):
            if ob_dir[j] == 1:
                entry = ob_hi[j]
                stop = ob_lo[j] - atr[t] * sl_buffer
                if lows[t] <= entry and highs[t] >= entry and (stop < entry):
                    long_entries[t] = True
                    long_stops[t] = entry - stop
                    long_targets[t] = (entry - stop) * 3.0
                    break
            else:
                entry = ob_lo[j]
                stop = ob_hi[j] + atr[t] * sl_buffer
                if lows[t] <= entry and highs[t] >= entry and (stop > entry):
                    short_entries[t] = True
                    short_stops[t] = stop - entry
                    short_targets[t] = (stop - entry) * 3.0
                    break
    return (long_entries, short_entries, long_stops, short_stops, long_targets, short_targets)

def generate_signals(features, signal_params):
    n = features.market.size
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    atr = np.asarray(features.atr(22), dtype=np.float64)
    sr_pivot_left_lookback = int(signal_params['sr_pivot_left_lookback'])
    sr_pivot_right_lookback = int(signal_params['sr_pivot_right_lookback'])
    ob_vol_atr_mult = float(signal_params['ob_vol_atr_mult'])
    ob_overlap_fraction = float(signal_params['ob_overlap_fraction'])
    fvg_min_atr_mult = float(signal_params['fvg_min_atr_mult'])
    sr_wick_fallback_atr_mult = float(signal_params['sr_wick_fallback_atr_mult'])
    sr_merge_atr_mult = float(signal_params['sr_merge_atr_mult'])
    sr_tolerance = float(signal_params['sr_tolerance'])
    entry_point_size = float(signal_params['entry_point_size'])
    sl_buffer = float(signal_params['sl_buffer'])
    tp1_risk_multiple = float(signal_params['tp1_risk_multiple'])
    tp2_risk_multiple = float(signal_params['tp2_risk_multiple'])
    tp3_risk_multiple = float(signal_params['tp3_risk_multiple'])
    breakeven_offset = float(signal_params['breakeven_offset'])
    pivot_highs = np.asarray(features.pivot_high(sr_pivot_left_lookback, sr_pivot_right_lookback), dtype=np.float64)
    pivot_lows = np.asarray(features.pivot_low(sr_pivot_left_lookback, sr_pivot_right_lookback), dtype=np.float64)
    long_entries, short_entries, long_stops, short_stops, long_targets, short_targets = _build_zone_entries(opens, highs, lows, closes, atr, pivot_highs, pivot_lows, sr_pivot_left_lookback, sr_pivot_right_lookback, ob_vol_atr_mult, ob_overlap_fraction, fvg_min_atr_mult, sr_wick_fallback_atr_mult, sr_merge_atr_mult, sr_tolerance, entry_point_size, sl_buffer)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    stop_distances[long_entries] = long_stops[long_entries]
    stop_distances[short_entries] = short_stops[short_entries]
    target_distances[long_entries] = long_stops[long_entries] * tp3_risk_multiple
    target_distances[short_entries] = short_stops[short_entries] * tp3_risk_multiple
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

STRATEGY = {**{'strategy_id': 'OB-FVG_Limit_Retest_0__native__follow', 'hypothesis': '多空區域需同時符合未填補 FVG 重疊與有效支撐／阻力篩選，觸及區域掛單價後進場，並以區域外停損及分段風險倍數止盈。', 'position': 'both', 'signal_parameter_names': ['sr_pivot_left_lookback', 'sr_pivot_right_lookback', 'ob_vol_atr_mult', 'ob_overlap_fraction', 'fvg_min_atr_mult', 'sr_wick_fallback_atr_mult', 'sr_merge_atr_mult', 'sr_tolerance', 'entry_point_size', 'sl_buffer', 'tp1_risk_multiple', 'tp2_risk_multiple', 'tp3_risk_multiple', 'breakeven_offset'], 'signal_parameter_specs': [{'name': 'sr_pivot_left_lookback', 'family': 'lookback', 'anchor': 7}, {'name': 'sr_pivot_right_lookback', 'family': 'lookback', 'anchor': 7}, {'name': 'ob_vol_atr_mult', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'ob_overlap_fraction', 'family': 'fraction', 'anchor': 0.5}, {'name': 'fvg_min_atr_mult', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'sr_wick_fallback_atr_mult', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'sr_merge_atr_mult', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'sr_tolerance', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'entry_point_size', 'family': 'multiplier', 'anchor': 0.01}, {'name': 'sl_buffer', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'tp1_risk_multiple', 'family': 'multiplier', 'anchor': 1.0}, {'name': 'tp2_risk_multiple', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'tp3_risk_multiple', 'family': 'multiplier', 'anchor': 3.0}, {'name': 'breakeven_offset', 'family': 'multiplier', 'anchor': 2.0}], 'signal_parameter_relations': [['tp1_risk_multiple', 'lt', 'tp2_risk_multiple'], ['tp2_risk_multiple', 'lt', 'tp3_risk_multiple']], 'signal_parameter_candidates': {'sr_pivot_left_lookback': [7, 4, 14], 'sr_pivot_right_lookback': [7, 4, 14], 'ob_vol_atr_mult': [2.0, 1.4, 2.8], 'ob_overlap_fraction': [0.5, 0.25, 1.0], 'fvg_min_atr_mult': [0.2, 0.13999999999999999, 0.27999999999999997], 'sr_wick_fallback_atr_mult': [2.0, 1.4, 2.8], 'sr_merge_atr_mult': [0.2, 0.13999999999999999, 0.27999999999999997], 'sr_tolerance': [2.0, 1.0, 1.5, 3.0], 'entry_point_size': [0.01, 0.006999999999999999, 0.013999999999999999], 'sl_buffer': [2.0, 1.0, 1.5, 3.0], 'tp1_risk_multiple': [2.0, 1.0, 1.5, 3.0], 'tp2_risk_multiple': [2.0, 1.0, 1.5, 3.0], 'tp3_risk_multiple': [2.0, 1.0, 1.5, 3.0], 'breakeven_offset': [2.0, 1.0, 1.5, 3.0]}}, 'generate_signals': generate_signals}
