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

def _ema(values, length):
    if length < 1:
        raise ValueError('ma_length must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    previous = np.nan
    alpha = 2.0 / (length + 1.0)
    for index in range(values.size):
        if not np.isfinite(values[index]):
            previous = np.nan
            continue
        if index + 1 < length:
            continue
        window = values[index - length + 1:index + 1]
        if not np.all(np.isfinite(window)):
            previous = np.nan
            continue
        previous = float(np.mean(window)) if not np.isfinite(previous) else previous + alpha * (values[index] - previous)
        result[index] = previous
    return result

def _prior_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window, values.size):
        sample = values[index - window:index]
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
    volatility_window = int(signal_params.get('volatility_window', 14))
    volatility_multiplier = float(signal_params.get('volatility_multiplier', 1.5))
    ma_length = int(signal_params.get('ma_length', 20))
    if volatility_window < 1:
        raise ValueError('volatility_window must be positive')
    if not np.isfinite(volatility_multiplier) or volatility_multiplier <= 0.0:
        raise ValueError('volatility_multiplier must be finite and positive')
    candle_range = highs - lows
    prior_range_mean = _prior_mean(candle_range, volatility_window)
    tall = np.isfinite(candle_range) & np.isfinite(prior_range_mean)
    tall &= candle_range >= volatility_multiplier * prior_range_mean
    moving_average = _ema(closes, ma_length)
    trend_bar = np.full(size, False, dtype=np.bool_)
    trend_bar[1:] = np.isfinite(closes[1:]) & np.isfinite(moving_average[1:]) & np.isfinite(moving_average[:-1]) & (closes[1:] > moving_average[1:]) & (moving_average[1:] > moving_average[:-1])
    long_entries = np.zeros(size, dtype=np.bool_)
    if size >= 3:
        first_open = opens[:-2]
        first_high = highs[:-2]
        first_close = closes[:-2]
        second_open = opens[1:-1]
        second_low = lows[1:-1]
        second_close = closes[1:-1]
        third_open = opens[2:]
        third_close = closes[2:]
        first_body_low = np.minimum(first_open, first_close)
        first_body_high = np.maximum(first_open, first_close)
        second_body_low = np.minimum(second_open, second_close)
        second_body_high = np.maximum(second_open, second_close)
        valid = tall[:-2] & tall[1:-1] & (first_close > first_open) & (second_close > second_open) & (second_low > first_high) & (third_close < third_open) & (third_open >= second_body_low) & (third_open <= second_body_high) & (third_close >= first_body_low) & (third_close <= first_body_high) & trend_bar[2:]
        long_entries[2:] = valid
    short_entries = np.zeros(size, dtype=np.bool_)
    exit_params = dict(signal_params)
    exit_params.update(k_base=2.0, gamma=1.0, n_base=2000.0)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'upside_gap_three_methods_long', 'hypothesis': '上行動態 MA 中的 Upside Gap Three Methods 形態可能延續多頭走勢。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['volatility_window', 'volatility_multiplier', 'ma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'volatility_window': 14, 'volatility_multiplier': 1.5, 'ma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
