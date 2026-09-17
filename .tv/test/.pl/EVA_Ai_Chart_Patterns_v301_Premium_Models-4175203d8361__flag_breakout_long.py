from __future__ import annotations
import numpy as np

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
    length = values.size
    x = np.arange(length, dtype=float)
    x_mean = (length - 1) / 2.0
    centered_x = x - x_mean
    denominator = float(np.dot(centered_x, centered_x))
    slope = float(np.dot(centered_x, values - float(np.mean(values))) / denominator)
    intercept = float(np.mean(values) - slope * x_mean)
    return (intercept, intercept + slope * (length - 1))

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    volumes = np.asarray(features.market.volumes, dtype=float)
    atr = np.asarray(features.atr(14), dtype=float)
    pole_len = 14
    min_pole_atr = 1.0
    max_pattern_pole_ratio = 1.35
    max_flag_slope = 0.18
    max_slope_difference = 0.1
    min_end_width_atr = 0.05
    breakout_buffer_atr = 0.05
    min_quality = 65.0
    max_pattern_len = 80
    breakout_volume_len = 20
    for t in range(size):
        best_quality = -1.0
        best_upper_end = np.nan
        best_upper_slope = np.nan
        for pattern_len in range(12, 81, 4):
            if t < pattern_len + pole_len + breakout_volume_len + 5:
                continue
            local_atr = atr[t - pattern_len]
            if not np.isfinite(local_atr) or local_atr <= 0.0:
                continue
            pattern_highs = highs[t - pattern_len:t]
            pattern_lows = lows[t - pattern_len:t]
            pattern_volumes = volumes[t - pattern_len:t]
            pole_volumes = volumes[t - pattern_len - pole_len:t - pattern_len]
            if not (np.all(np.isfinite(pattern_highs)) and np.all(np.isfinite(pattern_lows)) and np.all(np.isfinite(pattern_volumes)) and np.all(np.isfinite(pole_volumes))):
                continue
            upper_start, upper_end = _linreg_endpoints(pattern_highs)
            lower_start, lower_end = _linreg_endpoints(pattern_lows)
            divisor = float(max(pattern_len - 1, 1))
            upper_slope = (upper_end - upper_start) / divisor
            lower_slope = (lower_end - lower_start) / divisor
            upper_slope_atr = upper_slope / local_atr
            lower_slope_atr = lower_slope / local_atr
            width_start = upper_start - lower_start
            width_end = upper_end - lower_end
            width_end_atr = width_end / local_atr
            pattern_range = float(np.max(pattern_highs) - np.min(pattern_lows))
            pole_start = t - pattern_len - pole_len
            pole_end = t - pattern_len
            pole_move = closes[pole_end] - closes[pole_start]
            pole_size = abs(float(pole_move))
            pole_strength = pole_size / local_atr
            if pole_move <= 0.0:
                continue
            pattern_pole_ratio = pattern_range / pole_size if pole_size > 1e-12 else 100.0
            pole_volume_mean = float(np.mean(pole_volumes))
            pattern_volume_mean = float(np.mean(pattern_volumes))
            volume_ratio = pattern_volume_mean / pole_volume_mean if pole_volume_mean > 0.0 else 1.0
            flag_shape = -max_flag_slope <= upper_slope_atr <= 0.05 and -max_flag_slope <= lower_slope_atr <= 0.05 and (abs(upper_slope_atr - lower_slope_atr) <= max_slope_difference)
            base_valid = flag_shape and pole_strength >= min_pole_atr and (pattern_pole_ratio <= max_pattern_pole_ratio) and (width_end_atr >= min_end_width_atr)
            if not base_valid:
                continue
            end_ratio = width_end / width_start if width_start > 1e-12 else 10.0
            pole_score = min(30.0, pole_strength / max(min_pole_atr, 0.01) * 20.0)
            geometry_score = max(0.0, min(30.0, (max_slope_difference - abs(upper_slope_atr - lower_slope_atr)) / max(max_slope_difference, 0.001) * 30.0))
            compact_score = max(0.0, min(20.0, (max_pattern_pole_ratio - pattern_pole_ratio) / max(max_pattern_pole_ratio, 0.01) * 20.0))
            span_score = min(10.0, pattern_len / max(max_pattern_len, 1) * 10.0)
            volume_score = max(0.0, min(10.0, (1.3 - volume_ratio) * 20.0))
            quality = min(100.0, pole_score + geometry_score + compact_score + span_score + volume_score)
            if quality > best_quality:
                best_quality = quality
                best_upper_end = upper_end
                best_upper_slope = upper_slope
        if best_quality < min_quality:
            continue
        if not (np.isfinite(closes[t]) and np.isfinite(atr[t]) and (atr[t] > 0.0)):
            continue
        upper_now = best_upper_end + best_upper_slope
        long_entries[t] = closes[t] > upper_now + breakout_buffer_atr * atr[t] and t > 0 and np.isfinite(closes[t - 1]) and np.isfinite(atr[t - 1]) and (closes[t - 1] <= best_upper_end + breakout_buffer_atr * atr[t - 1])
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries.astype(np.bool_, copy=False), np.asarray(long_exits, dtype=np.bool_), short_entries.astype(np.bool_, copy=False), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'flag_breakout_long', 'hypothesis': '上升旗形整理後的收盤突破上軌，延續前置上漲波段並做多。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
