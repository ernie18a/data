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

def _is_confirmed_pivot(values, index, left=3, right=3):
    if index < left or index + right >= values.size:
        return False
    window = values[index - left:index + right + 1]
    center = values[index]
    return bool(np.isfinite(center) and np.all(np.isfinite(window)) and (center == np.max(window)))

def _append_pivot(types, bars, prices, pivot_type, pivot_bar, pivot_price):
    if types and types[-1] == pivot_type:
        replace = pivot_type == 1 and pivot_price > prices[-1] or (pivot_type == -1 and pivot_price < prices[-1])
        if replace:
            bars[-1] = pivot_bar
            prices[-1] = pivot_price
    else:
        types.append(pivot_type)
        bars.append(pivot_bar)
        prices.append(pivot_price)
    if len(types) > 20:
        del types[0]
        del bars[0]
        del prices[0]

def _line_value(x1, y1, x2, y2, x):
    return y1 + (y2 - y1) / max(x2 - x1, 1) * (x - x1)

def _clamp01(value):
    return max(0.0, min(1.0, value))

def _best_falling_wedge(types, bars, prices, atr):
    if len(types) < 4 or not np.isfinite(atr) or atr <= 0.0:
        return None
    best = None
    best_quality = -1.0
    first_index = max(0, len(types) - 10)
    count = len(types)
    for i in range(first_index, count - 3):
        for j in range(i + 1, count - 2):
            for k in range(j + 1, count - 1):
                for m in range(k + 1, count):
                    t1, t2, t3, t4 = (types[i], types[j], types[k], types[m])
                    if not (t1 != t2 and t2 != t3 and (t3 != t4) and (t1 == t3) and (t2 == t4)):
                        continue
                    x1, x2, x3, x4 = (bars[i], bars[j], bars[k], bars[m])
                    if not (x2 - x1 >= 3 and x3 - x2 >= 3 and (x4 - x3 >= 3)):
                        continue
                    if not (18 <= x4 - x1 <= 180 and count - 1 - m <= 2):
                        continue
                    y1, y2, y3, y4 = (prices[i], prices[j], prices[k], prices[m])
                    if t1 == 1:
                        upper_x1, upper_y1, upper_x2, upper_y2 = (x1, y1, x3, y3)
                        lower_x1, lower_y1, lower_x2, lower_y2 = (x2, y2, x4, y4)
                    else:
                        lower_x1, lower_y1, lower_x2, lower_y2 = (x1, y1, x3, y3)
                        upper_x1, upper_y1, upper_x2, upper_y2 = (x2, y2, x4, y4)
                    upper_slope = (upper_y2 - upper_y1) / max(upper_x2 - upper_x1, 1)
                    lower_slope = (lower_y2 - lower_y1) / max(lower_x2 - lower_x1, 1)
                    upper_slope_atr = upper_slope / atr
                    lower_slope_atr = lower_slope / atr
                    convergence_atr = lower_slope_atr - upper_slope_atr
                    upper_start = _line_value(upper_x1, upper_y1, upper_x2, upper_y2, x1)
                    lower_start = _line_value(lower_x1, lower_y1, lower_x2, lower_y2, x1)
                    upper_end = _line_value(upper_x1, upper_y1, upper_x2, upper_y2, x4)
                    lower_end = _line_value(lower_x1, lower_y1, lower_x2, lower_y2, x4)
                    width_start = upper_start - lower_start
                    width_end = upper_end - lower_end
                    end_ratio = width_end / width_start if width_start > 0.0 else np.inf
                    if not (upper_slope_atr <= -0.008 and lower_slope_atr <= -0.008 and (lower_slope_atr > upper_slope_atr) and (convergence_atr >= 0.012) and (width_start >= 1.1 * atr) and (width_end > 0.0) and (0.0 < end_ratio <= 0.82)):
                        continue
                    compression_score = _clamp01((0.82 - end_ratio) / (0.82 - 0.1))
                    slope_shape_score = _clamp01(convergence_atr / (0.012 * 4.0))
                    height_score = _clamp01(width_start / (1.1 * atr * 2.5))
                    span_score = _clamp01((x4 - x1) / (180.0 * 0.65))
                    tail_pivots = count - 1 - m
                    tail_score = _clamp01(1.0 - tail_pivots / 3.0)
                    closing_speed = lower_slope - upper_slope
                    apex_ahead = width_end / closing_speed if closing_speed > 0.0 else 280.0
                    apex_score = _clamp01(1.0 - apex_ahead / 140.0)
                    quality = min(100.0, compression_score * 27.0 + slope_shape_score * 25.0 + height_score * 16.0 + span_score * 12.0 + tail_score * 10.0 + apex_score * 10.0)
                    if quality > best_quality:
                        best_quality = quality
                        best = (upper_x1, upper_y1, upper_x2, upper_y2)
    return best if best_quality >= 72.0 else None

def generate_signals(features, signal_params):
    size = int(features.market.size)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    opens = np.asarray(features.market.opens, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    types = []
    bars = []
    prices = []
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    atr = np.asarray(features.atr(14), dtype=float)
    for t in range(size):
        pivot_bar = t - 3
        if pivot_bar >= 3:
            if _is_confirmed_pivot(highs, pivot_bar):
                _append_pivot(types, bars, prices, 1, pivot_bar, float(highs[pivot_bar]))
            if _is_confirmed_pivot(lows, pivot_bar):
                _append_pivot(types, bars, prices, -1, pivot_bar, float(lows[pivot_bar]))
        if t == 0 or not np.isfinite(atr[t]) or atr[t] <= 0.0:
            continue
        if not (np.isfinite(opens[t]) and np.isfinite(closes[t])):
            continue
        wedge = _best_falling_wedge(types, bars, prices, float(atr[t]))
        if wedge is None:
            continue
        upper_x1, upper_y1, upper_x2, upper_y2 = wedge
        upper_now = _line_value(upper_x1, upper_y1, upper_x2, upper_y2, t)
        upper_prev = _line_value(upper_x1, upper_y1, upper_x2, upper_y2, t - 1)
        previous_atr = atr[t - 1]
        if not np.isfinite(previous_atr) or previous_atr <= 0.0:
            continue
        bullish_body = closes[t] > opens[t] and abs(closes[t] - opens[t]) >= 0.15 * atr[t]
        crossed = closes[t] > upper_now + 0.06 * atr[t]
        previous_not_broken = closes[t - 1] <= upper_prev + 0.06 * previous_atr
        long_entries[t] = bool(bullish_body and crossed and previous_not_broken)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, {'k_base': float(signal_params.get('k_base', 2.0)), 'gamma': float(signal_params.get('gamma', 1.0)), 'n_base': float(signal_params.get('n_base', 2000.0))})
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'falling_wedge_breakout_long', 'hypothesis': '下降楔形向上突破具有多頭延續優勢。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
