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

def _is_confirmed_high(highs, index, swing_length):
    pivot = index - swing_length
    if pivot < swing_length:
        return False
    value = highs[pivot]
    return np.isfinite(value) and np.all(value > highs[pivot - swing_length:pivot]) and np.all(value > highs[pivot + 1:pivot + swing_length + 1])

def _is_confirmed_low(lows, index, swing_length):
    pivot = index - swing_length
    if pivot < swing_length:
        return False
    value = lows[pivot]
    return np.isfinite(value) and np.all(value < lows[pivot - swing_length:pivot]) and np.all(value < lows[pivot + 1:pivot + swing_length + 1])

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    if len(highs) != size or len(lows) != size or len(closes) != size:
        raise ValueError('market OHLC arrays must match features.market.size')
    params = dict(signal_params or {})
    swing_length = int(params.get('swing_length', 5))
    if swing_length < 1:
        raise ValueError('swing_length must be >= 1')
    current_high = None
    previous_high = None
    current_low = None
    previous_low = None
    high_type = 0
    low_type = 0
    previous_bias = 0
    for t in range(size):
        if _is_confirmed_high(highs, t, swing_length):
            previous_high = current_high
            current_high = float(highs[t - swing_length])
            if previous_high is not None:
                high_type = 1 if current_high > previous_high else -1
        if _is_confirmed_low(lows, t, swing_length):
            previous_low = current_low
            current_low = float(lows[t - swing_length])
            if previous_low is not None:
                low_type = 1 if current_low > previous_low else -1
        real_time_high_type = high_type
        real_time_low_type = low_type
        if previous_low is not None and closes[t] < previous_low:
            real_time_low_type = -1
        if previous_high is not None and closes[t] > previous_high:
            real_time_high_type = 1
        if real_time_high_type == 1 and real_time_low_type == 1:
            bias = 1
        elif real_time_high_type == -1 and real_time_low_type == -1:
            bias = -1
        else:
            bias = 0
        if bias == 1 and previous_bias != 1:
            long_entries[t] = True
        if bias == -1 and previous_bias != -1:
            short_entries[t] = True
        previous_bias = bias
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'market_structure_bias_transition', 'hypothesis': '已確認 swing 的 HH/HL 或 LH/LL 結構轉換，可捕捉市場方向偏向的早期變化。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['swing_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'swing_length': 5, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
