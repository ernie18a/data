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

def _sma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length <= values.size:
        cumulative = np.cumsum(values, dtype=float)
        previous = np.concatenate(([0.0], cumulative[:-length]))
        result[length - 1:] = (cumulative[length - 1:] - previous) / float(length)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    ma_length = max(1, int(signal_params.get('ma_length', 20)))
    doji_tolerance = float(signal_params.get('doji_tolerance', 0.04))
    moving_average = _sma(closes, ma_length)
    for t in range(2, size):
        trend_index = t - 3
        if trend_index < 0 or not np.isfinite(moving_average[trend_index]):
            continue
        first = t - 2
        middle = t - 1
        third = t
        middle_range = highs[middle] - lows[middle]
        is_doji = middle_range > 0.0 and abs(closes[middle] - opens[middle]) <= doji_tolerance * middle_range
        is_bullish_abandoned_baby = closes[first] < opens[first] and is_doji and (closes[third] > opens[third]) and (highs[middle] < lows[first]) and (highs[middle] < lows[third]) and (closes[trend_index] <= moving_average[trend_index])
        long_entries[t] = is_bullish_abandoned_baby
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_abandoned_baby_long', 'hypothesis': '下行趨勢中的看漲遺棄嬰兒型態預示反轉，建立多單。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'doji_tolerance', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'doji_tolerance': 0.04, 'k_base': 2.0, 'mult': 2.0}]}
