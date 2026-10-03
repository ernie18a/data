def generate_entries(features, signal_params):
    n = features.market.size
    threshold = signal_params['realized_return_threshold']
    closes = np.asarray(features.market.closes, dtype=np.float64)
    realized_return = np.full(n, np.nan, dtype=np.float64)
    with np.errstate(divide='ignore', invalid='ignore'):
        realized_return[1:] = closes[1:] / closes[:-1] - 1.0
    prev_return = np.concatenate(([np.nan], realized_return[:-1]))
    long_entries = (realized_return > threshold) & (prev_return <= threshold)
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries.astype(bool), short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    import numpy as np
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'realized_return_threshold': 0.0}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'realized_return_zero_up__reversion__reverse', 'hypothesis': '當已實現報酬由零以下向上穿越零時做多。', 'position': 'both', 'signal_parameter_names': ['realized_return_threshold'], 'signal_parameter_specs': [{'name': 'realized_return_threshold', 'family': 'fraction', 'anchor': 0.0}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
