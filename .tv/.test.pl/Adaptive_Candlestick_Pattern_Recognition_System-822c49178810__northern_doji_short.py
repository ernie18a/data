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

def _rolling_sma(values, length):
    length = int(length)
    if length < 2:
        raise ValueError('ma_length must be at least 2')
    result = np.full(values.shape, np.nan, dtype=float)
    for t in range(length - 1, values.size):
        window = values[t - length + 1:t + 1]
        if np.all(np.isfinite(window)):
            result[t] = np.mean(window)
    return result

def generate_signals(features, signal_params):
    size = features.market.size
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    tolerance = float(signal_params.get('i_DojiTol', 0.1))
    ma_length = int(signal_params.get('ma_length', 20))
    if not np.isfinite(tolerance) or tolerance < 0.0:
        raise ValueError('i_DojiTol must be a finite non-negative scalar')
    if opens.size != size or highs.size != size or lows.size != size or (closes.size != size):
        raise ValueError('market OHLC arrays must match market.size')
    ranges = highs - lows
    body = np.abs(closes - opens)
    doji = np.isfinite(body) & np.isfinite(ranges) & (ranges > 0.0) & (body / ranges <= tolerance)
    moving_average = _rolling_sma(closes, ma_length)
    prior_uptrend = np.zeros(size, dtype=np.bool_)
    if size >= 3:
        prior_uptrend[2:] = np.isfinite(closes[1:-1]) & np.isfinite(moving_average[1:-1]) & np.isfinite(moving_average[:-2]) & (closes[1:-1] > moving_average[1:-1]) & (moving_average[1:-1] > moving_average[:-2])
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = doji & prior_uptrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'northern_doji_short', 'hypothesis': '上升趨勢中的北方十字線可能預示反轉，建立空頭部位。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_DojiTol', 'ma_length'], 'signal_parameter_sets': [{'i_DojiTol': 0.1, 'ma_length': 20}]}
