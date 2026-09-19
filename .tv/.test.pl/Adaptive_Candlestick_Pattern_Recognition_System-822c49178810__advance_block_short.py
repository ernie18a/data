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
    if length < 1:
        raise ValueError('ma_length must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, long_entries.copy(), short_entries, short_entries.copy())
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)[:size]
    highs = np.asarray(market.highs, dtype=float).reshape(-1)[:size]
    closes = np.asarray(market.closes, dtype=float).reshape(-1)[:size]
    ma_length = int(signal_params.get('ma_length', 20))
    moving_average = _sma(closes, ma_length)
    dynamic_uptrend = np.isfinite(closes) & np.isfinite(moving_average) & (closes > moving_average)
    bullish = closes > opens
    body_low = np.minimum(opens, closes)
    body_high = np.maximum(opens, closes)
    upper_wick = highs - body_high
    if size >= 3:
        finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(closes)
        three_bullish = bullish[:-2] & bullish[1:-1] & bullish[2:]
        second_open_inside = (opens[1:-1] > body_low[:-2]) & (opens[1:-1] < body_high[:-2])
        third_open_inside = (opens[2:] > body_low[1:-1]) & (opens[2:] < body_high[1:-1])
        wicks_increase = (upper_wick[1:-1] > upper_wick[:-2]) & (upper_wick[2:] > upper_wick[1:-1])
        valid = finite[:-2] & finite[1:-1] & finite[2:] & three_bullish & second_open_inside & third_open_inside & wicks_increase & dynamic_uptrend[2:]
        short_entries[2:] = valid
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'advance_block_short', 'hypothesis': '上行動態 MA 中的 Advance Block 三連陽形態可能預示空頭反轉。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
