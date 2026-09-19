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

def _sma(values, window):
    import numpy as np
    result = np.full(values.size, np.nan, dtype=float)
    if window <= 0:
        return result
    running = 0.0
    for index, value in enumerate(values):
        running += value
        if index >= window:
            running -= values[index - window]
        if index + 1 >= window:
            result[index] = running / window
    return result

def _previous_mean(values, window):
    import numpy as np
    result = np.full(values.size, np.nan, dtype=float)
    if window <= 0:
        return result
    running = 0.0
    for index, value in enumerate(values):
        if index >= window:
            result[index] = running / window
            running -= values[index - window]
        running += value
    return result

def generate_signals(features, signal_params):
    import numpy as np
    params = signal_params or {}
    size = int(features.market.size)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    doji_tolerance = float(params.get('doji_tolerance', 0.04))
    tall_window = max(1, int(params.get('tall_window', 14)))
    tall_multiplier = float(params.get('tall_multiplier', 1.5))
    ma_window = max(1, int(params.get('ma_window', 20)))
    ranges = highs - lows
    previous_range_mean = _previous_mean(ranges, tall_window)
    dynamic_ma = _sma(closes, ma_window)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for index in range(3, size):
        first = index - 2
        middle = index - 1
        first_range = ranges[first]
        third_range = ranges[index]
        middle_body = abs(closes[middle] - opens[middle])
        middle_is_doji = ranges[middle] > 0.0 and middle_body / ranges[middle] <= doji_tolerance
        middle_body_high = max(opens[middle], closes[middle])
        first_body_low = min(opens[first], closes[first])
        third_body_low = min(opens[index], closes[index])
        first_is_tall = np.isfinite(previous_range_mean[first]) and first_range >= tall_multiplier * previous_range_mean[first]
        third_is_tall = np.isfinite(previous_range_mean[index]) and third_range >= tall_multiplier * previous_range_mean[index]
        downtrend = np.isfinite(dynamic_ma[first - 1]) and closes[first - 1] < dynamic_ma[first - 1]
        long_entries[index] = bool(first_is_tall and third_is_tall and (closes[first] < opens[first]) and (closes[index] > opens[index]) and middle_is_doji and (middle_body_high < first_body_low) and (middle_body_high < third_body_low) and (closes[index] > (opens[first] + closes[first]) / 2.0) and downtrend)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, {'k_base': float(params.get('k_base', 2.0)), 'mult': float(params.get('mult', 2.0))})
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'morning_doji_star_long', 'hypothesis': '下行趨勢中的高波動晨星十字形態可能反映多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['doji_tolerance', 'tall_window', 'tall_multiplier', 'ma_window', 'k_base', 'mult'], 'signal_parameter_sets': [{'doji_tolerance': 0.04, 'tall_window': 14, 'tall_multiplier': 1.5, 'ma_window': 20, 'k_base': 2.0, 'mult': 2.0}]}
