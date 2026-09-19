import numpy as np

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    volumes = features.market.volumes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    gamma = float(signal_params.get('gamma', 1.0))
    n_base = float(signal_params.get('n_base', 2000.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    cum_vol = 0.0
    entry_atr = 1.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
                cum_vol += volumes[t]
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
                cum_vol += volumes[t]
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
    return (long_exits, short_exits)

def _rolling_sma(values, period):
    result = np.full(values.size, np.nan, dtype=float)
    if period <= 0:
        return result
    cumulative = np.cumsum(values, dtype=float)
    for index in range(period - 1, values.size):
        previous = cumulative[index - period] if index >= period else 0.0
        result[index] = (cumulative[index] - previous) / period
    return result

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    ma_period = max(1, int(signal_params.get('ma_period', 20)))
    atr_period = max(1, int(signal_params.get('atr_period', 14)))
    volatility_multiplier = float(signal_params.get('volatility_multiplier', 1.0))
    moving_average = _rolling_sma(closes, ma_period)
    atr = np.asarray(features.atr(atr_period), dtype=float)
    ranges = highs - lows
    for t in range(4, size):
        first = t - 4
        middle = slice(t - 3, t)
        finite = np.isfinite(opens[first:t + 1]).all() and np.isfinite(highs[first:t + 1]).all() and np.isfinite(lows[first:t + 1]).all() and np.isfinite(closes[first:t + 1]).all() and np.isfinite(atr[first:t + 1]).all() and np.isfinite(moving_average[t]) and np.isfinite(moving_average[t - 1])
        if not finite:
            continue
        first_bullish = closes[first] > opens[first]
        fifth_bullish = closes[t] > opens[t]
        first_high_volatility = ranges[first] > volatility_multiplier * atr[first]
        fifth_high_volatility = ranges[t] > volatility_multiplier * atr[t]
        middle_inside_first = np.all(highs[middle] <= highs[first]) and np.all(lows[middle] >= lows[first])
        middle_bearish = np.all(closes[middle] < opens[middle])
        middle_retracing = closes[t - 3] < closes[first] and closes[t - 2] < closes[t - 3] and (closes[t - 1] < closes[t - 2])
        middle_contracting = ranges[t - 3] >= ranges[t - 2] >= ranges[t - 1]
        rising_ma_trend = moving_average[t] > moving_average[t - 1] and closes[t] > moving_average[t]
        long_entries[t] = first_bullish and fifth_bullish and first_high_volatility and fifth_high_volatility and middle_inside_first and middle_bearish and middle_retracing and middle_contracting and (closes[t] > closes[first]) and rising_ma_trend
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'rising_three_methods_long', 'hypothesis': '上行動態均線中的上升三法型態，可能延續原有多頭趨勢。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_period', 'atr_period', 'volatility_multiplier', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'ma_period': 20, 'atr_period': 14, 'volatility_multiplier': 1.0, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
