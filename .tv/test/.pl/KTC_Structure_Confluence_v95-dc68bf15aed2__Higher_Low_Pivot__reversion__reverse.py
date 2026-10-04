import numpy as np

def generate_entries(features, signal_params):
    pivot_len = signal_params['pivot_len']
    n = features.market.size
    pivot_lows = features.pivot_low(pivot_len, pivot_len)
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    last_low = np.nan
    for t in range(n):
        pivot_low = pivot_lows[t]
        if not np.isnan(pivot_low):
            if np.isnan(last_low) or pivot_low > last_low:
                long_entries[t] = True
            last_low = pivot_low
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Higher_Low_Pivot__reversion__reverse', 'hypothesis': '每當確認的 pivot low 高於先前記錄的低點時觸發，並更新記錄低點。', 'position': 'both', 'signal_parameter_names': ['pivot_len'], 'signal_parameter_specs': [{'name': 'pivot_len', 'family': 'lookback', 'anchor': 5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivot_len': [5, 2, 10]}}, 'generate_signals': generate_signals}
