import numpy as np
from numba import njit

def generate_signals(features, signal_params):
    fast_ma_length = signal_params['fast_ma_length']
    slow_ma_length = signal_params['slow_ma_length']
    fast_ma = features.sma(fast_ma_length)
    slow_ma = features.sma(slow_ma_length)
    prev_fast_ma = np.concatenate(([np.nan], fast_ma[:-1]))
    prev_slow_ma = np.concatenate(([np.nan], slow_ma[:-1]))
    long_entries = (fast_ma > slow_ma) & (prev_fast_ma <= prev_slow_ma)
    long_exits = (fast_ma < slow_ma) & (prev_fast_ma >= prev_slow_ma)
    short_entries = np.zeros(features.market.size, dtype=bool)
    short_exits = np.zeros(features.market.size, dtype=bool)
    stop_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    target_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

STRATEGY = {**{'strategy_id': 'sma_crossover_0__native', 'hypothesis': '當短期均線上穿長期均線時做多，短期均線下穿長期均線時平倉。', 'position': 'long', 'signal_parameter_names': ['fast_ma_length', 'slow_ma_length'], 'signal_parameter_specs': [{'name': 'fast_ma_length', 'family': 'lookback', 'anchor': 10}, {'name': 'slow_ma_length', 'family': 'lookback', 'anchor': 30}], 'signal_parameter_relations': [['fast_ma_length', 'lt', 'slow_ma_length']], 'signal_parameter_candidates': {'fast_ma_length': [10, 5, 20], 'slow_ma_length': [30, 15, 60]}}, 'generate_signals': generate_signals}
