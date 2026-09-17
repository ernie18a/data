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

def _prior_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    if window <= 0:
        raise ValueError('tall_sample must be positive')
    for index in range(window, values.size):
        sample = values[index - window:index]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def _rolling_sma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length <= 0:
        raise ValueError('ma_length must be positive')
    for index in range(length - 1, values.size):
        sample = values[index - length + 1:index + 1]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)[:size]
    highs = np.asarray(market.highs, dtype=float).reshape(-1)[:size]
    lows = np.asarray(market.lows, dtype=float).reshape(-1)[:size]
    closes = np.asarray(market.closes, dtype=float).reshape(-1)[:size]
    wick_tolerance = float(signal_params.get('i_OnNeckWickTol', 0.1))
    neck_tolerance = float(signal_params.get('i_OnNeckTol', 0.5))
    tall_sample = int(signal_params.get('tall_sample', 14))
    tall_tolerance = float(signal_params.get('tall_tolerance', 0.5))
    tall_mode = str(signal_params.get('tall_mode', 'range')).lower()
    ma_length = int(signal_params.get('ma_length', 20))
    if not 0.0 <= wick_tolerance <= 1.0:
        raise ValueError('i_OnNeckWickTol must be between 0 and 1')
    if not 0.0 <= neck_tolerance <= 1.0:
        raise ValueError('i_OnNeckTol must be between 0 and 1')
    if tall_sample <= 0 or tall_tolerance < 0.0 or ma_length <= 0:
        raise ValueError('on_neck_short parameters are out of range')
    if tall_mode not in ('range', 'body'):
        raise ValueError("tall_mode must be 'range' or 'body'")
    candle_range = highs - lows
    candle_size = candle_range if tall_mode == 'range' else np.abs(closes - opens)
    size_mean = _prior_mean(candle_size, tall_sample)
    moving_average = _rolling_sma(closes, ma_length)
    short_entries = np.zeros(size, dtype=np.bool_)
    for index in range(max(tall_sample + 1, ma_length + 2), size):
        previous = index - 1
        trend_reference = index - 2
        if not np.all(np.isfinite([opens[previous], highs[previous], lows[previous], closes[previous], opens[index], highs[index], lows[index], closes[index], size_mean[previous], size_mean[index], moving_average[trend_reference]])):
            continue
        previous_range = candle_range[previous]
        if previous_range <= 0.0:
            continue
        previous_tall = candle_size[previous] >= size_mean[previous] * (1.0 + tall_tolerance)
        current_tall = candle_size[index] >= size_mean[index] * (1.0 + tall_tolerance)
        previous_bearish = closes[previous] < opens[previous]
        current_bullish = closes[index] >= opens[index]
        current_not_tall = not current_tall
        lower_wick = closes[previous] - lows[previous]
        valid_wick = lower_wick / previous_range <= wick_tolerance
        lower_close_limit = closes[previous] - lower_wick * neck_tolerance
        close_in_neck = lower_close_limit <= closes[index] <= closes[previous]
        opens_below_low = opens[index] < lows[previous]
        downtrend = closes[trend_reference] <= moving_average[trend_reference]
        short_entries[index] = previous_tall and previous_bearish and current_bullish and current_not_tall and valid_wick and close_in_neck and opens_below_low and downtrend
    long_exits, short_exits = i5_apply_trend_exit(features, empty, short_entries, signal_params)
    return (np.asarray(empty, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'on_neck_short', 'hypothesis': '下行動態 MA 中，高波動陰線後的 On Neck 形態可能延續空頭走勢。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_OnNeckWickTol', 'i_OnNeckTol', 'tall_sample', 'tall_tolerance', 'tall_mode', 'ma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'i_OnNeckWickTol': 0.1, 'i_OnNeckTol': 0.5, 'tall_sample': 14, 'tall_tolerance': 0.5, 'tall_mode': 'range', 'ma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
