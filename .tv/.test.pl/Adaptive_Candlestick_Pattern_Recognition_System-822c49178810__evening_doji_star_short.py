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
        raise ValueError('tall_sample must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window, values.size):
        sample = values[index - window:index]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def _sma(values, window):
    window = int(window)
    if window < 1:
        raise ValueError('ma_length must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        sample = values[index - window + 1:index + 1]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if any((values.size != size for values in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match market.size')
    ma_length = int(signal_params.get('ma_length', 20))
    tall_sample = int(signal_params.get('tall_sample', 14))
    tall_setting = str(signal_params.get('tall_setting', 'RANGE')).upper()
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    doji_tolerance = float(signal_params.get('doji_tolerance', 0.04))
    if ma_length < 1 or tall_sample < 1:
        raise ValueError('ma_length and tall_sample must be positive')
    if tall_setting not in ('RANGE', 'BODY'):
        raise ValueError("tall_setting must be 'RANGE' or 'BODY'")
    if not np.isfinite(tall_multiplier) or tall_multiplier <= 0.0:
        raise ValueError('tall_multiplier must be finite and positive')
    if not np.isfinite(doji_tolerance) or doji_tolerance < 0.0:
        raise ValueError('doji_tolerance must be finite and non-negative')
    candle_range = highs - lows
    candle_body = np.abs(closes - opens)
    tall_value = candle_range if tall_setting == 'RANGE' else candle_body
    prior_tall_mean = _rolling_prior_mean(tall_value, tall_sample)
    moving_average = _sma(closes, ma_length)
    finite_ohlc = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    body_ratio = np.full(size, np.nan, dtype=float)
    np.divide(candle_body, candle_range, out=body_ratio, where=candle_range > 0.0)
    is_doji = finite_ohlc & (candle_range > 0.0) & (body_ratio <= doji_tolerance)
    is_tall = finite_ohlc & np.isfinite(prior_tall_mean) & (tall_value >= tall_multiplier * prior_tall_mean)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for t in range(2, size):
        first = t - 2
        middle = t - 1
        if first < 1:
            continue
        first_body_high = max(opens[first], closes[first])
        third_body_high = max(opens[t], closes[t])
        doji_above_bodies = lows[middle] > max(first_body_high, third_body_high)
        first_body_midpoint = (opens[first] + closes[first]) / 2.0
        short_entries[t] = is_tall[first] and closes[first] > opens[first] and is_doji[middle] and doji_above_bodies and is_tall[t] and (closes[t] < opens[t]) and (closes[t] < first_body_midpoint) and np.isfinite(moving_average[first - 1]) and (closes[first - 1] > moving_average[first - 1])
    exit_params = dict(signal_params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'evening_doji_star_short', 'hypothesis': '上行動態 MA 中的 Evening Doji Star 可能預示看跌反轉，採空頭。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_setting', 'tall_multiplier', 'doji_tolerance', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_setting': 'RANGE', 'tall_multiplier': 1.5, 'doji_tolerance': 0.04, 'k_base': 2.0, 'mult': 2.0}]}
