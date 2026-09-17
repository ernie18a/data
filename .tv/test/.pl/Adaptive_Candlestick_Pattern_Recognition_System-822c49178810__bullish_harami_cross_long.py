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

def _rolling_prior_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window, values.size):
        sample = values[index - window:index]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def _rolling_sma(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        sample = values[index - window + 1:index + 1]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def generate_signals(features, signal_params):
    params = dict(signal_params or {})
    size = int(features.market.size)
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if any((values.size != size for values in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match market.size')
    doji_tol = float(params.get('i_DojiTol', 0.04))
    tall_sample = int(params.get('i_TCSample', 14))
    tall_setting = str(params.get('i_TCSetting', 'RANGE')).upper()
    tall_multiplier = float(params.get('i_TCTol', 1.5))
    wick_base = str(params.get('i_DojiWickBase', 'WICKS')).upper()
    wick_sample = int(params.get('i_DojiWickSam', 14))
    wick_behavior = str(params.get('i_DojiTallWick', 'ONE')).upper()
    long_wick_multiplier = float(params.get('i_DLWT', 3.0))
    ma_length = int(params.get('ma_length', 20))
    if not np.isfinite(doji_tol) or doji_tol < 0.0:
        raise ValueError('i_DojiTol must be finite and non-negative')
    if tall_sample < 1 or wick_sample < 1 or ma_length < 1:
        raise ValueError('sample sizes and ma_length must be positive')
    if tall_setting not in {'RANGE', 'BODY'}:
        raise ValueError('i_TCSetting must be RANGE or BODY')
    if wick_base not in {'RANGE', 'WICKS'}:
        raise ValueError('i_DojiWickBase must be RANGE or WICKS')
    if wick_behavior not in {'ONE', 'BOTH', 'AVG'}:
        raise ValueError('i_DojiTallWick must be ONE, BOTH, or AVG')
    if not np.isfinite(tall_multiplier) or tall_multiplier <= 0.0:
        raise ValueError('i_TCTol must be finite and positive')
    if not np.isfinite(long_wick_multiplier) or long_wick_multiplier < 0.0:
        raise ValueError('i_DLWT must be finite and non-negative')
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    candle_range = highs - lows
    body = np.abs(closes - opens)
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    valid = finite & (candle_range > 0.0) & (upper_wick >= 0.0) & (lower_wick >= 0.0)
    tall_value = candle_range if tall_setting == 'RANGE' else body
    prior_tall_mean = _rolling_prior_mean(tall_value, tall_sample)
    is_tall = valid & np.isfinite(prior_tall_mean) & (tall_value >= tall_multiplier * prior_tall_mean)
    is_bearish = valid & (closes < opens)
    body_ratio = np.full(size, np.nan, dtype=float)
    body_ratio[valid] = body[valid] / candle_range[valid]
    is_doji = valid & (body_ratio <= doji_tol)
    if wick_base == 'RANGE':
        upper_measure = np.full(size, np.nan, dtype=float)
        lower_measure = np.full(size, np.nan, dtype=float)
        upper_measure[valid] = upper_wick[valid] / candle_range[valid]
        lower_measure[valid] = lower_wick[valid] / candle_range[valid]
    else:
        upper_measure = np.where(valid, upper_wick, np.nan)
        lower_measure = np.where(valid, lower_wick, np.nan)
    prior_upper_mean = _rolling_prior_mean(upper_measure, wick_sample)
    prior_lower_mean = _rolling_prior_mean(lower_measure, wick_sample)
    upper_long = np.isfinite(prior_upper_mean) & (upper_measure >= long_wick_multiplier * prior_upper_mean)
    lower_long = np.isfinite(prior_lower_mean) & (lower_measure >= long_wick_multiplier * prior_lower_mean)
    if wick_behavior == 'ONE':
        long_legged = upper_long | lower_long
    elif wick_behavior == 'BOTH':
        long_legged = upper_long & lower_long
    else:
        current_average = (upper_measure + lower_measure) / 2.0
        prior_average = (prior_upper_mean + prior_lower_mean) / 2.0
        long_legged = np.isfinite(prior_average) & (current_average >= long_wick_multiplier * prior_average)
    moving_average = _rolling_sma(closes, ma_length)
    downtrend = valid & np.isfinite(moving_average) & (closes <= moving_average)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size > 1:
        previous_range = candle_range[:-1]
        current_open = opens[1:]
        current_close = closes[1:]
        contained = (current_open[1 - 1:] > lows[:-1]) & (current_open[1 - 1:] < highs[:-1]) & (current_close[1 - 1:] > lows[:-1]) & (current_close[1 - 1:] < highs[:-1])
        long_entries[1:] = is_bearish[:-1] & is_tall[:-1] & is_doji[1:] & ~long_legged[1:] & contained & downtrend[1:]
    exit_params = dict(params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_).reshape(-1), short_entries, np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'bullish_harami_cross_long', 'hypothesis': '下行動態 MA 中的看漲 Harami Cross 可能形成多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_DojiTol', 'i_TCSample', 'i_TCSetting', 'i_TCTol', 'i_DojiWickBase', 'i_DojiWickSam', 'i_DojiTallWick', 'i_DLWT', 'ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'i_DojiTol': 0.04, 'i_TCSample': 14, 'i_TCSetting': 'RANGE', 'i_TCTol': 1.5, 'i_DojiWickBase': 'WICKS', 'i_DojiWickSam': 14, 'i_DojiTallWick': 'ONE', 'i_DLWT': 3.0, 'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
