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

def _number(params, name, default):
    try:
        value = float(params.get(name, default))
    except (TypeError, ValueError):
        value = float(default)
    return value if np.isfinite(value) else float(default)

def _rolling_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    if window <= values.size:
        cumulative = np.concatenate((np.array([0.0]), np.cumsum(values, dtype=float)))
        result[window - 1:] = (cumulative[window:] - cumulative[:-window]) / window
    return result

def _rolling_variance(values, window):
    mean = _rolling_mean(values, window)
    square_mean = _rolling_mean(values * values, window)
    return np.maximum(square_mean - mean * mean, 0.0)

def _yang_zhang_sigma(opens, highs, lows, closes, window):
    previous_close = np.empty_like(closes)
    previous_close[0] = opens[0]
    previous_close[1:] = closes[:-1]
    with np.errstate(divide='ignore', invalid='ignore'):
        overnight = np.log(opens / previous_close)
        close_open = np.log(closes / opens)
        high_open = np.log(highs / opens)
        high_close = np.log(highs / closes)
        low_open = np.log(lows / opens)
        low_close = np.log(lows / closes)
        rogers_satchell = high_open * high_close + low_open * low_close
    overnight_var = _rolling_variance(overnight, window)
    close_open_var = _rolling_variance(close_open, window)
    rs_mean = _rolling_mean(rogers_satchell, window)
    k = 0.34 / (1.34 + (window + 1.0) / max(window - 1.0, 1.0))
    variance = overnight_var + k * close_open_var + (1.0 - k) * rs_mean
    variance = np.nan_to_num(variance, nan=0.0, posinf=0.0, neginf=0.0)
    return np.maximum(np.sqrt(np.maximum(variance, 0.0)), 1e-10)

def _ics_line(p1, x1, p2, x2, target_x, sigma):
    if x1 != x2 and p1 > 0.0 and (p2 > 0.0) and (sigma > 1e-10):
        y1 = np.log(p1) / sigma
        y2 = np.log(p2) / sigma
        return float(np.exp((y1 + (y2 - y1) * (target_x - x1) / (x2 - x1)) * sigma))
    return float(p1)

def _channel_at(endpoint, highs, lows, sigma, period, groups, threshold):
    if endpoint < groups * period:
        return (0, np.nan, np.nan)
    block_gm = []
    block_hi = []
    block_lo = []
    block_x = []
    for index in range(groups):
        block_end = endpoint - index * period
        block_start = block_end - period + 1
        if block_start < 0:
            return (0, np.nan, np.nan)
        high = float(np.max(highs[block_start:block_end + 1]))
        low = float(np.min(lows[block_start:block_end + 1]))
        if not (np.isfinite(high) and np.isfinite(low) and (high > 0.0) and (low > 0.0)):
            return (0, np.nan, np.nan)
        block_hi.append(high)
        block_lo.append(low)
        block_gm.append(float(np.exp((np.log(high) + np.log(low)) / 2.0)))
        block_x.append(endpoint - index * period - period // 2)
    current = block_gm[0]
    following = block_gm[1]
    if current == following:
        return (0, np.nan, np.nan)
    primary_direction = 1 if current > following else -1
    segment_end = 1
    for index in range(1, groups - 1):
        pair_direction = 1 if block_gm[index] > block_gm[index + 1] else -1 if block_gm[index] < block_gm[index + 1] else 0
        if pair_direction == primary_direction:
            segment_end = index + 1
        else:
            break
    current_sigma = float(sigma[endpoint])
    if not np.isfinite(current_sigma) or current_sigma <= 1e-10:
        return (0, np.nan, np.nan)
    oldest = block_gm[segment_end]
    newest = block_gm[0]
    oldest_x = block_x[segment_end]
    newest_x = block_x[0]
    angle = np.degrees(np.arctan((np.log(newest) - np.log(oldest)) / current_sigma / (newest_x - oldest_x)))
    direction = 0 if abs(angle) <= threshold else primary_direction
    segment_indices = range(segment_end + 1)
    highest_high_index = max(segment_indices, key=lambda i: block_hi[i])
    lowest_high_index = min(segment_indices, key=lambda i: block_hi[i])
    highest_low_index = max(segment_indices, key=lambda i: block_lo[i])
    lowest_low_index = min(segment_indices, key=lambda i: block_lo[i])
    f_hh, x_hh = (block_hi[highest_high_index], block_x[highest_high_index])
    f_lh, x_lh = (block_hi[lowest_high_index], block_x[lowest_high_index])
    f_hl, x_hl = (block_lo[highest_low_index], block_x[highest_low_index])
    f_ll, x_ll = (block_lo[lowest_low_index], block_x[lowest_low_index])
    if direction == 1:
        upper = _ics_line(f_lh, x_lh, f_hh, x_hh, endpoint, current_sigma)
        lower = _ics_line(f_ll, x_ll, f_hl, x_hl, endpoint, current_sigma)
    elif direction == -1:
        upper = _ics_line(f_hh, x_hh, f_lh, x_lh, endpoint, current_sigma)
        lower = _ics_line(f_hl, x_hl, f_ll, x_ll, endpoint, current_sigma)
    else:
        upper, lower = (f_hh, f_ll)
    if not (np.isfinite(upper) and np.isfinite(lower) and (upper > lower)):
        return (direction, np.nan, np.nan)
    return (direction, upper, lower)

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    params = signal_params or {}
    if size == 0:
        long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
        return (long_entries, long_exits, short_entries, short_exits)
    period = min(100, max(5, int(_number(params, 'period', 13))))
    groups = min(5, max(3, int(_number(params, 'groups', 5))))
    threshold = min(45.0, max(0.0, _number(params, 'threshold', 0.5)))
    sigma_length = min(100, max(5, int(_number(params, 'sigma_length', 20))))
    anchor = 1 if params.get('calculation_bar', 'Live Bar') == 'Close Bar' else 0
    opens = np.asarray(market.opens, dtype=float)
    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    sigma = _yang_zhang_sigma(opens, highs, lows, closes, sigma_length)
    state = 0
    bo_distanced = False
    previous_direction = 0
    for t in range(size):
        endpoint = t - anchor
        if endpoint < 0 or t < groups * period + anchor:
            continue
        direction, upper, lower = _channel_at(endpoint, highs, lows, sigma, period, groups, threshold)
        if not (np.isfinite(upper) and np.isfinite(lower) and (closes[endpoint] > 0.0)):
            continue
        current_sigma = float(sigma[endpoint])
        if not np.isfinite(current_sigma) or current_sigma <= 1e-10:
            continue
        with np.errstate(divide='ignore', invalid='ignore'):
            ext_pos = (np.log(closes[endpoint]) - np.log(lower)) / (np.log(upper) - np.log(lower))
            distance_up = abs(np.log(closes[endpoint]) - np.log(upper)) / current_sigma
            distance_down = abs(np.log(closes[endpoint]) - np.log(lower)) / current_sigma
        if not (np.isfinite(ext_pos) and np.isfinite(distance_up) and np.isfinite(distance_down)):
            continue
        direction_changed = direction != previous_direction and previous_direction != 0
        previous_direction = direction
        if direction_changed:
            state = 0
            bo_distanced = False
            continue
        if state == 0:
            if ext_pos > 1.0:
                state = 1
                bo_distanced = False
            elif ext_pos < 0.0:
                state = -1
                bo_distanced = False
                short_entries[t] = True
        elif state == 1:
            if distance_up >= 1.0:
                bo_distanced = True
            if ext_pos < 0.0:
                state = -1
                bo_distanced = False
            elif ext_pos <= 1.0:
                state = 0
                bo_distanced = False
            elif bo_distanced and distance_up < 1.0:
                state = 2
        elif state == 2:
            if ext_pos < 0.0:
                state = -1
                bo_distanced = False
            elif ext_pos <= 1.0:
                state = 0
                bo_distanced = False
            elif distance_up >= 1.0:
                state = 1
        elif state == -1:
            if distance_down >= 1.0:
                bo_distanced = True
            if ext_pos > 1.0:
                state = 1
                bo_distanced = False
            elif ext_pos >= 0.0:
                state = 0
                bo_distanced = False
            elif bo_distanced and distance_down < 1.0:
                state = -2
        elif ext_pos > 1.0:
            state = 1
            bo_distanced = False
        elif ext_pos >= 0.0:
            state = 0
            bo_distanced = False
        elif distance_down >= 1.0:
            state = -1
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'primary_channel_breakout_down', 'hypothesis': '主通道下破反映結構性下行動能，做空下破事件並以趨勢追蹤出場。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['period', 'groups', 'threshold', 'sigma_length', 'calculation_bar', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'period': 13, 'groups': 5, 'threshold': 0.5, 'sigma_length': 20, 'calculation_bar': 'Live Bar', 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
