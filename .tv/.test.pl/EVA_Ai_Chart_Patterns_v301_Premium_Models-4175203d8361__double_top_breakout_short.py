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
_PIVOT_LEFT = 3
_PIVOT_RIGHT = 3
_MIN_PIVOT_GAP = 2
_MIN_SPAN = 8
_MAX_SPAN = 140
_DOUBLE_TOLERANCE_ATR = 0.45
_MIN_DEPTH_ATR = 0.75
_MIN_CONTEXT_MOVE_ATR = 0.75
_MAX_TIME_RATIO = 2.2
_BREAKOUT_BUFFER_ATR = 0.05
_MIN_BREAKOUT_BODY_ATR = 0.18
_MIN_CONFIRMED_QUALITY = 68.0

def _market_field(market, *names):
    for name in names:
        if isinstance(market, dict):
            value = market.get(name)
        else:
            value = getattr(market, name, None)
        if value is not None:
            return np.asarray(value, dtype=float).reshape(-1)
    raise AttributeError(f'market field not found: {names}')

def _series(value, size):
    array = np.asarray(value, dtype=float).reshape(-1)
    if array.size == 1:
        return np.full(size, float(array[0]), dtype=float)
    if array.size != size:
        raise ValueError('feature series length does not match market.size')
    return array

def _clamp01(value):
    return float(max(0.0, min(1.0, value)))

def _time_quality(ratio, maximum_ratio):
    if maximum_ratio <= 1.0:
        return 1.0 if ratio <= 1.0 else 0.0
    return _clamp01(1.0 - (ratio - 1.0) / (maximum_ratio - 1.0))

def _double_quality(extremum_difference, allowed_difference, depth, minimum_depth, time_ratio, context_move, minimum_context_move, span):
    equality_score = _clamp01(1.0 - extremum_difference / allowed_difference) if allowed_difference > 0.0 else 0.0
    depth_score = _clamp01(depth / (minimum_depth * 1.8)) if minimum_depth > 0.0 else 0.0
    context_score = _clamp01(context_move / (minimum_context_move * 1.8)) if minimum_context_move > 0.0 else 1.0
    span_score = _clamp01(span / _MAX_SPAN)
    return min(100.0, equality_score * 25.0 + depth_score * 25.0 + _time_quality(time_ratio, _MAX_TIME_RATIO) * 15.0 + context_score * 15.0 + 10.0 + span_score * 10.0)

def _confirmed_pivot(values, center, left, right, high_pivot):
    start = center - left
    end = center + right + 1
    if start < 0 or end > values.size:
        return None
    window = values[start:end]
    value = values[center]
    if not np.isfinite(window).all():
        return None
    extreme = np.max(window) if high_pivot else np.min(window)
    if value == extreme:
        return float(value)
    return None

def _update_pivots(types, bars, prices, pivot_type, pivot_bar, pivot_price):
    if not np.isfinite(pivot_price):
        return False
    if not types:
        types.append(pivot_type)
        bars.append(pivot_bar)
        prices.append(pivot_price)
        return True
    last = len(types) - 1
    if types[last] == pivot_type:
        replace = pivot_price > prices[last] if pivot_type == 1 else pivot_price < prices[last]
        if replace:
            bars[last] = pivot_bar
            prices[last] = pivot_price
            return True
        return False
    types.append(pivot_type)
    bars.append(pivot_bar)
    prices.append(pivot_price)
    if len(types) > 20:
        del types[0]
        del bars[0]
        del prices[0]
    return True

def _double_top_candidate(types, bars, prices, atr_at_x3):
    if len(types) < 4 or not np.isfinite(atr_at_x3) or atr_at_x3 <= 0.0:
        return None
    t1, t2, t3 = types[-3:]
    x1, x2, x3 = bars[-3:]
    y1, y2, y3 = prices[-3:]
    if (t1, t2, t3) != (1, -1, 1):
        return None
    if x2 - x1 < _MIN_PIVOT_GAP or x3 - x2 < _MIN_PIVOT_GAP or x3 - x1 < _MIN_SPAN or (x3 - x1 > _MAX_SPAN) or (types[-4] != -1):
        return None
    context_move = y1 - prices[-4]
    tolerance = _DOUBLE_TOLERANCE_ATR * atr_at_x3
    minimum_depth = _MIN_DEPTH_ATR * atr_at_x3
    depth = min(y1, y3) - y2
    if context_move < _MIN_CONTEXT_MOVE_ATR * atr_at_x3:
        return None
    if abs(y1 - y3) > tolerance or depth < minimum_depth:
        return None
    left_span = x2 - x1
    right_span = x3 - x2
    time_ratio = max(left_span, right_span) / max(min(left_span, right_span), 1.0)
    if time_ratio > _MAX_TIME_RATIO:
        return None
    quality = _double_quality(abs(y1 - y3), tolerance, depth, minimum_depth, time_ratio, context_move, _MIN_CONTEXT_MOVE_ATR * atr_at_x3, x3 - x1)
    if quality < _MIN_CONFIRMED_QUALITY:
        return None
    return {'x1': x1, 'x2': x2, 'x3': x3, 'y1': y1, 'y2': y2, 'y3': y3, 'quality': quality}

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    try:
        highs = _series(_market_field(features.market, 'highs', 'high'), size)
        lows = _series(_market_field(features.market, 'lows', 'low'), size)
        closes = _series(_market_field(features.market, 'closes', 'close'), size)
        opens = _series(_market_field(features.market, 'opens', 'open'), size)
        atr = _series(features.atr(14), size)
    except (AttributeError, TypeError, ValueError):
        return (long_entries, np.zeros(size, dtype=np.bool_), short_entries, np.zeros(size, dtype=np.bool_))
    pivot_types = []
    pivot_bars = []
    pivot_prices = []
    pending = None
    last_confirmed_x3 = None
    for t in range(size):
        center = t - _PIVOT_RIGHT
        if center >= _PIVOT_LEFT:
            pivot_high = _confirmed_pivot(highs, center, _PIVOT_LEFT, _PIVOT_RIGHT, True)
            if pivot_high is not None:
                _update_pivots(pivot_types, pivot_bars, pivot_prices, 1, center, pivot_high)
            pivot_low = _confirmed_pivot(lows, center, _PIVOT_LEFT, _PIVOT_RIGHT, False)
            if pivot_low is not None:
                _update_pivots(pivot_types, pivot_bars, pivot_prices, -1, center, pivot_low)
            if pivot_types and pivot_bars[-1] == center:
                candidate = _double_top_candidate(pivot_types, pivot_bars, pivot_prices, atr[center])
                if candidate is not None and candidate['x3'] != last_confirmed_x3:
                    if pending is None or candidate['quality'] > pending['quality'] + 3.0 or (candidate['x3'] == pending['x3'] and candidate['quality'] > pending['quality']):
                        pending = candidate
        if pending is None or not np.isfinite(atr[t]) or atr[t] <= 0.0:
            continue
        break_level = pending['y2'] - _BREAKOUT_BUFFER_ATR * atr[t]
        confirmed = t > pending['x3'] + _PIVOT_RIGHT and closes[t] < break_level and (t > 0) and (closes[t - 1] >= break_level) and (opens[t] > closes[t]) and (abs(closes[t] - opens[t]) >= _MIN_BREAKOUT_BODY_ATR * atr[t])
        expired = t - pending['x3'] > max(12, min(220, pending['x3'] - pending['x1']))
        invalidated = highs[t] > max(pending['y1'], pending['y3']) + _DOUBLE_TOLERANCE_ATR * atr[t]
        if confirmed:
            short_entries[t] = True
            last_confirmed_x3 = pending['x3']
            pending = None
        elif expired or invalidated:
            pending = None
    try:
        long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, dict(signal_params or {}))
    except (AttributeError, TypeError, ValueError):
        long_exits = np.zeros(size, dtype=np.bool_)
        short_exits = np.zeros(size, dtype=np.bool_)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'double_top_breakout_short', 'hypothesis': 'Confirmed double-top neckline breakdown captures bearish reversal momentum.', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
