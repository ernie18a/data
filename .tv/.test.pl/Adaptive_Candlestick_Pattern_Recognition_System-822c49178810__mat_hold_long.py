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

def _sma(values: np.ndarray, length: int) -> np.ndarray:
    result = np.full(values.size, np.nan, dtype=np.float64)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = float(np.mean(window))
    return result

def _tall_candles(highs: np.ndarray, lows: np.ndarray, sample: int, multiplier: float) -> np.ndarray:
    sizes = highs - lows
    result = np.zeros(sizes.size, dtype=np.bool_)
    for index in range(sample + 1, sizes.size):
        previous_sizes = sizes[index - sample - 1:index - 1]
        if np.all(np.isfinite(previous_sizes)) and np.isfinite(sizes[index]) and (sizes[index] >= multiplier * float(np.mean(previous_sizes))):
            result[index] = True
    return result

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    ma_length = int(signal_params.get('ma_length', 20))
    tall_sample = int(signal_params.get('tall_sample', 14))
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    if ma_length < 1 or tall_sample < 1 or tall_multiplier <= 0.0:
        raise ValueError('ma_length、tall_sample 必須為正整數，tall_multiplier 必須為正數')
    moving_average = _sma(closes, ma_length)
    tall = _tall_candles(highs, lows, tall_sample, tall_multiplier)
    for index in range(4, size):
        c1 = index - 4
        c2 = index - 3
        c3 = index - 2
        c4 = index - 1
        c5 = index
        trend_index = c1 - 1
        if trend_index < 0:
            continue
        if not (np.isfinite(opens[c1]) and np.isfinite(opens[c2]) and np.isfinite(opens[c3]) and np.isfinite(opens[c4]) and np.isfinite(opens[c5]) and np.isfinite(highs[c1]) and np.isfinite(highs[c2]) and np.isfinite(highs[c3]) and np.isfinite(highs[c4]) and np.isfinite(highs[c5]) and np.isfinite(lows[c1]) and np.isfinite(lows[c2]) and np.isfinite(lows[c3]) and np.isfinite(lows[c4]) and np.isfinite(lows[c5]) and np.isfinite(closes[c1]) and np.isfinite(closes[c2]) and np.isfinite(closes[c3]) and np.isfinite(closes[c4]) and np.isfinite(closes[c5]) and np.isfinite(closes[trend_index]) and np.isfinite(moving_average[trend_index])):
            continue
        c3_higher = max(opens[c3], closes[c3])
        c3_lower = min(opens[c3], closes[c3])
        highest_high = max(highs[c1], highs[c2], highs[c3], highs[c4])
        c1_valid = closes[c1] >= opens[c1] and tall[c1]
        c2_valid = closes[c2] < opens[c2] and closes[c2] > closes[c1]
        middle_three_above_low = closes[c2] > lows[c1] and c3_lower > lows[c1] and (closes[c4] > lows[c1])
        c3_valid = c3_higher < opens[c2]
        c4_valid = closes[c4] < opens[c4] and opens[c4] < c3_higher
        c5_valid = closes[c5] >= opens[c5] and closes[c5] > highest_high and tall[c5]
        uptrend = closes[trend_index] > moving_average[trend_index]
        if c1_valid and c2_valid and middle_three_above_low and c3_valid and c4_valid and c5_valid and uptrend:
            long_entries[index] = True
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'mat_hold_long', 'hypothesis': '以 Mat Hold 五根 K 棒多頭延續型態搭配動態 SMA 上行趨勢捕捉多頭延續。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_multiplier', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_multiplier': 1.5, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
