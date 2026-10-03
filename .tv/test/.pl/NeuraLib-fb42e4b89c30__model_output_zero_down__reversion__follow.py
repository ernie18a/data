import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    entry_threshold = signal_params['entry_threshold']
    modelOutput = np.asarray(features.market.closes, dtype=np.float64) - entry_threshold
    short_entries = np.zeros(n, dtype=bool)
    short_entries[1:] = (modelOutput[1:] < 0.0) & (modelOutput[:-1] >= 0.0)
    long_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    import numpy as np
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'entry_threshold': 0.0}, {'entry_threshold': 10.0}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'model_output_zero_down__reversion__follow', 'hypothesis': '當 modelOutput 下穿零時做空。', 'position': 'both', 'signal_parameter_names': ['entry_threshold'], 'signal_parameter_specs': [{'name': 'entry_threshold', 'family': 'threshold_0_100', 'anchor': 0.0}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
