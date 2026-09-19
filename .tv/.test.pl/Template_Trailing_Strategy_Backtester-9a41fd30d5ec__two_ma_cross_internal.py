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

def _series(value, size, name):
    array = np.asarray(value, dtype=float)
    if array.ndim != 1 or array.size != size:
        raise ValueError(f'{name} must be a one-dimensional array of market.size')
    return array

def _rolling_mean(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _rolling_wma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    weights = np.arange(1, length + 1, dtype=float)
    denominator = float(np.sum(weights))
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = float(np.dot(window, weights) / denominator)
    return result

def _rolling_vwma(values, volumes, length):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        price_window = values[index - length + 1:index + 1]
        volume_window = volumes[index - length + 1:index + 1]
        denominator = float(np.sum(volume_window))
        if np.all(np.isfinite(price_window)) and np.all(np.isfinite(volume_window)) and (denominator > 0.0):
            result[index] = float(np.dot(price_window, volume_window) / denominator)
    return result

def _ema(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    alpha = 2.0 / (length + 1.0)
    seed_index = None
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
            seed_index = index
            break
    if seed_index is None:
        return result
    for index in range(seed_index + 1, values.size):
        if np.isfinite(values[index]) and np.isfinite(result[index - 1]):
            result[index] = alpha * values[index] + (1.0 - alpha) * result[index - 1]
    return result

def _rma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    seed_index = None
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
            seed_index = index
            break
    if seed_index is None:
        return result
    for index in range(seed_index + 1, values.size):
        if np.isfinite(values[index]) and np.isfinite(result[index - 1]):
            result[index] = (result[index - 1] * (length - 1.0) + values[index]) / length
    return result

def _rolling_median(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.median(window)
    return result

def _rolling_linreg(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    x = np.arange(length, dtype=float)
    centered_x = x - np.mean(x)
    denominator = float(np.dot(centered_x, centered_x))
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)) and denominator > 0.0:
            slope = float(np.dot(centered_x, window - np.mean(window)) / denominator)
            result[index] = float(np.mean(window) + slope * (length - 1 - np.mean(x)))
    return result

def _rolling_alma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    offset = 0.85
    sigma = 6.0
    center = offset * (length - 1)
    scale = length / sigma
    positions = np.arange(length, dtype=float)
    weights = np.exp(-(positions - center) ** 2 / (2.0 * scale * scale))
    weights /= np.sum(weights)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = float(np.dot(window, weights))
    return result

def _rolling_swma(values):
    result = np.full(values.size, np.nan, dtype=float)
    weights = np.array([1.0, 2.0, 2.0, 1.0])
    for index in range(3, values.size):
        window = values[index - 3:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = float(np.dot(window, weights) / 6.0)
    return result

def _moving_average(values, volumes, length, ma_type):
    kind = str(ma_type).strip().lower().rsplit('.', 1)[-1].replace('_', '').replace('-', '')
    if kind in {'sma', 'simple', 'simplemovingaverage'}:
        return _rolling_mean(values, length)
    if kind in {'ema', 'exponential', 'exponentialmovingaverage'}:
        return _ema(values, length)
    if kind in {'rma', 'wilder'}:
        return _rma(values, length)
    if kind in {'wma', 'weighted', 'weightedmovingaverage'}:
        return _rolling_wma(values, length)
    if kind in {'vwma', 'volumeweighted', 'volumeweightedmovingaverage'}:
        if volumes is None:
            raise ValueError('volumes are required for VWMA')
        return _rolling_vwma(values, volumes, length)
    if kind == 'hma':
        half = max(1, length // 2)
        root = max(1, int(np.sqrt(length)))
        raw = 2.0 * _rolling_wma(values, half) - _rolling_wma(values, length)
        return _rolling_wma(raw, root)
    if kind == 'dema':
        first = _ema(values, length)
        return 2.0 * first - _ema(first, length)
    if kind == 'swma':
        return _rolling_swma(values)
    if kind in {'linreg', 'linearregression'}:
        return _rolling_linreg(values, length)
    if kind == 'median':
        return _rolling_median(values, length)
    if kind == 'alma':
        return _rolling_alma(values, length)
    raise ValueError(f'unsupported moving-average type: {ma_type}')

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty.copy(), empty.copy(), empty.copy(), empty.copy())
    params = signal_params or {}
    fast_length = max(1, int(params.get('fast_ma_length', 21)))
    slow_length = max(1, int(params.get('slow_ma_length', 49)))
    fast_type = params.get('fast_ma_type', 'sma')
    slow_type = params.get('slow_ma_type', 'sma')
    closes = _series(market.closes, size, 'features.market.closes')
    volumes = None
    fast_kind = str(fast_type).lower().rsplit('.', 1)[-1].replace('_', '').replace('-', '')
    slow_kind = str(slow_type).lower().rsplit('.', 1)[-1].replace('_', '').replace('-', '')
    if fast_kind in {'vwma', 'volumeweighted', 'volumeweightedmovingaverage'} or slow_kind in {'vwma', 'volumeweighted', 'volumeweightedmovingaverage'}:
        volumes = _series(market.volumes, size, 'features.market.volumes')
    fast_ma = _moving_average(closes, volumes, fast_length, fast_type)
    slow_ma = _moving_average(closes, volumes, slow_length, slow_type)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size > 1:
        ready = np.isfinite(fast_ma) & np.isfinite(slow_ma)
        long_entries[1:] = ready[1:] & ready[:-1] & (fast_ma[1:] > slow_ma[1:]) & (fast_ma[:-1] <= slow_ma[:-1])
        short_entries[1:] = ready[1:] & ready[:-1] & (fast_ma[1:] < slow_ma[1:]) & (fast_ma[:-1] >= slow_ma[:-1])
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'two_ma_cross_internal', 'hypothesis': 'A fast moving-average crossover identifies bullish and bearish trend entries.', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['fast_ma_type', 'fast_ma_length', 'slow_ma_type', 'slow_ma_length'], 'signal_parameter_sets': [{'fast_ma_type': 'sma', 'fast_ma_length': 21, 'slow_ma_type': 'sma', 'slow_ma_length': 49}]}
