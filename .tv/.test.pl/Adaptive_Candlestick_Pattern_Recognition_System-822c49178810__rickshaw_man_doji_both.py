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

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    opens = np.asarray(market.opens, dtype=np.float64).reshape(-1)
    highs = np.asarray(market.highs, dtype=np.float64).reshape(-1)
    lows = np.asarray(market.lows, dtype=np.float64).reshape(-1)
    closes = np.asarray(market.closes, dtype=np.float64).reshape(-1)
    if any((series.size != size for series in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match market.size')
    params = dict(signal_params or {})
    doji_tol = float(params.get('i_DojiTol', 0.04))
    wick_base = str(params.get('i_DojiWickBase', 'WICKS')).upper()
    wick_sample = int(params.get('i_DojiWickSam', 14))
    wick_behavior = str(params.get('i_DojiTallWick', 'ONE')).upper()
    long_wick_tol = float(params.get('i_DLWT', 3.0))
    body_tol = float(params.get('i_RSMBodyTol', 0.05))
    params.setdefault('k_base', 2.0)
    params.setdefault('mult', 2.0)
    if not np.isfinite(doji_tol) or doji_tol < 0.0:
        raise ValueError('i_DojiTol must be finite and non-negative')
    if wick_base not in ('RANGE', 'WICKS'):
        raise ValueError('i_DojiWickBase must be RANGE or WICKS')
    if wick_sample < 1:
        raise ValueError('i_DojiWickSam must be positive')
    if wick_behavior not in ('ONE', 'BOTH', 'AVG'):
        raise ValueError('i_DojiTallWick must be ONE, BOTH, or AVG')
    if not np.isfinite(long_wick_tol) or long_wick_tol < 0.0:
        raise ValueError('i_DLWT must be finite and non-negative')
    if not np.isfinite(body_tol) or body_tol < 0.0:
        raise ValueError('i_RSMBodyTol must be finite and non-negative')
    k_base = float(params['k_base'])
    mult = float(params['mult'])
    if not np.isfinite(k_base) or k_base <= 0.0:
        raise ValueError('k_base must be finite and positive')
    if not np.isfinite(mult) or mult <= 0.0:
        raise ValueError('mult must be finite and positive')
    candle_range = highs - lows
    body = np.abs(closes - opens)
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    valid_current = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & np.isfinite(candle_range) & (candle_range > 0.0)
    body_ratio = np.full(size, np.nan, dtype=np.float64)
    body_position = np.full(size, np.nan, dtype=np.float64)
    body_ratio[valid_current] = body[valid_current] / candle_range[valid_current]
    body_position[valid_current] = ((opens[valid_current] + closes[valid_current]) * 0.5 - lows[valid_current]) / candle_range[valid_current]
    rsm = np.zeros(size, dtype=np.bool_)
    for t in range(wick_sample, size):
        if not valid_current[t] or body_ratio[t] > doji_tol:
            continue
        sample = slice(t - wick_sample, t)
        sample_valid = np.isfinite(upper_wick[sample]) & np.isfinite(lower_wick[sample]) & np.isfinite(candle_range[sample]) & (candle_range[sample] > 0.0)
        if not np.all(sample_valid):
            continue
        if wick_base == 'RANGE':
            sample_ranges = candle_range[sample]
            upper_average = np.mean(upper_wick[sample] / sample_ranges)
            lower_average = np.mean(lower_wick[sample] / sample_ranges)
            current_upper = upper_wick[t] / candle_range[t]
            current_lower = lower_wick[t] / candle_range[t]
        else:
            upper_average = np.mean(upper_wick[sample])
            lower_average = np.mean(lower_wick[sample])
            current_upper = upper_wick[t]
            current_lower = lower_wick[t]
        upper_limit = upper_average * long_wick_tol
        lower_limit = lower_average * long_wick_tol
        if wick_behavior == 'ONE':
            long_legged = current_upper >= upper_limit or current_lower >= lower_limit
        elif wick_behavior == 'BOTH':
            long_legged = current_upper >= upper_limit and current_lower >= lower_limit
        else:
            long_legged = (current_upper + current_lower) * 0.5 >= (upper_limit + lower_limit) * 0.5
        rsm[t] = long_legged and body_position[t] >= 0.5 - body_tol and (body_position[t] <= 0.5 + body_tol)
    long_entries = rsm.copy()
    short_entries = rsm.copy()
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_).reshape(-1), short_entries, np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'rickshaw_man_doji_both', 'hypothesis': '長影線且實體居中的 Rickshaw Man 可能預示後續反轉波動，於多空兩側捕捉機會。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_DojiTol', 'i_DojiWickBase', 'i_DojiWickSam', 'i_DojiTallWick', 'i_DLWT', 'i_RSMBodyTol', 'k_base', 'mult'], 'signal_parameter_sets': [{'i_DojiTol': 0.04, 'i_DojiWickBase': 'WICKS', 'i_DojiWickSam': 14, 'i_DojiTallWick': 'ONE', 'i_DLWT': 3.0, 'i_RSMBodyTol': 0.05, 'k_base': 2.0, 'mult': 2.0}]}
