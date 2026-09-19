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

def _ema(values, length):
    values = np.asarray(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    alpha = 2.0 / (length + 1.0)
    finite = np.flatnonzero(np.isfinite(values))
    if finite.size == 0:
        return result
    first = int(finite[0])
    result[first] = values[first]
    for index in range(first + 1, values.size):
        if np.isfinite(values[index]):
            previous = result[index - 1]
            result[index] = alpha * values[index] + (1.0 - alpha) * previous if np.isfinite(previous) else values[index]
    return result

def _rsi(values, length):
    values = np.asarray(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    if values.size <= length:
        return result
    delta = np.diff(values, prepend=np.nan)
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
    average_gain = np.nan
    average_loss = np.nan
    for index in range(length, values.size):
        if index == length or not np.isfinite(average_gain):
            gain_window = gains[index - length + 1:index + 1]
            loss_window = losses[index - length + 1:index + 1]
            if not (np.all(np.isfinite(gain_window)) and np.all(np.isfinite(loss_window))):
                continue
            average_gain = float(np.mean(gain_window))
            average_loss = float(np.mean(loss_window))
        else:
            if not (np.isfinite(gains[index]) and np.isfinite(losses[index])):
                average_gain = np.nan
                average_loss = np.nan
                continue
            average_gain = (average_gain * (length - 1.0) + gains[index]) / length
            average_loss = (average_loss * (length - 1.0) + losses[index]) / length
        if average_loss == 0.0:
            result[index] = 50.0 if average_gain == 0.0 else 100.0
        else:
            result[index] = 100.0 - 100.0 / (1.0 + average_gain / average_loss)
    return result

def _rolling_extreme(values, length, maximum):
    values = np.asarray(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.max(window) if maximum else np.min(window)
    return result

def _sma(values, length):
    values = np.asarray(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _stoch_rsi(values, rsi_length, stoch_length, k_length, d_length):
    rsi = _rsi(values, rsi_length)
    lowest = _rolling_extreme(rsi, stoch_length, False)
    highest = _rolling_extreme(rsi, stoch_length, True)
    denominator = np.maximum(highest - lowest, 1e-10)
    raw = (rsi - lowest) / denominator * 100.0
    k = _sma(raw, k_length)
    d = _sma(k, d_length)
    return (k, d)

def _macd_histogram(values, fast_length, slow_length, signal_length):
    fast = _ema(values, fast_length)
    slow = _ema(values, slow_length)
    macd = fast - slow
    signal = _ema(macd, signal_length)
    return macd - signal

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    closes = np.asarray(market.closes, dtype=float)
    if closes.ndim != 1 or closes.size != size:
        raise ValueError('features.market.closes must be a one-dimensional market-sized array')
    primary_histogram = _macd_histogram(closes, 12, 26, 9)
    primary_k, primary_d = _stoch_rsi(closes, 14, 8, 3, 3)
    secondary_k, secondary_d = _stoch_rsi(closes, 7, 7, 3, 2)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size > 1:
        finite_long = np.isfinite(primary_histogram[1:]) & np.isfinite(primary_histogram[:-1]) & np.isfinite(primary_k[1:]) & np.isfinite(primary_d[1:]) & np.isfinite(secondary_k[1:]) & np.isfinite(secondary_d[1:])
        finite_short = finite_long.copy()
        long_entries[1:] = finite_long & ((primary_histogram[1:] > primary_histogram[:-1]) & (primary_k[1:] > primary_d[1:]) & (secondary_k[1:] > secondary_d[1:]))
        short_entries[1:] = finite_short & ((primary_histogram[1:] < primary_histogram[:-1]) & (primary_k[1:] < primary_d[1:]) & (secondary_k[1:] < secondary_d[1:]))
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'rems_deep_synergy_c1', 'hypothesis': 'Primary MACD 柱體上升且 Primary/Secondary Stoch RSI 同向排列時，捕捉多週期動能共振。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
