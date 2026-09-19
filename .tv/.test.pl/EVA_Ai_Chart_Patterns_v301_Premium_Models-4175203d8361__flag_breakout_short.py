def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    volumes = features.market.volumes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    gamma = float(signal_params.get('gamma', 1.0))
    n_base = float(signal_params.get('n_base', 2000.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    cum_vol = 0.0
    entry_atr = 1.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
                cum_vol += volumes[t]
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
                cum_vol += volumes[t]
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
    return (long_exits, short_exits)

def _linreg_endpoints(values):
    import numpy as np
    length = values.size
    x = np.arange(length, dtype=float)
    x_centered = x - x.mean()
    y_mean = float(values.mean())
    slope = float(np.dot(x_centered, values - y_mean) / np.dot(x_centered, x_centered))
    intercept = y_mean - slope * float(x.mean())
    return (intercept, intercept + slope * float(length - 1), slope)

def _evaluate_short_flag(t, pattern_len, pole_len, highs, lows, closes, volumes, atr):
    import numpy as np
    pole_end_index = t - pattern_len
    pole_start_index = pole_end_index - pole_len
    pattern_start_index = t - pattern_len
    if pole_start_index < 0 or not np.isfinite(atr[pole_end_index]) or atr[pole_end_index] <= 0.0:
        return None
    if t < pattern_len + pole_len + 20 + 5:
        return None
    upper_values = highs[pattern_start_index:t]
    lower_values = lows[pattern_start_index:t]
    if upper_values.size != pattern_len or not np.all(np.isfinite(upper_values)) or (not np.all(np.isfinite(lower_values))):
        return None
    upper_start, upper_end, upper_slope = _linreg_endpoints(upper_values)
    lower_start, lower_end, lower_slope = _linreg_endpoints(lower_values)
    local_atr = float(atr[pole_end_index])
    upper_slope_atr = upper_slope / local_atr
    lower_slope_atr = lower_slope / local_atr
    pole_move = float(closes[pole_end_index] - closes[pole_start_index])
    pole_size = abs(pole_move)
    pole_strength = pole_size / local_atr
    if not np.isfinite(pole_strength) or pole_move >= 0.0 or pole_strength < 1.0:
        return None
    width_end = upper_end - lower_end
    pattern_range = float(np.max(upper_values) - np.min(lower_values))
    pattern_pole_ratio = pattern_range / pole_size if pole_size > 1e-12 else 100.0
    if upper_slope_atr < -0.05 or upper_slope_atr > 0.18 or lower_slope_atr < -0.05 or (lower_slope_atr > 0.18) or (abs(upper_slope_atr - lower_slope_atr) > 0.1) or (pattern_pole_ratio > 1.35) or (width_end / local_atr < 0.05):
        return None
    pole_volume_values = volumes[pole_start_index:pole_end_index]
    pattern_volume_values = volumes[pattern_start_index:t]
    if not np.all(np.isfinite(pole_volume_values)) or not np.all(np.isfinite(pattern_volume_values)):
        return None
    pole_volume = float(np.mean(pole_volume_values))
    pattern_volume = float(np.mean(pattern_volume_values))
    volume_ratio = pattern_volume / pole_volume if pole_volume > 0.0 else 1.0
    pole_score = min(30.0, pole_strength / 1.0 * 20.0)
    geometry_score = max(0.0, min(30.0, (0.1 - abs(upper_slope_atr - lower_slope_atr)) / 0.1 * 30.0))
    compact_score = max(0.0, min(20.0, (1.35 - pattern_pole_ratio) / 1.35 * 20.0))
    span_score = min(10.0, pattern_len / 80.0 * 10.0)
    volume_score = max(0.0, min(10.0, (1.3 - volume_ratio) * 20.0))
    quality = min(100.0, pole_score + geometry_score + compact_score + span_score + volume_score)
    if not np.isfinite(quality):
        return None
    return (quality, lower_end, lower_slope)

def generate_signals(features, signal_params):
    import numpy as np
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    volumes = np.asarray(features.market.volumes, dtype=float)
    atr = np.asarray(features.atr(14), dtype=float)
    buffer_atr = 0.05
    pole_len = 14
    candidate_lengths = range(12, 81, 4)
    for t in range(size):
        best = None
        for pattern_len in candidate_lengths:
            candidate = _evaluate_short_flag(t, pattern_len, pole_len, highs, lows, closes, volumes, atr)
            if candidate is not None and (best is None or candidate[0] > best[0]):
                best = candidate
        if best is None or best[0] < 65.0:
            continue
        _, lower_end, lower_slope = best
        current_lower = lower_end + lower_slope
        previous_lower = lower_end
        current_buffer = buffer_atr * float(atr[t])
        previous_buffer = buffer_atr * float(atr[t - 1]) if t > 0 else np.nan
        if np.isfinite(current_buffer) and np.isfinite(previous_buffer) and (closes[t] < current_lower - current_buffer) and (closes[t - 1] >= previous_lower - previous_buffer):
            short_entries[t] = True
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'flag_breakout_short', 'hypothesis': '空頭旗形整理後的收盤跌破下軌，預示下行延續。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
