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

def _series(market, *names):
    for name in names:
        value = getattr(market, name, None)
        if value is not None:
            return np.asarray(value, dtype=float).reshape(-1)
    raise AttributeError(f'missing market series: {names}')

def _is_pivot(values, index, left, right):
    if index - left < 0 or index + right >= values.size:
        return False
    window = values[index - left:index + right + 1]
    if not np.isfinite(window).all():
        return False
    return bool(np.argmax(window) == left)

def _is_pivot_low(values, index, left, right):
    if index - left < 0 or index + right >= values.size:
        return False
    window = values[index - left:index + right + 1]
    if not np.isfinite(window).all():
        return False
    return bool(np.argmin(window) == left)

def _add_pivot(pivots, kind, index, price):
    if pivots and pivots[-1][0] == kind:
        stronger = kind == 1 and price > pivots[-1][2] or (kind == -1 and price < pivots[-1][2])
        if stronger:
            pivots[-1] = (kind, index, price)
            return True
        return False
    pivots.append((kind, index, price))
    if len(pivots) > 20:
        del pivots[:-20]
    return True

def _clamp(value):
    return max(0.0, min(1.0, value))

def _quality(shoulder_difference, head_prominence, head_height, neckline_slope_atr, time_ratio, shoulder_depth, context_move, span, atr):
    allowed_shoulder_difference = 0.6 * atr
    minimum_shoulder_depth = 0.35 * atr
    minimum_context_move = 0.75 * atr
    minimum_head_ratio = 0.7 / 1.7
    shoulder_score = _clamp(1.0 - shoulder_difference / allowed_shoulder_difference)
    head_ratio = head_prominence / head_height if head_height > 0.0 else 0.0
    head_score = _clamp(head_ratio / (minimum_head_ratio * 1.8))
    neckline_score = _clamp(1.0 - neckline_slope_atr / 0.2)
    time_score = _clamp(1.0 - (time_ratio - 1.0) / (2.0 - 1.0))
    depth_score = _clamp(shoulder_depth / (minimum_shoulder_depth * 1.8))
    context_score = _clamp(context_move / (minimum_context_move * 1.8))
    span_score = _clamp(span / 140.0)
    return min(100.0, shoulder_score * 20.0 + head_score * 22.0 + neckline_score * 13.0 + time_score * 14.0 + depth_score * 10.0 + context_score * 10.0 + 6.0 + span_score * 5.0)

def _make_candidate(pivots, reversal_atr):
    if len(pivots) < 6 or not np.isfinite(reversal_atr) or reversal_atr <= 0.0:
        return None
    points = pivots[-5:]
    if [point[0] for point in points] != [1, -1, 1, -1, 1]:
        return None
    (_, x1, y1), (_, x2, y2), (_, x3, y3), (_, x4, y4), (_, x5, y5) = points
    gaps = (x2 - x1, x3 - x2, x4 - x3, x5 - x4)
    span = x5 - x1
    if min(gaps) < 2 or span < 8 or span > 140:
        return None
    context_type, _, context_price = pivots[-6]
    if context_type != -1:
        return None
    context_move = y1 - context_price
    if context_move < 0.75 * reversal_atr:
        return None
    neckline_slope = (y4 - y2) / max(x4 - x2, 1)
    neckline_slope_atr = abs(neckline_slope) / reversal_atr
    shoulder_time_ratio = max(x3 - x1, x5 - x3) / max(min(x3 - x1, x5 - x3), 1)
    shoulder_depth = min(y1, y5) - max(y2, y4)
    neckline_average = (y2 + y4) * 0.5
    head_height = y3 - neckline_average
    head_prominence = y3 - max(y1, y5)
    shoulder_difference = abs(y1 - y5)
    if neckline_slope_atr > 0.2:
        return None
    if shoulder_time_ratio > 2.0:
        return None
    if shoulder_difference > 0.6 * reversal_atr:
        return None
    if shoulder_depth < 0.35 * reversal_atr:
        return None
    if head_prominence < 0.7 * reversal_atr or head_height <= 0.0:
        return None
    quality = _quality(shoulder_difference, head_prominence, head_height, neckline_slope_atr, shoulder_time_ratio, shoulder_depth, context_move, span, reversal_atr)
    if quality < 68.0:
        return None
    return {'x2': x2, 'y2': y2, 'x4': x4, 'y4': y4, 'x5': x5, 'y3': y3, 'quality': quality}

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    highs = _series(market, 'highs', 'high')
    lows = _series(market, 'lows', 'low')
    opens = _series(market, 'opens', 'open')
    closes = _series(market, 'closes', 'close')
    atr = np.asarray(features.atr(14), dtype=float).reshape(-1)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    pivots = []
    pending = None
    left = 3
    right = 3
    for t in range(size):
        pivot_index = t - right
        changed = False
        if _is_pivot(highs, pivot_index, left, right):
            changed = _add_pivot(pivots, 1, pivot_index, highs[pivot_index]) or changed
        if _is_pivot_low(lows, pivot_index, left, right):
            changed = _add_pivot(pivots, -1, pivot_index, lows[pivot_index]) or changed
        if changed:
            pending = _make_candidate(pivots, atr[pivot_index])
        if pending is None:
            continue
        current_atr = atr[t]
        invalidated = np.isfinite(current_atr) and current_atr > 0.0 and np.isfinite(highs[t]) and (highs[t] > pending['y3'] + 0.6 * current_atr)
        expired = t > pending['x5'] + 140
        confirmed_after_shoulder = t >= pending['x5'] + right + 3
        if confirmed_after_shoulder and t > 0:
            previous_atr = atr[t - 1]
            values_finite = np.isfinite([current_atr, previous_atr, opens[t], closes[t], closes[t - 1]]).all()
            if values_finite and current_atr > 0.0 and (previous_atr > 0.0):
                neckline = pending['y2'] + (pending['y4'] - pending['y2']) / max(pending['x4'] - pending['x2'], 1) * (t - pending['x2'])
                previous_neckline = pending['y2'] + (pending['y4'] - pending['y2']) / max(pending['x4'] - pending['x2'], 1) * (t - 1 - pending['x2'])
                break_level = neckline - 0.05 * current_atr
                previous_break_level = previous_neckline - 0.05 * previous_atr
                breakout = closes[t] < break_level and closes[t - 1] >= previous_break_level and (closes[t] < opens[t]) and (abs(closes[t] - opens[t]) >= 0.18 * current_atr)
                if breakout:
                    short_entries[t] = True
                    pending = None
                    continue
        if invalidated or expired:
            pending = None
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'head_shoulders_breakout_short', 'hypothesis': 'A confirmed head-and-shoulders neckline breakdown anticipates a bearish reversal.', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
