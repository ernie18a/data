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
    size = features.market.size
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    ranges = highs - lows
    ma_period = max(2, int(signal_params.get('ma_period', 20)))
    volatility_window = max(1, int(signal_params.get('volatility_window', 20)))
    volatility_multiplier = float(signal_params.get('volatility_multiplier', 1.0))
    volatility_mean = np.full(size, np.nan, dtype=float)
    moving_average = np.full(size, np.nan, dtype=float)
    for t in range(size):
        if t >= volatility_window:
            volatility_mean[t] = np.mean(ranges[t - volatility_window:t])
        if t + 1 >= ma_period:
            moving_average[t] = np.mean(closes[t - ma_period + 1:t + 1])
    for t in range(4, size):
        first = t - 4
        second = t - 3
        third = t - 2
        fourth = t - 1
        downtrend = first > 0 and np.isfinite(moving_average[first]) and np.isfinite(moving_average[first - 1]) and (closes[first] < moving_average[first]) and (moving_average[first] < moving_average[first - 1])
        long_entries[t] = bool(np.isfinite(volatility_mean[first]) and np.isfinite(volatility_mean[t]) and (ranges[first] > volatility_multiplier * volatility_mean[first]) and (ranges[t] > volatility_multiplier * volatility_mean[t]) and (closes[first] < opens[first]) and (closes[second] < opens[second]) and (opens[second] < closes[first]) and (highs[third] < closes[first]) and (closes[fourth] < opens[fourth]) and (lows[fourth] < lows[third]) and (closes[t] > opens[t]) and (opens[second] < closes[t] < closes[first]) and downtrend)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, {'k_base': 2.0, 'mult': 2.0})
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_breakaway_long', 'hypothesis': '下行趨勢中的看漲 Breakaway 五根 K 形態預示多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_period', 'volatility_window', 'volatility_multiplier'], 'signal_parameter_sets': [{'ma_period': 20, 'volatility_window': 20, 'volatility_multiplier': 1.0}]}
