import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    closes = features.market.closes
    n = features.market.size
    realized_return = np.full(n, np.nan, dtype=np.float64)
    if n > 1:
        previous_closes = closes[:-1]
        realized_return[1:] = (closes[1:] - previous_closes) / np.maximum(np.abs(previous_closes), 1e-07)
    previous_return = np.concatenate(([np.nan], realized_return[:-1]))
    long_entries = (realized_return > 0.0) & (previous_return <= 0.0)
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Realized_Return_Crosses_Above_Zero_0__trend__follow', 'hypothesis': '當 realizedReturn 向上穿越零軸時進場。', 'position': 'both', 'signal_parameter_names': [], 'signal_parameter_specs': [], 'signal_parameter_relations': [], 'signal_parameter_candidates': {}}, 'generate_signals': generate_signals}
