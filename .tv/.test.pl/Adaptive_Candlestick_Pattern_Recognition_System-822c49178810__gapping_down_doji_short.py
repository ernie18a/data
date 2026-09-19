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
    for t in range(length - 1, values.size):
        window = values[t - length + 1:t + 1]
        if np.all(np.isfinite(window)):
            result[t] = np.mean(window)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    if any((series.size != size for series in (opens, highs, lows, closes))):
        raise ValueError('OHLC series length must equal features.market.size')
    doji_tolerance = float(signal_params.get('i_DojiTol', 0.04))
    ma_length = int(signal_params.get('ma_length', 20))
    if not np.isfinite(doji_tolerance) or doji_tolerance < 0.0:
        raise ValueError('i_DojiTol must be finite and non-negative')
    if ma_length < 1:
        raise ValueError('ma_length must be positive')
    candle_range = highs - lows
    body_ratio = np.full(size, np.nan, dtype=float)
    valid_range = np.isfinite(candle_range) & (candle_range > 0.0)
    body_ratio[valid_range] = np.abs(closes[valid_range] - opens[valid_range]) / candle_range[valid_range]
    moving_average = _sma(closes, ma_length)
    downtrend = np.zeros(size, dtype=np.bool_)
    if size > 1:
        downtrend[1:] = np.isfinite(closes[:-1]) & np.isfinite(moving_average[:-1]) & (closes[:-1] <= moving_average[:-1])
    finite_ohlc = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    doji = finite_ohlc & valid_range & (body_ratio <= doji_tolerance)
    gap_down = np.zeros(size, dtype=np.bool_)
    if size > 1:
        gap_down[1:] = finite_ohlc[1:] & np.isfinite(lows[:-1]) & (highs[1:] < lows[:-1])
    short_entries[:] = doji & gap_down & downtrend
    params = dict(signal_params or {})
    params.setdefault('k_base', 2.0)
    params.setdefault('gamma', 1.0)
    params.setdefault('n_base', 2000.0)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'gapping_down_doji_short', 'hypothesis': '下行趨勢中的向下跳空十字線可能延續下跌，建立空頭部位捕捉後續走勢。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_DojiTol', 'ma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'i_DojiTol': 0.04, 'ma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
