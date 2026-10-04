import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    n = features.market.size
    length = signal_params['length']
    pgo_threshold = signal_params['pgo_threshold']
    closes = features.market.closes
    atr_ema = features.ema(length, features.atr(22))
    pgo = (closes - features.sma(length, closes)) / atr_ema
    long_entries = pgo > pgo_threshold
    short_entries = pgo < -pgo_threshold
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'pretty_good_oscillator_breakout_1__trend__follow', 'hypothesis': '以 PGO 高於 3 做多、低於 -3 做空，捕捉收盤價相對均線的標準化偏離。', 'position': 'both', 'signal_parameter_names': ['length', 'pgo_threshold'], 'signal_parameter_specs': [{'name': 'length', 'family': 'lookback', 'anchor': 14}, {'name': 'pgo_threshold', 'family': 'multiplier', 'anchor': 3.0}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'length': [14, 7, 28], 'pgo_threshold': [3.0, 2.0999999999999996, 4.199999999999999]}}, 'generate_signals': generate_signals}
