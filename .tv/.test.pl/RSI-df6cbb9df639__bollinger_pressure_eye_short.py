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

def _rolling_sma_std(values, length):
    values = np.asarray(values, dtype=float).reshape(-1)
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
    params = signal_params or {}
    if size == 0:
        return (long_entries, np.zeros(size, dtype=np.bool_), short_entries, np.zeros(size, dtype=np.bool_))
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    if closes.size != size or highs.size != size:
        raise ValueError('market closes and highs must match market size')
    eye_len = int(params.get('eye_len', 20))
    eye_mult = float(params.get('eye_mult', 2.0))
    eye_mode = str(params.get('eye_mode', 'high')).lower()
    if eye_len < 2:
        raise ValueError('eye_len must be at least 2')
    if not np.isfinite(eye_mult) or eye_mult <= 0.0:
        raise ValueError('eye_mult must be finite and positive')
    if eye_mode in {'high', 'wick'}:
        pressure_series = highs
    elif eye_mode in {'close', 'closes'}:
        pressure_series = closes
    else:
        raise ValueError("eye_mode must be 'high' or 'close'")
    basis, deviation = _rolling_sma_std(closes, eye_len)
    upper_band = basis + eye_mult * deviation
    outside = np.isfinite(pressure_series) & np.isfinite(upper_band) & (pressure_series > upper_band)
    active = False
    extreme_price = -np.inf
    extreme_index = -1
    for index in range(size):
        if outside[index]:
            if not active or highs[index] > extreme_price:
                extreme_price = highs[index]
                extreme_index = index
            active = True
        elif active:
            if 0 <= extreme_index < index:
                short_entries[index] = True
            active = False
            extreme_price = -np.inf
            extreme_index = -1
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bollinger_pressure_eye_short', 'hypothesis': '布林上軌連續突破後回到帶內，可能代表上方壓力與上漲動能衰竭，形成空頭反轉機會。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['eye_len', 'eye_mult', 'eye_mode', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'eye_len': 20, 'eye_mult': 2.0, 'eye_mode': 'high', 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
