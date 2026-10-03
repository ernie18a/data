import numpy as np

def generate_entries(features, signal_params):
    import numpy as np
    length = signal_params['length']
    mult = signal_params['mult']
    n = features.market.size
    closes = np.asarray(features.market.closes, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    prev_close = np.concatenate(([np.nan], closes[:-1]))
    tr = np.maximum(highs - lows, np.maximum(np.abs(highs - prev_close), np.abs(lows - prev_close)))
    if n > 0:
        tr[0] = highs[0] - lows[0]
    alpha = 2.0 / (length + 1.0)
    tr_ema = np.full(n, np.nan, dtype=np.float64)
    for t in range(n):
        if t == 0 or np.isnan(tr_ema[t - 1]):
            tr_ema[t] = tr[t]
        else:
            tr_ema[t] = (tr[t] - tr_ema[t - 1]) * alpha + tr_ema[t - 1]
    a = mult * tr_ema
    highest_close = np.asarray(features.highest(length, closes), dtype=np.float64)
    lowest_close = np.asarray(features.lowest(length, closes), dtype=np.float64)
    l0 = highest_close - a
    s0 = lowest_close + a
    l = np.full(n, np.nan, dtype=np.float64)
    s = np.full(n, np.nan, dtype=np.float64)
    lp = np.full(n, np.nan, dtype=np.float64)
    sp = np.full(n, np.nan, dtype=np.float64)
    direction = np.ones(n, dtype=np.int8)
    for t in range(n):
        l_prev = l[t - 1] if t > 0 and (not np.isnan(l[t - 1])) else l0[t]
        s_prev = s[t - 1] if t > 0 and (not np.isnan(s[t - 1])) else s0[t]
        lp[t] = l_prev
        sp[t] = s_prev
        if t > 0 and closes[t - 1] > lp[t]:
            l[t] = max(l0[t], lp[t])
        else:
            l[t] = l0[t]
        if t > 0 and closes[t - 1] < sp[t]:
            s[t] = min(s0[t], sp[t])
        else:
            s[t] = s0[t]
        if t > 0:
            if closes[t] > sp[t - 1]:
                direction[t] = 1
            elif closes[t] < l[t - 1]:
                direction[t] = -1
            else:
                direction[t] = direction[t - 1]
    trend = np.where(direction == 1, l, s)
    long_entries = np.zeros(n, dtype=bool)
    if n > 1:
        long_entries[1:] = (closes[1:] > trend[1:]) & (closes[:-1] <= trend[:-1])
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'length': 22, 'mult': 1.5}, {'length': 22, 'mult': 1.0499999999999998}, {'length': 22, 'mult': 2.0999999999999996}, {'length': 11, 'mult': 1.5}, {'length': 11, 'mult': 1.0499999999999998}, {'length': 11, 'mult': 2.0999999999999996}, {'length': 44, 'mult': 1.5}, {'length': 44, 'mult': 1.0499999999999998}, {'length': 44, 'mult': 2.0999999999999996}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'nce_trend_cross_up__trend__reverse', 'hypothesis': '以最高與最低收盤價及 ATR 建構方向切換的追蹤趨勢線，收盤價上穿趨勢線時做多。', 'position': 'both', 'signal_parameter_names': ['length', 'mult'], 'signal_parameter_specs': [{'name': 'length', 'family': 'lookback', 'anchor': 22}, {'name': 'mult', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
