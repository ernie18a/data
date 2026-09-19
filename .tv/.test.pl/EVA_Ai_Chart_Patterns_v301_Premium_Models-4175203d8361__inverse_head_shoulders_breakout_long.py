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

def _value(signal_params, name, default):
    return float(signal_params.get(name, default))

def _clamp01(value):
    return max(0.0, min(1.0, float(value)))

def _time_quality(ratio, maximum):
    if maximum <= 1.0:
        return 1.0 if ratio <= 1.0 else 0.0
    return _clamp01(1.0 - (ratio - 1.0) / (maximum - 1.0))

def _add_pivot(types, bars, prices, kind, bar, price):
    if not types:
        types.append(kind)
        bars.append(bar)
        prices.append(price)
        return True
    if types[-1] == kind:
        replace = kind == 1 and price > prices[-1] or (kind == -1 and price < prices[-1])
        if replace:
            bars[-1] = bar
            prices[-1] = price
            return True
        return False
    types.append(kind)
    bars.append(bar)
    prices.append(price)
    if len(types) > 20:
        del types[0]
        del bars[0]
        del prices[0]
    return True

def _inverse_candidate(types, bars, prices, atr, params):
    if len(types) < 6 or types[-5:] != [-1, 1, -1, 1, -1]:
        return None
    x1, x2, x3, x4, x5 = bars[-5:]
    y1, y2, y3, y4, y5 = prices[-5:]
    context_type = types[-6]
    context_price = prices[-6]
    atr_entry = float(atr[x5])
    if not np.isfinite(atr_entry) or atr_entry <= 0.0:
        return None
    gaps = (x2 - x1, x3 - x2, x4 - x3, x5 - x4)
    span = x5 - x1
    if min(gaps) < params['min_pivot_gap'] or span < params['min_span'] or span > params['max_span']:
        return None
    neckline_slope = (y4 - y2) / max(x4 - x2, 1)
    neckline_slope_atr = abs(neckline_slope) / atr_entry
    if neckline_slope_atr > params['max_neckline_slope_atr']:
        return None
    left_span = x3 - x1
    right_span = x5 - x3
    time_ratio = max(left_span, right_span) / max(min(left_span, right_span), 1.0)
    if time_ratio > params['max_shoulder_time_ratio']:
        return None
    context_move = context_price - y1 if context_type == 1 else 0.0
    if context_move < params['min_approach_atr'] * atr_entry:
        return None
    shoulder_depth = min(y2, y4) - max(y1, y5)
    head_height = (y2 + y4) * 0.5 - y3
    head_prominence = min(y1, y5) - y3
    shoulder_difference = abs(y1 - y5)
    shoulder_tolerance = params['shoulder_tolerance_atr'] * atr_entry
    if shoulder_depth < params['min_shoulder_depth_atr'] * atr_entry:
        return None
    if shoulder_difference > shoulder_tolerance:
        return None
    if head_prominence < params['min_head_height_atr'] * atr_entry:
        return None
    min_head_ratio = params['min_head_height_atr'] / max(params['min_head_height_atr'] + 1.0, 1.0)
    head_ratio = head_prominence / head_height if head_height > 0.0 else 0.0
    quality = min(100.0, _clamp01(1.0 - shoulder_difference / shoulder_tolerance) * 20.0 + _clamp01(head_ratio / max(min_head_ratio * 1.8, 1e-12)) * 22.0 + _clamp01(1.0 - neckline_slope_atr / max(params['max_neckline_slope_atr'], 1e-12)) * 13.0 + _time_quality(time_ratio, params['max_shoulder_time_ratio']) * 14.0 + _clamp01(shoulder_depth / (params['min_shoulder_depth_atr'] * atr_entry * 1.8)) * 10.0 + _clamp01(context_move / (params['min_approach_atr'] * atr_entry * 1.8)) * 10.0 + 6.0 + _clamp01(span / params['max_span']) * 5.0)
    if quality < params['min_quality']:
        return None
    return {'x1': x1, 'x5': x5, 'y1': y1, 'y2': y2, 'y3': y3, 'y4': y4, 'y5': y5, 'quality': quality}

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    atr = np.asarray(features.atr(14), dtype=float).reshape(-1)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    params = {'min_pivot_gap': int(_value(signal_params, 'min_pivot_gap', 2)), 'min_span': int(_value(signal_params, 'min_span', 8)), 'max_span': int(_value(signal_params, 'max_span', 140)), 'max_neckline_slope_atr': _value(signal_params, 'max_neckline_slope_atr', 0.2), 'max_shoulder_time_ratio': _value(signal_params, 'max_shoulder_time_ratio', 2.0), 'min_approach_atr': _value(signal_params, 'min_approach_atr', 0.75), 'shoulder_tolerance_atr': _value(signal_params, 'shoulder_tolerance_atr', 0.6), 'min_shoulder_depth_atr': _value(signal_params, 'min_shoulder_depth_atr', 0.35), 'min_head_height_atr': _value(signal_params, 'min_head_height_atr', 0.7), 'min_quality': _value(signal_params, 'min_quality', 68.0)}
    left = int(_value(signal_params, 'pivot_left', 3))
    right = int(_value(signal_params, 'pivot_right', 3))
    breakout_buffer = _value(signal_params, 'breakout_buffer_atr', 0.05)
    breakout_body = _value(signal_params, 'min_breakout_body_atr', 0.18)
    bars_after_shoulder = int(_value(signal_params, 'min_bars_after_shoulder', 3))
    replace_margin = _value(signal_params, 'reversal_replace_margin', 3.0)
    lifetime_factor = _value(signal_params, 'micro_lifetime_factor', 1.0)
    min_lifetime = int(_value(signal_params, 'min_lifetime', 12))
    max_lifetime = int(_value(signal_params, 'max_lifetime', 220))
    pivot_types = []
    pivot_bars = []
    pivot_prices = []
    pending = None
    last_pattern_x5 = None
    for t in range(left + right, size):
        pivot = t - right
        start = pivot - left
        end = pivot + right + 1
        high_window = highs[start:end]
        low_window = lows[start:end]
        new_pivot = False
        if np.all(np.isfinite(high_window)) and highs[pivot] >= np.max(high_window):
            new_pivot = _add_pivot(pivot_types, pivot_bars, pivot_prices, 1, pivot, highs[pivot]) or new_pivot
        if np.all(np.isfinite(low_window)) and lows[pivot] <= np.min(low_window):
            new_pivot = _add_pivot(pivot_types, pivot_bars, pivot_prices, -1, pivot, lows[pivot]) or new_pivot
        if new_pivot:
            candidate = _inverse_candidate(pivot_types, pivot_bars, pivot_prices, atr, params)
            if candidate is not None and candidate['x5'] != last_pattern_x5:
                if pending is None or candidate['quality'] > pending['quality'] + replace_margin or (candidate['x5'] == pending['x5'] and candidate['quality'] > pending['quality']):
                    pending = candidate
        if pending is None:
            continue
        if not np.isfinite(atr[t]) or atr[t] <= 0.0:
            continue
        lifetime = max(min_lifetime, min(max_lifetime, int(round((pending['x5'] - pending['x1']) * lifetime_factor))))
        if t - pending['x5'] > lifetime or lows[t] < pending['y3'] - params['shoulder_tolerance_atr'] * atr[t]:
            pending = None
            continue
        if t == 0 or not np.isfinite(closes[t - 1]) or (not np.isfinite(atr[t - 1])):
            continue
        neckline = pending['y2'] + (pending['y4'] - pending['y2']) / max(pending['x4'] - pending['x2'], 1) * (t - pending['x2'])
        previous_neckline = pending['y2'] + (pending['y4'] - pending['y2']) / max(pending['x4'] - pending['x2'], 1) * (t - 1 - pending['x2'])
        breakout_level = neckline + breakout_buffer * atr[t]
        previous_breakout_level = previous_neckline + breakout_buffer * atr[t - 1]
        ready = t >= pending['x5'] + right + bars_after_shoulder
        body_ok = np.isfinite(opens[t]) and abs(closes[t] - opens[t]) >= breakout_body * atr[t]
        if ready and closes[t] > breakout_level and (closes[t - 1] <= previous_breakout_level) and (closes[t] > opens[t]) and body_ok:
            long_entries[t] = True
            last_pattern_x5 = pending['x5']
            pending = None
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'inverse_head_shoulders_breakout_long', 'hypothesis': '下跌後的反頭肩形態完成並突破頸線，可能形成多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['pivot_left', 'pivot_right', 'min_pivot_gap', 'min_span', 'max_span', 'max_neckline_slope_atr', 'max_shoulder_time_ratio', 'min_approach_atr', 'shoulder_tolerance_atr', 'min_shoulder_depth_atr', 'min_head_height_atr', 'min_quality', 'breakout_buffer_atr', 'min_breakout_body_atr', 'min_bars_after_shoulder', 'reversal_replace_margin', 'micro_lifetime_factor', 'min_lifetime', 'max_lifetime', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'pivot_left': 3, 'pivot_right': 3, 'min_pivot_gap': 2, 'min_span': 8, 'max_span': 140, 'max_neckline_slope_atr': 0.2, 'max_shoulder_time_ratio': 2.0, 'min_approach_atr': 0.75, 'shoulder_tolerance_atr': 0.6, 'min_shoulder_depth_atr': 0.35, 'min_head_height_atr': 0.7, 'min_quality': 68.0, 'breakout_buffer_atr': 0.05, 'min_breakout_body_atr': 0.18, 'min_bars_after_shoulder': 3, 'reversal_replace_margin': 3.0, 'micro_lifetime_factor': 1.0, 'min_lifetime': 12, 'max_lifetime': 220, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
