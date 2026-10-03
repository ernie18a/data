import numpy as np

def generate_entries(features, signal_params):
    length = int(signal_params['length'])
    mult = float(signal_params['mult'])
    n = features.market.size
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    prev_closes = np.concatenate(([np.nan], closes[:-1]))
    tr = np.fmax(highs - lows, np.fmax(highs - prev_closes, prev_closes - lows))
    ema_tr = np.full(n, np.nan, dtype=np.float64)
    alpha = 2.0 / (length + 1.0)
    for t in range(n):
        if np.isnan(ema_tr[t - 1]) if t > 0 else True:
            ema_tr[t] = tr[t]
        else:
            ema_tr[t] = (tr[t] - ema_tr[t - 1]) * alpha + ema_tr[t - 1]
    a = mult * ema_tr
    l0 = features.highest(length, 'closes') - a
    s0 = features.lowest(length, 'closes') + a
    l = np.full(n, np.nan, dtype=np.float64)
    s = np.full(n, np.nan, dtype=np.float64)
    for t in range(n):
        lp = l0[t] if t == 0 or np.isnan(l[t - 1]) else l[t - 1]
        sp = s0[t] if t == 0 or np.isnan(s[t - 1]) else s[t - 1]
        l[t] = max(l0[t], lp) if t > 0 and closes[t - 1] > lp else l0[t]
        s[t] = min(s0[t], sp) if t > 0 and closes[t - 1] < sp else s0[t]
    d = np.ones(n, dtype=np.int8)
    for t in range(n):
        if t > 0:
            if closes[t] > s[t - 1]:
                d[t] = 1
            elif closes[t] < l[t - 1]:
                d[t] = -1
            else:
                d[t] = d[t - 1]
    trend = np.where(d == 1, l, s)
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    if n > 1:
        short_entries[1:] = (closes[1:] < trend[1:]) & (closes[:-1] >= trend[:-1])
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'length': 22, 'mult': 1.5}, {'length': 22, 'mult': 1.0499999999999998}, {'length': 22, 'mult': 2.0999999999999996}, {'length': 11, 'mult': 1.5}, {'length': 11, 'mult': 1.0499999999999998}, {'length': 11, 'mult': 2.0999999999999996}, {'length': 44, 'mult': 1.5}, {'length': 44, 'mult': 1.0499999999999998}, {'length': 44, 'mult': 2.0999999999999996}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'nce_trend_cross_down__reversion__follow', 'hypothesis': '以 ATR 倍數調整的 EMA 真實波幅建立追蹤趨勢線，收盤價向下穿越趨勢線時做空。', 'position': 'both', 'signal_parameter_names': ['length', 'mult'], 'signal_parameter_specs': [{'name': 'length', 'family': 'lookback', 'anchor': 22}, {'name': 'mult', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
