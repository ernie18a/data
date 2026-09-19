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

def _series(values, size, name):
    result = np.asarray(values, dtype=float).reshape(-1)
    if result.size != size:
        raise ValueError(f'{name} must have length market.size')
    return result

def _rsi_wilder(closes, length):
    result = np.full(closes.size, np.nan, dtype=float)
    if length < 2 or closes.size <= length:
        return result
    delta = np.diff(closes)
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
    if not np.all(np.isfinite(closes[:length + 1])):
        return result
    avg_gain = float(np.mean(gains[:length]))
    avg_loss = float(np.mean(losses[:length]))

    def value():
        if avg_loss == 0.0:
            return 100.0 if avg_gain > 0.0 else 0.0
        return 100.0 - 100.0 / (1.0 + avg_gain / avg_loss)
    result[length] = value()
    for index in range(length + 1, closes.size):
        if not np.isfinite(closes[index]):
            continue
        avg_gain = (avg_gain * (length - 1) + gains[index - 1]) / length
        avg_loss = (avg_loss * (length - 1) + losses[index - 1]) / length
        result[index] = value()
    return result

def _rma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length < 1 or values.size < length:
        return result
    for index in range(length - 1, values.size):
        if index == length - 1:
            window = values[:length]
            if np.all(np.isfinite(window)):
                result[index] = float(np.mean(window))
        elif np.isfinite(values[index]) and np.isfinite(result[index - 1]):
            result[index] = (result[index - 1] * (length - 1) + values[index]) / length
    return result

def _atr14(highs, lows, closes):
    true_range = np.full(closes.size, np.nan, dtype=float)
    finite = np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    if closes.size:
        true_range[finite] = highs[finite] - lows[finite]
        previous_close = np.full(closes.size, np.nan, dtype=float)
        if closes.size > 1:
            previous_close[1:] = closes[:-1]
        prior_finite = finite & np.isfinite(previous_close)
        true_range[prior_finite] = np.maximum(highs[prior_finite] - lows[prior_finite], np.maximum(np.abs(highs[prior_finite] - previous_close[prior_finite]), np.abs(lows[prior_finite] - previous_close[prior_finite])))
    return _rma(true_range, 14)

def _ema(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length < 1 or values.size < length:
        return result
    for index in range(length - 1, values.size):
        if index == length - 1:
            window = values[:length]
            if np.all(np.isfinite(window)):
                result[index] = float(np.mean(window))
        elif np.isfinite(values[index]) and np.isfinite(result[index - 1]):
            result[index] = result[index - 1] + 2.0 / (length + 1.0) * (values[index] - result[index - 1])
    return result

def _pivot_high(values, center, left, right):
    if center - left < 0 or center + right >= values.size:
        return False
    window = values[center - left:center + right + 1]
    return bool(np.all(np.isfinite(window)) and np.all(values[center] > np.delete(window, left)))

def _right_price_ok(endpoint, right_extreme, atr_at_endpoint, tolerance_percent):
    if not np.isfinite(endpoint) or not np.isfinite(right_extreme):
        return False
    percent = abs(endpoint) * max(0.0, tolerance_percent) / 100.0
    atr_tolerance = atr_at_endpoint * 0.15 if np.isfinite(atr_at_endpoint) else percent
    epsilon = np.finfo(float).eps * max(1.0, abs(endpoint)) * 2.0
    return bool(right_extreme <= endpoint + max(epsilon, min(percent, atr_tolerance)))

def _path_ok(values, first_bar, first_value, last_bar, last_value, edge_skip, tolerance):
    if last_bar - first_bar < 2:
        return True
    if not np.isfinite(first_value) or not np.isfinite(last_value):
        return False
    span = float(last_bar - first_bar)
    skip = max(0, min(edge_skip, int(np.floor((span - 1.0) / 4.0))))
    maximum = max(first_value, last_value)
    for bar in range(first_bar + 1, last_bar):
        value = values[bar]
        if not np.isfinite(value):
            return False
        line = first_value + (last_value - first_value) * ((bar - first_bar) / span)
        middle = bar >= first_bar + 1 + skip and bar <= last_bar - 1 - skip
        if value > maximum + tolerance or (middle and value > line + tolerance):
            return False
    return True

def _ema_hit(highs, closes, center, atr, ema_values, ema_tolerance, enabled):
    if not enabled or center <= 0 or (not np.isfinite(atr[center])):
        return False
    if not np.isfinite(highs[center]) or not np.isfinite(closes[center - 1]):
        return False
    epsilon = np.finfo(float).eps * max(1.0, abs(highs[center])) * 2.0
    tolerance = max(epsilon, atr[center] * max(0.0, ema_tolerance))
    for ema, enabled_ema in ema_values:
        if not enabled_ema or not np.isfinite(ema[center]) or (not np.isfinite(ema[center - 1])):
            continue
        if abs(highs[center] - ema[center]) <= tolerance and closes[center - 1] <= ema[center - 1] + epsilon:
            return True
    return False

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    highs = _series(market.highs, size, 'market.highs')
    lows = _series(market.lows, size, 'market.lows')
    closes = _series(market.closes, size, 'market.closes')
    params = signal_params or {}
    rsi_length = max(2, int(params.get('rsi_len', 14)))
    piv_left = max(1, int(params.get('piv_left', 4)))
    piv_right = max(1, int(params.get('piv_right', 1)))
    n_back = min(10, max(1, int(params.get('n_back', 4))))
    gap_min = max(1, int(params.get('gap_min', 5)))
    gap_max = max(2, int(params.get('gap_max', 60)))
    min_gap = min(gap_min, gap_max)
    max_gap = max(gap_min, gap_max)
    strict = bool(params.get('strict', True))
    strict_any = bool(params.get('strict_any', False))
    check_path = bool(params.get('check_path', True))
    check_osc_path = bool(params.get('check_osc_path', True))
    check_price_path = bool(params.get('check_price_path', True))
    edge_skip = max(0, int(params.get('edge_skip', 0)))
    tol_osc = max(0.0, float(params.get('tol_osc', 1.5)))
    tol_prc = max(0.0, float(params.get('tol_prc', 0.5)))
    min_rsi_d = max(0.0, float(params.get('min_rsi_d', 0.0)))
    obos_only = bool(params.get('obos_only', False))
    price_mode = str(params.get('price_mode', 'mix')).lower()
    level = str(params.get('strict_level', 'normal')).lower()
    if level in {'loose', '寬鬆', '宽松'}:
        effective_n_back = min(10, n_back + 1)
        effective_strict = False
        effective_strict_any = False
        effective_check_path = check_path
        effective_check_osc = check_osc_path
        effective_check_price = check_price_path
        effective_edge_skip = min(10, edge_skip + 1)
        effective_tol_osc = min(20.0, tol_osc * 1.5)
        effective_tol_prc = min(10.0, tol_prc * 1.5)
    elif level in {'strict', '嚴格', '严格'}:
        effective_n_back = max(1, n_back - 1)
        effective_strict = True
        effective_strict_any = strict_any
        effective_check_path = True
        effective_check_osc = True
        effective_check_price = True
        effective_edge_skip = max(0, edge_skip - 1)
        effective_tol_osc = tol_osc * 0.5
        effective_tol_prc = tol_prc * 0.5
    else:
        effective_n_back = n_back
        effective_strict = strict
        effective_strict_any = strict_any
        effective_check_path = check_path
        effective_check_osc = check_osc_path
        effective_check_price = check_price_path
        effective_edge_skip = edge_skip
        effective_tol_osc = tol_osc
        effective_tol_prc = tol_prc
    rsi = _rsi_wilder(closes, rsi_length)
    atr = _atr14(highs, lows, closes)
    try:
        feature_atr = np.asarray(features.atr(14), dtype=float).reshape(-1)
        if feature_atr.size == size:
            atr = feature_atr
    except (AttributeError, TypeError, ValueError):
        pass
    use_ema_touch = bool(params.get('use_ema_touch', False))
    ema_rescue = bool(params.get('ema_rescue', True))
    ema_tolerance = max(0.0, float(params.get('ema_tol_atr', 0.25)))
    ema_values = ((_ema(closes, 21), bool(params.get('ema_use_21', True))), (_ema(closes, 55), bool(params.get('ema_use_55', True))), (_ema(closes, 100), bool(params.get('ema_use_100', True))), (_ema(closes, 200), bool(params.get('ema_use_200', True))))
    rescue_left = max(1, piv_left - 1)
    rescue_min_gap = max(1, min_gap - 1)
    rescue_min_rsi_d = max(0.5, min_rsi_d)
    use_wick = price_mode in {'mix', 'mixed', 'hl', 'high_low', 'highlow'}
    use_close = price_mode in {'mix', 'mixed', 'close', 'closing'}
    history = []
    for confirmation_bar in range(size):
        center = confirmation_bar - piv_right
        if center < 0:
            continue
        standard_pivot = _pivot_high(rsi, center, piv_left, piv_right)
        rescue_pivot = _pivot_high(rsi, center, rescue_left, piv_right)
        right_high = np.max(highs[center + 1:confirmation_bar + 1])
        right_close_high = np.max(closes[center + 1:confirmation_bar + 1])
        current_wick_valid = use_wick and _right_price_ok(highs[center], right_high, atr[center], effective_tol_prc)
        current_close_valid = use_close and _right_price_ok(closes[center], right_close_high, atr[center], effective_tol_prc)
        if standard_pivot and (current_wick_valid or current_close_valid):
            current_rsi = rsi[center]
            if np.isfinite(current_rsi):
                for old in reversed(history):
                    gap = center - old['bar']
                    if gap > max_gap:
                        break
                    pair_wick = current_wick_valid and old['wick_valid']
                    pair_close = current_close_valid and old['close_valid']
                    regular = gap >= min_gap and (not obos_only or current_rsi >= 70.0) and (old['rsi'] > current_rsi)
                    rsi_difference = old['rsi'] - current_rsi
                    oscillator_ok = not effective_check_path or not effective_check_osc or _path_ok(rsi, old['bar'], old['rsi'], center, current_rsi, effective_edge_skip, effective_tol_osc)
                    wick_ok = pair_wick and highs[center] > old['wick'] and (not effective_check_path or not effective_check_price or _path_ok(highs, old['bar'], old['wick'], center, highs[center], effective_edge_skip, abs(old['wick']) * effective_tol_prc / 100.0))
                    close_ok = pair_close and closes[center] > old['close'] and (not effective_check_path or not effective_check_price or _path_ok(closes, old['bar'], old['close'], center, closes[center], effective_edge_skip, abs(old['close']) * effective_tol_prc / 100.0))
                    if regular and rsi_difference >= min_rsi_d and oscillator_ok and (wick_ok or close_ok):
                        short_entries[confirmation_bar] = True
                        break
                    block_wick = pair_wick and old['wick'] > highs[center]
                    block_close = pair_close and old['close'] > closes[center]
                    block_rsi = old['rsi'] < current_rsi
                    price_block = (not current_wick_valid or (pair_wick and block_wick)) and (not current_close_valid or (pair_close and block_close))
                    blocked = block_rsi or price_block if effective_strict_any else block_rsi and price_block
                    if effective_strict and blocked:
                        break
        if ema_rescue and use_ema_touch and rescue_pivot and current_close_valid and (not short_entries[confirmation_bar]) and (not obos_only or rsi[center] >= 70.0) and _ema_hit(highs, closes, center, atr, ema_values, ema_tolerance, True):
            for old in reversed(history):
                gap = center - old['bar']
                if gap > max_gap:
                    break
                if gap >= rescue_min_gap and gap > 0 and old['close_valid']:
                    rescue_difference = old['rsi'] - rsi[center]
                    oscillator_ok = rsi[center] < old['rsi'] and rescue_difference >= rescue_min_rsi_d and _path_ok(rsi, old['bar'], old['rsi'], center, rsi[center], effective_edge_skip, effective_tol_osc)
                    price_ok = closes[center] > old['close'] and _path_ok(closes, old['bar'], old['close'], center, closes[center], effective_edge_skip, abs(old['close']) * effective_tol_prc / 100.0)
                    if oscillator_ok and price_ok:
                        short_entries[confirmation_bar] = True
                    break
        if standard_pivot and (current_wick_valid or current_close_valid):
            history.append({'bar': center, 'wick': highs[center], 'close': closes[center], 'rsi': rsi[center], 'wick_valid': current_wick_valid, 'close_valid': current_close_valid})
            if len(history) > effective_n_back:
                del history[:len(history) - effective_n_back]
    exit_params = dict(params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'rsi_regular_bearish_divergence_short', 'hypothesis': '上升行情中的價格創新高而 RSI 高點走低，代表上行動能衰減，可能形成空單反轉機會。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['rsi_len', 'piv_left', 'piv_right', 'n_back', 'gap_min', 'gap_max', 'strict_level', 'strict', 'strict_any', 'check_path', 'check_osc_path', 'check_price_path', 'edge_skip', 'tol_osc', 'tol_prc', 'min_rsi_d', 'obos_only', 'price_mode', 'use_ema_touch', 'ema_rescue', 'ema_tol_atr', 'ema_use_21', 'ema_use_55', 'ema_use_100', 'ema_use_200', 'k_base', 'mult'], 'signal_parameter_sets': [{'rsi_len': 14, 'piv_left': 4, 'piv_right': 1, 'n_back': 4, 'gap_min': 5, 'gap_max': 60, 'strict_level': 'normal', 'strict': True, 'strict_any': False, 'check_path': True, 'check_osc_path': True, 'check_price_path': True, 'edge_skip': 0, 'tol_osc': 1.5, 'tol_prc': 0.5, 'min_rsi_d': 0.0, 'obos_only': False, 'price_mode': 'mix', 'use_ema_touch': False, 'ema_rescue': True, 'ema_tol_atr': 0.25, 'ema_use_21': True, 'ema_use_55': True, 'ema_use_100': True, 'ema_use_200': True, 'k_base': 2.0, 'mult': 2.0}]}
