import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    closes = features.market.closes
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    if n >= 3:
        returns = (closes[1:] - closes[:-1]) / np.maximum(np.abs(closes[:-1]), 1e-07)
        short_entries[2:] = (returns[1:] < 0) & (returns[:-1] >= 0)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'realized_return_crosses_below_zero__trend__follow', 'hypothesis': '當報酬由前一根非負轉為當前負值時做空。', 'position': 'both', 'signal_parameter_names': [], 'signal_parameter_specs': [], 'signal_parameter_relations': [], 'signal_parameter_candidates': {}}, 'generate_signals': generate_signals}
