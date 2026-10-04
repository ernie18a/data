import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    length = signal_params['length']
    pgo_threshold = signal_params['pgo_threshold']
    close = features.market.closes
    pgo = (close - features.sma(length)) / features.ema(length, features.atr(22))
    long_entries = pgo > pgo_threshold
    short_entries = pgo < -pgo_threshold
    return (long_entries.astype(bool), short_entries.astype(bool))

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'pgo_threshold_breakout_1__reversion__follow', 'hypothesis': '當 PGO 高於 3.0 時做多，低於 -3.0 時做空。', 'position': 'both', 'signal_parameter_names': ['length', 'pgo_threshold'], 'signal_parameter_specs': [{'name': 'length', 'family': 'lookback', 'anchor': 14}, {'name': 'pgo_threshold', 'family': 'threshold_0_100', 'anchor': 3.0}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'length': [14, 7, 28], 'pgo_threshold': [3.0, 0.0, 13.0]}}, 'generate_signals': generate_signals}
