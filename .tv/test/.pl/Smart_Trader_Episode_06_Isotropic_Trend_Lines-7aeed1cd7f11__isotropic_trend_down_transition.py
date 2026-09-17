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

def _rolling_extreme(values, window, find_max):
    from collections import deque
    size = values.size
    result = np.full(size, np.nan, dtype=float)
    queue = deque()
    for index, value in enumerate(values):
        while queue and queue[0] <= index - window:
            queue.popleft()
        while queue:
            tail_value = values[queue[-1]]
            if find_max and tail_value <= value or (not find_max and tail_value >= value):
                queue.pop()
            else:
                break
        queue.append(index)
        if index >= window - 1:
            result[index] = values[queue[0]]
    return result

def _rolling_variance(values, window):
    size = values.size
    result = np.zeros(size, dtype=float)
    if size < window:
        return result
    cumulative = np.concatenate((np.array([0.0]), np.cumsum(values)))
    cumulative_square = np.concatenate((np.array([0.0]), np.cumsum(values * values)))
    total = cumulative[window:] - cumulative[:-window]
    total_square = cumulative_square[window:] - cumulative_square[:-window]
    variance = total_square / window - (total / window) ** 2
    result[window - 1:] = np.maximum(variance, 0.0)
    return result

def _rolling_mean(values, window):
    size = values.size
    result = np.zeros(size, dtype=float)
    if size < window:
        return result
    cumulative = np.concatenate((np.array([0.0]), np.cumsum(values)))
    result[window - 1:] = (cumulative[window:] - cumulative[:-window]) / window
    return result

def _yang_zhang_sigma(opens, highs, lows, closes, window):
    size = opens.size
    if size == 0:
        return np.empty(0, dtype=float)
    previous_close = np.empty(size, dtype=float)
    previous_close[0] = opens[0]
    previous_close[1:] = closes[:-1]
    yz_or = np.log(opens / previous_close)
    yz_co = np.log(closes / opens)
    yz_ho = np.log(highs / opens)
    yz_hc = np.log(highs / closes)
    yz_lo = np.log(lows / opens)
    yz_lc = np.log(lows / closes)
    overnight_variance = _rolling_variance(yz_or, window)
    close_open_variance = _rolling_variance(yz_co, window)
    rogers_satchell_mean = _rolling_mean(yz_ho * yz_hc + yz_lo * yz_lc, window)
    weight = 0.34 / (1.34 + (window + 1.0) / max(window - 1.0, 1.0))
    variance = overnight_variance + weight * close_open_variance + (1.0 - weight) * rogers_satchell_mean
    return np.maximum(np.sqrt(np.maximum(variance, 0.0)), 1e-10)

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    period = max(1, int(signal_params.get('period', 13)))
    groups = max(2, int(signal_params.get('groups', 5)))
    range_threshold = float(signal_params.get('range_threshold', signal_params.get('threshold', 0.5)))
    sigma_length = max(2, int(signal_params.get('sigma_length', signal_params.get('sigma_len', 20))))
    sigma = _yang_zhang_sigma(opens, highs, lows, closes, sigma_length)
    block_highs = _rolling_extreme(highs, period, True)
    block_lows = _rolling_extreme(lows, period, False)
    previous_direction = 0
    for t in range(size):
        direction = 0
        angle = 0.0
        if t >= groups * period:
            geometric_means = np.empty(groups, dtype=float)
            for block in range(groups):
                endpoint = t - block * period
                geometric_means[block] = np.exp((np.log(block_highs[endpoint]) + np.log(block_lows[endpoint])) / 2.0)
            if geometric_means[0] != geometric_means[1]:
                candidate_direction = 1 if geometric_means[0] > geometric_means[1] else -1
                segment = 1
                for block in range(1, groups - 1):
                    if geometric_means[block] == geometric_means[block + 1]:
                        pair_direction = 0
                    else:
                        pair_direction = 1 if geometric_means[block] > geometric_means[block + 1] else -1
                    if pair_direction == candidate_direction:
                        segment = block + 1
                    else:
                        break
                normalized_slope = (np.log(geometric_means[0]) - np.log(geometric_means[segment])) / (max(1e-10, sigma[t]) * segment * period)
                angle = float(np.degrees(np.arctan(normalized_slope)))
                if abs(angle) > range_threshold:
                    direction = candidate_direction
        short_entries[t] = direction == -1 and previous_direction != -1 and (abs(angle) > range_threshold)
        previous_direction = direction
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'isotropic_trend_down_transition', 'hypothesis': 'Yang-Zhang 波動率標準化的 ICS 結構性下降轉折可捕捉短倉趨勢起點。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['period', 'groups', 'range_threshold', 'sigma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'period': 13, 'groups': 5, 'range_threshold': 0.5, 'sigma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
