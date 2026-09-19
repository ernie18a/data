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

def _parameter(signal_params, name, default):
    try:
        value = float(signal_params.get(name, default))
    except (AttributeError, TypeError, ValueError):
        value = float(default)
    return value if np.isfinite(value) else float(default)

def _sma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if values.size < length:
        return result
    finite = np.isfinite(values)
    safe_values = np.where(finite, values, 0.0)
    window = np.ones(length, dtype=float)
    sums = np.convolve(safe_values, window, mode='valid')
    counts = np.convolve(finite.astype(float), window, mode='valid')
    valid = counts == float(length)
    result[length - 1:] = np.divide(sums, counts, out=np.full(sums.shape, np.nan, dtype=float), where=valid)
    return result

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    for name, values in (('opens', opens), ('highs', highs), ('lows', lows), ('closes', closes)):
        if values.size != size:
            raise ValueError(f'features.market.{name} length must equal size')
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    doji_tolerance = np.clip(_parameter(signal_params, 'doji_tolerance', 0.04), 0.0, 1.0)
    ma_length = max(1, int(round(_parameter(signal_params, 'ma_length', 20.0))))
    moving_average = _sma(closes, ma_length)
    candle_range = highs - lows
    finite_candles = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & np.isfinite(candle_range) & (candle_range > 0.0)
    valid_doji = finite_candles & (np.abs(closes - opens) / candle_range <= doji_tolerance)
    if size >= 4:
        left_body_low = np.minimum(opens[1:-2], closes[1:-2])
        middle_high = highs[2:-1]
        right_body_low = np.minimum(opens[3:], closes[3:])
        three_doji = valid_doji[1:-2] & valid_doji[2:-1] & valid_doji[3:] & (middle_high < left_body_low) & (middle_high < right_body_low)
        trend_index = np.arange(size - 3)
        downtrend = np.isfinite(closes[trend_index]) & np.isfinite(moving_average[trend_index]) & (closes[trend_index] <= moving_average[trend_index])
        long_entries[3:] = three_doji & downtrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_tri_star_long', 'hypothesis': '三根有效十字線在下行 SMA 趨勢中形成下方星群缺口，預期價格反轉上行。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['doji_tolerance', 'ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'doji_tolerance': 0.04, 'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
