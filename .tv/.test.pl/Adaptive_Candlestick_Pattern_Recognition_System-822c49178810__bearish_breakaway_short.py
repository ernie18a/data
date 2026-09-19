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
    if length < 1:
        raise ValueError('ma_length must be positive')
    if values.size >= length:
        prefix = np.concatenate(([0.0], np.cumsum(values, dtype=float)))
        result[length - 1:] = (prefix[length:] - prefix[:-length]) / float(length)
    return result

def _previous_mean(values, window):
    values = np.asarray(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    if window < 1:
        raise ValueError('tall_sample must be positive')
    if values.size > window:
        prefix = np.concatenate(([0.0], np.cumsum(values, dtype=float)))
        n = values.size
        result[window:] = (prefix[window:n] - prefix[:n - window]) / float(window)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    ma_length = int(signal_params.get('ma_length', 20))
    tall_sample = int(signal_params.get('tall_sample', 14))
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    if tall_multiplier <= 0.0:
        raise ValueError('tall_multiplier must be positive')
    moving_average = _sma(closes, ma_length)
    candle_ranges = highs - lows
    previous_range_mean = _previous_mean(candle_ranges, tall_sample)
    is_tall = candle_ranges >= tall_multiplier * previous_range_mean
    if size >= 5:
        c1_open = opens[:-4]
        c1_close = closes[:-4]
        c1_tall = is_tall[:-4]
        c2_open = opens[1:-3]
        c2_close = closes[1:-3]
        c2_bullish = c2_close >= c2_open
        c1_bullish = c1_close >= c1_open
        c3_open = opens[2:-2]
        c3_close = closes[2:-2]
        c3_body_high = np.maximum(c3_open, c3_close)
        c3_body_low = np.minimum(c3_open, c3_close)
        c4_open = opens[3:-1]
        c4_close = closes[3:-1]
        c4_bullish = c4_close >= c4_open
        c5_open = opens[4:]
        c5_close = closes[4:]
        c5_bearish = c5_close < c5_open
        c5_tall = is_tall[4:]
        uptrend = (closes[:-4] > moving_average[:-4]) & np.isfinite(moving_average[:-4])
        bearish_breakaway = c1_tall & c5_tall & c1_bullish & c2_bullish & (c2_open > c1_close) & (c3_body_high > c2_close) & (c3_body_low > c1_close) & c4_bullish & (c4_close > c3_body_high) & (c4_open > c1_open) & c5_bearish & (c5_close > c1_close) & (c5_close < c2_open) & uptrend
        short_entries[4:] = bearish_breakaway
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bearish_breakaway_short', 'hypothesis': '上行趨勢中的看跌 Breakaway 形態可能預示下跌反轉。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_multiplier', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_multiplier': 1.5, 'k_base': 2.0, 'mult': 2.0}]}
