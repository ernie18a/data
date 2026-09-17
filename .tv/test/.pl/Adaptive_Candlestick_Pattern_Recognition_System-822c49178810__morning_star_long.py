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

def _previous_mean(values, window):
    import numpy as np
    result = np.full(values.size, np.nan, dtype=np.float64)
    if window <= 0 or values.size <= window:
        return result
    cumulative = np.concatenate((np.array([0.0]), np.cumsum(values, dtype=np.float64)))
    result[window:] = (cumulative[window:] - cumulative[:-window]) / window
    return result

def _sma(values, window):
    import numpy as np
    result = np.full(values.size, np.nan, dtype=np.float64)
    if window <= 0 or values.size < window:
        return result
    cumulative = np.concatenate((np.array([0.0]), np.cumsum(values, dtype=np.float64)))
    result[window - 1:] = (cumulative[window:] - cumulative[:-window]) / window
    return result

def generate_signals(features, signal_params):
    import numpy as np
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    ma_length = int(signal_params.get('ma_length', 20))
    tall_sample = int(signal_params.get('tall_sample', 14))
    tall_tolerance = float(signal_params.get('tall_tolerance', 1.5))
    candle_ranges = highs - lows
    previous_range_mean = _previous_mean(candle_ranges, tall_sample)
    tall = candle_ranges >= tall_tolerance * previous_range_mean
    ma = _sma(closes, ma_length)
    first = slice(0, size - 2)
    middle = slice(1, size - 1)
    third = slice(2, size)
    first_body = closes[first] - opens[first]
    third_body = closes[third] - opens[third]
    middle_body_high = np.maximum(opens[middle], closes[middle])
    first_midprice = (opens[first] + closes[first]) / 2.0
    pattern = (first_body < 0.0) & (third_body >= 0.0) & tall[first] & tall[third] & (middle_body_high < closes[first]) & (middle_body_high < opens[third]) & (closes[third] > first_midprice)
    trend_index = np.arange(size) - 3
    trend_index_valid = trend_index >= 0
    downtrend = np.zeros(size, dtype=np.bool_)
    downtrend[trend_index_valid] = closes[trend_index[trend_index_valid]] <= ma[trend_index[trend_index_valid]]
    downtrend &= np.isfinite(ma[trend_index.clip(min=0)])
    long_entries[2:] = pattern & downtrend[2:]
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'morning_star_long', 'hypothesis': '下行趨勢中的 Morning Star 反轉形態可能預示多方反彈。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_tolerance', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_tolerance': 1.5, 'k_base': 2.0, 'mult': 2.0}]}
