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
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)[:size]
    highs = np.asarray(market.highs, dtype=float).reshape(-1)[:size]
    lows = np.asarray(market.lows, dtype=float).reshape(-1)[:size]
    closes = np.asarray(market.closes, dtype=float).reshape(-1)[:size]
    mode = str(signal_params.get('engulfing_mode', 'range')).lower()
    if mode not in ('range', 'body'):
        raise ValueError("engulfing_mode must be 'range' or 'body'")
    ma_length = int(signal_params.get('ma_length', 20))
    moving_average = _sma(closes, ma_length)
    downtrend = np.zeros(size, dtype=np.bool_)
    downtrend[:] = np.isfinite(closes) & np.isfinite(moving_average) & (closes <= moving_average)
    previous_bearish = closes[:-1] < opens[:-1]
    current_bullish = closes[1:] > opens[1:]
    if mode == 'range':
        engulfing = (highs[1:] >= highs[:-1]) & (lows[1:] <= lows[:-1])
    else:
        engulfing = (opens[1:] <= closes[:-1]) & (closes[1:] >= opens[:-1])
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    long_entries[1:] = previous_bearish & current_bullish & engulfing & downtrend[1:]
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_engulfing_long', 'hypothesis': '下行動態 MA 中的看漲吞沒形態可能預示多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['engulfing_mode', 'ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'engulfing_mode': 'range', 'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}, {'engulfing_mode': 'body', 'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
