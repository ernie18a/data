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
import numpy as np

def _add_confirmed_pivot(types, bars, prices, pivot_type, pivot_bar, pivot_price):
    if not types:
        types.append(pivot_type)
        bars.append(pivot_bar)
        prices.append(pivot_price)
    elif types[-1] == pivot_type:
        more_extreme = pivot_price > prices[-1] if pivot_type == 1 else pivot_price < prices[-1]
        if more_extreme:
            bars[-1] = pivot_bar
            prices[-1] = pivot_price
    else:
        types.append(pivot_type)
        bars.append(pivot_bar)
        prices.append(pivot_price)
    del types[:-20]
    del bars[:-20]
    del prices[:-20]

def _is_pivot(values, index, left, right, want_high):
    start = index - left
    end = index + right + 1
    window = values[start:end]
    value = values[index]
    if window.size != left + right + 1 or not np.all(np.isfinite(window)):
        return False
    if want_high:
        return bool(value == np.max(window))
    return bool(value == np.min(window))

def _line_value(x1, y1, x2, y2, x):
    return y1 + (y2 - y1) / max(x2 - x1, 1) * (x - x1)

def _clamp01(value):
    return max(0.0, min(1.0, value))

def _scan_rising_wedge(types, bars, prices, atr_value):
    if len(types) < 4 or not np.isfinite(atr_value) or atr_value <= 0.0:
        return None
    first_index = max(0, len(types) - 10)
    best = None
    best_rank = float('-inf')
    last_index = len(types)
    for i in range(first_index, last_index - 3):
        for j in range(i + 1, last_index - 2):
            for k in range(j + 1, last_index - 1):
                for m in range(k + 1, last_index):
                    t1, t2, t3, t4 = (types[i], types[j], types[k], types[m])
                    if not (t1 != t2 and t2 != t3 and (t3 != t4) and (t1 == t3) and (t2 == t4)):
                        continue
                    x1, x2, x3, x4 = (bars[i], bars[j], bars[k], bars[m])
                    if not (x2 - x1 >= 3 and x3 - x2 >= 3 and (x4 - x3 >= 3)):
                        continue
                    span = x4 - x1
                    tail_pivots = len(types) - 1 - m
                    if not (18 <= span <= 180 and tail_pivots <= 2):
                        continue
                    y1, y2, y3, y4 = (prices[i], prices[j], prices[k], prices[m])
                    if t1 == 1:
                        upper_x1, upper_y1 = (x1, y1)
                        lower_x1, lower_y1 = (x2, y2)
                        upper_x2, upper_y2 = (x3, y3)
                        lower_x2, lower_y2 = (x4, y4)
                    else:
                        lower_x1, lower_y1 = (x1, y1)
                        upper_x1, upper_y1 = (x2, y2)
                        lower_x2, lower_y2 = (x3, y3)
                        upper_x2, upper_y2 = (x4, y4)
                    upper_slope = (upper_y2 - upper_y1) / max(upper_x2 - upper_x1, 1)
                    lower_slope = (lower_y2 - lower_y1) / max(lower_x2 - lower_x1, 1)
                    upper_slope_atr = upper_slope / atr_value
                    lower_slope_atr = lower_slope / atr_value
                    convergence_atr = lower_slope_atr - upper_slope_atr
                    upper_at_start = _line_value(upper_x1, upper_y1, upper_x2, upper_y2, x1)
                    lower_at_start = _line_value(lower_x1, lower_y1, lower_x2, lower_y2, x1)
                    upper_at_end = _line_value(upper_x1, upper_y1, upper_x2, upper_y2, x4)
                    lower_at_end = _line_value(lower_x1, lower_y1, lower_x2, lower_y2, x4)
                    width_start = upper_at_start - lower_at_start
                    width_end = upper_at_end - lower_at_end
                    end_ratio = width_end / width_start if width_start > 1e-12 else 999.0
                    if not (width_start >= 1.1 * atr_value and width_end > 1e-12 and (end_ratio > 0.0) and (end_ratio <= 0.82) and (convergence_atr >= 0.012) and (upper_slope_atr >= 0.008) and (lower_slope_atr >= 0.008) and (lower_slope_atr > upper_slope_atr)):
                        continue
                    compression_score = _clamp01((0.82 - end_ratio) / 0.72)
                    slope_shape_score = _clamp01(convergence_atr / 0.048)
                    height_score = _clamp01(width_start / (1.1 * atr_value * 2.5))
                    span_score = _clamp01(span / (180.0 * 0.65))
                    tail_score = _clamp01(1.0 - tail_pivots / 3.0)
                    closing_speed = lower_slope - upper_slope
                    apex_ahead = width_end / closing_speed if closing_speed > 1e-12 else 280.0
                    apex_score = _clamp01(1.0 - apex_ahead / 140.0)
                    quality = min(100.0, compression_score * 27.0 + slope_shape_score * 25.0 + height_score * 16.0 + span_score * 12.0 + tail_score * 10.0 + apex_score * 10.0)
                    rank = quality
                    if rank > best_rank:
                        best_rank = rank
                        best = {'quality': quality, 'upper_x1': upper_x1, 'upper_y1': upper_y1, 'upper_x2': upper_x2, 'upper_y2': upper_y2, 'lower_x1': lower_x1, 'lower_y1': lower_y1, 'lower_x2': lower_x2, 'lower_y2': lower_y2, 'end_x': x4, 'span': span}
    return best

def _best_structure(micro, macro):
    if macro is not None and (micro is None or macro['quality'] + 6.0 >= micro['quality']):
        return macro
    return micro

def generate_signals(features, signal_params):
    import numpy as np
    size = int(features.market.size)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    opens = np.asarray(features.market.opens, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    atr = np.asarray(features.atr(14), dtype=np.float64)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    micro_types, micro_bars, micro_prices = ([], [], [])
    macro_types, macro_bars, macro_prices = ([], [], [])
    for t in range(size):
        micro_right = 3
        micro_pivot = t - micro_right
        if micro_pivot >= 3 and micro_pivot + micro_right < size:
            if _is_pivot(highs, micro_pivot, 3, micro_right, True):
                _add_confirmed_pivot(micro_types, micro_bars, micro_prices, 1, micro_pivot, float(highs[micro_pivot]))
            if _is_pivot(lows, micro_pivot, 3, micro_right, False):
                _add_confirmed_pivot(micro_types, micro_bars, micro_prices, -1, micro_pivot, float(lows[micro_pivot]))
        macro_right = 7
        macro_pivot = t - macro_right
        if macro_pivot >= 7 and macro_pivot + macro_right < size:
            if _is_pivot(highs, macro_pivot, 7, macro_right, True):
                _add_confirmed_pivot(macro_types, macro_bars, macro_prices, 1, macro_pivot, float(highs[macro_pivot]))
            if _is_pivot(lows, macro_pivot, 7, macro_right, False):
                _add_confirmed_pivot(macro_types, macro_bars, macro_prices, -1, macro_pivot, float(lows[macro_pivot]))
        current_atr = float(atr[t]) if t < atr.size else float('nan')
        if t <= 0 or not np.isfinite(current_atr) or current_atr <= 0.0 or (not np.isfinite(closes[t])) or (not np.isfinite(closes[t - 1])) or (not np.isfinite(opens[t])):
            continue
        micro = _scan_rising_wedge(micro_types, micro_bars, micro_prices, current_atr)
        macro = _scan_rising_wedge(macro_types, macro_bars, macro_prices, current_atr)
        structure = _best_structure(micro, macro)
        if structure is None or structure['quality'] < 72.0:
            continue
        if t - structure['end_x'] < 0 or t - structure['end_x'] > min(220, max(12, round(structure['span'] * 1.8))):
            continue
        lower_now = _line_value(structure['lower_x1'], structure['lower_y1'], structure['lower_x2'], structure['lower_y2'], t)
        lower_prev = _line_value(structure['lower_x1'], structure['lower_y1'], structure['lower_x2'], structure['lower_y2'], t - 1)
        previous_atr = float(atr[t - 1])
        if not np.isfinite(previous_atr) or previous_atr <= 0.0:
            continue
        body_ok = closes[t] < opens[t] and abs(closes[t] - opens[t]) >= 0.15 * current_atr
        crossed = closes[t] < lower_now - 0.06 * current_atr
        previous_not_broken = closes[t - 1] >= lower_prev - 0.06 * previous_atr
        short_entries[t] = bool(body_ok and crossed and previous_not_broken)
    params = dict(signal_params or {})
    params.setdefault('k_base', 2.0)
    params.setdefault('gamma', 1.0)
    params.setdefault('n_base', 2000.0)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'rising_wedge_breakout_short', 'hypothesis': '上升楔形跌破下軌後，價格可能延續下行。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
