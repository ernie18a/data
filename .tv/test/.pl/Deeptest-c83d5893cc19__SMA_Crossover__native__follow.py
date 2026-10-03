import numpy as np

def generate_signals(features, signal_params):
    fast_ma_period = signal_params['fast_ma_period']
    slow_ma_period = signal_params['slow_ma_period']
    n = features.market.size
    fast_ma = features.sma(fast_ma_period, 'closes')
    slow_ma = features.sma(slow_ma_period, 'closes')
    long_entries = np.zeros(n, dtype=bool)
    long_exits = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    short_exits = np.zeros(n, dtype=bool)
    long_entries[1:] = (fast_ma[1:] > slow_ma[1:]) & (fast_ma[:-1] <= slow_ma[:-1])
    long_exits[1:] = (fast_ma[1:] < slow_ma[1:]) & (fast_ma[:-1] >= slow_ma[:-1])
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

_SIGNAL_PARAMETER_SETS = [{'fast_ma_period': 10, 'slow_ma_period': 30}, {'fast_ma_period': 10, 'slow_ma_period': 15}, {'fast_ma_period': 10, 'slow_ma_period': 60}, {'fast_ma_period': 5, 'slow_ma_period': 30}, {'fast_ma_period': 5, 'slow_ma_period': 15}, {'fast_ma_period': 5, 'slow_ma_period': 60}, {'fast_ma_period': 20, 'slow_ma_period': 30}, {'fast_ma_period': 20, 'slow_ma_period': 60}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'SMA_Crossover__native__follow', 'hypothesis': '短期 SMA 上穿長期 SMA 時進場，短期 SMA 下穿長期 SMA 時出場。', 'position': 'long', 'signal_parameter_names': ['fast_ma_period', 'slow_ma_period'], 'signal_parameter_specs': [{'name': 'fast_ma_period', 'family': 'lookback', 'anchor': 10}, {'name': 'slow_ma_period', 'family': 'lookback', 'anchor': 30}], 'signal_parameter_relations': [['fast_ma_period', 'lt', 'slow_ma_period']]}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
