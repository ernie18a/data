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
SCALES = (3, 7, 13, 19, 29, 47)
GROUPS = 5
RANGE_THRESHOLD = 0.5
SIGMA_LENGTH = 20

def _read_series(features, names, size):
    for owner in (features, getattr(features, 'market', None)):
        if owner is None:
            continue
        for name in names:
            if not hasattr(owner, name):
                continue
            value = getattr(owner, name)
            if callable(value):
                try:
                    value = value()
                except TypeError:
                    continue
            try:
                array = np.asarray(value, dtype=float)
            except (TypeError, ValueError):
                continue
            if array.ndim == 1 and array.size == size:
                return array
    return np.full(size, np.nan, dtype=float)

def _rolling_extreme(values, window, maximum):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        part = values[index - window + 1:index + 1]
        if np.all(np.isfinite(part)):
            result[index] = np.max(part) if maximum else np.min(part)
    return result

def _yang_zhang_sigma(opens, highs, lows, closes, window):
    size = closes.size
    overnight = np.full(size, np.nan, dtype=float)
    close_open = np.full(size, np.nan, dtype=float)
    rogers_satchell = np.full(size, np.nan, dtype=float)
    with np.errstate(divide='ignore', invalid='ignore'):
        for index in range(size):
            if not (np.isfinite(opens[index]) and np.isfinite(highs[index]) and np.isfinite(lows[index]) and np.isfinite(closes[index])):
                continue
            if opens[index] <= 0.0 or highs[index] <= 0.0 or lows[index] <= 0.0 or (closes[index] <= 0.0):
                continue
            previous_close = closes[index - 1] if index > 0 else opens[index]
            if np.isfinite(previous_close) and previous_close > 0.0:
                overnight[index] = np.log(opens[index] / previous_close)
            close_open[index] = np.log(closes[index] / opens[index])
            rogers_satchell[index] = np.log(highs[index] / opens[index]) * np.log(highs[index] / closes[index]) + np.log(lows[index] / opens[index]) * np.log(lows[index] / closes[index])
    result = np.full(size, np.nan, dtype=float)
    k = 0.34 / (1.34 + (window + 1.0) / max(window - 1.0, 1.0))
    for index in range(window - 1, size):
        part = slice(index - window + 1, index + 1)
        values = (overnight[part], close_open[part], rogers_satchell[part])
        if all((np.all(np.isfinite(value)) for value in values)):
            variance = np.var(values[0], ddof=0) + k * np.var(values[1], ddof=0) + (1.0 - k) * np.mean(values[2])
            result[index] = max(float(np.sqrt(max(variance, 0.0))), 1e-10)
    return result

def _direction_at(index, scale, groups, threshold, sigma, rolling_high, rolling_low):
    if index < groups * scale or not np.isfinite(sigma) or sigma <= 0.0:
        return 0
    means = []
    centers = []
    for block in range(groups):
        endpoint = index - block * scale
        high = rolling_high[endpoint]
        low = rolling_low[endpoint]
        if not np.isfinite(high) or not np.isfinite(low) or high <= 0.0 or (low <= 0.0):
            return 0
        means.append(float(np.sqrt(high * low)))
        centers.append(endpoint - scale // 2)
    if means[0] == means[1]:
        return 0
    primary = 1 if means[0] > means[1] else -1
    segment = 1
    for block in range(1, groups - 1):
        comparison = 1 if means[block] > means[block + 1] else -1 if means[block] < means[block + 1] else 0
        if comparison != primary:
            break
        segment = block + 1
    distance = centers[0] - centers[segment]
    if distance <= 0:
        return 0
    angle = np.degrees(np.arctan((np.log(means[0]) - np.log(means[segment])) / (sigma * distance)))
    return 0 if abs(angle) <= threshold else primary

def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    opens = _read_series(features, ('opens', 'open'), size)
    highs = _read_series(features, ('highs', 'high'), size)
    lows = _read_series(features, ('lows', 'low'), size)
    closes = _read_series(features, ('closes', 'close'), size)
    sigma = _yang_zhang_sigma(opens, highs, lows, closes, SIGMA_LENGTH)
    rolling = {scale: (_rolling_extreme(highs, scale, True), _rolling_extreme(lows, scale, False)) for scale in SCALES}
    long_entries = np.zeros(size, dtype=np.bool_)
    previous_up_count = 0
    for index in range(size):
        up_count = sum((_direction_at(index, scale, GROUPS, RANGE_THRESHOLD, sigma[index], rolling[scale][0], rolling[scale][1]) == 1 for scale in SCALES))
        long_entries[index] = up_count == 6 and previous_up_count != 6
        previous_up_count = up_count
    params = {} if signal_params is None else dict(signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, empty, params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), empty, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'full_bullish_scale_consensus', 'hypothesis': '六個 OHLC 結構尺度同步轉為上升時，代表跨尺度確認的多頭趨勢。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
