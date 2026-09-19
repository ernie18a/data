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
    if length <= 0:
        raise ValueError('ma_length must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    if values.size >= length:
        result[length - 1:] = np.convolve(values, np.full(length, 1.0 / length, dtype=float), mode='valid')
    return result

def _tall_candles(opens: np.ndarray, highs: np.ndarray, lows: np.ndarray, closes: np.ndarray, sample: int, tolerance: float) -> np.ndarray:
    size = opens.size
    candle_size = highs - lows
    tall = np.zeros(size, dtype=np.bool_)
    for index in range(sample + 1, size):
        previous = candle_size[index - sample - 1:index - 1]
        average = np.mean(previous)
        tall[index] = abs(candle_size[index]) >= average * tolerance
    return tall

def generate_signals(features, signal_params):
    size = int(features.market.size)
    params = signal_params or {}
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    if any((values.size != size for values in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match features.market.size')
    ma_length = int(params.get('ma_length', 20))
    tall_sample = int(params.get('tall_sample', 14))
    tall_tolerance = float(params.get('tall_tolerance', 1.5))
    if ma_length <= 0 or tall_sample <= 0 or tall_tolerance <= 0.0:
        raise ValueError('signal parameters must be positive')
    moving_average = _sma(closes, ma_length)
    tall = _tall_candles(opens, highs, lows, closes, tall_sample, tall_tolerance)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for t in range(size):
        c1, c2, c3, c4, c5 = (t - 4, t - 3, t - 2, t - 1, t)
        trend_index = t - 5
        if c1 < 0 or trend_index < 0:
            continue
        if not np.isfinite(moving_average[trend_index]):
            continue
        c3_body_high = max(opens[c3], closes[c3])
        c3_body_low = min(opens[c3], closes[c3])
        c1_valid = opens[c1] > closes[c1] and tall[c1]
        c2_valid = opens[c2] <= closes[c2] and opens[c2] > lows[c1] and (closes[c2] < highs[c1])
        c3_valid = c3_body_high > closes[c2] and c3_body_low > opens[c2] and (c3_body_high < highs[c1])
        c4_valid = opens[c4] <= closes[c4] and opens[c4] > c3_body_low and (closes[c4] > c3_body_high) and (closes[c4] < highs[c1])
        c5_valid = opens[c5] > closes[c5] and closes[c5] < closes[c1] and tall[c5]
        downtrend = closes[trend_index] <= moving_average[trend_index]
        short_entries[t] = downtrend and c1_valid and c2_valid and c3_valid and c4_valid and c5_valid
    exit_params = {'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'falling_three_methods_short', 'hypothesis': '下行趨勢中的 Falling Three Methods 代表空方延續，形態完成後做空。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_tolerance'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_tolerance': 1.5}]}
