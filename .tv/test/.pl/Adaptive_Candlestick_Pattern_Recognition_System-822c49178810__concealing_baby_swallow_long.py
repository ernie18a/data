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
    size = int(features.market.size)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    params = signal_params or {}
    ma_window = max(1, int(params.get('ma_window', 20)))
    tall_window = max(1, int(params.get('tall_window', 14)))
    tall_multiplier = float(params.get('tall_multiplier', 1.5))
    c3_wick_ratio = float(params.get('c3_wick_ratio', 0.5))
    marubozu_inclusive = bool(params.get('marubozu_inclusive', False))
    engulf_inclusive = bool(params.get('engulf_inclusive', False))
    candle_range = highs - lows
    bearish = closes < opens
    moving_average = np.full(size, np.nan, dtype=float)
    if size >= ma_window:
        moving_average[ma_window - 1:] = np.convolve(closes, np.ones(ma_window, dtype=float) / ma_window, mode='valid')
    previous_range_average = np.full(size, np.nan, dtype=float)
    for index in range(tall_window, size):
        sample = candle_range[index - tall_window:index]
        if np.all(np.isfinite(sample)):
            previous_range_average[index] = float(np.mean(sample))

    def is_tall(index):
        average = previous_range_average[index]
        return np.isfinite(average) and np.isfinite(candle_range[index]) and (candle_range[index] >= tall_multiplier * average)
    high_touches_open = np.isclose(highs, opens, rtol=1e-10, atol=1e-12)
    low_touches_close = np.isclose(lows, closes, rtol=1e-10, atol=1e-12)

    def is_bearish_marubozu(index):
        if not bearish[index]:
            return False
        if marubozu_inclusive:
            return bool(high_touches_open[index] or low_touches_close[index])
        return bool(high_touches_open[index] and low_touches_close[index])
    for index in range(3, size):
        first, second, third, fourth = (index - 3, index - 2, index - 1, index)
        trend_reference = index - 4
        if trend_reference < 0:
            continue
        if not (np.isfinite(closes[trend_reference]) and np.isfinite(moving_average[trend_reference]) and (closes[trend_reference] < moving_average[trend_reference])):
            continue
        if not (is_tall(first) and is_tall(second)):
            continue
        if not (is_bearish_marubozu(first) and is_bearish_marubozu(second) and bearish[third] and (opens[third] < closes[second])):
            continue
        second_body_low = min(opens[second], closes[second])
        second_body_high = max(opens[second], closes[second])
        high_in_second_body = second_body_low < highs[third] < second_body_high
        upper_wick = highs[third] - opens[third]
        third_size_valid = upper_wick > 0.0 and abs(closes[third] - opens[third]) / upper_wick <= c3_wick_ratio
        if not (high_in_second_body and third_size_valid):
            continue
        if not is_bearish_marubozu(fourth):
            continue
        range_engulfs = highs[fourth] >= highs[third] and lows[fourth] <= lows[third] if engulf_inclusive else highs[fourth] > highs[third] and lows[fourth] < lows[third]
        if range_engulfs:
            long_entries[index] = True
    exit_params = dict(params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'concealing_baby_swallow_long', 'hypothesis': '下行趨勢中的 Concealing Baby Swallow 形態可能帶來多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_window', 'tall_window', 'tall_multiplier', 'c3_wick_ratio', 'marubozu_inclusive', 'engulf_inclusive'], 'signal_parameter_sets': [{'ma_window': 20, 'tall_window': 14, 'tall_multiplier': 1.5, 'c3_wick_ratio': 0.5, 'marubozu_inclusive': False, 'engulf_inclusive': False}]}
