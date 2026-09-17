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
    except (AttributeError, TypeError, ValueError):
        value = float(default)
    return value if np.isfinite(value) else float(default)

def _integer(params, name, default, minimum, maximum):
    value = int(round(_number(params, name, default)))
    return max(minimum, min(maximum, value))

def _rolling_variance(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for end in range(length - 1, values.size):
        window = values[end - length + 1:end + 1]
        if np.all(np.isfinite(window)):
            result[end] = np.var(window, ddof=0)
    return result

def _yang_zhang_sigma(opens, highs, lows, closes, length):
    previous_closes = np.empty(closes.size, dtype=float)
    if closes.size:
        previous_closes[0] = opens[0]
        previous_closes[1:] = closes[:-1]
    with np.errstate(divide='ignore', invalid='ignore'):
        overnight = np.log(opens / previous_closes)
        close_open = np.log(closes / opens)
        high_open = np.log(highs / opens)
        high_close = np.log(highs / closes)
        low_open = np.log(lows / opens)
        low_close = np.log(lows / closes)
        rogers_satchell = high_open * high_close + low_open * low_close
    overnight_variance = _rolling_variance(overnight, length)
    close_open_variance = _rolling_variance(close_open, length)
    rs_mean = np.full(closes.size, np.nan, dtype=float)
    for end in range(length - 1, closes.size):
        window = rogers_satchell[end - length + 1:end + 1]
        if np.all(np.isfinite(window)):
            rs_mean[end] = np.mean(window)
    k = 0.34 / (1.34 + (length + 1.0) / max(length - 1.0, 1.0))
    variance = np.nan_to_num(overnight_variance, nan=0.0) + k * np.nan_to_num(close_open_variance, nan=0.0) + (1.0 - k) * np.nan_to_num(rs_mean, nan=0.0)
    return np.maximum(np.sqrt(np.maximum(variance, 0.0)), 1e-10)

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    opens_source = getattr(market, 'opens', None)
    if opens_source is None:
        opens_source = getattr(market, 'open', None)
    if opens_source is None:
        raise ValueError('market.opens is required for Yang-Zhang volatility')
    opens = np.asarray(opens_source, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if any((values.size != size for values in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must have length market.size')
    period = _integer(signal_params, 'period', 13, 5, 100)
    groups = _integer(signal_params, 'groups', 5, 3, 5)
    range_threshold = max(0.0, min(45.0, _number(signal_params, 'range_threshold', 0.5)))
    sigma_length = _integer(signal_params, 'sigma_length', 20, 5, 100)
    sigma = _yang_zhang_sigma(opens, highs, lows, closes, sigma_length)
    directions = np.zeros(size, dtype=np.int8)
    for t in range(groups * period, size):
        block_centers = []
        block_highs = []
        block_lows = []
        block_x = []
        valid = True
        for block in range(groups):
            end = t - block * period
            start = end - period + 1
            block_high = np.max(highs[start:end + 1])
            block_low = np.min(lows[start:end + 1])
            if not np.isfinite(block_high) or not np.isfinite(block_low) or block_high <= 0.0 or (block_low <= 0.0):
                valid = False
                break
            block_centers.append(np.exp((np.log(block_high) + np.log(block_low)) / 2.0))
            block_highs.append(block_high)
            block_lows.append(block_low)
            block_x.append(t - block * period - period // 2)
        if not valid or block_centers[0] == block_centers[1]:
            continue
        primary_direction = 1 if block_centers[0] > block_centers[1] else -1
        segment = 1
        for block in range(1, groups - 1):
            pair_direction = 1 if block_centers[block] > block_centers[block + 1] else -1 if block_centers[block] < block_centers[block + 1] else 0
            if pair_direction != primary_direction:
                break
            segment = block + 1
        if sigma[t] > 1e-10:
            angle = np.degrees(np.arctan((np.log(block_centers[0]) - np.log(block_centers[segment])) / (block_x[0] - block_x[segment]) / sigma[t]))
        else:
            angle = 0.0
        directions[t] = 0 if abs(angle) <= range_threshold else primary_direction
    long_entries = (directions == 1) & (np.concatenate(([0], directions[:-1])) != 1)
    short_entries = np.zeros(size, dtype=np.bool_)
    exit_params = {'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'isotropic_trend_up_transition', 'hypothesis': 'ICS 正向結構趨勢由非上升切換為上升時，可能代表新的上行結構啟動。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['period', 'groups', 'range_threshold', 'sigma_length'], 'signal_parameter_sets': [{'period': 13, 'groups': 5, 'range_threshold': 0.5, 'sigma_length': 20}]}
