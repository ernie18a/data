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

def _rsi_wilder(closes, length):
    result = np.full(closes.size, np.nan, dtype=float)
    if length < 2 or closes.size <= length:
        return result
    delta = np.diff(closes)
    if not np.all(np.isfinite(delta[:length])):
        return result
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
    avg_gain = float(np.mean(gains[:length]))
    avg_loss = float(np.mean(losses[:length]))

    def value(gain, loss):
        if loss == 0.0:
            return 100.0 if gain > 0.0 else 50.0
        return 100.0 - 100.0 / (1.0 + gain / loss)
    result[length] = value(avg_gain, avg_loss)
    for index in range(length + 1, closes.size):
        if not np.isfinite(delta[index - 1]):
            avg_gain = np.nan
            avg_loss = np.nan
            continue
        if not np.isfinite(avg_gain) or not np.isfinite(avg_loss):
            continue
        avg_gain = (avg_gain * (length - 1) + gains[index - 1]) / length
        avg_loss = (avg_loss * (length - 1) + losses[index - 1]) / length
        result[index] = value(avg_gain, avg_loss)
    return result

def _path_ok(series, first, first_value, last, last_value, tolerance, edge_skip):
    if last - first < 2:
        return True
    values = series[first + 1:last]
    if values.size == 0 or not np.all(np.isfinite(values)):
        return False
    lower = min(first_value, last_value)
    span = float(last - first)
    skip = max(0, min(edge_skip, int(np.floor((span - 1.0) / 4.0))))
    for offset, current in enumerate(values, start=1):
        if current < lower - tolerance:
            return False
        if first + 1 + skip <= first + offset <= last - 1 - skip:
            line = first_value + (last_value - first_value) * (offset / span)
            if current < line - tolerance:
                return False
    return True

def _right_low_valid(endpoint, right_extreme, atr_value, price_tolerance):
    if not np.isfinite(endpoint) or not np.isfinite(right_extreme):
        return False
    percent_tolerance = abs(endpoint) * price_tolerance / 100.0
    tolerance = min(percent_tolerance, atr_value * 0.15) if np.isfinite(atr_value) else percent_tolerance
    return right_extreme >= endpoint - max(1e-10, tolerance)

def _is_pivot_low(series, index, left, right):
    if index < left or index + right >= series.size:
        return False
    window = series[index - left:index + right + 1]
    return np.all(np.isfinite(window)) and series[index] <= np.min(window)

def _blocked(pair_low, pair_close, pair_rsi, current_low_valid, current_close_valid, strict_any):
    price_blocked = (not current_low_valid or (pair_low[0] and pair_low[1])) and (not current_close_valid or (pair_close[0] and pair_close[1]))
    return pair_rsi or price_blocked if strict_any else pair_rsi and price_blocked

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    params = signal_params or {}
    rsi_len = max(2, int(params.get('rsi_len', 14)))
    pivot_left = max(1, int(params.get('pivot_left', 4)))
    pivot_right = max(1, int(params.get('pivot_right', 1)))
    n_back = max(1, min(10, int(params.get('n_back', 4))))
    min_gap = max(1, int(params.get('min_gap', 5)))
    max_gap = max(2, int(params.get('max_gap', 60)))
    min_gap, max_gap = (min(min_gap, max_gap), max(min_gap, max_gap))
    min_rsi_delta = max(0.0, float(params.get('min_rsi_delta', 0.0)))
    price_mode = str(params.get('price_mode', 'mix')).lower()
    use_low = price_mode in {'mix', 'mixed', 'hl', 'high_low', 'wick'}
    use_close = price_mode in {'mix', 'mixed', 'close'}
    if not use_low and (not use_close):
        use_low = True
        use_close = True
    strict_block = bool(params.get('strict_block', True))
    strict_any = bool(params.get('strict_any', False))
    check_path = bool(params.get('check_path', True))
    check_rsi_path = bool(params.get('check_rsi_path', True))
    check_price_path = bool(params.get('check_price_path', True))
    edge_skip = max(0, int(params.get('edge_skip', 0)))
    rsi_tolerance = max(0.0, float(params.get('rsi_path_tolerance', 1.5)))
    price_tolerance = max(0.0, float(params.get('price_path_tolerance', 0.5)))
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    if lows.ndim != 1 or closes.ndim != 1 or lows.size != size or (closes.size != size):
        raise ValueError('market lows and closes must be one-dimensional arrays of market size')
    rsi = _rsi_wilder(closes, rsi_len)
    atr = np.asarray(features.atr(14), dtype=float)
    if atr.ndim != 1 or atr.size != size:
        raise ValueError('ATR14 must be a one-dimensional array of market size')
    prior_lows = []
    for confirmation in range(size):
        pivot = confirmation - pivot_right
        if pivot < 0 or not _is_pivot_low(rsi, pivot, pivot_left, pivot_right):
            continue
        current_low_valid = False
        current_close_valid = False
        right_lows = lows[pivot + 1:pivot + pivot_right + 1]
        right_closes = closes[pivot + 1:pivot + pivot_right + 1]
        if use_low and right_lows.size and np.all(np.isfinite(right_lows)):
            current_low_valid = _right_low_valid(lows[pivot], np.min(right_lows), atr[pivot], price_tolerance)
        if use_close and right_closes.size and np.all(np.isfinite(right_closes)):
            current_close_valid = _right_low_valid(closes[pivot], np.min(right_closes), atr[pivot], price_tolerance)
        if current_low_valid or current_close_valid:
            current_rsi = rsi[pivot]
            for old in reversed(prior_lows):
                old_pivot, old_low, old_close, old_rsi, old_low_valid, old_close_valid = old
                gap = pivot - old_pivot
                if gap > max_gap:
                    break
                pair_low = (current_low_valid and old_low_valid, old_low > lows[pivot])
                pair_close = (current_close_valid and old_close_valid, old_close > closes[pivot])
                pair_rsi = old_rsi < current_rsi
                if gap >= min_gap and pair_rsi and (old_rsi - current_rsi >= min_rsi_delta):
                    rsi_ok = not check_path or not check_rsi_path or _path_ok(rsi, old_pivot, old_rsi, pivot, current_rsi, rsi_tolerance, edge_skip)
                    low_ok = pair_low[0] and pair_low[1] and (not check_path or not check_price_path or _path_ok(lows, old_pivot, old_low, pivot, lows[pivot], abs(old_low) * price_tolerance / 100.0, edge_skip))
                    close_ok = pair_close[0] and pair_close[1] and (not check_path or not check_price_path or _path_ok(closes, old_pivot, old_close, pivot, closes[pivot], abs(old_close) * price_tolerance / 100.0, edge_skip))
                    if rsi_ok and (low_ok or close_ok):
                        long_entries[confirmation] = True
                        break
                if strict_block and _blocked(pair_low, pair_close, pair_rsi, current_low_valid, current_close_valid, strict_any):
                    break
            prior_lows.append((pivot, lows[pivot], closes[pivot], current_rsi, current_low_valid, current_close_valid))
            if len(prior_lows) > n_back:
                del prior_lows[0]
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'rsi_hidden_bullish_divergence_long', 'hypothesis': '隱性底背離代表上升趨勢回撤後的延續機會。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['rsi_len', 'pivot_left', 'pivot_right', 'n_back', 'min_gap', 'max_gap', 'min_rsi_delta', 'price_mode', 'strict_block', 'strict_any', 'check_path', 'check_rsi_path', 'check_price_path', 'edge_skip', 'rsi_path_tolerance', 'price_path_tolerance', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'rsi_len': 14, 'pivot_left': 4, 'pivot_right': 1, 'n_back': 4, 'min_gap': 5, 'max_gap': 60, 'min_rsi_delta': 0.0, 'price_mode': 'mix', 'strict_block': True, 'strict_any': False, 'check_path': True, 'check_rsi_path': True, 'check_price_path': True, 'edge_skip': 0, 'rsi_path_tolerance': 1.5, 'price_path_tolerance': 0.5, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
