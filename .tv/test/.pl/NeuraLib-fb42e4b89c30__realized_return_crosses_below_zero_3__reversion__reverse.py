import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    closes = np.asarray(features.market.closes, dtype=np.float64)
    n = features.market.size
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    if n >= 3:
        close_t = closes[2:]
        close_prev = closes[1:-1]
        close_prev2 = closes[:-2]
        valid = np.isfinite(close_t) & np.isfinite(close_prev) & np.isfinite(close_prev2)
        r_t = (close_t - close_prev) / np.maximum(np.abs(close_prev), 1e-07)
        r_prev = (close_prev - close_prev2) / np.maximum(np.abs(close_prev2), 1e-07)
        short_entries[2:] = valid & (r_t < 0) & (r_prev >= 0)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'realized_return_crosses_below_zero_3__reversion__reverse', 'hypothesis': '當前報酬率由非負轉為負時做空。', 'position': 'both', 'signal_parameter_names': [], 'signal_parameter_specs': [], 'signal_parameter_relations': [], 'signal_parameter_candidates': {}}, 'generate_signals': generate_signals}
