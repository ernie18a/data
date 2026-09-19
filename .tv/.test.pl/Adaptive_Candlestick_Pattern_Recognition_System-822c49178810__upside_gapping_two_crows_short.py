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

def _ema(values, span):
    result = np.empty(values.size, dtype=float)
    if values.size == 0:
        return result
    alpha = 2.0 / (span + 1.0)
    result[0] = values[0]
    for index in range(1, values.size):
        result[index] = alpha * values[index] + (1.0 - alpha) * result[index - 1]
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    if size >= 3:
        ranges = highs - lows
        ma = _ema(closes, 20)
        tall_window = 14
        tall_multiplier = 1.5
        for index in range(2, size):
            first = index - 2
            second = index - 1
            if first < tall_window:
                continue
            prior_average_range = np.mean(ranges[first - tall_window:first])
            first_is_tall = ranges[first] >= tall_multiplier * prior_average_range
            first_is_bullish = closes[first] > opens[first]
            second_is_bearish = closes[second] < opens[second]
            third_is_bearish = closes[index] < opens[index]
            second_is_above_first_close = closes[second] > closes[first]
            body_engulfs = opens[index] > opens[second] and closes[index] < closes[second]
            range_engulfs = highs[index] > highs[second] and lows[index] < lows[second]
            third_closes_above_first_open = closes[index] > opens[first]
            in_uptrend = closes[first] > ma[first]
            short_entries[index] = first_is_tall and first_is_bullish and second_is_bearish and third_is_bearish and second_is_above_first_close and (body_engulfs or range_engulfs) and third_closes_above_first_open and in_uptrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'upside_gapping_two_crows_short', 'hypothesis': '上行趨勢中的高波動上行缺口雙烏鴉形態預示短線反轉下跌。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'mult'], 'signal_parameter_sets': [{'k_base': 2.0, 'mult': 2.0}]}
