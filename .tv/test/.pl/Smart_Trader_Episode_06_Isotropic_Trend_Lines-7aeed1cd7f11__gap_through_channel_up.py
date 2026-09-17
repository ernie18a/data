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

def _as_series(value, size):
    return np.asarray(value, dtype=float).reshape(-1)[:size]

def _yang_zhang_sigma(opens, highs, lows, closes, length):
    size = closes.size
    result = np.full(size, np.nan, dtype=float)
    if size == 0 or length < 2:
        return result
    previous_close = np.empty(size, dtype=float)
    previous_close[0] = opens[0]
    if size > 1:
        previous_close[1:] = closes[:-1]
    with np.errstate(divide='ignore', invalid='ignore'):
        overnight = np.log(opens / previous_close)
        close_open = np.log(closes / opens)
        high_open = np.log(highs / opens)
        high_close = np.log(highs / closes)
        low_open = np.log(lows / opens)
        low_close = np.log(lows / closes)
        range_component = high_open * high_close + low_open * low_close
    weight = 0.34 / (1.34 + (length + 1.0) / max(length - 1.0, 1.0))
    for t in range(length - 1, size):
        start = t - length + 1
        stop = t + 1
        windows = (overnight[start:stop], close_open[start:stop], range_component[start:stop])
        if not all((np.isfinite(window).all() for window in windows)):
            continue
        variance_overnight = float(np.var(windows[0]))
        variance_close_open = float(np.var(windows[1]))
        mean_range = float(np.mean(windows[2]))
        variance = max(variance_overnight + weight * variance_close_open + (1.0 - weight) * mean_range, 0.0)
        result[t] = max(float(np.sqrt(variance)), _MIN_SIGMA)
    return result

def _ics_line(price1, x1, price2, x2, target_x, sigma):
    if x1 == x2 or not np.isfinite(price1) or (not np.isfinite(price2)) or (price1 <= 0.0) or (price2 <= 0.0) or (not np.isfinite(sigma)) or (sigma <= _MIN_SIGMA):
        return float(price1)
    with np.errstate(over='ignore', invalid='ignore'):
        value = np.exp(np.log(price1) + (np.log(price2) - np.log(price1)) * (target_x - x1) / (x2 - x1))
    return float(value) if np.isfinite(value) else np.nan

def _channel_at(t, highs, lows, sigma, period, groups, threshold):
    if t < groups * period or not np.isfinite(sigma) or sigma <= _MIN_SIGMA:
        return (0, np.nan, np.nan)
    geometric_means = []
    block_highs = []
    block_lows = []
    centers = []
    for block in range(groups):
        end = t - block * period
        start = end - period + 1
        if start < 0:
            return (0, np.nan, np.nan)
        block_high = float(np.max(highs[start:end + 1]))
        block_low = float(np.min(lows[start:end + 1]))
        if not np.isfinite(block_high) or not np.isfinite(block_low) or block_high <= 0.0 or (block_low <= 0.0):
            return (0, np.nan, np.nan)
        geometric_means.append(float(np.sqrt(block_high * block_low)))
        block_highs.append(block_high)
        block_lows.append(block_low)
        centers.append(t - block * period - period // 2)
    if geometric_means[0] == geometric_means[1]:
        return (0, np.nan, np.nan)
    direction = 1 if geometric_means[0] > geometric_means[1] else -1
    segment = 1
    for block in range(1, groups - 1):
        pair_direction = 1 if geometric_means[block] > geometric_means[block + 1] else -1 if geometric_means[block] < geometric_means[block + 1] else 0
        if pair_direction != direction:
            break
        segment = block + 1
    angle = np.degrees(np.arctan((np.log(geometric_means[0]) - np.log(geometric_means[segment])) / (sigma * (centers[0] - centers[segment]))))
    trend_direction = 0 if abs(angle) <= threshold else direction
    indices = range(segment + 1)
    highest_high_index = max(indices, key=lambda i: block_highs[i])
    lowest_high_index = min(indices, key=lambda i: block_highs[i])
    highest_low_index = max(indices, key=lambda i: block_lows[i])
    lowest_low_index = min(indices, key=lambda i: block_lows[i])
    if trend_direction == 1:
        upper = _ics_line(block_highs[lowest_high_index], centers[lowest_high_index], block_highs[highest_high_index], centers[highest_high_index], t, sigma)
        lower = _ics_line(block_lows[lowest_low_index], centers[lowest_low_index], block_lows[highest_low_index], centers[highest_low_index], t, sigma)
    elif trend_direction == -1:
        upper = _ics_line(block_highs[highest_high_index], centers[highest_high_index], block_highs[lowest_high_index], centers[lowest_high_index], t, sigma)
        lower = _ics_line(block_lows[highest_low_index], centers[highest_low_index], block_lows[lowest_low_index], centers[lowest_low_index], t, sigma)
    else:
        upper = block_highs[highest_high_index]
        lower = block_lows[lowest_low_index]
    if not np.isfinite(upper) or not np.isfinite(lower) or upper <= lower:
        return (trend_direction, np.nan, np.nan)
    return (trend_direction, upper, lower)

def _gap_up_entries(closes, directions, uppers, lowers, sigmas):
    entries = np.zeros(closes.size, dtype=np.bool_)
    state = 0
    previous_direction = 0
    breakout_distanced = False
    gapped = False
    for t in range(closes.size):
        if not np.isfinite(closes[t]) or closes[t] <= 0.0 or (not np.isfinite(sigmas[t])) or (not np.isfinite(uppers[t])) or (not np.isfinite(lowers[t])) or (uppers[t] <= lowers[t]):
            continue
        close = closes[t]
        sigma = sigmas[t]
        upper = uppers[t]
        lower = lowers[t]
        with np.errstate(divide='ignore', invalid='ignore'):
            ext_pos = (np.log(close) - np.log(lower)) / (np.log(upper) - np.log(lower))
            distance_up = abs(np.log(close) - np.log(upper)) / sigma
            distance_down = abs(np.log(close) - np.log(lower)) / sigma
        if not np.isfinite(ext_pos):
            continue
        gapped_before = gapped
        direction = int(directions[t])
        direction_changed = direction != previous_direction and previous_direction != 0
        previous_direction = direction
        if direction_changed:
            state = 0
            breakout_distanced = False
            gapped = False
        elif state == 0:
            if ext_pos > 1.0:
                state = 1
                breakout_distanced = False
                gapped = False
            elif ext_pos < 0.0:
                state = -1
                breakout_distanced = False
                gapped = False
        elif state == 1:
            if distance_up >= 1.0:
                breakout_distanced = True
            if ext_pos < 0.0:
                state = -1
                breakout_distanced = False
                gapped = True
            elif ext_pos <= 1.0:
                state = 0
                breakout_distanced = False
                gapped = False
            elif breakout_distanced and distance_up < 1.0:
                state = 2
                gapped = False
        elif state == 2:
            if ext_pos < 0.0:
                state = -1
                breakout_distanced = False
                gapped = True
            elif ext_pos <= 1.0:
                state = 0
                breakout_distanced = False
                gapped = False
            elif distance_up >= 1.0:
                state = 1
                breakout_distanced = True
                gapped = False
        elif state == -1:
            if distance_down >= 1.0:
                breakout_distanced = True
            if ext_pos > 1.0:
                state = 1
                breakout_distanced = False
                gapped = True
            elif ext_pos >= 0.0:
                state = 0
                breakout_distanced = False
                gapped = False
            elif breakout_distanced and distance_down < 1.0:
                state = -2
                gapped = False
        elif ext_pos > 1.0:
            state = 1
            breakout_distanced = False
            gapped = True
        elif ext_pos >= 0.0:
            state = 0
            breakout_distanced = False
            gapped = False
        elif distance_down >= 1.0:
            state = -1
            breakout_distanced = True
            gapped = False
        if state == 1 and gapped and (not gapped_before):
            entries[t] = True
    return entries

def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    params = signal_params or {}
    opens = _as_series(features.market.opens, size)
    highs = _as_series(features.market.highs, size)
    lows = _as_series(features.market.lows, size)
    closes = _as_series(features.market.closes, size)
    period = max(5, int(params.get('period', 13)))
    groups = max(3, int(params.get('groups', 5)))
    threshold = float(params.get('range_threshold', 0.5))
    sigma_length = max(5, int(params.get('sigma_length', 20)))
    sigmas = _yang_zhang_sigma(opens, highs, lows, closes, sigma_length)
    directions = np.zeros(size, dtype=np.int8)
    uppers = np.full(size, np.nan, dtype=float)
    lowers = np.full(size, np.nan, dtype=float)
    for t in range(size):
        directions[t], uppers[t], lowers[t] = _channel_at(t, highs, lows, sigmas[t], period, groups, threshold)
    long_entries = _gap_up_entries(closes, directions, uppers, lowers, sigmas)
    short_entries = empty.copy()
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, {'k_base': float(params.get('k_base', 2.0)), 'gamma': float(params.get('gamma', 1.0)), 'n_base': float(params.get('n_base', 2000.0))})
    return (np.asarray(long_entries, dtype=np.bool_).reshape(-1), np.asarray(long_exits, dtype=np.bool_).reshape(-1), np.asarray(short_entries, dtype=np.bool_).reshape(-1), np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'gap_through_channel_up', 'hypothesis': '價格由下方穿越整個動態通道的向上跳空，可能代表強勢突破延續。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['period', 'groups', 'range_threshold', 'sigma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'period': 13, 'groups': 5, 'range_threshold': 0.5, 'sigma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
