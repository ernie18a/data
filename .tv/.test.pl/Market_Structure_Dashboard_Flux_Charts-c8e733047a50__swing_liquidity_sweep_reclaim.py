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

def _liquidity_sweep_reclaim_entries(features, swing_length):
    highs = np.asarray(features.market.highs)
    lows = np.asarray(features.market.lows)
    closes = np.asarray(features.market.closes)
    size = features.market.size
    length = int(swing_length)
    if length < 1:
        raise ValueError('swing_length must be >= 1')
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    swing_low = None
    swing_high = None
    low_swept = False
    high_swept = False
    low_consumed = False
    high_consumed = False
    for t in range(size):
        pivot = t - length
        if pivot >= length:
            pivot_high = highs[pivot]
            pivot_low = lows[pivot]
            left_highs = highs[pivot - length:pivot]
            right_highs = highs[pivot + 1:pivot + length + 1]
            left_lows = lows[pivot - length:pivot]
            right_lows = lows[pivot + 1:pivot + length + 1]
            if np.isfinite(pivot_high) and np.all(pivot_high > left_highs) and np.all(pivot_high > right_highs):
                swing_high = float(pivot_high)
                high_swept = False
                high_consumed = False
            if np.isfinite(pivot_low) and np.all(pivot_low < left_lows) and np.all(pivot_low < right_lows):
                swing_low = float(pivot_low)
                low_swept = False
                low_consumed = False
        if swing_low is not None and (not low_consumed):
            if lows[t] < swing_low:
                low_swept = True
            if low_swept and closes[t] > swing_low:
                long_entries[t] = True
                low_consumed = True
        if swing_high is not None and (not high_consumed):
            if highs[t] > swing_high:
                high_swept = True
            if high_swept and closes[t] < swing_high:
                short_entries[t] = True
                high_consumed = True
    return (long_entries, short_entries)

def generate_signals(features, signal_params):
    params = dict(signal_params or {})
    long_entries, short_entries = _liquidity_sweep_reclaim_entries(features, params.get('swing_length', 5))
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, {'k_base': float(params.get('k_base', 2.0)), 'mult': float(params.get('mult', 2.0))})
    size = features.market.size
    return (np.asarray(long_entries, dtype=np.bool_).reshape(size), np.asarray(long_exits, dtype=np.bool_).reshape(size), np.asarray(short_entries, dtype=np.bool_).reshape(size), np.asarray(short_exits, dtype=np.bool_).reshape(size))
STRATEGY = {'strategy_id': 'swing_liquidity_sweep_reclaim', 'hypothesis': '流動性掃掠後重新收回已確認 swing level，可能形成反轉進場訊號。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['swing_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'swing_length': 5, 'k_base': 2.0, 'mult': 2.0}]}
