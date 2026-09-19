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

def _rolling_sma(values, length):
    import numpy as np
    if length < 1:
        raise ValueError('ma_length must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    finite = np.isfinite(values)
    clean = np.where(finite, values, 0.0)
    prefix = np.concatenate((np.array([0.0]), np.cumsum(clean, dtype=float)))
    counts = np.concatenate((np.array([0], dtype=np.int64), np.cumsum(finite, dtype=np.int64)))
    window_sum = prefix[length:] - prefix[:-length]
    window_count = counts[length:] - counts[:-length]
    complete = window_count == length
    tail = result[length - 1:]
    tail[complete] = window_sum[complete] / length
    return result

def generate_signals(features, signal_params):
    import numpy as np
    size = int(features.market.size)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    ma_length = int(signal_params.get('ma_length', 20))
    doji_tolerance = float(signal_params.get('doji_tolerance', 0.04))
    if ma_length < 1 or not np.isfinite(doji_tolerance) or doji_tolerance < 0.0:
        raise ValueError('invalid signal parameters')
    candle_range = highs - lows
    body_ratio = np.full(size, np.nan, dtype=float)
    valid_range = np.isfinite(candle_range) & (candle_range > 0.0)
    body_ratio[valid_range] = np.abs(closes[valid_range] - opens[valid_range]) / candle_range[valid_range]
    doji = valid_range & np.isfinite(opens) & np.isfinite(closes) & (body_ratio <= doji_tolerance)
    ma = _rolling_sma(closes, ma_length)
    uptrend = np.isfinite(closes) & np.isfinite(ma) & (closes > ma)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size >= 3:
        first_body_high = np.maximum(opens[:-2], closes[:-2])
        third_body_high = np.maximum(opens[2:], closes[2:])
        middle_low = lows[1:-1]
        tri_star = doji[:-2] & doji[1:-1] & doji[2:] & np.isfinite(middle_low) & np.isfinite(first_body_high) & np.isfinite(third_body_high) & (middle_low > first_body_high) & (middle_low > third_body_high) & uptrend[2:]
        short_entries[2:] = tri_star
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bearish_tri_star_short', 'hypothesis': '上行趨勢中的 bearish Tri-Star 可能預示反轉下跌，採空單交易。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'doji_tolerance', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'doji_tolerance': 0.04, 'k_base': 2.0, 'mult': 2.0}]}
