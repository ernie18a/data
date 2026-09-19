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

def generate_signals(features, signal_params):
    import numpy as np
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    doji_tol = float(signal_params.get('i_DojiTol', 0.04))
    wick_base = str(signal_params.get('i_DojiWickBase', 'WICKS')).upper()
    wick_sample = int(signal_params.get('i_DojiWickSam', 14))
    long_wick_tol = float(signal_params.get('i_DLWT', 3.0))
    shadow_tol = float(signal_params.get('i_GS_DFDojiSSize', 0.02))
    ranges = highs - lows
    bodies = np.abs(closes - opens)
    upper_wicks = highs - np.maximum(opens, closes)
    lower_wicks = np.minimum(opens, closes) - lows
    if wick_sample > 0:
        for t in range(wick_sample, size):
            current_range = ranges[t]
            if not np.isfinite(current_range) or current_range <= 0.0:
                continue
            start = t - wick_sample
            previous_ranges = ranges[start:t]
            if not np.all(np.isfinite(previous_ranges)):
                continue
            if wick_base == 'RANGE':
                if np.any(previous_ranges <= 0.0):
                    continue
                previous_lower = lower_wicks[start:t] / previous_ranges
                current_lower = lower_wicks[t] / current_range
            else:
                previous_lower = lower_wicks[start:t]
                current_lower = lower_wicks[t]
            previous_lower_avg = float(np.mean(previous_lower))
            is_doji = bodies[t] / current_range <= doji_tol
            has_long_lower_wick = current_lower >= previous_lower_avg * long_wick_tol
            has_small_upper_wick = upper_wicks[t] <= shadow_tol * current_range
            if is_doji and has_long_lower_wick and has_small_upper_wick:
                long_entries[t] = True
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'dragonfly_doji_long', 'hypothesis': 'Dragonfly Doji 的長下影線反映下方拒絕，可能形成多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_DojiTol', 'i_DojiWickBase', 'i_DojiWickSam', 'i_DLWT', 'i_GS_DFDojiSSize'], 'signal_parameter_sets': [{'i_DojiTol': 0.04, 'i_DojiWickBase': 'WICKS', 'i_DojiWickSam': 14, 'i_DLWT': 3.0, 'i_GS_DFDojiSSize': 0.02}]}
