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
    for index in range(window - 1, values.size):
        result[index] = np.mean(values[index - window + 1:index + 1])
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    ranges = highs - lows
    ma_length = max(1, int(signal_params.get('ma_length', 20)))
    tall_sample = max(1, int(signal_params.get('tall_sample', 14)))
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    doji_tolerance = float(signal_params.get('doji_tolerance', 0.04))
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    moving_average = _sma(closes, ma_length)
    for t in range(size):
        if t < max(ma_length + 2, tall_sample + 2):
            continue
        previous = t - 1
        trend_index = t - 3
        sample_start = previous - tall_sample - 1
        sample_end = previous - 1
        if sample_start < 0 or sample_end <= sample_start:
            continue
        previous_range = ranges[previous]
        average_range = np.mean(ranges[sample_start:sample_end])
        current_range = ranges[t]
        if not (np.isfinite(previous_range) and np.isfinite(average_range)):
            continue
        if not (np.isfinite(current_range) and current_range > 0.0):
            continue
        if not np.isfinite(moving_average[trend_index]):
            continue
        previous_bearish = closes[previous] < opens[previous]
        previous_high_volatility = previous_range >= average_range * tall_multiplier
        current_doji = abs(closes[t] - opens[t]) / current_range <= doji_tolerance
        gap_below_previous_close = highs[t] < closes[previous]
        downtrend = closes[trend_index] <= moving_average[trend_index]
        long_entries[t] = previous_bearish and previous_high_volatility and current_doji and gap_below_previous_close and downtrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_doji_star_long', 'hypothesis': '下行趨勢中的看漲 Doji Star 可能標示空方動能衰竭，適合做多反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_multiplier', 'doji_tolerance', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_multiplier': 1.5, 'doji_tolerance': 0.04, 'k_base': 2.0, 'mult': 2.0}]}
