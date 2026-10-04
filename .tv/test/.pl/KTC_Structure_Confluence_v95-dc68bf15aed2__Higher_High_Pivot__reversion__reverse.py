import numpy as np

def generate_entries(features, signal_params):
    pivot_len = signal_params['pivotLen']
    n = features.market.size
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    ph = features.pivot_high(pivot_len, pivot_len)
    last_high = np.nan
    for t in range(n):
        if not np.isnan(ph[t]):
            if np.isnan(last_high) or ph[t] > last_high:
                long_entries[t] = True
            last_high = ph[t]
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Higher_High_Pivot__reversion__reverse', 'hypothesis': '策略在已確認的樞紐高點高於先前記錄的最高點時觸發。', 'position': 'both', 'signal_parameter_names': ['pivotLen'], 'signal_parameter_specs': [{'name': 'pivotLen', 'family': 'lookback', 'anchor': 5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivotLen': [5, 2, 10]}}, 'generate_signals': generate_signals}
