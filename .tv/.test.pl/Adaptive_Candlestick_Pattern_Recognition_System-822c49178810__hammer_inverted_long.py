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

def _sma(values, period):
    result = np.full(values.size, np.nan, dtype=float)
    if values.size >= period:
        result[period - 1:] = np.convolve(values, np.ones(period, dtype=float), mode='valid') / float(period)
    return result

def _market_array(market, name, size):
    values = np.asarray(getattr(market, name), dtype=float).reshape(-1)
    if values.size != size:
        raise ValueError(f'features.market.{name} length must equal features.market.size')
    return values

def generate_signals(features, signal_params):
    params = {'tall_sample_size': 14, 'tall_multiplier': 1.5, 'ma_period': 20, 'k_base': 2.0, 'mult': 2.0}
    if signal_params:
        params.update(signal_params)
    sample_size = int(params['tall_sample_size'])
    ma_period = int(params['ma_period'])
    tall_multiplier = float(params['tall_multiplier'])
    if sample_size < 1 or ma_period < 1 or tall_multiplier <= 0.0:
        raise ValueError('tall_sample_size and ma_period must be positive; tall_multiplier must be positive')
    market = features.market
    size = int(market.size)
    opens = _market_array(market, 'opens', size)
    highs = _market_array(market, 'highs', size)
    lows = _market_array(market, 'lows', size)
    closes = _market_array(market, 'closes', size)
    ranges = highs - lows
    moving_average = _sma(closes, ma_period)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for t in range(1, size):
        previous = t - 1
        if previous < sample_size:
            continue
        history = ranges[previous - sample_size:previous]
        if not np.all(np.isfinite(history)):
            continue
        previous_range = ranges[previous]
        previous_is_bearish = closes[previous] < opens[previous]
        previous_is_tall = np.isfinite(previous_range) and previous_range >= tall_multiplier * float(np.mean(history))
        current_range = highs[t] - lows[t]
        current_body = abs(closes[t] - opens[t])
        current_body_center = (opens[t] + closes[t]) / 2.0
        current_upper_wick = highs[t] - max(opens[t], closes[t])
        current_is_inverted_hammer = np.isfinite(current_range) and current_range > 0.0 and (current_body > 0.0) and (current_body_center <= lows[t] + 0.5 * current_range) and (current_upper_wick >= 2.0 * current_body)
        downtrend = np.isfinite(moving_average[previous]) and closes[previous] < moving_average[previous]
        if previous_is_bearish and previous_is_tall and current_is_inverted_hammer and downtrend:
            long_entries[t] = True
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_).reshape(-1), short_entries, np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'hammer_inverted_long', 'hypothesis': '前一根高波動陰線後形成倒錘形，且價格位於動態均線下方時，反轉形態可能帶來多頭機會。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['tall_sample_size', 'tall_multiplier', 'ma_period', 'k_base', 'mult'], 'signal_parameter_sets': [{'tall_sample_size': 14, 'tall_multiplier': 1.5, 'ma_period': 20, 'k_base': 2.0, 'mult': 2.0}]}
