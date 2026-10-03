import numpy as np

def generate_entries(features, signal_params):
    length = signal_params['length']
    mult = signal_params['mult']
    n = features.market.size
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    tr = np.empty(n, dtype=np.float64)
    if n > 0:
        tr[0] = highs[0] - lows[0]
    if n > 1:
        prev_close = closes[:-1]
        tr[1:] = np.maximum(highs[1:] - lows[1:], np.maximum(highs[1:] - prev_close, prev_close - lows[1:]))
    ema_tr = np.empty(n, dtype=np.float64)
    for t in range(n):
        if t == 0 or np.isnan(ema_tr[t - 1]):
            ema_tr[t] = tr[t]
        else:
            ema_tr[t] = (tr[t] - ema_tr[t - 1]) * 2.0 / (length + 1.0) + ema_tr[t - 1]
    a = mult * ema_tr
    highest_close = np.asarray(features.highest(length, 'closes'), dtype=np.float64)
    lowest_close = np.asarray(features.lowest(length, 'closes'), dtype=np.float64)
    l0 = highest_close - a
    s0 = lowest_close + a
    l = np.empty(n, dtype=np.float64)
    s = np.empty(n, dtype=np.float64)
    d = np.empty(n, dtype=np.int8)
    for t in range(n):
        prev_l = l[t - 1] if t > 0 else np.nan
        prev_s = s[t - 1] if t > 0 else np.nan
        prev_close = closes[t - 1] if t > 0 else np.nan
        lp = l0[t] if np.isnan(prev_l) else prev_l
        sp = s0[t] if np.isnan(prev_s) else prev_s
        l[t] = max(l0[t], lp) if prev_close > lp else l0[t]
        s[t] = min(s0[t], sp) if prev_close < sp else s0[t]
        if t == 0:
            d[t] = 1
        elif closes[t] > s[t - 1]:
            d[t] = 1
        elif closes[t] < l[t - 1]:
            d[t] = -1
        else:
            d[t] = d[t - 1]
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    if n > 1:
        short_entries[1:] = (d[1:] == -1) & (d[:-1] == 1)
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

STRATEGY = {**{'strategy_id': 'nce_dir_down_flip__trend__reverse', 'hypothesis': '以收盤價高低區間和 1.5 倍真實波幅指數均線建立追蹤界線，方向由收盤價突破前一根界線決定，方向由多翻空時做空。', 'position': 'both', 'signal_parameter_names': ['length', 'mult'], 'signal_parameter_specs': [{'name': 'length', 'family': 'lookback', 'anchor': 22}, {'name': 'mult', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
