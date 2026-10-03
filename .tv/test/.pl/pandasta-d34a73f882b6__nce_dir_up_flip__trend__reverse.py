import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    length = int(signal_params['lookback_length'])
    multiplier = float(signal_params['atr_multiplier'])
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    prev_closes = np.full(n, np.nan, dtype=np.float64)
    prev_closes[1:] = closes[:-1]
    tr = np.maximum(highs - lows, np.maximum(highs - prev_closes, prev_closes - lows))
    tr_ema = np.full(n, np.nan, dtype=np.float64)
    alpha = 2.0 / (length + 1.0)
    for t in range(n):
        if np.isnan(tr[t]):
            continue
        if t == 0 or np.isnan(tr_ema[t - 1]):
            tr_ema[t] = tr[t]
        else:
            tr_ema[t] = (tr[t] - tr_ema[t - 1]) * alpha + tr_ema[t - 1]
    a = multiplier * tr_ema
    l0 = features.highest(length, 'closes') - a
    s0 = features.lowest(length, 'closes') + a
    l = np.full(n, np.nan, dtype=np.float64)
    s = np.full(n, np.nan, dtype=np.float64)
    d = np.ones(n, dtype=np.float64)
    for t in range(n):
        if t == 0:
            lp = l0[t]
            sp = s0[t]
        else:
            lp = l[t - 1] if not np.isnan(l[t - 1]) else l0[t]
            sp = s[t - 1] if not np.isnan(s[t - 1]) else s0[t]
        l[t] = max(l0[t], lp) if t > 0 and closes[t - 1] > lp else l0[t]
        s[t] = min(s0[t], sp) if t > 0 and closes[t - 1] < sp else s0[t]
        if t > 0:
            if closes[t] > sp:
                d[t] = 1.0
            elif closes[t] < l[t - 1]:
                d[t] = -1.0
            else:
                d[t] = d[t - 1]
    long_entries = np.zeros(n, dtype=bool)
    if n > 1:
        long_entries[1:] = (d[1:] == 1.0) & (d[:-1] == -1.0)
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'lookback_length': 22, 'atr_multiplier': 1.5}, {'lookback_length': 22, 'atr_multiplier': 1.0499999999999998}, {'lookback_length': 22, 'atr_multiplier': 2.0999999999999996}, {'lookback_length': 11, 'atr_multiplier': 1.5}, {'lookback_length': 11, 'atr_multiplier': 1.0499999999999998}, {'lookback_length': 11, 'atr_multiplier': 2.0999999999999996}, {'lookback_length': 44, 'atr_multiplier': 1.5}, {'lookback_length': 44, 'atr_multiplier': 1.0499999999999998}, {'lookback_length': 44, 'atr_multiplier': 2.0999999999999996}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'nce_dir_up_flip__trend__reverse', 'hypothesis': '以收盤價區間與 ATR 平滑幅度形成追蹤上下界，收盤突破前一根上界使方向由空翻多時進場。', 'position': 'both', 'signal_parameter_names': ['lookback_length', 'atr_multiplier'], 'signal_parameter_specs': [{'name': 'lookback_length', 'family': 'lookback', 'anchor': 22}, {'name': 'atr_multiplier', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
