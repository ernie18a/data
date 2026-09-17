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

def _sma(values, window):
    result = np.full(values.shape, np.nan, dtype=float)
    if window <= values.size:
        cumulative = np.cumsum(values, dtype=float)
        result[window - 1:] = (cumulative[window - 1:] - np.concatenate(([0.0], cumulative[:-window]))) / window
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    ma_window = max(1, int(signal_params.get('ma_window', 20)))
    moving_average = _sma(closes, ma_window)
    for t in range(2, size):
        first = t - 2
        second = t - 1
        first_bullish = closes[first] > opens[first]
        second_bearish = closes[second] < opens[second]
        third_bearish = closes[t] < opens[t]
        body_engulfed = max(opens[second], closes[second]) > max(opens[first], closes[first]) and min(opens[second], closes[second]) < min(opens[first], closes[first])
        range_engulfed = highs[second] > highs[first] and lows[second] < lows[first]
        trend_index = t - 3
        in_uptrend = trend_index >= 0 and np.isfinite(moving_average[trend_index]) and (closes[trend_index] > moving_average[trend_index])
        short_entries[t] = first_bullish and second_bearish and third_bearish and (body_engulfed or range_engulfed) and (closes[t] < closes[second]) and in_uptrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, {'k_base': 2.0, 'mult': 2.0})
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'three_outside_down_short', 'hypothesis': 'A three-outside-down reversal in an uptrend may signal continued downside and support a short position.', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_window'], 'signal_parameter_sets': [{'ma_window': 20}]}
