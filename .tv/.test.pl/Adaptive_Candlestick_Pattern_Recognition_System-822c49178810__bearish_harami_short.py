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

def _series(market, name, size):
    values = np.asarray(getattr(market, name), dtype=float).reshape(-1)
    if values.size != size:
        raise ValueError(f'{name} must have exactly features.market.size values')
    return values

def _rolling_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window, values.size):
        sample = values[index - window:index]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def _moving_average(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        sample = values[index - window + 1:index + 1]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size < 2:
        long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
        return (long_entries, long_exits, short_entries, short_exits)
    market = features.market
    opens = _series(market, 'opens', size)
    highs = _series(market, 'highs', size)
    lows = _series(market, 'lows', size)
    closes = _series(market, 'closes', size)
    volatility_window = max(1, int(signal_params.get('volatility_window', 20)))
    volatility_multiplier = float(signal_params.get('volatility_multiplier', 1.5))
    ma_window = max(1, int(signal_params.get('ma_window', 20)))
    ranges = highs - lows
    prior_range_mean = _rolling_mean(ranges, volatility_window)
    moving_average = _moving_average(closes, ma_window)
    previous_range = ranges[:-1]
    previous_range_mean = prior_range_mean[:-1]
    previous_bullish = closes[:-1] > opens[:-1]
    current_bearish = closes[1:] < opens[1:]
    high_volatility = np.isfinite(previous_range) & np.isfinite(previous_range_mean) & (previous_range > volatility_multiplier * previous_range_mean)
    inside_open = (opens[1:] >= lows[:-1]) & (opens[1:] <= highs[:-1])
    inside_close = (closes[1:] >= lows[:-1]) & (closes[1:] <= highs[:-1])
    previous_body_low = np.minimum(opens[:-1], closes[:-1])
    previous_body_high = np.maximum(opens[:-1], closes[:-1])
    current_body_low = np.minimum(opens[1:], closes[1:])
    current_body_high = np.maximum(opens[1:], closes[1:])
    different_body = (current_body_low != previous_body_low) | (current_body_high != previous_body_high)
    ma_uptrend = np.isfinite(closes[1:]) & np.isfinite(moving_average[1:]) & np.isfinite(moving_average[:-1]) & (closes[1:] > moving_average[1:]) & (moving_average[1:] > moving_average[:-1])
    short_entries[1:] = previous_bullish & high_volatility & current_bearish & inside_open & inside_close & different_body & ma_uptrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bearish_harami_short', 'hypothesis': '上行動態均線中的高波動陽線後形成陰線內縮，預期價格反轉下行。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['volatility_window', 'volatility_multiplier', 'ma_window', 'k_base', 'mult'], 'signal_parameter_sets': [{'volatility_window': 20, 'volatility_multiplier': 1.5, 'ma_window': 20, 'k_base': 2.0, 'mult': 2.0}]}
