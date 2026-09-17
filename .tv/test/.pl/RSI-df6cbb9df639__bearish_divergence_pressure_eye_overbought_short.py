import numpy as np

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    mult = float(signal_params.get('mult', 2.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    entry_price = 0.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif closes[t] >= entry_price + mult * atr[t]:
                long_exits[t] = True
                position = 0
            elif closes[t] < entry_price - mult * atr[t]:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif closes[t] <= entry_price - mult * atr[t]:
                short_exits[t] = True
                position = 0
            elif closes[t] > entry_price + mult * atr[t]:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                entry_price = closes[t]
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                entry_price = closes[t]
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
    return (long_exits, short_exits)

def _rsi(closes, period=14):
    closes = np.asarray(closes, dtype=float)
    size = closes.size
    result = np.full(size, np.nan, dtype=float)
    if size <= period:
        return result
    delta = np.diff(closes)
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
    if not np.all(np.isfinite(gains[:period])) or not np.all(np.isfinite(losses[:period])):
        return result
    avg_gain = float(np.mean(gains[:period]))
    avg_loss = float(np.mean(losses[:period]))

    def value(gain, loss):
        if loss == 0.0:
            return 100.0 if gain > 0.0 else 50.0
        return 100.0 - 100.0 / (1.0 + gain / loss)
    result[period] = value(avg_gain, avg_loss)
    for index in range(period + 1, size):
        gain = gains[index - 1]
        loss = losses[index - 1]
        if not np.isfinite(gain) or not np.isfinite(loss):
            continue
        avg_gain = (avg_gain * (period - 1) + gain) / period
        avg_loss = (avg_loss * (period - 1) + loss) / period
        result[index] = value(avg_gain, avg_loss)
    return result

def _atr(highs, lows, closes, period=14):
    highs = np.asarray(highs, dtype=float)
    lows = np.asarray(lows, dtype=float)
    closes = np.asarray(closes, dtype=float)
    size = closes.size
    result = np.full(size, np.nan, dtype=float)
    if size < period:
        return result
    true_range = np.empty(size, dtype=float)
    true_range[0] = highs[0] - lows[0]
    true_range[1:] = np.maximum(highs[1:] - lows[1:], np.maximum(np.abs(highs[1:] - closes[:-1]), np.abs(lows[1:] - closes[:-1])))
    if not np.all(np.isfinite(true_range[:period])):
        return result
    result[period - 1] = np.mean(true_range[:period])
    for index in range(period, size):
        if np.isfinite(true_range[index]) and np.isfinite(result[index - 1]):
            result[index] = (result[index - 1] * (period - 1) + true_range[index]) / period
    return result

def _is_pivot_high(values, index, left, right):
    if index - left < 0 or index + right >= values.size:
        return False
    candidate = values[index]
    if not np.isfinite(candidate):
        return False
    neighbors = np.concatenate((values[index - left:index], values[index + 1:index + right + 1]))
    return np.all(np.isfinite(neighbors)) and candidate >= np.max(neighbors)

def _right_price_valid(endpoint, right_extreme, endpoint_atr):
    if not np.isfinite(endpoint) or not np.isfinite(right_extreme):
        return False
    percentage_tolerance = abs(endpoint) * 0.005
    atr_tolerance = endpoint_atr * 0.15 if np.isfinite(endpoint_atr) else percentage_tolerance
    tolerance = max(1e-10, min(percentage_tolerance, atr_tolerance))
    return right_extreme <= endpoint + tolerance

def _clean_path(values, first_index, first_value, last_index, last_value, tolerance):
    if last_index <= first_index + 1:
        return True
    if not np.isfinite(first_value) or not np.isfinite(last_value):
        return False
    upper = max(first_value, last_value)
    slope = (last_value - first_value) / (last_index - first_index)
    for index in range(first_index + 1, last_index):
        value = values[index]
        if not np.isfinite(value):
            return False
        line_value = first_value + slope * (index - first_index)
        if value > upper + tolerance or value > line_value + tolerance:
            return False
    return True

def generate_signals(features, signal_params):
    size = int(features.market.size)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)[:size]
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)[:size]
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)[:size]
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    rsi = _rsi(closes, 14)
    atr = _atr(highs, lows, closes, 14)
    eye_length = 20
    eye_basis = np.full(size, np.nan, dtype=float)
    eye_deviation = np.full(size, np.nan, dtype=float)
    for index in range(eye_length - 1, size):
        window = closes[index - eye_length + 1:index + 1]
        if np.all(np.isfinite(window)):
            eye_basis[index] = np.mean(window)
            eye_deviation[index] = 2.0 * np.std(window, ddof=0)
    eye_upper = eye_basis + eye_deviation
    eye_confirmation = np.full(size, -1, dtype=int)
    eye_active = False
    eye_origin = -1
    eye_extreme = np.nan
    for index in range(size):
        outside = np.isfinite(highs[index]) and np.isfinite(eye_upper[index]) and (highs[index] > eye_upper[index])
        if outside:
            if not eye_active or highs[index] > eye_extreme:
                eye_origin = index
                eye_extreme = highs[index]
            eye_active = True
        elif eye_active:
            if eye_origin >= 0 and np.isfinite(rsi[eye_origin]) and (rsi[eye_origin] >= 70.0):
                eye_confirmation[eye_origin] = index
            eye_active = False
            eye_origin = -1
            eye_extreme = np.nan
    divergence_confirmation = np.full(size, -1, dtype=int)
    prior_pivots = []
    pivot_left = 4
    pivot_right = 1
    minimum_gap = 5
    maximum_gap = 60
    for confirmation_index in range(size):
        endpoint = confirmation_index - pivot_right
        if endpoint >= pivot_left and _is_pivot_high(rsi, endpoint, pivot_left, pivot_right):
            endpoint_rsi = rsi[endpoint]
            endpoint_high = highs[endpoint]
            endpoint_close = closes[endpoint]
            high_valid = _right_price_valid(endpoint_high, highs[confirmation_index], atr[endpoint])
            close_valid = _right_price_valid(endpoint_close, closes[confirmation_index], atr[endpoint])
            current_usable = high_valid or close_valid
            if current_usable and endpoint_rsi >= 70.0:
                for previous in reversed(prior_pivots):
                    gap = endpoint - previous['index']
                    if gap > maximum_gap:
                        break
                    if gap < minimum_gap:
                        continue
                    pair_high = high_valid and previous['high_valid']
                    pair_close = close_valid and previous['close_valid']
                    regular_divergence = False
                    if endpoint_rsi < previous['rsi']:
                        rsi_ok = _clean_path(rsi, previous['index'], previous['rsi'], endpoint, endpoint_rsi, 1.5)
                        high_ok = pair_high and endpoint_high > previous['high'] and _clean_path(highs, previous['index'], previous['high'], endpoint, endpoint_high, abs(previous['high']) * 0.005)
                        close_ok = pair_close and endpoint_close > previous['close'] and _clean_path(closes, previous['index'], previous['close'], endpoint, endpoint_close, abs(previous['close']) * 0.005)
                        regular_divergence = rsi_ok and (high_ok or close_ok)
                    if regular_divergence:
                        divergence_confirmation[endpoint] = confirmation_index
                        break
                    blocked_by_rsi = previous['rsi'] < endpoint_rsi
                    blocked_by_high = pair_high and previous['high'] > endpoint_high
                    blocked_by_close = pair_close and previous['close'] > endpoint_close
                    price_block = (not high_valid or (pair_high and blocked_by_high)) and (not close_valid or (pair_close and blocked_by_close))
                    if blocked_by_rsi and price_block:
                        break
            if current_usable:
                prior_pivots.append({'index': endpoint, 'high': endpoint_high, 'close': endpoint_close, 'rsi': endpoint_rsi, 'high_valid': high_valid, 'close_valid': close_valid})
                if len(prior_pivots) > 4:
                    prior_pivots.pop(0)
    for origin in range(size):
        divergence_at = divergence_confirmation[origin]
        eye_at = eye_confirmation[origin]
        if divergence_at >= 0 and eye_at >= 0:
            entry_index = max(divergence_at, eye_at)
            short_entries[entry_index] = True
    params = {'k_base': float(signal_params.get('k_base', 2.0)), 'mult': float(signal_params.get('mult', 2.0))}
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bearish_divergence_pressure_eye_overbought_short', 'hypothesis': '超買區的頂背離與壓力眼共振，可能預示上行動能衰竭並轉為下跌。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'mult'], 'signal_parameter_sets': [{'k_base': 2.0, 'mult': 2.0}]}
