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
import numpy as np

def _sma(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    if values.size >= window:
        result[window - 1:] = np.convolve(values, np.ones(window, dtype=float), mode='valid') / window
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if any((values.size != size for values in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match features.market.size')
    ma_length = max(1, int(signal_params.get('ma_length', 20)))
    tall_sample = max(1, int(signal_params.get('tall_sample', 14)))
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    moving_average = _sma(closes, ma_length)
    candle_ranges = highs - lows
    for t in range(1, size):
        first = t - 1
        trend_index = t - 2
        if first < tall_sample or trend_index < ma_length - 1:
            continue
        first_open = opens[first]
        first_close = closes[first]
        second_open = opens[t]
        second_close = closes[t]
        average_range = np.mean(candle_ranges[first - tall_sample:first])
        values = (first_open, first_close, second_open, second_close, average_range, moving_average[trend_index])
        if not all((np.isfinite(value) for value in values)):
            continue
        if average_range <= 0.0:
            continue
        first_bearish = first_close < first_open
        second_bearish = second_close < second_open
        body_low = min(first_open, first_close)
        body_high = max(first_open, first_close)
        second_within_first_body = body_low < second_open < body_high and body_low < second_close < body_high
        first_is_tall = candle_ranges[first] >= average_range * tall_multiplier
        downtrend = closes[trend_index] <= moving_average[trend_index]
        long_entries[t] = first_bearish and second_bearish and second_within_first_body and first_is_tall and downtrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'homing_pigeon_long', 'hypothesis': '下行趨勢中的高波動雙陰線內包形態可能標示空方動能衰竭，適合做多反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_multiplier', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_multiplier': 1.5, 'k_base': 2.0, 'mult': 2.0}]}
