import numpy as np

def generate_signals(features, signal_params):
    n = features.market.size
    fast_ma = features.sma(signal_params['fast_ma_length'])
    slow_ma = features.sma(signal_params['slow_ma_length'])
    prev_fast_ma = np.concatenate(([np.nan], fast_ma[:-1]))
    prev_slow_ma = np.concatenate(([np.nan], slow_ma[:-1]))
    long_entries = (fast_ma > slow_ma) & (prev_fast_ma <= prev_slow_ma)
    long_exits = (fast_ma < slow_ma) & (prev_fast_ma >= prev_slow_ma)
    short_entries = np.zeros(n, dtype=bool)
    short_exits = np.zeros(n, dtype=bool)
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

_SIGNAL_PARAMETER_SETS = [{'fast_ma_length': 10, 'slow_ma_length': 30}, {'fast_ma_length': 10, 'slow_ma_length': 15}, {'fast_ma_length': 10, 'slow_ma_length': 60}, {'fast_ma_length': 5, 'slow_ma_length': 30}, {'fast_ma_length': 5, 'slow_ma_length': 15}, {'fast_ma_length': 5, 'slow_ma_length': 60}, {'fast_ma_length': 20, 'slow_ma_length': 30}, {'fast_ma_length': 20, 'slow_ma_length': 60}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'sma_crossover__native__follow', 'hypothesis': '快均線向上穿越慢均線時做多，向下穿越時平倉。', 'position': 'long', 'signal_parameter_names': ['fast_ma_length', 'slow_ma_length'], 'signal_parameter_specs': [{'name': 'fast_ma_length', 'family': 'lookback', 'anchor': 10}, {'name': 'slow_ma_length', 'family': 'lookback', 'anchor': 30}], 'signal_parameter_relations': [['fast_ma_length', 'lt', 'slow_ma_length']]}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
