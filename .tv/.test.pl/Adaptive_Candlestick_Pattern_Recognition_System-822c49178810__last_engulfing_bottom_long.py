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
    if length > values.size:
        return result
    cumulative = np.cumsum(values, dtype=np.float64)
    prior = np.concatenate((np.array([0.0], dtype=np.float64), cumulative[:-length]))
    result[length - 1:] = (cumulative[length - 1:] - prior) / float(length)
    return result

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    ma_length = int(signal_params.get('ma_length', 20))
    if ma_length < 1:
        raise ValueError('ma_length must be positive')
    ma = _rolling_sma(closes, ma_length)
    trend_index = np.arange(size, dtype=np.int64) - 3
    trend_valid = (trend_index >= ma_length - 1) & (trend_index < size)
    downtrend = np.zeros(size, dtype=np.bool_)
    downtrend[trend_valid] = closes[trend_index[trend_valid]] <= ma[trend_index[trend_valid]]
    if size >= 2:
        previous_bullish = closes[:-1] >= opens[:-1]
        current_bearish = closes[1:] < opens[1:]
        previous_body_high = np.maximum(opens[:-1], closes[:-1])
        previous_body_low = np.minimum(opens[:-1], closes[:-1])
        current_body_high = np.maximum(opens[1:], closes[1:])
        current_body_low = np.minimum(opens[1:], closes[1:])
        body_engulfing = (current_body_high > previous_body_high) & (current_body_low < previous_body_low)
        long_entries[1:] = previous_bullish & current_bearish & body_engulfing & downtrend[1:]
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, {'k_base': 2.0, 'mult': 2.0})
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'last_engulfing_bottom_long', 'hypothesis': '下行 MA 中的最後吞沒底部型態可能捕捉多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length'], 'signal_parameter_sets': [{'ma_length': 20}]}
