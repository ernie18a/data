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

def _rolling_mean(values, window):
    window = int(window)
    if window < 1:
        raise ValueError('window must be positive')
    result = np.full(values.size, np.nan, dtype=np.float64)
    for t in range(window - 1, values.size):
        sample = values[t - window + 1:t + 1]
        if np.all(np.isfinite(sample)):
            result[t] = np.mean(sample)
    return result

def _prior_mean(values, window):
    window = int(window)
    if window < 1:
        raise ValueError('window must be positive')
    result = np.full(values.size, np.nan, dtype=np.float64)
    for t in range(window, values.size):
        sample = values[t - window:t]
        if np.all(np.isfinite(sample)):
            result[t] = np.mean(sample)
    return result

def _long_shadow_mask(opens, highs, lows, closes, wick_base, wick_sample, wick_behavior, long_wick_tolerance):
    size = opens.size
    ranges = highs - lows
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    result = np.ones(size, dtype=np.bool_)
    for t in range(size):
        if not np.isfinite(ranges[t]) or ranges[t] <= 0.0 or t < wick_sample:
            result[t] = False
            continue
        sample_slice = slice(t - wick_sample, t)
        sample_ranges = ranges[sample_slice]
        sample_upper = upper_wick[sample_slice]
        sample_lower = lower_wick[sample_slice]
        if not (np.all(np.isfinite(sample_ranges)) and np.all(sample_ranges > 0.0) and np.all(np.isfinite(sample_upper)) and np.all(np.isfinite(sample_lower))):
            result[t] = False
            continue
        if wick_base == 'RANGE':
            upper_average = np.mean(sample_upper / sample_ranges)
            lower_average = np.mean(sample_lower / sample_ranges)
            current_upper = upper_wick[t] / ranges[t]
            current_lower = lower_wick[t] / ranges[t]
        else:
            upper_average = np.mean(sample_upper)
            lower_average = np.mean(sample_lower)
            current_upper = upper_wick[t]
            current_lower = lower_wick[t]
        upper_limit = upper_average * long_wick_tolerance
        lower_limit = lower_average * long_wick_tolerance
        if wick_behavior == 'ONE':
            long_shadow = current_upper >= upper_limit or current_lower >= lower_limit
        elif wick_behavior == 'BOTH':
            long_shadow = current_upper >= upper_limit and current_lower >= lower_limit
        else:
            long_shadow = (current_upper + current_lower) / 2.0 >= (upper_limit + lower_limit) / 2.0
        result[t] = not long_shadow
    return result

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    opens = np.asarray(market.opens, dtype=np.float64).reshape(-1)
    highs = np.asarray(market.highs, dtype=np.float64).reshape(-1)
    lows = np.asarray(market.lows, dtype=np.float64).reshape(-1)
    closes = np.asarray(market.closes, dtype=np.float64).reshape(-1)
    if any((series.size != size for series in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match market.size')
    params = dict(signal_params or {})
    doji_tolerance = float(params.get('i_DojiTol', 0.04))
    tall_sample = int(params.get('i_TCSample', 14))
    tall_setting = str(params.get('i_TCSetting', 'RANGE')).upper()
    tall_tolerance = float(params.get('i_TCTol', 1.5))
    ma_length = int(params.get('ma_length', 20))
    wick_base = str(params.get('i_DojiWickBase', 'WICKS')).upper()
    wick_sample = int(params.get('i_DojiWickSam', 14))
    wick_behavior = str(params.get('i_DojiTallWick', 'ONE')).upper()
    long_wick_tolerance = float(params.get('i_DLWT', 3.0))
    if not np.isfinite(doji_tolerance) or doji_tolerance < 0.0 or tall_sample < 1 or (tall_setting not in ('RANGE', 'BODY')) or (not np.isfinite(tall_tolerance)) or (tall_tolerance <= 0.0) or (ma_length < 1) or (wick_base not in ('RANGE', 'WICKS')) or (wick_sample < 1) or (wick_behavior not in ('ONE', 'BOTH', 'AVG')) or (not np.isfinite(long_wick_tolerance)) or (long_wick_tolerance < 0.0):
        raise ValueError('invalid signal parameters')
    candle_range = highs - lows
    body = np.abs(closes - opens)
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & (candle_range > 0.0)
    tall_value = candle_range if tall_setting == 'RANGE' else body
    prior_tall_average = _prior_mean(tall_value, tall_sample)
    is_tall = finite & np.isfinite(prior_tall_average) & (tall_value >= tall_tolerance * prior_tall_average)
    moving_average = _rolling_mean(closes, ma_length)
    uptrend = finite & np.isfinite(moving_average) & (closes > moving_average)
    body_ratio = np.full(size, np.nan, dtype=np.float64)
    body_ratio[finite] = body[finite] / candle_range[finite]
    is_doji = finite & (body_ratio <= doji_tolerance)
    is_not_long_shadow = _long_shadow_mask(opens, highs, lows, closes, wick_base, wick_sample, wick_behavior, long_wick_tolerance)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for t in range(1, size):
        previous_range_valid = np.isfinite(lows[t - 1]) and np.isfinite(highs[t - 1]) and (highs[t - 1] >= lows[t - 1])
        if not previous_range_valid:
            continue
        current_inside_previous_range = lows[t - 1] <= opens[t] <= highs[t - 1] and lows[t - 1] <= closes[t] <= highs[t - 1]
        short_entries[t] = bool(finite[t] and is_tall[t - 1] and (closes[t - 1] >= opens[t - 1]) and is_doji[t] and is_not_long_shadow[t] and current_inside_previous_range and uptrend[t])
    exit_params = dict(params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (np.asarray(long_entries, dtype=np.bool_).reshape(-1), np.asarray(long_exits, dtype=np.bool_).reshape(-1), np.asarray(short_entries, dtype=np.bool_).reshape(-1), np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'bearish_harami_cross_short', 'hypothesis': '上行動態 MA 中的高波動陽線後非長影線十字線可能預示看跌反轉。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_DojiTol', 'i_TCSample', 'i_TCSetting', 'i_TCTol', 'ma_length', 'i_DojiWickBase', 'i_DojiWickSam', 'i_DojiTallWick', 'i_DLWT', 'k_base', 'mult'], 'signal_parameter_sets': [{'i_DojiTol': 0.04, 'i_TCSample': 14, 'i_TCSetting': 'RANGE', 'i_TCTol': 1.5, 'ma_length': 20, 'i_DojiWickBase': 'WICKS', 'i_DojiWickSam': 14, 'i_DojiTallWick': 'ONE', 'i_DLWT': 3.0, 'k_base': 2.0, 'mult': 2.0}]}
