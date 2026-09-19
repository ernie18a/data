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

def _sma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        sample = values[index - length + 1:index + 1]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, long_entries.copy(), short_entries, short_entries.copy())
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if any((values.size != size for values in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match market.size')
    params = dict(signal_params or {})
    ma_length = int(params.get('ma_length', 20))
    tall_sample = int(params.get('tall_sample', 14))
    tall_setting = str(params.get('tall_setting', 'RANGE')).upper()
    tall_multiplier = float(params.get('tall_multiplier', 1.5))
    close_low_tolerance = float(params.get('close_low_tolerance', 0.03))
    if ma_length < 1 or tall_sample < 1:
        raise ValueError('ma_length and tall_sample must be positive')
    if tall_setting not in ('RANGE', 'BODY'):
        raise ValueError("tall_setting must be 'RANGE' or 'BODY'")
    if not np.isfinite(tall_multiplier) or tall_multiplier <= 0.0 or (not np.isfinite(close_low_tolerance)) or (not 0.0 <= close_low_tolerance <= 1.0):
        raise ValueError('invalid candle parameters')
    candle_range = highs - lows
    candle_body = np.abs(closes - opens)
    candle_size = candle_range if tall_setting == 'RANGE' else candle_body
    prior_average = _rolling_prior_mean(candle_size, tall_sample)
    moving_average = _sma(closes, ma_length)
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & (candle_range > 0.0)
    is_bearish = finite & (closes < opens)
    is_tall = finite & np.isfinite(prior_average) & (candle_size >= tall_multiplier * prior_average)
    closes_near_low = finite & ((closes - lows) / candle_range <= close_low_tolerance)
    for index in range(2, size):
        first = index - 2
        second = index - 1
        trend_index = index - 3
        if trend_index < 0:
            continue
        if not (is_bearish[first] and is_bearish[second] and is_bearish[index] and is_tall[first] and is_tall[second] and is_tall[index] and closes_near_low[first] and closes_near_low[second] and closes_near_low[index] and np.isfinite(moving_average[trend_index]) and np.isfinite(closes[trend_index]) and (closes[trend_index] > moving_average[trend_index])):
            continue
        first_body_low = min(opens[first], closes[first])
        first_body_high = max(opens[first], closes[first])
        second_body_low = min(opens[second], closes[second])
        second_body_high = max(opens[second], closes[second])
        short_entries[index] = bool(first_body_low < opens[second] < first_body_high and second_body_low < opens[index] < second_body_high and (lows[second] < lows[first]) and (lows[index] < lows[second]))
    exit_params = dict(params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'three_black_crows_short', 'hypothesis': '上行動態 SMA 趨勢中的三黑鴉形態可能預示空頭反轉。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_setting', 'tall_multiplier', 'close_low_tolerance', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_setting': 'RANGE', 'tall_multiplier': 1.5, 'close_low_tolerance': 0.03, 'k_base': 2.0, 'mult': 2.0}]}
