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
_MIN_SIGMA = 1e-10
_ST_INSIDE = 0
_ST_BO_UP = 1
_ST_RT_UP = 2
_ST_BO_DN = -1
_ST_RT_DN = -2

def _field(obj, names):
    for name in names:
        if hasattr(obj, name):
            return getattr(obj, name)
    raise AttributeError('missing market field: ' + '/'.join(names))

def _array(market, names, size):
    value = np.asarray(_field(market, names), dtype=float)
    if value.ndim != 1 or value.size < size:
        raise ValueError('market field must be one-dimensional and market.size long')
    return value[:size]

def _yang_zhang_sigma(opens, highs, lows, closes, length):
    size = closes.size
    result = np.full(size, _MIN_SIGMA, dtype=float)
    with np.errstate(divide='ignore', invalid='ignore'):
        overnight = np.full(size, np.nan, dtype=float)
        overnight[1:] = np.log(opens[1:] / closes[:-1])
        close_open = np.log(closes / opens)
        high_open = np.log(highs / opens)
        high_close = np.log(highs / closes)
        low_open = np.log(lows / opens)
        low_close = np.log(lows / closes)
        rogers_satchell = high_open * high_close + low_open * low_close
    weight = 0.34 / (1.34 + (length + 1.0) / max(length - 1.0, 1.0))
    for t in range(length, size):
        start = t - length + 1
        parts = (overnight[start:t + 1], close_open[start:t + 1], rogers_satchell[start:t + 1])
        if all((np.all(np.isfinite(part)) for part in parts)):
            variance = np.var(parts[0]) + weight * np.var(parts[1]) + (1.0 - weight) * np.mean(parts[2])
            result[t] = max(float(np.sqrt(max(variance, 0.0))), _MIN_SIGMA)
    return result

def _ics_line(price1, x1, price2, x2, target, sigma):
    if x1 == x2 or price1 <= 0.0 or price2 <= 0.0 or (sigma <= _MIN_SIGMA):
        return price1
    return float(np.exp(np.log(price1) + (np.log(price2) - np.log(price1)) * (target - x1) / (x2 - x1)))

def _channel(highs, lows, t, period, groups, threshold, sigma):
    if t < groups * period:
        return None
    means = []
    block_highs = []
    block_lows = []
    centers = []
    for i in range(groups):
        end = t - i * period
        start = end - period + 1
        high = float(np.max(highs[start:end + 1]))
        low = float(np.min(lows[start:end + 1]))
        if not np.isfinite(high) or not np.isfinite(low) or high <= 0.0 or (low <= 0.0):
            return None
        block_highs.append(high)
        block_lows.append(low)
        means.append(float(np.sqrt(high * low)))
        centers.append(t - i * period - period // 2)
    if means[0] == means[1]:
        return None
    direction = 1 if means[0] > means[1] else -1
    segment = 1
    for i in range(1, groups - 1):
        pair_direction = 1 if means[i] > means[i + 1] else -1 if means[i] < means[i + 1] else 0
        if pair_direction == direction:
            segment = i + 1
        else:
            break
    if sigma > _MIN_SIGMA:
        angle = np.degrees(np.arctan((np.log(means[0]) - np.log(means[segment])) / sigma / (centers[0] - centers[segment])))
    else:
        angle = 0.0
    classified = 0 if abs(angle) <= threshold else direction
    hh = lh = hl = ll = None
    x_hh = x_lh = x_hl = x_ll = None
    for i in range(segment + 1):
        high, low, x = (block_highs[i], block_lows[i], centers[i])
        if hh is None or high > hh:
            hh, x_hh = (high, x)
        if lh is None or high < lh:
            lh, x_lh = (high, x)
        if hl is None or low > hl:
            hl, x_hl = (low, x)
        if ll is None or low < ll:
            ll, x_ll = (low, x)
    if classified == 1:
        upper = _ics_line(lh, x_lh, hh, x_hh, t, sigma)
        lower = _ics_line(ll, x_ll, hl, x_hl, t, sigma)
    elif classified == -1:
        upper = _ics_line(hh, x_hh, lh, x_lh, t, sigma)
        lower = _ics_line(hl, x_hl, ll, x_ll, t, sigma)
    else:
        upper, lower = (hh, ll)
    if not np.isfinite(upper) or not np.isfinite(lower) or upper <= 0.0 or (lower <= 0.0) or (upper <= lower):
        return None
    return (classified, float(upper), float(lower))

def _short_entries(features, signal_params):
    market = features.market
    size = int(market.size)
    highs = _array(market, ('highs', 'high'), size)
    lows = _array(market, ('lows', 'low'), size)
    closes = _array(market, ('closes', 'close'), size)
    opens = _array(market, ('opens', 'open'), size)
    period = max(5, int(signal_params.get('period', 13)))
    groups = min(5, max(3, int(signal_params.get('groups', 5))))
    threshold = float(signal_params.get('threshold', 0.5))
    sigma_length = max(5, int(signal_params.get('sigma_length', 20)))
    sigmas = _yang_zhang_sigma(opens, highs, lows, closes, sigma_length)
    entries = np.zeros(size, dtype=np.bool_)
    state = _ST_INSIDE
    previous_direction = 0
    distanced = False
    for t in range(size):
        channel = _channel(highs, lows, t, period, groups, threshold, float(sigmas[t]))
        if channel is None or not np.isfinite(closes[t]) or closes[t] <= 0.0:
            continue
        direction, upper, lower = channel
        sigma = float(sigmas[t])
        if sigma <= _MIN_SIGMA:
            continue
        log_width = np.log(upper) - np.log(lower)
        if log_width <= 0.0:
            continue
        close = float(closes[t])
        extension = (np.log(close) - np.log(lower)) / log_width
        distance_up = abs(np.log(close) - np.log(upper)) / sigma
        distance_down = abs(np.log(close) - np.log(lower)) / sigma
        old_state = state
        direction_changed = direction != previous_direction and previous_direction != 0
        previous_direction = direction
        if direction_changed:
            state = _ST_INSIDE
            distanced = False
        elif state == _ST_INSIDE:
            if extension > 1.0:
                state, distanced = (_ST_BO_UP, False)
            elif extension < 0.0:
                state, distanced = (_ST_BO_DN, False)
        elif state == _ST_BO_UP:
            if distance_up >= 1.0:
                distanced = True
            if extension < 0.0:
                state, distanced = (_ST_BO_DN, False)
            elif extension <= 1.0:
                state, distanced = (_ST_INSIDE, False)
            elif distanced and distance_up < 1.0:
                state = _ST_RT_UP
        elif state == _ST_RT_UP:
            if extension < 0.0:
                state, distanced = (_ST_BO_DN, False)
            elif extension <= 1.0:
                state, distanced = (_ST_INSIDE, False)
            elif distance_up >= 1.0:
                state, distanced = (_ST_BO_UP, True)
        elif state == _ST_BO_DN:
            if distance_down >= 1.0:
                distanced = True
            if extension > 1.0:
                state, distanced = (_ST_BO_UP, False)
            elif extension >= 0.0:
                state, distanced = (_ST_INSIDE, False)
            elif distanced and distance_down < 1.0:
                state = _ST_RT_DN
        elif state == _ST_RT_DN:
            if extension > 1.0:
                state, distanced = (_ST_BO_UP, False)
            elif extension >= 0.0:
                state, distanced = (_ST_INSIDE, False)
            elif distance_down >= 1.0:
                state, distanced = (_ST_BO_DN, True)
        if state == _ST_RT_DN and old_state != _ST_RT_DN:
            entries[t] = True
    return entries

def generate_signals(features, signal_params):
    import numpy as np
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = _short_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'channel_retest_down', 'hypothesis': '下破主通道下界後的 1σ 回踩可能延續下行。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['period', 'groups', 'threshold', 'sigma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'period': 13, 'groups': 5, 'threshold': 0.5, 'sigma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
