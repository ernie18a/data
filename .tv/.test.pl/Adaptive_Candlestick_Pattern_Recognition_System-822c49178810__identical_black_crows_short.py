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

def _rolling_mean(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _previous_mean(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length, values.size):
        window = values[index - length:index]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _get_price_series(market, name, size):
    sources = {'open': market.opens, 'high': market.highs, 'low': market.lows, 'close': market.closes, 'hl2': (np.asarray(market.highs, dtype=float) + np.asarray(market.lows, dtype=float)) / 2.0, 'hlc3': (np.asarray(market.highs, dtype=float) + np.asarray(market.lows, dtype=float) + np.asarray(market.closes, dtype=float)) / 3.0, 'ohlc4': (np.asarray(market.opens, dtype=float) + np.asarray(market.highs, dtype=float) + np.asarray(market.lows, dtype=float) + np.asarray(market.closes, dtype=float)) / 4.0}
    key = str(name).lower()
    if key not in sources:
        raise ValueError('price source must be open, high, low, close, hl2, hlc3, or ohlc4')
    return np.asarray(sources[key], dtype=float).reshape(-1)[:size]

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
    ma_length = int(signal_params['ma_length'])
    ma_source_name = signal_params['ma_source']
    trend_price_name = signal_params['trend_price']
    tall_sample = int(signal_params['tall_sample'])
    tall_setting = str(signal_params['tall_setting']).upper()
    tall_tolerance = float(signal_params['tall_tolerance'])
    ibct_tolerance = float(signal_params['ibct_tolerance'])
    if ma_length < 1 or tall_sample < 1:
        raise ValueError('ma_length and tall_sample must be positive')
    if tall_setting not in ('RANGE', 'BODY'):
        raise ValueError('tall_setting must be RANGE or BODY')
    if tall_tolerance < 0.0 or ibct_tolerance < 0.0:
        raise ValueError('tolerances must be non-negative')
    ma_source = _get_price_series(market, ma_source_name, size)
    trend_price = _get_price_series(market, trend_price_name, size)
    moving_average = _rolling_mean(ma_source, ma_length)
    bodies = closes - opens
    body_sizes = np.abs(bodies)
    candle_ranges = highs - lows
    tall_values = candle_ranges if tall_setting == 'RANGE' else body_sizes
    previous_tall_mean = _previous_mean(tall_values, tall_sample)
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & np.isfinite(previous_tall_mean) & np.isfinite(moving_average) & (candle_ranges >= 0.0)
    tall = finite & (tall_values >= previous_tall_mean * tall_tolerance)
    bearish = finite & (bodies < 0.0)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size >= 4:
        t = np.arange(3, size)
        c1 = t - 2
        c2 = t - 1
        c3 = t
        trend_index = t - 3
        average_body = (body_sizes[c1] + body_sizes[c2] + body_sizes[c3]) / 3.0
        similar_bodies = (body_sizes[c1] >= average_body * (1.0 - ibct_tolerance)) & (body_sizes[c1] <= average_body * (1.0 + ibct_tolerance)) & (body_sizes[c2] >= average_body * (1.0 - ibct_tolerance)) & (body_sizes[c2] <= average_body * (1.0 + ibct_tolerance)) & (body_sizes[c3] >= average_body * (1.0 - ibct_tolerance)) & (body_sizes[c3] <= average_body * (1.0 + ibct_tolerance))
        opens_near_previous_close = (opens[c2] + bodies[c1] * ibct_tolerance >= closes[c1]) & (opens[c3] + bodies[c2] * ibct_tolerance >= closes[c2])
        pattern = finite[c1] & finite[c2] & finite[c3] & np.isfinite(trend_price[trend_index]) & (trend_price[trend_index] > moving_average[trend_index]) & bearish[c1] & bearish[c2] & bearish[c3] & tall[c1] & tall[c2] & tall[c3] & similar_bodies & opens_near_previous_close
        short_entries[t] = pattern
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'identical_black_crows_short', 'hypothesis': '上行動態 MA 中的連續高波動陰線形態可能預示看跌反轉，採空頭。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'ma_source', 'trend_price', 'tall_sample', 'tall_setting', 'tall_tolerance', 'ibct_tolerance', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'ma_length': 20, 'ma_source': 'close', 'trend_price': 'close', 'tall_sample': 14, 'tall_setting': 'RANGE', 'tall_tolerance': 1.5, 'ibct_tolerance': 0.25, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
