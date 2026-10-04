import numpy as np

def generate_entries(features, signal_params):
    pivotLen = signal_params['pivotLen']
    n = features.market.size
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    ph = features.pivot_high(pivotLen, pivotLen)
    lastHigh = np.nan
    for t in range(n):
        if not np.isnan(ph[t]):
            if not np.isnan(lastHigh) and ph[t] <= lastHigh:
                short_entries[t] = True
            lastHigh = ph[t]
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Lower_High_Pivot__trend__follow', 'hypothesis': '以長度 5 確認高點樞紐，當新確認的樞紐高點不高於前一個樞紐高點時觸發標記。', 'position': 'both', 'signal_parameter_names': ['pivotLen'], 'signal_parameter_specs': [{'name': 'pivotLen', 'family': 'lookback', 'anchor': 5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivotLen': [5, 2, 10]}}, 'generate_signals': generate_signals}
