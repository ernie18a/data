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

def _market_array(market, *names):
    for name in names:
        if hasattr(market, name):
            return np.asarray(getattr(market, name), dtype=float).reshape(-1)
    raise AttributeError('market 缺少必要的 OHLCV 欄位')

def _yang_zhang_sigma(opens, highs, lows, closes, length):
    size = len(closes)
    result = np.full(size, np.nan, dtype=float)
    if size == 0 or length <= 0:
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
        range_term = high_open * high_close + low_open * low_close
    k = 0.34 / (1.34 + (length + 1.0) / max(length - 1.0, 1.0))
    for t in range(length - 1, size):
        start = t - length + 1
        values = (overnight[start:t + 1], close_open[start:t + 1], range_term[start:t + 1])
        if any((not np.all(np.isfinite(value)) for value in values)):
            continue
        variance = float(np.var(values[0], ddof=0)) + k * float(np.var(values[1], ddof=0)) + (1.0 - k) * float(np.mean(values[2]))
        result[t] = max(float(np.sqrt(max(variance, 0.0))), 1e-10)
    return result

def _ics_line(price_one, x_one, price_two, x_two, target_x, sigma):
    if x_one == x_two or not np.isfinite(price_one) or (not np.isfinite(price_two)) or (price_one <= 0.0) or (price_two <= 0.0) or (sigma <= 1e-10):
        return float(price_one)
    y_one = np.log(price_one) / sigma
    y_two = np.log(price_two) / sigma
    return float(np.exp((y_one + (y_two - y_one) * (target_x - x_one) / (x_two - x_one)) * sigma))

def _primary_channel(t, highs, lows, sigma, period, groups, threshold):
    if t < groups * period or not np.isfinite(sigma) or sigma <= 1e-10:
        return None
    geometric_means = []
    block_highs = []
    block_lows = []
    centers = []
    for index in range(groups):
        end = t - index * period
        start = end - period + 1
        if start < 0:
            return None
        block_high = float(np.max(highs[start:end + 1]))
        block_low = float(np.min(lows[start:end + 1]))
        if not np.isfinite(block_high) or not np.isfinite(block_low) or block_high <= 0.0 or (block_low <= 0.0):
            return None
        block_highs.append(block_high)
        block_lows.append(block_low)
        geometric_means.append(float(np.sqrt(block_high * block_low)))
        centers.append(end - period // 2)
    if geometric_means[0] == geometric_means[1]:
        return None
    primary_direction = 1 if geometric_means[0] > geometric_means[1] else -1
    segment = 1
    for index in range(1, groups - 1):
        pair_direction = 1 if geometric_means[index] > geometric_means[index + 1] else -1 if geometric_means[index] < geometric_means[index + 1] else 0
        if pair_direction == primary_direction:
            segment = index + 1
        else:
            break
    angle = np.degrees(np.arctan((np.log(geometric_means[0]) - np.log(geometric_means[segment])) / (sigma * (centers[0] - centers[segment]))))
    direction = 0 if abs(angle) <= threshold else primary_direction
    highest_high = lowest_high = None
    highest_low = lowest_low = None
    x_highest_high = x_lowest_high = None
    x_highest_low = x_lowest_low = None
    for index in range(segment + 1):
        high = block_highs[index]
        low = block_lows[index]
        center = centers[index]
        if highest_high is None or high > highest_high:
            highest_high, x_highest_high = (high, center)
        if lowest_high is None or high < lowest_high:
            lowest_high, x_lowest_high = (high, center)
        if highest_low is None or low > highest_low:
            highest_low, x_highest_low = (low, center)
        if lowest_low is None or low < lowest_low:
            lowest_low, x_lowest_low = (low, center)
    if direction == 1:
        upper = _ics_line(lowest_high, x_lowest_high, highest_high, x_highest_high, t, sigma)
        lower = _ics_line(lowest_low, x_lowest_low, highest_low, x_highest_low, t, sigma)
    elif direction == -1:
        upper = _ics_line(highest_high, x_highest_high, lowest_high, x_lowest_high, t, sigma)
        lower = _ics_line(highest_low, x_highest_low, lowest_low, x_lowest_low, t, sigma)
    else:
        upper, lower = (float(highest_high), float(lowest_low))
    if not np.isfinite(upper) or not np.isfinite(lower) or upper <= lower:
        return None
    return (direction, upper, lower)

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    market = features.market
    opens = _market_array(market, 'opens', 'open')
    highs = _market_array(market, 'highs', 'high')
    lows = _market_array(market, 'lows', 'low')
    closes = _market_array(market, 'closes', 'close')
    period = max(5, int(signal_params.get('period', 13)))
    groups = max(3, int(signal_params.get('groups', 5)))
    threshold = float(signal_params.get('threshold', 0.5))
    sigma_length = max(5, int(signal_params.get('sigma_length', 20)))
    sigma = _yang_zhang_sigma(opens, highs, lows, closes, sigma_length)
    state = 0
    previous_direction = 0
    distanced = False
    for t in range(size):
        channel = _primary_channel(t, highs, lows, sigma[t], period, groups, threshold)
        if channel is None:
            continue
        direction, upper, lower = channel
        close = float(closes[t])
        if not np.isfinite(close) or close <= 0.0:
            continue
        log_width = np.log(upper) - np.log(lower)
        if not np.isfinite(log_width) or log_width <= 0.0:
            continue
        extension_position = (np.log(close) - np.log(lower)) / log_width
        distance_up = abs(np.log(close) - np.log(upper)) / sigma[t]
        distance_down = abs(np.log(close) - np.log(lower)) / sigma[t]
        previous_state = state
        direction_changed = direction != previous_direction and previous_direction != 0
        previous_direction = direction
        if direction_changed:
            state = 0
            distanced = False
        elif state == 0:
            if extension_position > 1.0:
                state = 1
                distanced = False
            elif extension_position < 0.0:
                state = -1
                distanced = False
        elif state == 1:
            if distance_up >= 1.0:
                distanced = True
            if extension_position < 0.0:
                state = -1
                distanced = False
            elif extension_position <= 1.0:
                state = 0
                distanced = False
            elif distanced and distance_up < 1.0:
                state = 2
        elif state == 2:
            if extension_position < 0.0:
                state = -1
                distanced = False
            elif extension_position <= 1.0:
                state = 0
                distanced = False
            elif distance_up >= 1.0:
                state = 1
                distanced = True
        elif state == -1:
            if distance_down >= 1.0:
                distanced = True
            if extension_position > 1.0:
                state = 1
                distanced = False
            elif extension_position >= 0.0:
                state = 0
                distanced = False
            elif distanced and distance_down < 1.0:
                state = -2
        elif state == -2:
            if extension_position > 1.0:
                state = 1
                distanced = False
            elif extension_position >= 0.0:
                state = 0
                distanced = False
            elif distance_down >= 1.0:
                state = -1
                distanced = True
        if previous_state == 1 and state == 2:
            long_entries[t] = True
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'channel_retest_up', 'hypothesis': '上破通道上界後完成 1σ 距離確認並回測上界，可能延續上行。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['period', 'groups', 'threshold', 'sigma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'period': 13, 'groups': 5, 'threshold': 0.5, 'sigma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
