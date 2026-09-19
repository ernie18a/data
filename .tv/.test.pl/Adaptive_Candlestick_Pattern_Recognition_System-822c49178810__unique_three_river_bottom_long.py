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

def _sma(values, period):
    result = np.full(values.size, np.nan, dtype=np.float64)
    if period <= 0:
        raise ValueError('ma_length must be positive')
    for index in range(period - 1, values.size):
        window = values[index - period + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _tall_flags(opens, highs, lows, closes, sample, multiplier, mode):
    if sample <= 0:
        raise ValueError('tall_sample must be positive')
    if multiplier <= 0.0:
        raise ValueError('tall_multiplier must be positive')
    if mode not in ('RANGE', 'BODY'):
        raise ValueError('tall_mode must be RANGE or BODY')
    sizes = highs - lows if mode == 'RANGE' else np.abs(closes - opens)
    flags = np.zeros(sizes.size, dtype=np.bool_)
    for index in range(sample, sizes.size):
        current = sizes[index]
        previous = sizes[index - sample:index]
        if np.isfinite(current) and np.all(np.isfinite(previous)):
            flags[index] = abs(current) >= np.mean(previous) * multiplier
    return flags

def generate_signals(features, signal_params):
    size = int(features.market.size)
    market = features.market
    opens = np.asarray(market.opens, dtype=np.float64).reshape(-1)
    highs = np.asarray(market.highs, dtype=np.float64).reshape(-1)
    lows = np.asarray(market.lows, dtype=np.float64).reshape(-1)
    closes = np.asarray(market.closes, dtype=np.float64).reshape(-1)
    if any((series.size != size for series in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must equal features.market.size')
    ma_length = int(signal_params.get('ma_length', 20))
    tall_sample = int(signal_params.get('tall_sample', 14))
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    tall_mode = str(signal_params.get('tall_mode', 'RANGE')).upper()
    include_open_close = bool(signal_params.get('include_open_close', False))
    ma = _sma(closes, ma_length)
    tall = _tall_flags(opens, highs, lows, closes, tall_sample, tall_multiplier, tall_mode)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for index in range(2, size):
        first = index - 2
        second = index - 1
        trend_index = index - 3
        if trend_index < 0 or not np.isfinite(ma[trend_index]):
            continue
        downtrend = closes[trend_index] <= ma[trend_index]
        first_bearish = opens[first] > closes[first]
        second_bearish = opens[second] > closes[second]
        second_open_inside = closes[first] <= opens[second] <= opens[first] if include_open_close else closes[first] < opens[second] < opens[first]
        third_bullish = closes[index] >= opens[index]
        third_not_tall = not tall[index]
        if downtrend and first_bearish and tall[first] and second_bearish and second_open_inside and (lows[second] < lows[first]) and third_bullish and third_not_tall and (closes[index] < closes[second]):
            long_entries[index] = True
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'unique_three_river_bottom_long', 'hypothesis': '下行趨勢中的 Unique Three River Bottom 看漲反轉形態預期帶來多頭機會。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_multiplier', 'tall_mode', 'include_open_close', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_multiplier': 1.5, 'tall_mode': 'RANGE', 'include_open_close': False, 'k_base': 2.0, 'mult': 2.0}]}
