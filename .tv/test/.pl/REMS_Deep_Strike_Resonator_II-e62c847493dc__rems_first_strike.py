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

def _sma(values, length):
    values = np.asarray(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _ema(values, length):
    values = np.asarray(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    index = 0
    alpha = 2.0 / (length + 1.0)
    while index < values.size:
        while index < values.size and (not np.isfinite(values[index])):
            index += 1
        start = index
        while index < values.size and np.isfinite(values[index]):
            index += 1
        if index - start < length:
            continue
        seed = start + length - 1
        result[seed] = np.mean(values[start:seed + 1])
        for current in range(seed + 1, index):
            result[current] = alpha * values[current] + (1.0 - alpha) * result[current - 1]
    return result

def _rsi(values, length):
    values = np.asarray(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    if values.size <= length:
        return result
    changes = np.diff(values)
    gains = np.maximum(changes, 0.0)
    losses = np.maximum(-changes, 0.0)
    avg_gain = np.mean(gains[:length])
    avg_loss = np.mean(losses[:length])

    def value(gain, loss):
        if loss == 0.0:
            return 50.0 if gain == 0.0 else 100.0
        return 100.0 - 100.0 / (1.0 + gain / loss)
    result[length] = value(avg_gain, avg_loss)
    for index in range(length + 1, values.size):
        avg_gain = ((length - 1.0) * avg_gain + gains[index - 1]) / length
        avg_loss = ((length - 1.0) * avg_loss + losses[index - 1]) / length
        result[index] = value(avg_gain, avg_loss)
    return result

def _stoch_rsi(values):
    rsi = _rsi(values, 14)
    raw = np.full(values.shape, np.nan, dtype=float)
    for index in range(7, values.size):
        window = rsi[index - 7:index + 1]
        if np.all(np.isfinite(window)):
            low = np.min(window)
            high = np.max(window)
            raw[index] = (rsi[index] - low) / max(high - low, 1e-10) * 100.0
    k = _sma(raw, 3)
    return (k, _sma(k, 3))

def _cross(first, second):
    previous_first = np.roll(first, 1)
    previous_second = np.roll(second, 1)
    previous_first[0] = np.nan
    previous_second[0] = np.nan
    finite = np.isfinite(first) & np.isfinite(second) & np.isfinite(previous_first) & np.isfinite(previous_second)
    return finite & ((first > second) & (previous_first <= previous_second) | (first < second) & (previous_first >= previous_second))

def _primary_series(features):
    size = features.market.size
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    if closes.size != size:
        raise ValueError('market.closes must match market.size')
    rsi = _rsi(closes, 14)
    ema_fast = _ema(closes, 12)
    ema_slow = _ema(closes, 26)
    macd = ema_fast - ema_slow
    macd_signal = _ema(macd, 9)
    hist = macd - macd_signal
    stoch_k, stoch_d = _stoch_rsi(closes)
    ema8 = _ema(closes, 8)
    ema21 = _ema(closes, 21)
    return (rsi, hist, stoch_k, stoch_d, ema8, ema21, macd, macd_signal)

def generate_signals(features, signal_params):
    size = features.market.size
    rsi, hist, stoch_k, stoch_d, ema_fast, ema_slow, macd, macd_signal = _primary_series(features)
    rsi_previous = np.roll(rsi, 1)
    hist_previous = np.roll(hist, 1)
    rsi_previous[0] = np.nan
    hist_previous[0] = np.nan
    long_raw = (rsi > rsi_previous) & (hist > hist_previous) & (stoch_k > stoch_d)
    short_raw = (rsi < rsi_previous) & (hist < hist_previous) & (stoch_k < stoch_d)
    reset_event = _cross(rsi, _sma(rsi, 20)) | _cross(ema_fast, ema_slow) | _cross(macd, macd_signal) | _cross(stoch_k, stoch_d)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    long_cooldown = False
    short_cooldown = False
    for index in range(size):
        reset = bool(reset_event[index])
        long_entries[index] = bool(long_raw[index]) and (not long_cooldown or reset)
        short_entries[index] = bool(short_raw[index]) and (not short_cooldown or reset)
        if bool(long_raw[index]):
            long_cooldown = True
        elif reset:
            long_cooldown = False
        if bool(short_raw[index]):
            short_cooldown = True
        elif reset:
            short_cooldown = False
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (np.asarray(long_entries, dtype=np.bool_).reshape(-1), np.asarray(long_exits, dtype=np.bool_).reshape(-1), np.asarray(short_entries, dtype=np.bool_).reshape(-1), np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'rems_first_strike', 'hypothesis': 'Primary RSI、MACD 柱體與 Stoch RSI 同向動能延續，搭配趨勢型防守出場。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
