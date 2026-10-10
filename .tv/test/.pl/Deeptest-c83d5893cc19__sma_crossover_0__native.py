import numpy as np
from numba import njit

def generate_signals(features, signal_params):
    n = features.market.size
    fast_ma = features.sma(signal_params['fast_ma_length'], 'closes')
    slow_ma = features.sma(signal_params['slow_ma_length'], 'closes')
    long_entries = np.zeros(n, dtype=bool)
    long_exits = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    short_exits = np.zeros(n, dtype=bool)
    long_entries[1:] = (fast_ma[1:] > slow_ma[1:]) & (fast_ma[:-1] <= slow_ma[:-1])
    long_exits[1:] = (fast_ma[1:] < slow_ma[1:]) & (fast_ma[:-1] >= slow_ma[:-1])
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

STRATEGY = {**{'strategy_id': 'sma_crossover_0__native', 'hypothesis': '短期均線上穿長期均線時做多，下穿時平倉。', 'position': 'long', 'signal_parameter_names': ['fast_ma_length', 'slow_ma_length'], 'signal_parameter_specs': [{'name': 'fast_ma_length', 'family': 'lookback', 'anchor': 10}, {'name': 'slow_ma_length', 'family': 'lookback', 'anchor': 30}], 'signal_parameter_relations': [['fast_ma_length', 'lt', 'slow_ma_length']], 'signal_parameter_candidates': {'fast_ma_length': [10, 5, 20], 'slow_ma_length': [30, 15, 60]}}, 'generate_signals': generate_signals}
