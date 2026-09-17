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
    values = np.asarray(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    if length < 1 or values.size < length:
        return result
    cumulative = np.cumsum(values, dtype=float)
    result[length - 1:] = (cumulative[length - 1:] - np.r_[0.0, cumulative[:-length]]) / length
    return result

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(market.opens, dtype=float)
    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    ma_length = int(signal_params.get('ma_length', 20))
    doji_tolerance = float(signal_params.get('doji_tolerance', 0.04))
    trend_ma = _sma(closes, ma_length)
    if size >= 4 and ma_length >= 1:
        first_open = opens[1:-2]
        first_close = closes[1:-2]
        first_high = highs[1:-2]
        middle_open = opens[2:-1]
        middle_close = closes[2:-1]
        middle_low = lows[2:-1]
        middle_range = highs[2:-1] - lows[2:-1]
        third_open = opens[3:]
        third_close = closes[3:]
        third_high = highs[3:]
        middle_is_doji = (middle_range > 0.0) & (np.abs(middle_close - middle_open) / middle_range <= doji_tolerance)
        bearish_abandoned_baby = (first_close >= first_open) & middle_is_doji & (middle_low > first_high) & (middle_low > third_high) & (third_close < third_open) & (closes[:-3] > trend_ma[:-3])
        short_entries[3:] = bearish_abandoned_baby
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bearish_abandoned_baby_short', 'hypothesis': '上行趨勢中的看跌隔離嬰兒形態預示反轉下跌。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'doji_tolerance', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'doji_tolerance': 0.04, 'k_base': 2.0, 'mult': 2.0}]}
