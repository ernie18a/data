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

def _previous_mean(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length, values.size):
        window = values[index - length:index]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _rolling_mean(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, long_entries.copy(), short_entries, short_entries.copy())
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)[:size]
    highs = np.asarray(market.highs, dtype=float).reshape(-1)[:size]
    lows = np.asarray(market.lows, dtype=float).reshape(-1)[:size]
    closes = np.asarray(market.closes, dtype=float).reshape(-1)[:size]
    ma_length = int(signal_params.get('ma_length', 20))
    tall_window = int(signal_params.get('tall_window', 14))
    tall_setting = str(signal_params.get('tall_setting', 'RANGE')).upper()
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    if ma_length < 1 or tall_window < 1:
        raise ValueError('ma_length and tall_window must be positive')
    if tall_setting not in ('RANGE', 'BODY'):
        raise ValueError("tall_setting must be 'RANGE' or 'BODY'")
    if tall_multiplier < 0.0:
        raise ValueError('tall_multiplier must be non-negative')
    body = np.abs(closes - opens)
    candle_range = highs - lows
    volatility_size = candle_range if tall_setting == 'RANGE' else body
    previous_average = _previous_mean(volatility_size, tall_window)
    moving_average = _rolling_mean(closes, ma_length)
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & np.isfinite(previous_average) & np.isfinite(moving_average)
    bullish = closes > opens
    bearish = closes < opens
    tall = finite & (volatility_size >= previous_average * tall_multiplier)
    for third_index in range(2, size):
        first_index = third_index - 2
        second_index = third_index - 1
        if not (finite[first_index] and finite[second_index] and finite[third_index] and bullish[first_index] and tall[first_index] and bearish[second_index] and bearish[third_index]):
            continue
        second_above_first_close = closes[second_index] > closes[first_index]
        second_body_low = min(opens[second_index], closes[second_index])
        second_body_high = max(opens[second_index], closes[second_index])
        third_open_in_second_body = second_body_low <= opens[third_index] <= second_body_high
        first_body_low = min(opens[first_index], closes[first_index])
        first_body_high = max(opens[first_index], closes[first_index])
        third_close_in_first_body = first_body_low <= closes[third_index] <= first_body_high
        in_uptrend = closes[first_index] > moving_average[first_index]
        short_entries[third_index] = second_above_first_close and third_open_in_second_body and third_close_in_first_body and in_uptrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, {'k_base': float(signal_params.get('k_base', 2.0)), 'mult': float(signal_params.get('mult', 2.0))})
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'two_crows_short', 'hypothesis': '上行動態 MA 中的 Two Crows 形態可能預示看跌反轉，採空頭。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_window', 'tall_setting', 'tall_multiplier', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_window': 14, 'tall_setting': 'RANGE', 'tall_multiplier': 1.5, 'k_base': 2.0, 'mult': 2.0}]}
