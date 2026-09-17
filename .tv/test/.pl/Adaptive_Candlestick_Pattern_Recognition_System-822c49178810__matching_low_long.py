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

def _prior_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window, values.size):
        result[index] = np.mean(values[index - window:index])
    return result

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    match_tol = float(signal_params.get('i_MatchLowTol', 0.0))
    tall_sample = int(signal_params.get('tall_sample', 20))
    tall_tolerance = float(signal_params.get('tall_tolerance', 0.0))
    tall_mode = str(signal_params.get('tall_mode', 'range')).lower()
    ma_length = int(signal_params.get('ma_length', 20))
    if tall_sample <= 0 or ma_length <= 0 or match_tol < 0.0 or (tall_tolerance < 0.0):
        raise ValueError('matching_low_long parameters are out of range')
    if tall_mode == 'range':
        candle_size = highs - lows
    elif tall_mode == 'body':
        candle_size = np.abs(closes - opens)
    else:
        raise ValueError("tall_mode must be 'range' or 'body'")
    volatility_mean = _prior_mean(candle_size, tall_sample)
    ma = _prior_mean(closes, ma_length)
    for t in range(max(tall_sample + 1, ma_length + 1, 3), size):
        first = t - 1
        trend_reference = t - 2
        threshold_first = volatility_mean[first] * (1.0 + tall_tolerance)
        threshold_second = volatility_mean[t] * (1.0 + tall_tolerance)
        if not (np.isfinite(opens[first]) and np.isfinite(opens[t]) and np.isfinite(closes[first]) and np.isfinite(closes[t]) and np.isfinite(ma[trend_reference]) and np.isfinite(threshold_first) and np.isfinite(threshold_second)):
            continue
        long_entries[t] = closes[first] < opens[first] and closes[t] < opens[t] and (candle_size[first] > threshold_first) and (candle_size[t] <= threshold_second) and (abs(closes[t] - closes[first]) <= match_tol) and (closes[trend_reference] <= ma[trend_reference])
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'matching_low_long', 'hypothesis': 'Matching Low after a high-volatility bearish candle may produce a long reversal in a dynamic downtrend.', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_MatchLowTol', 'tall_sample', 'tall_tolerance', 'tall_mode', 'ma_length'], 'signal_parameter_sets': [{'i_MatchLowTol': 0.0, 'tall_sample': 20, 'tall_tolerance': 0.0, 'tall_mode': 'range', 'ma_length': 20}]}
