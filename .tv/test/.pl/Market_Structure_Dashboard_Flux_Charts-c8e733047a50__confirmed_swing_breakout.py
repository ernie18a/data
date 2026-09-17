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

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size == 0:
        empty = np.zeros(0, dtype=np.bool_)
        return (empty, empty.copy(), empty.copy(), empty.copy())
    market = features.market
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if highs.size != size or lows.size != size or closes.size != size:
        raise ValueError('market OHLC arrays must match market.size')
    swing_length = int(signal_params.get('swing_length', 5))
    if swing_length < 1:
        raise ValueError('swing_length must be positive')
    latest_swing_high = np.nan
    latest_swing_low = np.nan
    for t in range(size):
        if t >= 2 * swing_length:
            pivot = t - swing_length
            high_left = highs[pivot - swing_length:pivot]
            high_right = highs[pivot + 1:t + 1]
            low_left = lows[pivot - swing_length:pivot]
            low_right = lows[pivot + 1:t + 1]
            if np.isfinite(highs[pivot]) and np.all(np.isfinite(high_left)) and np.all(np.isfinite(high_right)) and (highs[pivot] > np.max(high_left)) and (highs[pivot] > np.max(high_right)):
                latest_swing_high = highs[pivot]
            if np.isfinite(lows[pivot]) and np.all(np.isfinite(low_left)) and np.all(np.isfinite(low_right)) and (lows[pivot] < np.min(low_left)) and (lows[pivot] < np.min(low_right)):
                latest_swing_low = lows[pivot]
        if t == 0 or not np.isfinite(closes[t]) or (not np.isfinite(closes[t - 1])):
            continue
        if np.isfinite(latest_swing_high):
            long_entries[t] = closes[t] > latest_swing_high and closes[t - 1] <= latest_swing_high
        if np.isfinite(latest_swing_low):
            short_entries[t] = closes[t] < latest_swing_low and closes[t - 1] >= latest_swing_low
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    long_exits = np.asarray(long_exits, dtype=np.bool_).reshape(-1)
    short_exits = np.asarray(short_exits, dtype=np.bool_).reshape(-1)
    if long_exits.size != size or short_exits.size != size:
        raise ValueError('exit arrays must match market.size')
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'confirmed_swing_breakout', 'hypothesis': '突破最近已確認的擺動高低點可能代表結構動能延續，雙向順勢進場。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['swing_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'swing_length': 5, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
