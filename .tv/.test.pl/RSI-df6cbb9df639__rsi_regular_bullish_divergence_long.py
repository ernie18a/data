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

def _array(value):
    return np.asarray(value, dtype=float)

def _rsi_value(avg_gain, avg_loss):
    if avg_loss == 0.0:
        return 50.0 if avg_gain == 0.0 else 100.0
    return 100.0 - 100.0 / (1.0 + avg_gain / avg_loss)

def _rsi(closes, length):
    closes = _array(closes)
    result = np.full(closes.size, np.nan, dtype=float)
    if closes.size <= length:
        return result
    changes = np.diff(closes)
    gains = np.maximum(changes, 0.0)
    losses = np.maximum(-changes, 0.0)
    avg_gain = float(np.mean(gains[:length]))
    avg_loss = float(np.mean(losses[:length]))
    result[length] = _rsi_value(avg_gain, avg_loss)
    for index in range(length + 1, closes.size):
        avg_gain = (avg_gain * (length - 1) + gains[index - 1]) / length
        avg_loss = (avg_loss * (length - 1) + losses[index - 1]) / length
        result[index] = _rsi_value(avg_gain, avg_loss)
    return result

def _ema(values, length):
    values = _array(values)
    result = np.full(values.size, np.nan, dtype=float)
    if values.size == 0:
        return result
    first = next((i for i, value in enumerate(values) if np.isfinite(value)), None)
    if first is None:
        return result
    result[first] = values[first]
    alpha = 2.0 / (length + 1.0)
    for index in range(first + 1, values.size):
        if np.isfinite(values[index]) and np.isfinite(result[index - 1]):
            result[index] = alpha * values[index] + (1.0 - alpha) * result[index - 1]
    return result

def _is_pivot_low(values, index, left, right):
    start = index - left
    stop = index + right + 1
    if start < 0 or stop > values.size or (not np.isfinite(values[index])):
        return False
    window = values[start:stop]
    return np.all(np.isfinite(window)) and values[index] <= np.min(window)

def _endpoint_low_valid(endpoint, following, atr_value, price_tolerance):
    if not np.isfinite(endpoint) or following.size == 0 or (not np.all(np.isfinite(following))):
        return False
    percent_tolerance = abs(endpoint) * price_tolerance / 100.0
    if np.isfinite(atr_value):
        tolerance = max(1e-12, min(percent_tolerance, atr_value * 0.15))
    else:
        tolerance = max(1e-12, percent_tolerance)
    return float(np.min(following)) >= endpoint - tolerance

def _path_ok(series, first_bar, first_value, last_bar, last_value, tolerance, edge_skip):
    if last_bar - first_bar < 2:
        return True
    inside = series[first_bar + 1:last_bar]
    if inside.size != last_bar - first_bar - 1 or not np.all(np.isfinite(inside)):
        return False
    span = float(last_bar - first_bar)
    skip = max(0, min(edge_skip, int((last_bar - first_bar - 1) // 4)))
    lower = min(first_value, last_value)
    for bar, value in enumerate(inside, first_bar + 1):
        line = first_value + (last_value - first_value) * ((bar - first_bar) / span)
        middle = bar >= first_bar + 1 + skip and bar <= last_bar - 1 - skip
        if value < lower - tolerance or (middle and value < line - tolerance):
            return False
    return True

def _ema_touched_low(index, lows, closes, atr, tolerance_atr):
    if index <= 0 or not np.isfinite(atr[index]) or (not np.isfinite(lows[index])):
        return False
    previous_close = closes[index - 1]
    if not np.isfinite(previous_close):
        return False
    tolerance = max(1e-12, atr[index] * tolerance_atr)
    for length in (21, 55, 100, 200):
        ema = _ema(closes, length)
        if np.isfinite(ema[index]) and np.isfinite(ema[index - 1]) and (abs(lows[index] - ema[index]) <= tolerance) and (previous_close >= ema[index - 1] - 1e-12):
            return True
    return False

def _normal_divergence(current, history, lows, closes, rsi, params, use_low, use_close):
    if not (use_low and current[4] or (use_close and current[5])) or not history:
        return False
    min_gap = min(params['min_gap'], params['max_gap'])
    max_gap = max(params['min_gap'], params['max_gap'])
    current_bar, current_low, current_close, current_rsi, low_valid, close_valid = current
    for old in reversed(history):
        old_bar, old_low, old_close, old_rsi, old_low_valid, old_close_valid = old
        gap = current_bar - old_bar
        if gap > max_gap:
            break
        if gap < min_gap:
            continue
        pair_low = use_low and low_valid and old_low_valid
        pair_close = use_close and close_valid and old_close_valid
        rsi_ok = current_rsi > old_rsi and current_rsi - old_rsi >= params['min_rsi_diff'] and (not params['check_path'] or not params['check_osc_path'] or _path_ok(rsi, old_bar, old_rsi, current_bar, current_rsi, params['rsi_path_tolerance'], params['edge_skip']))
        low_ok = pair_low and current_low < old_low and (not params['check_path'] or not params['check_price_path'] or _path_ok(lows, old_bar, old_low, current_bar, current_low, abs(old_low) * params['price_path_tolerance_pct'] / 100.0, params['edge_skip']))
        close_ok = pair_close and current_close < old_close and (not params['check_path'] or not params['check_price_path'] or _path_ok(closes, old_bar, old_close, current_bar, current_close, abs(old_close) * params['price_path_tolerance_pct'] / 100.0, params['edge_skip']))
        if rsi_ok and (low_ok or close_ok):
            return True
        if params['strict']:
            current_low_available = use_low and low_valid
            current_close_available = use_close and close_valid
            prior_price_stronger = (not current_low_available or (pair_low and old_low < current_low)) and (not current_close_available or (pair_close and old_close < current_close))
            prior_rsi_stronger = old_rsi > current_rsi
            blocked = prior_rsi_stronger or prior_price_stronger if params['strict_any'] else prior_rsi_stronger and prior_price_stronger
            if blocked:
                break
    return False

def _rescue_divergence(current, history, closes, rsi, lows, atr, params):
    if not params['use_ema_rescue'] or not params['use_close_price'] or (not current[5]) or (not history) or (params['obos_only'] and current[3] > 30.0) or (not _ema_touched_low(current[0], lows, closes, atr, params['ema_tolerance_atr'])):
        return False
    min_gap = max(1, min(params['min_gap'], params['max_gap']) - 1)
    max_gap = max(params['min_gap'], params['max_gap'])
    current_bar, _, current_close, current_rsi, _, close_valid = current
    for old in reversed(history):
        gap = current_bar - old[0]
        if gap > max_gap:
            break
        if gap < min_gap or not old[5]:
            continue
        rsi_ok = current_rsi > old[3] and current_rsi - old[3] >= max(0.5, params['min_rsi_diff']) and _path_ok(rsi, old[0], old[3], current_bar, current_rsi, params['rsi_path_tolerance'], params['edge_skip'])
        price_ok = close_valid and current_close < old[2] and _path_ok(closes, old[0], old[2], current_bar, current_close, abs(old[2]) * params['price_path_tolerance_pct'] / 100.0, params['edge_skip'])
        return bool(rsi_ok and price_ok)
    return False

def generate_signals(features, signal_params):
    params = dict(signal_params or {})
    market = features.market
    size = int(market.size)
    lows = _array(market.lows)
    closes = _array(market.closes)
    atr = _array(features.atr(14))
    price_mode = params.get('price_mode', 'mixed')
    settings = {'rsi_len': max(2, int(params.get('rsi_len', 14))), 'piv_left': max(1, int(params.get('piv_left', 4))), 'piv_right': max(1, int(params.get('piv_right', 1))), 'n_back': max(1, int(params.get('n_back', 4))), 'min_gap': max(1, int(params.get('min_gap', 5))), 'max_gap': max(2, int(params.get('max_gap', 60))), 'min_rsi_diff': max(0.0, float(params.get('min_rsi_diff', 0.0))), 'strict': bool(params.get('strict', True)), 'strict_any': bool(params.get('strict_any', False)), 'check_path': bool(params.get('check_path', True)), 'check_osc_path': bool(params.get('check_osc_path', True)), 'check_price_path': bool(params.get('check_price_path', True)), 'edge_skip': max(0, int(params.get('edge_skip', 0))), 'rsi_path_tolerance': max(0.0, float(params.get('rsi_path_tolerance', 1.5))), 'price_path_tolerance_pct': max(0.0, float(params.get('price_path_tolerance_pct', 0.5))), 'obos_only': bool(params.get('obos_only', False)), 'use_ema_rescue': bool(params.get('use_ema_rescue', True)), 'ema_tolerance_atr': max(0.0, float(params.get('ema_tolerance_atr', 0.25))), 'use_close_price': price_mode in ('mixed', 'close')}
    use_low = price_mode in ('mixed', 'low', 'high_low', 'wick')
    use_close = settings['use_close_price']
    rsi = _rsi(closes, settings['rsi_len'])
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    history = []
    rescue_left = max(1, settings['piv_left'] - 1)
    for t in range(size):
        candidate_bar = t - settings['piv_right']
        normal_pivot = candidate_bar >= settings['piv_left'] and _is_pivot_low(rsi, candidate_bar, settings['piv_left'], settings['piv_right'])
        if normal_pivot:
            current_low = lows[candidate_bar]
            current_close = closes[candidate_bar]
            current = (candidate_bar, current_low, current_close, rsi[candidate_bar], _endpoint_low_valid(current_low, lows[candidate_bar + 1:t + 1], atr[candidate_bar], settings['price_path_tolerance_pct']), _endpoint_low_valid(current_close, closes[candidate_bar + 1:t + 1], atr[candidate_bar], settings['price_path_tolerance_pct']))
            normal_signal = (not settings['obos_only'] or current[3] <= 30.0) and _normal_divergence(current, history, lows, closes, rsi, settings, use_low, use_close)
            if normal_signal:
                long_entries[t] = True
        rescue_pivot = candidate_bar >= rescue_left and _is_pivot_low(rsi, candidate_bar, rescue_left, settings['piv_right'])
        if not long_entries[t] and rescue_pivot:
            current_close = closes[candidate_bar]
            rescue_current = (candidate_bar, lows[candidate_bar], current_close, rsi[candidate_bar], False, _endpoint_low_valid(current_close, closes[candidate_bar + 1:t + 1], atr[candidate_bar], settings['price_path_tolerance_pct']))
            if _rescue_divergence(rescue_current, history, closes, rsi, lows, atr, settings):
                long_entries[t] = True
        if normal_pivot:
            if use_low and current[4] or (use_close and current[5]):
                history.append(current)
                if len(history) > settings['n_back']:
                    del history[:-settings['n_back']]
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'rsi_regular_bullish_divergence_long', 'hypothesis': 'RSI 常規底背離表示下跌動能減弱，可能帶來多頭反轉機會。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['rsi_len', 'piv_left', 'piv_right', 'n_back', 'min_gap', 'max_gap', 'min_rsi_diff', 'price_mode', 'strict', 'strict_any', 'check_path', 'check_osc_path', 'check_price_path', 'edge_skip', 'rsi_path_tolerance', 'price_path_tolerance_pct', 'obos_only', 'use_ema_rescue', 'ema_tolerance_atr', 'k_base', 'mult'], 'signal_parameter_sets': [{'rsi_len': 14, 'piv_left': 4, 'piv_right': 1, 'n_back': 4, 'min_gap': 5, 'max_gap': 60, 'min_rsi_diff': 0.0, 'price_mode': 'mixed', 'strict': True, 'strict_any': False, 'check_path': True, 'check_osc_path': True, 'check_price_path': True, 'edge_skip': 0, 'rsi_path_tolerance': 1.5, 'price_path_tolerance_pct': 0.5, 'obos_only': False, 'use_ema_rescue': True, 'ema_tolerance_atr': 0.25, 'k_base': 2.0, 'mult': 2.0}]}
