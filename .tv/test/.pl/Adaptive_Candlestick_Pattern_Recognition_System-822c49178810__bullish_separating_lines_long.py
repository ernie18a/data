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

def _sma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length <= 0 or values.size < length:
        return result
    cumulative = np.cumsum(values, dtype=float)
    prefix = np.concatenate((np.array([0.0]), cumulative))
    result[length - 1:] = (prefix[length:] - prefix[:-length]) / float(length)
    return result

def _prior_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    if window <= 0 or values.size <= window:
        return result
    cumulative = np.cumsum(values, dtype=float)
    prefix = np.concatenate((np.array([0.0]), cumulative))
    result[window:] = (prefix[window:values.size] - prefix[:values.size - window]) / float(window)
    return result

def generate_signals(features, signal_params):
    size = features.market.size
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    tall_sample = int(signal_params.get('tall_sample', 14))
    tall_setting = signal_params.get('tall_setting', 'RANGE')
    tall_tolerance = float(signal_params.get('tall_tolerance', 1.5))
    lines_tolerance = float(signal_params.get('lines_tolerance', 0.05))
    ma_length = int(signal_params.get('ma_length', 20))
    candle_size = highs - lows if tall_setting == 'RANGE' else np.abs(closes - opens)
    prior_average = _prior_mean(candle_size, tall_sample)
    tall = candle_size >= tall_tolerance * prior_average
    moving_average = _sma(closes, ma_length)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for t in range(2, size):
        previous = t - 1
        trend_bar = t - 2
        long_entries[t] = closes[previous] < opens[previous] and closes[t] > opens[t] and tall[previous] and tall[t] and (abs(opens[t] - opens[previous]) <= (highs[previous] - lows[previous]) * lines_tolerance) and (closes[trend_bar] > moving_average[trend_bar])
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_separating_lines_long', 'hypothesis': '兩根高波動 K 線以相近開盤價形成看漲分離線，且價格位於動態 SMA 上方時做多。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['tall_sample', 'tall_setting', 'tall_tolerance', 'lines_tolerance', 'ma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'tall_sample': 14, 'tall_setting': 'RANGE', 'tall_tolerance': 1.5, 'lines_tolerance': 0.05, 'ma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
