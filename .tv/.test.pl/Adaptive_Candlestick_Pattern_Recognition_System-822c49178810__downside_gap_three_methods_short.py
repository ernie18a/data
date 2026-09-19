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

def _market_array(market, name, size):
    value = market[name] if isinstance(market, dict) else getattr(market, name)
    array = np.asarray(value, dtype=float).reshape(-1)
    if array.size != size:
        raise ValueError(f'market.{name} length must equal market.size')
    return array

def _sma(values, period):
    result = np.full(values.size, np.nan, dtype=float)
    if period < 1:
        raise ValueError('period must be positive')
    for index in range(period - 1, values.size):
        window = values[index - period + 1:index + 1]
        if np.isfinite(window).all():
            result[index] = np.mean(window)
    return result

def _previous_mean(values, period):
    result = np.full(values.size, np.nan, dtype=float)
    if period < 1:
        raise ValueError('period must be positive')
    for index in range(period, values.size):
        window = values[index - period:index]
        if np.isfinite(window).all():
            result[index] = np.mean(window)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    params = dict(signal_params or {})
    ma_length = max(1, int(params.get('ma_length', 20)))
    tall_sample = max(1, int(params.get('tall_sample', 14)))
    tall_multiplier = float(params.get('tall_multiplier', 1.5))
    opens = _market_array(features.market, 'opens', size)
    highs = _market_array(features.market, 'highs', size)
    lows = _market_array(features.market, 'lows', size)
    closes = _market_array(features.market, 'closes', size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    ranges = highs - lows
    tall_average = _previous_mean(ranges, tall_sample)
    moving_average = _sma(closes, ma_length)
    for index in range(2, size):
        first = index - 2
        second = index - 1
        trend_index = index - 3
        if trend_index < 0:
            continue
        if not (np.isfinite(tall_average[first]) and np.isfinite(moving_average[trend_index]) and np.isfinite(ranges[first]) and np.isfinite(ranges[second])):
            continue
        first_bearish = closes[first] < opens[first]
        second_bearish = closes[second] < opens[second]
        second_gapped_down = highs[second] < lows[first]
        third_bullish = closes[index] >= opens[index]
        third_open_in_second_body = min(opens[second], closes[second]) < opens[index] < max(opens[second], closes[second])
        third_close_in_first_body = min(opens[first], closes[first]) < closes[index] < max(opens[first], closes[first])
        first_tall = ranges[first] >= tall_multiplier * tall_average[first]
        second_tall = ranges[second] >= tall_multiplier * tall_average[second]
        downtrend = closes[trend_index] <= moving_average[trend_index]
        short_entries[index] = first_bearish and second_bearish and second_gapped_down and third_bullish and third_open_in_second_body and third_close_in_first_body and first_tall and second_tall and downtrend
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (np.asarray(long_entries, dtype=np.bool_).reshape(-1), np.asarray(long_exits, dtype=np.bool_).reshape(-1), np.asarray(short_entries, dtype=np.bool_).reshape(-1), np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'downside_gap_three_methods_short', 'hypothesis': 'A downside gap three methods pattern during a moving-average downtrend may precede continued weakness.', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_multiplier', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_multiplier': 1.5, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
