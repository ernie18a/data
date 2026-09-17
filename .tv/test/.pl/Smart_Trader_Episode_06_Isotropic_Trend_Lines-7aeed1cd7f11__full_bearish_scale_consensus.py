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
_SCALE_PERIODS = (3, 7, 13, 19, 29, 47)
_GROUPS = 5
_RANGE_THRESHOLD = 0.5
_SIGMA_LENGTH = 20
_MIN_SIGMA = 1e-10

def _market_series(market, names, size):
    for name in names:
        if not hasattr(market, name):
            continue
        value = getattr(market, name)
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
    raise ValueError(f'market 必須提供等長的一維序列: {names}')

def _rolling_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        part = values[index - window + 1:index + 1]
        if np.all(np.isfinite(part)):
            result[index] = np.mean(part)
    return result

def _rolling_variance(values, window):
    mean = _rolling_mean(values, window)
    second = _rolling_mean(values * values, window)
    result = second - mean * mean
    return np.where(np.isfinite(result), np.maximum(result, 0.0), np.nan)

def _rolling_extreme(values, window, maximum):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        part = values[index - window + 1:index + 1]
        if np.all(np.isfinite(part)):
            result[index] = np.max(part) if maximum else np.min(part)
    return result

def _yang_zhang_sigma(opens, highs, lows, closes, window):
    previous_close = np.empty(closes.size, dtype=float)
    if closes.size:
        previous_close[0] = opens[0]
    if closes.size > 1:
        previous_close[1:] = closes[:-1]
    with np.errstate(divide='ignore', invalid='ignore'):
        overnight = np.log(opens / previous_close)
        open_close = np.log(closes / opens)
        high_open = np.log(highs / opens)
        high_close = np.log(highs / closes)
        low_open = np.log(lows / opens)
        low_close = np.log(lows / closes)
        rogers_satchell = high_open * high_close + low_open * low_close
    variance_overnight = _rolling_variance(overnight, window)
    variance_open_close = _rolling_variance(open_close, window)
    mean_rogers_satchell = _rolling_mean(rogers_satchell, window)
    k = 0.34 / (1.34 + (window + 1.0) / max(window - 1.0, 1.0))
    squared_sigma = np.where(np.isfinite(variance_overnight), variance_overnight, 0.0) + k * np.where(np.isfinite(variance_open_close), variance_open_close, 0.0) + (1.0 - k) * np.where(np.isfinite(mean_rogers_satchell), mean_rogers_satchell, 0.0)
    return np.maximum(np.sqrt(np.maximum(squared_sigma, 0.0)), _MIN_SIGMA)

def _scale_direction(t, period, groups, threshold, sigma, rolling_high, rolling_low):
    if t < groups * period:
        return 0
    geometric_means = []
    for group in range(groups):
        end = t - group * period
        high = rolling_high[end]
        low = rolling_low[end]
        if not np.isfinite(high) or not np.isfinite(low) or high <= 0.0 or (low <= 0.0):
            return 0
        geometric_means.append(np.exp((np.log(high) + np.log(low)) / 2.0))
    primary = geometric_means[0]
    next_mean = geometric_means[1]
    if primary == next_mean:
        return 0
    direction = 1 if primary > next_mean else -1
    segment = 1
    for index in range(1, groups - 1):
        left = geometric_means[index]
        right = geometric_means[index + 1]
        pair_direction = 1 if left > right else -1 if left < right else 0
        if pair_direction == direction:
            segment = index + 1
        else:
            break
    angle = np.degrees(np.arctan((np.log(primary) - np.log(geometric_means[segment])) / max(_MIN_SIGMA, sigma[t]) / float(segment * period)))
    return 0 if abs(angle) <= threshold else direction

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, long_entries.copy(), long_entries.copy(), long_entries.copy())
    opens = _market_series(market, ('opens', 'open'), size)
    highs = _market_series(market, ('highs', 'high'), size)
    lows = _market_series(market, ('lows', 'low'), size)
    closes = _market_series(market, ('closes', 'close'), size)
    _market_series(market, ('volumes', 'volume'), size)
    sigma = _yang_zhang_sigma(opens, highs, lows, closes, _SIGMA_LENGTH)
    rolling_high = {period: _rolling_extreme(highs, period, True) for period in _SCALE_PERIODS}
    rolling_low = {period: _rolling_extreme(lows, period, False) for period in _SCALE_PERIODS}
    short_entries = np.zeros(size, dtype=np.bool_)
    previous_down_consensus = 0
    for t in range(size):
        down_consensus = 0
        for period in _SCALE_PERIODS:
            direction = _scale_direction(t, period, _GROUPS, _RANGE_THRESHOLD, sigma, rolling_high[period], rolling_low[period])
            if direction == -1:
                down_consensus += 1
        short_entries[t] = down_consensus == 6 and previous_down_consensus != 6
        previous_down_consensus = down_consensus
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params or {})
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'full_bearish_scale_consensus', 'hypothesis': '六尺度結構一致轉空且共識剛達成時建立空頭，並以趨勢型 I5 出場。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
