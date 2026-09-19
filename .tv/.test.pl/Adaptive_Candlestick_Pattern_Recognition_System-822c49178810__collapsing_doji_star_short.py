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
    ma_length = max(1, int(signal_params.get('ma_length', 20)))
    doji_tolerance = float(signal_params.get('doji_tolerance', 0.04))
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    moving_average = _sma(closes, ma_length)
    for t in range(2, size):
        first = t - 2
        doji = t - 1
        if first < 1:
            continue
        first_range = highs[first] - lows[first]
        doji_range = highs[doji] - lows[doji]
        if not np.isfinite(first_range) or not np.isfinite(doji_range) or doji_range <= 0.0 or (not np.isfinite(moving_average[first - 1])):
            continue
        bullish_first = closes[first] > opens[first]
        bearish_third = closes[t] < opens[t]
        is_doji = abs(closes[doji] - opens[doji]) / doji_range <= doji_tolerance
        collapsing_gap = highs[doji] < lows[first] and lows[doji] > highs[t]
        uptrend = closes[first - 1] > moving_average[first - 1]
        short_entries[t] = bullish_first and is_doji and bearish_third and collapsing_gap and uptrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'collapsing_doji_star_short', 'hypothesis': '上行趨勢中的崩塌十字星可能標示多方動能衰竭，適合做空反轉。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'doji_tolerance', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'doji_tolerance': 0.04, 'k_base': 2.0, 'mult': 2.0}]}
