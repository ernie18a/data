import numpy as np

def generate_entries(features, signal_params):
    pivot_len = signal_params['pivot_len']
    n = features.market.size
    pivot_lows = features.pivot_low(pivot_len, pivot_len)
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    last_low = np.nan
    for t in range(n):
        pl = pivot_lows[t]
        if not np.isnan(pl):
            if not np.isnan(last_low) and pl <= last_low:
                long_entries[t] = True
            last_low = pl
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Lower_Low_Pivot__trend__follow', 'hypothesis': '當已確認的 pivot low 不高於前一次 pivot low 時觸發。', 'position': 'both', 'signal_parameter_names': ['pivot_len'], 'signal_parameter_specs': [{'name': 'pivot_len', 'family': 'lookback', 'anchor': 5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivot_len': [5, 2, 10]}}, 'generate_signals': generate_signals}
