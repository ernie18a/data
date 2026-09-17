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

def _prior_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for t in range(window, values.size):
        sample = values[t - window:t]
        if np.all(np.isfinite(sample)):
            result[t] = np.mean(sample)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if any((series.size != size for series in (opens, highs, lows, closes))):
        raise ValueError('OHLC series length must equal features.market.size')
    params = dict(signal_params or {})
    doji_tol = float(params.get('i_DojiTol', 0.04))
    wick_base = str(params.get('i_DojiWickBase', 'WICKS')).upper()
    wick_sample = int(params.get('i_DojiWickSam', 14))
    dlwt = float(params.get('i_DLWT', 3.0))
    shadow_tol = float(params.get('i_GS_DFDojiSSize', 0.02))
    params.setdefault('k_base', 2.0)
    params.setdefault('mult', 2.0)
    if not np.isfinite(doji_tol) or doji_tol < 0.0:
        raise ValueError('i_DojiTol must be finite and non-negative')
    if wick_base not in {'WICKS', 'RANGE'}:
        raise ValueError('i_DojiWickBase must be WICKS or RANGE')
    if wick_sample < 1:
        raise ValueError('i_DojiWickSam must be positive')
    if not np.isfinite(dlwt) or dlwt < 0.0:
        raise ValueError('i_DLWT must be finite and non-negative')
    if not np.isfinite(shadow_tol) or shadow_tol < 0.0:
        raise ValueError('i_GS_DFDojiSSize must be finite and non-negative')
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    candle_range = highs - lows
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    finite_ohlc = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    valid_candle = finite_ohlc & (candle_range > 0.0) & (upper_wick >= 0.0) & (lower_wick >= 0.0)
    body_ratio = np.full(size, np.nan, dtype=float)
    body_ratio[valid_candle] = np.abs(closes[valid_candle] - opens[valid_candle]) / candle_range[valid_candle]
    if wick_base == 'RANGE':
        upper_measure = np.full(size, np.nan, dtype=float)
        upper_measure[valid_candle] = upper_wick[valid_candle] / candle_range[valid_candle]
    else:
        upper_measure = upper_wick.copy()
    prior_upper_mean = _prior_mean(upper_measure, wick_sample)
    current_long_upper = valid_candle & np.isfinite(prior_upper_mean) & (upper_measure >= dlwt * prior_upper_mean)
    lower_shadow_ratio = np.full(size, np.nan, dtype=float)
    lower_shadow_ratio[valid_candle] = lower_wick[valid_candle] / candle_range[valid_candle]
    gravestone = valid_candle & (body_ratio <= doji_tol) & current_long_upper & ((lower_wick == 0.0) | (lower_shadow_ratio <= shadow_tol))
    short_entries[:] = gravestone
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'gravestone_doji_short', 'hypothesis': '墓碑十字線的長上影與極小下影可能預示反轉，建立空頭部位捕捉後續下行。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_DojiTol', 'i_DojiWickBase', 'i_DojiWickSam', 'i_DLWT', 'i_GS_DFDojiSSize', 'k_base', 'mult'], 'signal_parameter_sets': [{'i_DojiTol': 0.04, 'i_DojiWickBase': 'WICKS', 'i_DojiWickSam': 14, 'i_DLWT': 3.0, 'i_GS_DFDojiSSize': 0.02, 'k_base': 2.0, 'mult': 2.0}]}
