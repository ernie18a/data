import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    n = features.market.size
    closes = features.market.closes
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    if n >= 3:
        current = closes[2:]
        previous = closes[1:-1]
        previous2 = closes[:-2]
        r_t = (current - previous) / np.maximum(np.abs(previous), 1e-07)
        r_previous = (previous - previous2) / np.maximum(np.abs(previous2), 1e-07)
        valid = np.isfinite(current) & np.isfinite(previous) & np.isfinite(previous2)
        long_entries[2:] = valid & (r_t > 0) & (r_previous <= 0)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'realized_return_crosses_above_zero_3__reversion__follow', 'hypothesis': '當本期報酬由非正轉正時做多。', 'position': 'both', 'signal_parameter_names': [], 'signal_parameter_specs': [], 'signal_parameter_relations': [], 'signal_parameter_candidates': {}}, 'generate_signals': generate_signals}
