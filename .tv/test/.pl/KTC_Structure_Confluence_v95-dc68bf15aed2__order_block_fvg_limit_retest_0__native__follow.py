import numpy as np
from numba import njit

import numpy as np
from numba import njit

@njit
def _build_limit_zone_entries(opens, highs, lows, closes, atr, pivot_high, pivot_low, sr_tolerance, stop_buffer, point_size, ob_max_range_atr, ob_overlap_fraction, ob_ict_scan_bars, ob_ict_max_range_atr, ob_max_retests, fvg_min_gap_atr, fvg_arm_bars, sr_pivot_length, sr_merge_distance_atr):
    n = closes.size
    long_entries = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    fvg_dir = np.zeros(n, dtype=np.int8)
    fvg_lo = np.zeros(n, dtype=np.float64)
    fvg_hi = np.zeros(n, dtype=np.float64)
    fvg_active = np.zeros(n, dtype=np.bool_)
    fvg_arm_bar = np.full(n, -1000000000, dtype=np.int64)
    ob_dir = np.zeros(n, dtype=np.int8)
    ob_lo = np.zeros(n, dtype=np.float64)
    ob_hi = np.zeros(n, dtype=np.float64)
    ob_stop = np.zeros(n, dtype=np.float64)
    ob_retests = np.zeros(n, dtype=np.int64)
    ob_active = np.zeros(n, dtype=np.bool_)
    ob_last_touch = np.full(n, -1, dtype=np.int64)
    sr_level = np.zeros(4 * n + 1, dtype=np.float64)
    sr_dir = np.zeros(4 * n + 1, dtype=np.int8)
    sr_active = np.zeros(4 * n + 1, dtype=np.bool_)
    sr_count = 0
    nfvg = 0
    nob = 0
    for i in range(n):
        a = atr[i]
        if not np.isfinite(a):
            a = 0.0
        if np.isfinite(pivot_high[i]):
            p = i - sr_pivot_length
            if p >= 0:
                vals = (pivot_high[i], max(opens[p], closes[p]))
                for k in range(2):
                    v = vals[k]
                    merged = False
                    for j in range(sr_count):
                        if sr_active[j] and sr_dir[j] == 1 and (abs(sr_level[j] - v) <= a * sr_merge_distance_atr):
                            if v < sr_level[j]:
                                sr_level[j] = v
                            merged = True
                            break
                    if not merged and sr_count < sr_level.size:
                        sr_level[sr_count] = v
                        sr_dir[sr_count] = 1
                        sr_active[sr_count] = True
                        sr_count += 1
        if np.isfinite(pivot_low[i]):
            p = i - sr_pivot_length
            if p >= 0:
                vals = (pivot_low[i], min(opens[p], closes[p]))
                for k in range(2):
                    v = vals[k]
                    merged = False
                    for j in range(sr_count):
                        if sr_active[j] and sr_dir[j] == -1 and (abs(sr_level[j] - v) <= a * sr_merge_distance_atr):
                            if v > sr_level[j]:
                                sr_level[j] = v
                            merged = True
                            break
                    if not merged and sr_count < sr_level.size:
                        sr_level[sr_count] = v
                        sr_dir[sr_count] = -1
                        sr_active[sr_count] = True
                        sr_count += 1
        for j in range(sr_count):
            if sr_active[j] and (sr_dir[j] == 1 and closes[i] > sr_level[j] or (sr_dir[j] == -1 and closes[i] < sr_level[j])):
                sr_active[j] = False
        if i >= 2:
            if lows[i] > highs[i - 2] and lows[i] - highs[i - 2] >= a * fvg_min_gap_atr:
                fvg_dir[nfvg] = 1
                fvg_lo[nfvg] = highs[i - 2]
                fvg_hi[nfvg] = lows[i]
                fvg_active[nfvg] = True
                nfvg += 1
            if highs[i] < lows[i - 2] and lows[i - 2] - highs[i] >= a * fvg_min_gap_atr:
                fvg_dir[nfvg] = -1
                fvg_lo[nfvg] = highs[i]
                fvg_hi[nfvg] = lows[i - 2]
                fvg_active[nfvg] = True
                nfvg += 1
        for j in range(nfvg):
            if fvg_active[j] and lows[i] <= fvg_hi[j] and (highs[i] >= fvg_lo[j]):
                if fvg_dir[j] == 1:
                    fvg_hi[j] = min(fvg_hi[j], lows[i])
                    fvg_arm_bar[0] = i
                else:
                    fvg_lo[j] = max(fvg_lo[j], highs[i])
                    fvg_arm_bar[1] = i
                if fvg_lo[j] >= fvg_hi[j]:
                    fvg_active[j] = False
        for j in range(nob):
            if ob_active[j]:
                touched = lows[i] <= ob_hi[j] and highs[i] >= ob_lo[j]
                if touched and ob_last_touch[j] != i:
                    if ob_last_touch[j] < i - 1:
                        ob_retests[j] += 1
                    ob_last_touch[j] = i
                    if ob_retests[j] > ob_max_retests:
                        ob_active[j] = False
                elif not touched and ob_last_touch[j] == i - 1:
                    pass
                if ob_dir[j] == 1 and closes[i] < ob_lo[j] or (ob_dir[j] == -1 and closes[i] > ob_hi[j]):
                    ob_active[j] = False
        if i >= 2:
            bull_ob = closes[i - 2] < opens[i - 2] and closes[i - 1] > opens[i - 1] and (lows[i] > highs[i - 2])
            bear_ob = closes[i - 2] > opens[i - 2] and closes[i - 1] < opens[i - 1] and (highs[i] < lows[i - 2])
            if bull_ob or bear_ob:
                direction = 1 if bull_ob else -1
                lo = lows[i - 2]
                hi = highs[i - 2]
                if hi - lo < a * ob_max_range_atr:
                    fvg_ok = False
                    arm_idx = 0 if direction == 1 else 1
                    if i - fvg_arm_bar[arm_idx] >= 1 and i - fvg_arm_bar[arm_idx] <= fvg_arm_bars:
                        for k in range(nfvg):
                            if fvg_active[k] and fvg_dir[k] == direction:
                                if direction == 1 and fvg_lo[k] <= closes[i] and (fvg_hi[k] >= hi) and (closes[i] > hi):
                                    fvg_ok = True
                                if direction == -1 and fvg_hi[k] >= closes[i] and (fvg_lo[k] <= lo) and (lo > closes[i]):
                                    fvg_ok = True
                    sr_ok = False
                    tol = a * sr_tolerance
                    for k in range(sr_count):
                        if sr_active[k] and sr_level[k] >= lo - tol and (sr_level[k] <= hi + tol):
                            sr_ok = True
                    if fvg_ok and sr_ok:
                        overlaps = False
                        for k in range(nob):
                            if ob_active[k] and ob_dir[k] == direction:
                                overlap = min(hi, ob_hi[k]) - max(lo, ob_lo[k])
                                smaller = min(hi - lo, ob_hi[k] - ob_lo[k])
                                if smaller > 0.0 and overlap / smaller >= ob_overlap_fraction:
                                    overlaps = True
                                    break
                        if not overlaps:
                            ob_dir[nob] = direction
                            ob_lo[nob] = lo
                            ob_hi[nob] = hi
                            ob_stop[nob] = lo - a * stop_buffer if direction == 1 else hi + a * stop_buffer
                            ob_retests[nob] = 0
                            ob_active[nob] = True
                            ob_last_touch[nob] = i
                            nob += 1
        for j in range(nob):
            if ob_active[j] and i > 0 and (lows[i] <= (ob_hi[j] if ob_dir[j] == 1 else ob_lo[j])) and (highs[i] >= (ob_hi[j] if ob_dir[j] == 1 else ob_lo[j])):
                risk = ob_hi[j] - ob_stop[j] if ob_dir[j] == 1 else ob_stop[j] - ob_lo[j]
                if risk > 0.0:
                    if ob_dir[j] == 1:
                        long_entries[i] = True
                    else:
                        short_entries[i] = True
                    stop_distances[i] = risk
                    target_distances[i] = risk * 3.0
                    ob_active[j] = False
                    break
    return (long_entries, short_entries, stop_distances, target_distances)

def generate_signals(features, signal_params):
    sr_tolerance = signal_params['sr_tolerance']
    stop_buffer = signal_params['stop_buffer']
    point_size = signal_params['point_size']
    ob_max_range_atr = signal_params['ob_max_range_atr']
    ob_overlap_fraction = signal_params['ob_overlap_fraction']
    ob_ict_scan_bars = signal_params['ob_ict_scan_bars']
    ob_ict_max_range_atr = signal_params['ob_ict_max_range_atr']
    ob_max_retests = signal_params['ob_max_retests']
    fvg_min_gap_atr = signal_params['fvg_min_gap_atr']
    fvg_arm_bars = signal_params['fvg_arm_bars']
    sr_pivot_length = signal_params['sr_pivot_length']
    sr_merge_distance_atr = signal_params['sr_merge_distance_atr']
    tp1_risk_multiple = signal_params['tp1_risk_multiple']
    tp2_risk_multiple = signal_params['tp2_risk_multiple']
    tp3_risk_multiple = signal_params['tp3_risk_multiple']
    breakeven_offset = signal_params['breakeven_offset']
    n = features.market.size
    atr = features.atr(22)
    pivot_high = features.pivot_high(sr_pivot_length, sr_pivot_length)
    pivot_low = features.pivot_low(sr_pivot_length, sr_pivot_length)
    long_entries, short_entries, stop_distances, target_distances = _build_limit_zone_entries(features.market.opens, features.market.highs, features.market.lows, features.market.closes, atr, pivot_high, pivot_low, sr_tolerance, stop_buffer, point_size, ob_max_range_atr, ob_overlap_fraction, ob_ict_scan_bars, ob_ict_max_range_atr, ob_max_retests, fvg_min_gap_atr, fvg_arm_bars, sr_pivot_length, sr_merge_distance_atr)
    target_distances[np.isfinite(target_distances)] = stop_distances[np.isfinite(target_distances)] * tp3_risk_multiple
    long_exits = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    _ = (tp1_risk_multiple, tp2_risk_multiple, breakeven_offset)
    return (long_entries, long_exits, short_entries, short_exits, stop_distances.astype(np.float64), target_distances.astype(np.float64))

STRATEGY = {**{'strategy_id': 'order_block_fvg_limit_retest_0__native__follow', 'hypothesis': '收盤確認的 OB 區須有有效 FVG 與鄰近有效 SR 才建立限價入場，價格回測入場後依風險倍數分段止盈並以止損或 TP3 出場。', 'position': 'both', 'signal_parameter_names': ['sr_tolerance', 'stop_buffer', 'point_size', 'ob_max_range_atr', 'ob_overlap_fraction', 'ob_ict_scan_bars', 'ob_ict_max_range_atr', 'ob_max_retests', 'fvg_min_gap_atr', 'fvg_arm_bars', 'sr_pivot_length', 'sr_merge_distance_atr', 'tp1_risk_multiple', 'tp2_risk_multiple', 'tp3_risk_multiple', 'breakeven_offset'], 'signal_parameter_specs': [{'name': 'sr_tolerance', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'stop_buffer', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'point_size', 'family': 'multiplier', 'anchor': 0.01}, {'name': 'ob_max_range_atr', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'ob_overlap_fraction', 'family': 'fraction', 'anchor': 0.5}, {'name': 'ob_ict_scan_bars', 'family': 'count', 'anchor': 20}, {'name': 'ob_ict_max_range_atr', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'ob_max_retests', 'family': 'count', 'anchor': 2}, {'name': 'fvg_min_gap_atr', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'fvg_arm_bars', 'family': 'lookback', 'anchor': 3}, {'name': 'sr_pivot_length', 'family': 'lookback', 'anchor': 7}, {'name': 'sr_merge_distance_atr', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'tp1_risk_multiple', 'family': 'multiplier', 'anchor': 1.0}, {'name': 'tp2_risk_multiple', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'tp3_risk_multiple', 'family': 'multiplier', 'anchor': 3.0}, {'name': 'breakeven_offset', 'family': 'multiplier', 'anchor': 2.0}], 'signal_parameter_relations': [['tp1_risk_multiple', 'lt', 'tp2_risk_multiple'], ['tp2_risk_multiple', 'lt', 'tp3_risk_multiple']], 'signal_parameter_candidates': {'sr_tolerance': [2.0, 1.0, 1.5, 3.0], 'stop_buffer': [2.0, 1.0, 1.5, 3.0], 'point_size': [0.01, 0.006999999999999999, 0.013999999999999999], 'ob_max_range_atr': [2.0, 1.4, 2.8], 'ob_overlap_fraction': [0.5, 0.25, 1.0], 'ob_ict_scan_bars': [20, 10, 40], 'ob_ict_max_range_atr': [2.0, 1.4, 2.8], 'ob_max_retests': [2, 1, 4], 'fvg_min_gap_atr': [0.2, 0.13999999999999999, 0.27999999999999997], 'fvg_arm_bars': [3, 2, 6], 'sr_pivot_length': [7, 4, 14], 'sr_merge_distance_atr': [0.2, 0.13999999999999999, 0.27999999999999997], 'tp1_risk_multiple': [2.0, 1.0, 1.5, 3.0], 'tp2_risk_multiple': [2.0, 1.0, 1.5, 3.0], 'tp3_risk_multiple': [2.0, 1.0, 1.5, 3.0], 'breakeven_offset': [2.0, 1.0, 1.5, 3.0]}}, 'generate_signals': generate_signals}
