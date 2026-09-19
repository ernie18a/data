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
    n = values.size
    x = np.arange(n, dtype=np.float64)
    x_mean = float(x.mean())
    y_mean = float(values.mean())
    centered_x = x - x_mean
    denominator = float(np.dot(centered_x, centered_x))
    if denominator <= 0.0:
        return (float('nan'), float('nan'), float('nan'))
    slope = float(np.dot(centered_x, values - y_mean) / denominator)
    start = y_mean - slope * x_mean
    end = start + slope * (n - 1)
    return (float(start), float(end), slope)

def _finite_mean(values):
    import numpy as np
    if values.size == 0 or not np.all(np.isfinite(values)):
        return float('nan')
    return float(values.mean())

def generate_signals(features, signal_params):
    import numpy as np
    size = int(features.market.size)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volumes = np.asarray(features.market.volumes, dtype=np.float64)
    atr = np.asarray(features.atr(14), dtype=np.float64)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    pattern_lengths = range(12, 81, 4)
    pole_length = 14
    min_pole_atr = 1.0
    max_pattern_pole_ratio = 2.4
    min_converging_slope = 0.01
    max_pennant_end_ratio = 0.78
    min_end_width_atr = 0.05
    breakout_buffer_atr = 0.05
    min_quality = 65.0
    max_pattern_length = 80.0
    pennant_priority_bonus = 12.0
    macro_pattern_length = 36
    macro_priority_bonus = 8.0
    epsilon = 1e-12
    for t in range(size):
        best_rank = float('-inf')
        best_quality = float('-inf')
        best_lower_end = float('nan')
        best_lower_slope = float('nan')
        best_bias = 0
        for pattern_length in pattern_lengths:
            pattern_start = t - pattern_length
            pole_start_index = pattern_start - pole_length
            local_atr_index = pattern_start
            if pole_start_index < 0 or local_atr_index < 0:
                continue
            if t < pattern_length + pole_length + 20 + 5:
                continue
            if local_atr_index >= atr.size or t >= atr.size:
                continue
            local_atr = float(atr[local_atr_index])
            current_atr = float(atr[t])
            if not np.isfinite(local_atr) or local_atr <= 0.0:
                continue
            if not np.isfinite(current_atr) or current_atr <= 0.0:
                continue
            pattern_highs = highs[pattern_start:t]
            pattern_lows = lows[pattern_start:t]
            if pattern_highs.size != pattern_length or pattern_lows.size != pattern_length:
                continue
            if not np.all(np.isfinite(pattern_highs)) or not np.all(np.isfinite(pattern_lows)):
                continue
            upper_start, upper_end, upper_slope = _linreg_endpoints(pattern_highs)
            lower_start, lower_end, lower_slope = _linreg_endpoints(pattern_lows)
            if not all((np.isfinite(value) for value in (upper_start, upper_end, upper_slope, lower_start, lower_end, lower_slope))):
                continue
            width_start = upper_start - lower_start
            width_end = upper_end - lower_end
            if width_start <= 0.0 or width_end <= 0.0:
                continue
            upper_slope_atr = upper_slope / local_atr
            lower_slope_atr = lower_slope / local_atr
            end_ratio = width_end / width_start
            half_length = max(pattern_length // 2, 3)
            early_start = t - 2 * half_length
            early_end = t - half_length
            late_start = t - half_length
            if early_start < 0 or late_start < 0:
                continue
            early_highs = highs[early_start:early_end]
            early_lows = lows[early_start:early_end]
            late_highs = highs[late_start:t]
            late_lows = lows[late_start:t]
            if early_highs.size != half_length or early_lows.size != half_length or late_highs.size != half_length or (late_lows.size != half_length):
                continue
            if not all((np.all(np.isfinite(values)) for values in (early_highs, early_lows, late_highs, late_lows))):
                continue
            early_high = float(np.max(early_highs))
            early_low = float(np.min(early_lows))
            late_high = float(np.max(late_highs))
            late_low = float(np.min(late_lows))
            early_width = early_high - early_low
            late_width = late_high - late_low
            regression_pennant = upper_slope_atr <= -min_converging_slope and lower_slope_atr >= min_converging_slope and (end_ratio <= max_pennant_end_ratio)
            envelope_pennant = early_width > epsilon and late_width > epsilon and (late_high < early_high) and (late_low > early_low) and (late_width <= early_width * 0.88)
            if not (regression_pennant or envelope_pennant):
                continue
            pole_start = float(closes[pole_start_index])
            pole_end = float(closes[pattern_start])
            pole_move = pole_end - pole_start
            if not np.isfinite(pole_move) or pole_move >= 0.0:
                continue
            pole_size = abs(pole_move)
            pole_strength = pole_size / local_atr
            if pole_strength < min_pole_atr:
                continue
            pattern_range = float(np.max(pattern_highs) - np.min(pattern_lows))
            pattern_pole_ratio = pattern_range / pole_size if pole_size > epsilon else 100.0
            width_end_atr = width_end / local_atr
            if pattern_pole_ratio > max_pattern_pole_ratio or width_end_atr < min_end_width_atr:
                continue
            pole_volume = _finite_mean(volumes[pattern_start - 20:pattern_start])
            pattern_volume = _finite_mean(volumes[pattern_start:t])
            if not np.isfinite(pattern_volume):
                continue
            volume_ratio = pattern_volume / pole_volume if np.isfinite(pole_volume) and pole_volume > 0.0 else 1.0
            if not np.isfinite(volume_ratio):
                continue
            compression = max(0.0, min(1.0, 1.0 - end_ratio))
            pole_score = min(30.0, pole_strength / max(min_pole_atr, 0.01) * 20.0)
            geometry_score = min(30.0, compression * 45.0)
            compact_score = max(0.0, min(20.0, (max_pattern_pole_ratio - pattern_pole_ratio) / max(max_pattern_pole_ratio, 0.01) * 20.0))
            span_score = min(10.0, pattern_length / max_pattern_length * 10.0)
            volume_score = max(0.0, min(10.0, (1.3 - volume_ratio) * 20.0))
            quality = min(100.0, pole_score + geometry_score + compact_score + span_score + volume_score)
            rank = quality + pennant_priority_bonus
            if pattern_length >= macro_pattern_length:
                rank += macro_priority_bonus
            if rank > best_rank:
                best_rank = rank
                best_quality = quality
                best_lower_end = lower_end
                best_lower_slope = lower_slope
                best_bias = -1
        if best_bias == -1 and best_quality >= min_quality and np.isfinite(best_lower_end) and np.isfinite(best_lower_slope) and (t > 0) and np.isfinite(closes[t]) and np.isfinite(closes[t - 1]) and np.isfinite(atr[t]) and np.isfinite(atr[t - 1]):
            lower_now = best_lower_end + best_lower_slope
            short_breakout = closes[t] < lower_now - breakout_buffer_atr * atr[t]
            previous_not_broken = closes[t - 1] >= best_lower_end - breakout_buffer_atr * atr[t - 1]
            short_entries[t] = bool(short_breakout and previous_not_broken)
    params = dict(signal_params or {})
    params.setdefault('k_base', 2.0)
    params.setdefault('gamma', 1.0)
    params.setdefault('n_base', 2000.0)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'pennant_breakout_short', 'hypothesis': '下降 pole 後的收斂三角旗向下突破可延續下跌。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
