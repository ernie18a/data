import numpy as np

def generate_signals(features, signal_params):
    short_period = signal_params['short_sma_period']
    long_period = signal_params['long_sma_period']
    short_sma = features.sma(short_period)
    long_sma = features.sma(long_period)
    long_entries = (short_sma > long_sma) & np.concatenate(([False], short_sma[:-1] <= long_sma[:-1]))
    long_exits = (short_sma < long_sma) & np.concatenate(([False], short_sma[:-1] >= long_sma[:-1]))
    n = features.market.size
    short_entries = np.zeros(n, dtype=bool)
    short_exits = np.zeros(n, dtype=bool)
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

_SIGNAL_PARAMETER_SETS = [{'short_sma_period': 10, 'long_sma_period': 30}, {'short_sma_period': 10, 'long_sma_period': 15}, {'short_sma_period': 10, 'long_sma_period': 60}, {'short_sma_period': 5, 'long_sma_period': 30}, {'short_sma_period': 5, 'long_sma_period': 15}, {'short_sma_period': 5, 'long_sma_period': 60}, {'short_sma_period': 20, 'long_sma_period': 30}, {'short_sma_period': 20, 'long_sma_period': 60}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'sma_crossover__native__follow', 'hypothesis': '以短期均線上穿長期均線進場，並在短期均線下穿長期均線時出場。', 'position': 'long', 'signal_parameter_names': ['short_sma_period', 'long_sma_period'], 'signal_parameter_specs': [{'name': 'short_sma_period', 'family': 'lookback', 'anchor': 10}, {'name': 'long_sma_period', 'family': 'lookback', 'anchor': 30}], 'signal_parameter_relations': [['short_sma_period', 'lt', 'long_sma_period']]}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
