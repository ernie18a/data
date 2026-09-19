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

def _market_series(market, name, size):
    value = getattr(market, name, None)
    if value is None:
        return None
    array = np.asarray(value, dtype=float)
    if array.ndim != 1 or array.size != size:
        return None
    return array

def _yang_zhang_sigma(opens, highs, lows, closes, length):
    size = closes.size
    sigma = np.full(size, np.nan, dtype=float)
    if length < 2:
        return sigma
    with np.errstate(divide='ignore', invalid='ignore'):
        previous_close = np.roll(closes, -1)
        previous_close[-1] = opens[-1]
        previous_close = np.where(np.isfinite(previous_close), previous_close, opens)
        overnight = np.log(opens / previous_close)
        close_open = np.log(closes / opens)
        high_open = np.log(highs / opens)
        high_close = np.log(highs / closes)
        low_open = np.log(lows / opens)
        low_close = np.log(lows / closes)
        range_component = high_open * high_close + low_open * low_close
    weight = 0.34 / (1.34 + (length + 1.0) / max(length - 1.0, 1.0))
    for bar in range(length - 1, size):
        start = bar - length + 1
        values = (overnight[start:bar + 1], close_open[start:bar + 1], range_component[start:bar + 1])
        if not all((np.isfinite(value).all() for value in values)):
            continue
        variance = float(np.var(values[0])) + weight * float(np.var(values[1])) + (1.0 - weight) * float(np.mean(values[2]))
        sigma[bar] = max(float(np.sqrt(max(variance, 0.0))), 1e-10)
    return sigma

def _ics_line(price_one, x_one, price_two, x_two, target, sigma):
    if x_one == x_two or not np.isfinite(price_one) or (not np.isfinite(price_two)) or (price_one <= 0.0) or (price_two <= 0.0) or (not np.isfinite(sigma)) or (sigma <= 1e-10):
        return float(price_one)
    y_one = np.log(price_one) / sigma
    y_two = np.log(price_two) / sigma
    return float(np.exp((y_one + (y_two - y_one) * (target - x_one) / (x_two - x_one)) * sigma))

def _primary_channel(highs, lows, sigma, bar, period, groups, threshold):
    if bar < groups * period or not np.isfinite(sigma):
        return (0, np.nan, np.nan)
    geometric_means = []
    block_highs = []
    block_lows = []
    centers = []
    for group in range(groups):
        end = bar - group * period
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
        centers.append(end - period // 2)
    if geometric_means[0] == geometric_means[1]:
        return (0, np.nan, np.nan)
    direction = 1 if geometric_means[0] > geometric_means[1] else -1
    segment = 1
    for group in range(1, groups - 1):
        pair_direction = 1 if geometric_means[group] > geometric_means[group + 1] else -1 if geometric_means[group] < geometric_means[group + 1] else 0
        if pair_direction == direction:
            segment = group + 1
        else:
            break
    angle = np.degrees(np.arctan((np.log(geometric_means[0]) - np.log(geometric_means[segment])) / (centers[0] - centers[segment]) / sigma))
    if abs(float(angle)) <= threshold:
        direction = 0
    selected_highs = block_highs[:segment + 1]
    selected_lows = block_lows[:segment + 1]
    highest_high_index = int(np.argmax(selected_highs))
    lowest_high_index = int(np.argmin(selected_highs))
    highest_low_index = int(np.argmax(selected_lows))
    lowest_low_index = int(np.argmin(selected_lows))
    highest_high = selected_highs[highest_high_index]
    lowest_high = selected_highs[lowest_high_index]
    highest_low = selected_lows[highest_low_index]
    lowest_low = selected_lows[lowest_low_index]
    if direction == 1:
        upper = _ics_line(lowest_high, centers[lowest_high_index], highest_high, centers[highest_high_index], bar, sigma)
        lower = _ics_line(lowest_low, centers[lowest_low_index], highest_low, centers[highest_low_index], bar, sigma)
    elif direction == -1:
        upper = _ics_line(highest_high, centers[highest_high_index], lowest_high, centers[lowest_high_index], bar, sigma)
        lower = _ics_line(highest_low, centers[highest_low_index], lowest_low, centers[lowest_low_index], bar, sigma)
    else:
        upper = highest_high
        lower = lowest_low
    return (direction, float(upper), float(lower))

def _update_breakout_state(state, confirmed, distanced, close, upper, lower, sigma, direction, previous_direction):
    previous_confirmed = confirmed
    if previous_direction != 0 and direction != previous_direction:
        return (0, False, False, previous_confirmed, True)
    with np.errstate(divide='ignore', invalid='ignore'):
        extension = (np.log(close) - np.log(lower)) / (np.log(upper) - np.log(lower))
        distance_up = abs(np.log(close) - np.log(upper)) / sigma
        distance_down = abs(np.log(close) - np.log(lower)) / sigma
    if state == 0:
        if extension > 1.0:
            state, confirmed, distanced = (1, False, False)
        elif extension < 0.0:
            state, confirmed, distanced = (-1, False, False)
    elif state == 1:
        if distance_up >= 1.0:
            distanced = True
        if extension < 0.0:
            state, confirmed, distanced = (-1, False, False)
        elif extension <= 1.0:
            state, confirmed, distanced = (0, False, False)
        elif distanced and distance_up < 1.0:
            state = 2
    elif state == 2:
        if extension < 0.0:
            state, confirmed, distanced = (-1, False, False)
        elif extension <= 1.0:
            state, confirmed, distanced = (0, False, False)
        elif distance_up >= 1.0:
            state, confirmed, distanced = (1, True, True)
    elif state == -1:
        if distance_down >= 1.0:
            distanced = True
        if extension > 1.0:
            state, confirmed, distanced = (1, False, False)
        elif extension >= 0.0:
            state, confirmed, distanced = (0, False, False)
        elif distanced and distance_down < 1.0:
            state = -2
    elif extension > 1.0:
        state, confirmed, distanced = (1, False, False)
    elif extension >= 0.0:
        state, confirmed, distanced = (0, False, False)
    elif distance_down >= 1.0:
        state, confirmed, distanced = (-1, True, True)
    return (state, confirmed, distanced, previous_confirmed, False)

def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    market = features.market
    opens = _market_series(market, 'opens', size)
    highs = _market_series(market, 'highs', size)
    lows = _market_series(market, 'lows', size)
    closes = _market_series(market, 'closes', size)
    volumes = _market_series(market, 'volumes', size)
    if any((series is None for series in (opens, highs, lows, closes, volumes))):
        return (empty, empty.copy(), empty.copy(), empty.copy())
    params = signal_params if isinstance(signal_params, dict) else {}
    period = max(5, int(params.get('period', 13)))
    groups = min(5, max(3, int(params.get('groups', 5))))
    sigma_length = max(2, int(params.get('sigma_length', 20)))
    threshold = float(params.get('range_threshold', 0.5))
    sigma = _yang_zhang_sigma(opens, highs, lows, closes, sigma_length)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    state = 0
    confirmed = False
    distanced = False
    previous_direction = 0
    for bar in range(size):
        direction, upper, lower = _primary_channel(highs, lows, sigma[bar], bar, period, groups, threshold)
        if not np.isfinite(closes[bar]) or not np.isfinite(sigma[bar]) or (not np.isfinite(upper)) or (not np.isfinite(lower)) or (upper <= lower):
            continue
        previous_confirmed = confirmed
        state, confirmed, distanced, _, direction_reset = _update_breakout_state(state, confirmed, distanced, closes[bar], upper, lower, sigma[bar], direction, previous_direction)
        previous_direction = direction
        if direction_reset:
            continue
        long_entries[bar] = bool(state == 1 and (not previous_confirmed) and confirmed)
    exit_params = dict(params)
    exit_params.update({'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0})
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'confirmed_breakout_up', 'hypothesis': '上破通道後完成一σ距離、回測並再次上行確認，捕捉結構性上行延續。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['period', 'groups', 'range_threshold', 'sigma_length'], 'signal_parameter_sets': [{'period': 13, 'groups': 5, 'range_threshold': 0.5, 'sigma_length': 20}]}
