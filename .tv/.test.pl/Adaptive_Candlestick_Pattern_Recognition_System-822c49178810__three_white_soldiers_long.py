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

def _rolling_mean(values, window):
    result = np.full(values.shape, np.nan, dtype=float)
    if window <= 0 or values.size < window:
        return result
    cumulative = np.concatenate((np.array([0.0]), np.cumsum(values, dtype=float)))
    result[window - 1:] = (cumulative[window:] - cumulative[:values.size - window + 1]) / window
    return result

def _prior_mean(values, window):
    result = np.full(values.shape, np.nan, dtype=float)
    if window <= 0 or values.size <= window:
        return result
    cumulative = np.concatenate((np.array([0.0]), np.cumsum(values, dtype=float)))
    result[window:] = (cumulative[window:values.size] - cumulative[:values.size - window]) / window
    return result

def generate_signals(features, signal_params):
    size = features.market.size
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    ma_window = max(1, int(signal_params.get('ma_window', 20)))
    volatility_window = max(1, int(signal_params.get('volatility_window', 14)))
    volatility_multiplier = float(signal_params.get('volatility_multiplier', 1.5))
    close_high_tolerance = float(signal_params.get('close_high_tolerance', 0.03))
    ranges = highs - lows
    prior_average_range = _prior_mean(ranges, volatility_window)
    moving_average = _rolling_mean(closes, ma_window)
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    bullish = finite & (closes > opens)
    high_volatility = finite & (ranges > 0.0) & np.isfinite(prior_average_range) & (ranges >= volatility_multiplier * prior_average_range)
    near_high = finite & (closes >= lows) & (closes <= highs) & (highs - closes <= close_high_tolerance * ranges)
    body_low = np.minimum(opens, closes)
    body_high = np.maximum(opens, closes)
    pattern = np.zeros(size, dtype=np.bool_)
    if size >= 3:
        pattern[2:] = bullish[:-2] & bullish[1:-1] & bullish[2:] & high_volatility[:-2] & high_volatility[1:-1] & high_volatility[2:] & near_high[:-2] & near_high[1:-1] & near_high[2:] & (opens[1:-1] >= body_low[:-2]) & (opens[1:-1] <= body_high[:-2]) & (opens[2:] >= body_low[1:-1]) & (opens[2:] <= body_high[1:-1]) & (closes[1:-1] > closes[:-2]) & (closes[2:] > closes[1:-1])
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size >= 4:
        long_entries[3:] = pattern[3:] & np.isfinite(moving_average[:-3]) & (closes[:-3] < moving_average[:-3])
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'three_white_soldiers_long', 'hypothesis': '三根高波動白兵出現在動態均線下方時，預期後續反轉上行。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_window', 'volatility_window', 'volatility_multiplier', 'close_high_tolerance', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'ma_window': 20, 'volatility_window': 14, 'volatility_multiplier': 1.5, 'close_high_tolerance': 0.03, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
