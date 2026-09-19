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
    result = np.full(values.size, np.nan, dtype=np.float64)
    for t in range(length - 1, values.size):
        window = values[t - length + 1:t + 1]
        if np.all(np.isfinite(window)):
            result[t] = np.mean(window)
    return result

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    opens = np.asarray(market.opens, dtype=np.float64)
    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    closes = np.asarray(market.closes, dtype=np.float64)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    doji_tol = float(signal_params.get('i_DojiTol', 0.04))
    ma_length = int(signal_params.get('ma_length', 20))
    moving_average = _rolling_sma(closes, ma_length)
    candle_range = highs - lows
    body = np.abs(closes - opens)
    valid = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & np.isfinite(moving_average) & (candle_range > 0.0)
    doji = valid & (body / candle_range <= doji_tol)
    downtrend = np.zeros(size, dtype=np.bool_)
    if size > 1:
        downtrend[1:] = np.isfinite(closes[:-1]) & np.isfinite(moving_average[:-1]) & (closes[:-1] <= moving_average[:-1])
    long_entries[:] = doji & downtrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'southern_doji_long', 'hypothesis': '下行動態 MA 中的 Southern Doji 可能形成多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_DojiTol', 'ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'i_DojiTol': 0.04, 'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
