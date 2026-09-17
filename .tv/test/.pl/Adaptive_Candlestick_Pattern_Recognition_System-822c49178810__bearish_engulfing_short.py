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
    import numpy as np
    if length < 1:
        raise ValueError('ma_length must be positive')
    cumulative = np.cumsum(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    if values.size >= length:
        previous = np.concatenate(([0.0], cumulative[:-length]))
        result[length - 1:] = (cumulative[length - 1:] - previous) / float(length)
    return result

def generate_signals(features, signal_params):
    import numpy as np
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    mode = str(signal_params.get('engulfing_mode', 'range')).lower()
    if mode not in ('range', 'body'):
        raise ValueError("engulfing_mode must be 'range' or 'body'")
    ma_length = int(signal_params.get('ma_length', 20))
    moving_average = _sma(closes, ma_length)
    ma_uptrend = np.zeros(size, dtype=np.bool_)
    if size > 1:
        ma_uptrend[1:] = (moving_average[1:] > moving_average[:-1]) & (closes[1:] > moving_average[1:])
    bullish_previous = closes[:-1] > opens[:-1]
    bearish_current = closes[1:] < opens[1:]
    if mode == 'range':
        engulfing = (highs[1:] >= highs[:-1]) & (lows[1:] <= lows[:-1])
    else:
        engulfing = (opens[1:] >= closes[:-1]) & (closes[1:] <= opens[:-1])
    short_entries[1:] = bullish_previous & bearish_current & engulfing & ma_uptrend[1:]
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bearish_engulfing_short', 'hypothesis': '上行趨勢中的看跌吞沒可能預示下行反轉。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['engulfing_mode', 'ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'engulfing_mode': 'range', 'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}, {'engulfing_mode': 'body', 'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
