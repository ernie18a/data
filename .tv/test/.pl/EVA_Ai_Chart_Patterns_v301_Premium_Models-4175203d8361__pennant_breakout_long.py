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
_CANDIDATE_LENGTHS = tuple(range(12, 81, 4))
_POLE_LENGTH = 14
_ATR_LENGTH = 14
_MIN_POLE_ATR = 1.0
_MAX_PENNANT_POLE_RATIO = 2.4
_MIN_CONVERGING_SLOPE = 0.01
_MAX_PENNANT_END_RATIO = 0.78
_MIN_END_WIDTH_ATR = 0.05
_BREAKOUT_BUFFER_ATR = 0.05
_MIN_CONFIRMED_QUALITY = 65.0
_PENNANT_PRIORITY_BONUS = 12.0
_MACRO_PRIORITY_BONUS = 8.0
_MACRO_PATTERN_LENGTH = 36

def _linreg_endpoints(values):
    values = np.asarray(values, dtype=float)
    if values.ndim != 1 or values.size < 2 or (not np.all(np.isfinite(values))):
        return None
    x = np.arange(values.size, dtype=float)
    xc = x - x.mean()
    yc = values - values.mean()
    slope = float(np.dot(xc, yc) / np.dot(xc, xc))
    start = float(values.mean() - slope * x.mean())
    end = float(start + slope * (values.size - 1))
    return (start, end, slope)

def _evaluate_pennant(t, length, highs, lows, closes, volumes, atr):
    if t < length + _POLE_LENGTH:
        return None
    local_atr = float(atr[t - length])
    if not np.isfinite(local_atr) or local_atr <= 0.0:
        return None
    upper = _linreg_endpoints(highs[t - length:t])
    lower = _linreg_endpoints(lows[t - length:t])
    if upper is None or lower is None:
        return None
    upper_start, upper_end, upper_slope = upper
    lower_start, lower_end, lower_slope = lower
    width_start = upper_start - lower_start
    width_end = upper_end - lower_end
    upper_slope_atr = upper_slope / local_atr
    lower_slope_atr = lower_slope / local_atr
    pattern_range = float(np.max(highs[t - length:t]) - np.min(lows[t - length:t]))
    pole_start = float(closes[t - length - _POLE_LENGTH])
    pole_end = float(closes[t - length])
    pole_move = pole_end - pole_start
    pole_size = abs(pole_move)
    if not np.isfinite(pole_size):
        return None
    bias = 1 if pole_move > 0.0 else -1 if pole_move < 0.0 else 0
    pattern_pole_ratio = pattern_range / pole_size if pole_size > np.finfo(float).eps else np.inf
    half_length = max(length // 2, 3)
    early_highs = highs[t - 2 * half_length:t - half_length]
    early_lows = lows[t - 2 * half_length:t - half_length]
    late_highs = highs[t - half_length:t]
    late_lows = lows[t - half_length:t]
    if not all((values.size == half_length and np.all(np.isfinite(values)) for values in (early_highs, early_lows, late_highs, late_lows))):
        return None
    early_high = float(np.max(early_highs))
    early_low = float(np.min(early_lows))
    late_high = float(np.max(late_highs))
    late_low = float(np.min(late_lows))
    early_width = early_high - early_low
    late_width = late_high - late_low
    regression_pennant = upper_slope_atr <= -_MIN_CONVERGING_SLOPE and lower_slope_atr >= _MIN_CONVERGING_SLOPE and (width_start > 0.0) and (width_end > 0.0) and (width_end / width_start <= _MAX_PENNANT_END_RATIO)
    envelope_pennant = early_width > np.finfo(float).eps and late_width > np.finfo(float).eps and (late_high < early_high) and (late_low > early_low) and (late_width <= early_width * 0.88)
    if not (regression_pennant or envelope_pennant):
        return None
    if pole_size / local_atr < _MIN_POLE_ATR:
        return None
    if not np.isfinite(pattern_pole_ratio) or pattern_pole_ratio > _MAX_PENNANT_POLE_RATIO:
        return None
    if width_end / local_atr < _MIN_END_WIDTH_ATR:
        return None
    pole_volume_window = volumes[t - length - _POLE_LENGTH:t - length]
    pattern_volume_window = volumes[t - length:t]
    if not np.all(np.isfinite(pole_volume_window)) or not np.all(np.isfinite(pattern_volume_window)):
        return None
    pole_volume = float(np.mean(pole_volume_window))
    pattern_volume = float(np.mean(pattern_volume_window))
    volume_ratio = pattern_volume / pole_volume if pole_volume > 0.0 else 1.0
    compression = max(0.0, min(1.0, 1.0 - width_end / width_start)) if width_start > 0.0 else 0.0
    pole_score = min(30.0, pole_size / local_atr / max(_MIN_POLE_ATR, 0.01) * 20.0)
    geometry_score = min(30.0, compression * 45.0)
    compact_score = max(0.0, min(20.0, (_MAX_PENNANT_POLE_RATIO - pattern_pole_ratio) / max(_MAX_PENNANT_POLE_RATIO, 0.01) * 20.0))
    span_score = min(10.0, length / 80.0 * 10.0)
    volume_score = max(0.0, min(10.0, (1.3 - volume_ratio) * 20.0))
    quality = min(100.0, pole_score + geometry_score + compact_score + span_score + volume_score)
    rank = quality + _PENNANT_PRIORITY_BONUS
    if length >= _MACRO_PATTERN_LENGTH:
        rank += _MACRO_PRIORITY_BONUS
    return (rank, quality, bias, upper_end, upper_slope)

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    volumes = np.asarray(features.market.volumes, dtype=float).reshape(-1)
    atr = np.asarray(features.atr(_ATR_LENGTH), dtype=float).reshape(-1)
    for t in range(size):
        best = None
        for length in _CANDIDATE_LENGTHS:
            candidate = _evaluate_pennant(t, length, highs, lows, closes, volumes, atr)
            if candidate is not None and (best is None or candidate[0] > best[0]):
                best = candidate
        if best is None or best[1] < _MIN_CONFIRMED_QUALITY or best[2] != 1:
            continue
        current_atr = float(atr[t])
        previous_atr = float(atr[t - 1]) if t > 0 else np.nan
        current_close = float(closes[t])
        previous_close = float(closes[t - 1]) if t > 0 else np.nan
        if not all((np.isfinite(value) for value in (current_atr, previous_atr, current_close, previous_close, best[3], best[4]))):
            continue
        upper_now = best[3] + best[4]
        long_entries[t] = current_close > upper_now + _BREAKOUT_BUFFER_ATR * current_atr and previous_close <= best[3] + _BREAKOUT_BUFFER_ATR * previous_atr
    params = {} if signal_params is None else signal_params
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'pennant_breakout_long', 'hypothesis': '多頭 pole 後的 pennant 收斂突破具有延續上行動能。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
