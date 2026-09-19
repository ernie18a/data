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
    window = int(window)
    if window < 1:
        raise ValueError('i_TCSample must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window, values.size):
        sample = values[index - window:index]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def _get_param(signal_params, name, alias, default):
    return signal_params.get(name, signal_params.get(alias, default))

def generate_signals(features, signal_params):
    size = int(features.market.size)
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    if any((values.size != size for values in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match market.size')
    doji_tolerance = float(_get_param(signal_params, 'i_DojiTol', 'doji_tolerance', 0.04))
    tall_sample = int(_get_param(signal_params, 'i_TCSample', 'tall_sample', 14))
    tall_setting = str(_get_param(signal_params, 'i_TCSetting', 'tall_setting', 'RANGE')).upper()
    tall_multiplier = float(_get_param(signal_params, 'i_TCTol', 'tall_multiplier', 1.5))
    ma_length = int(_get_param(signal_params, 'ma_length', 'ma_length', 20))
    if not np.isfinite(doji_tolerance) or doji_tolerance < 0.0:
        raise ValueError('i_DojiTol must be a finite non-negative scalar')
    if tall_sample < 1:
        raise ValueError('i_TCSample must be positive')
    if tall_setting not in ('RANGE', 'BODY'):
        raise ValueError("i_TCSetting must be 'RANGE' or 'BODY'")
    if not np.isfinite(tall_multiplier) or tall_multiplier <= 0.0:
        raise ValueError('i_TCTol must be a finite positive scalar')
    if ma_length < 1:
        raise ValueError('ma_length must be positive')
    candle_range = highs - lows
    candle_body = np.abs(closes - opens)
    tall_value = candle_range if tall_setting == 'RANGE' else candle_body
    prior_tall_mean = _rolling_prior_mean(tall_value, tall_sample)
    moving_average = np.full(size, np.nan, dtype=float)
    for index in range(ma_length - 1, size):
        sample = closes[index - ma_length + 1:index + 1]
        if np.all(np.isfinite(sample)):
            moving_average[index] = np.mean(sample)
    finite_ohlc = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    body_ratio = np.zeros(size, dtype=float)
    np.divide(candle_body, candle_range, out=body_ratio, where=candle_range > 0.0)
    is_doji = finite_ohlc & (candle_range > 0.0) & (body_ratio <= doji_tolerance)
    is_tall_bullish = finite_ohlc & (closes > opens) & np.isfinite(prior_tall_mean) & (tall_value >= tall_multiplier * prior_tall_mean)
    in_uptrend = finite_ohlc & np.isfinite(moving_average) & (closes > moving_average)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size > 1:
        short_entries[1:] = is_tall_bullish[:-1] & is_doji[1:] & (lows[1:] > closes[:-1]) & in_uptrend[1:]
    long_entries = np.zeros(size, dtype=np.bool_)
    exit_params = dict(signal_params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'bearish_doji_star_short', 'hypothesis': '上行動態 SMA 趨勢中的高波動陽線後十字星可能預示看跌反轉。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_DojiTol', 'i_TCSample', 'i_TCSetting', 'i_TCTol', 'ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'i_DojiTol': 0.04, 'i_TCSample': 14, 'i_TCSetting': 'RANGE', 'i_TCTol': 1.5, 'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
