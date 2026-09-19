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

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    hammer_tol = float(signal_params.get('i_HammerTol', 0.35))
    ma_length = 20
    ma = np.full(size, np.nan, dtype=float)
    for t in range(ma_length - 1, size):
        window = closes[t - ma_length + 1:t + 1]
        if np.all(np.isfinite(window)):
            ma[t] = np.mean(window)
    for t in range(1, size):
        if not np.isfinite(ma[t - 1]):
            continue
        open_price = opens[t]
        high = highs[t]
        low = lows[t]
        close = closes[t]
        candle_range = high - low
        body = abs(close - open_price)
        if not (np.isfinite(open_price) and np.isfinite(high) and np.isfinite(low) and np.isfinite(close) and (candle_range > 0.0) and (body > 0.0)):
            continue
        midpoint = (open_price + close) / 2.0
        body_position = (midpoint - low) / candle_range
        if close >= open_price:
            upper_wick = high - close
            lower_wick = open_price - low
        else:
            upper_wick = high - open_price
            lower_wick = close - low
        downtrend = closes[t - 1] <= ma[t - 1]
        long_entries[t] = downtrend and body_position > 0.5 and (lower_wick / body >= 2.0) and (upper_wick / body <= hammer_tol)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, {'k_base': 2.0, 'mult': 2.0})
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'hammer_long', 'hypothesis': '錘頭線出現在動態 MA 下行趨勢後，可能形成多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_HammerTol'], 'signal_parameter_sets': [{'i_HammerTol': 0.35}]}
