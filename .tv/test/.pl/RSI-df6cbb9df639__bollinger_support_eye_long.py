import numpy as np

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    mult = float(signal_params.get('mult', 2.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    entry_price = 0.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif closes[t] >= entry_price + mult * atr[t]:
                long_exits[t] = True
                position = 0
            elif closes[t] < entry_price - mult * atr[t]:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif closes[t] <= entry_price - mult * atr[t]:
                short_exits[t] = True
                position = 0
            elif closes[t] > entry_price + mult * atr[t]:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                entry_price = closes[t]
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                entry_price = closes[t]
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
    return (long_exits, short_exits)

def _rolling_sma_std(values, length):
    means = np.full(values.size, np.nan, dtype=float)
    stds = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            means[index] = np.mean(window)
            stds[index] = np.std(window, ddof=0)
    return (means, stds)

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, long_entries.copy(), short_entries, short_entries.copy())
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)[:size]
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)[:size]
    eye_len = int(signal_params.get('eye_len', 20))
    eye_mult = float(signal_params.get('eye_mult', 2.0))
    if eye_len < 2:
        raise ValueError('eye_len must be at least 2')
    if not np.isfinite(eye_mult) or eye_mult <= 0.0:
        raise ValueError('eye_mult must be finite and positive')
    basis, deviation = _rolling_sma_std(closes, eye_len)
    lower_band = basis - eye_mult * deviation
    outside = np.isfinite(lows) & np.isfinite(lower_band) & (lows < lower_band)
    active = False
    extreme_low = np.inf
    extreme_index = -1
    for index in range(size):
        if outside[index]:
            if not active or lows[index] < extreme_low:
                extreme_low = lows[index]
                extreme_index = index
            active = True
        elif active:
            if extreme_index >= 0 and extreme_index < index:
                long_entries[index] = True
            active = False
            extreme_low = np.inf
            extreme_index = -1
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bollinger_support_eye_long', 'hypothesis': '布林下軌連續突破後回到帶內，可能代表支撐與下跌動能衰竭，形成多頭反轉機會。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['eye_len', 'eye_mult', 'k_base', 'mult'], 'signal_parameter_sets': [{'eye_len': 20, 'eye_mult': 2.0, 'k_base': 2.0, 'mult': 2.0}]}
