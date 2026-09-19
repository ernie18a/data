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
    size = features.market.size
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    ma_length = 20
    tall_sample = 14
    tall_multiplier = 1.5
    if size > ma_length:
        cumulative = np.concatenate(([0.0], np.cumsum(closes)))
        moving_average = np.full(size, np.nan, dtype=float)
        moving_average[ma_length - 1:] = (cumulative[ma_length:] - cumulative[:-ma_length]) / ma_length
    else:
        moving_average = np.full(size, np.nan, dtype=float)
    ranges = highs - lows
    for t in range(size):
        previous = t - 1
        if previous < 1:
            continue
        sample_end = previous - 1
        sample_start = sample_end - tall_sample + 1
        if sample_start < 0:
            continue
        average_range = float(np.mean(ranges[sample_start:sample_end + 1]))
        if not np.isfinite(average_range) or average_range <= 0.0:
            continue
        previous_is_tall_bear = closes[previous] < opens[previous] and ranges[previous] >= tall_multiplier * average_range
        current_is_bull = closes[t] >= opens[t]
        current_within_previous_range = lows[previous] < opens[t] < highs[previous] and lows[previous] < closes[t] < highs[previous]
        bodies_not_identical = not (opens[t] == closes[previous] and closes[t] == opens[previous] or (opens[t] == opens[previous] and closes[t] == closes[previous]))
        downtrend = t >= 2 and np.isfinite(moving_average[t - 2]) and (closes[t - 2] <= moving_average[t - 2])
        long_entries[t] = previous_is_tall_bear and current_is_bull and current_within_previous_range and bodies_not_identical and downtrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, {'k_base': 2.0, 'mult': 2.0})
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_harami_long', 'hypothesis': '下行動態MA趨勢中的高波動陰線後看多孕線可能形成反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': [], 'signal_parameter_sets': [{}]}
