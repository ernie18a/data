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
import numpy as np

def _sma(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        result[index] = np.mean(values[index - window + 1:index + 1])
    return result

def _is_tall(values, index, sample, multiplier):
    start = index - sample - 1
    stop = index - 1
    if start < 0 or stop <= start:
        return False
    average = np.mean(values[start:stop])
    return np.isfinite(average) and values[index] >= average * multiplier

def generate_signals(features, signal_params):
    size = int(features.market.size)
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    ranges = highs - lows
    ma_length = max(1, int(signal_params.get('ma_length', 20)))
    tall_sample = max(1, int(signal_params.get('tall_sample', 14)))
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    lines_tolerance = float(signal_params.get('lines_tolerance', 0.05))
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    moving_average = _sma(closes, ma_length)
    for t in range(size):
        if t < max(ma_length + 2, tall_sample + 2, 3):
            continue
        previous = t - 1
        trend_index = t - 3
        if not (np.isfinite(opens[previous]) and np.isfinite(opens[t]) and np.isfinite(highs[previous]) and np.isfinite(lows[previous]) and np.isfinite(closes[previous]) and np.isfinite(closes[t]) and np.isfinite(moving_average[trend_index])):
            continue
        previous_range = ranges[previous]
        if not np.isfinite(previous_range) or previous_range <= 0.0:
            continue
        previous_bullish = closes[previous] > opens[previous]
        current_bearish = closes[t] < opens[t]
        previous_high_volatility = _is_tall(ranges, previous, tall_sample, tall_multiplier)
        current_high_volatility = _is_tall(ranges, t, tall_sample, tall_multiplier)
        open_matches = abs(opens[t] - opens[previous]) <= previous_range * lines_tolerance
        downtrend = closes[trend_index] <= moving_average[trend_index]
        short_entries[t] = previous_bullish and current_bearish and previous_high_volatility and current_high_volatility and open_matches and downtrend
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, {**signal_params, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0})
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bearish_separating_lines_short', 'hypothesis': '下行趨勢中的看跌分離線形態可能延續空方動能，適合做空。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_sample', 'tall_multiplier', 'lines_tolerance', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_sample': 14, 'tall_multiplier': 1.5, 'lines_tolerance': 0.05, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
