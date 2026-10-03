def generate_entries(features, signal_params):
    n = features.market.size
    closes = np.asarray(features.market.closes, dtype=np.float64)
    threshold = signal_params['realized_return_threshold']
    realized_return = np.full(n, np.nan, dtype=np.float64)
    if n > 1:
        prev_closes = closes[:-1]
        valid = prev_closes != 0.0
        returns = np.full(n - 1, np.nan, dtype=np.float64)
        returns[valid] = closes[1:][valid] / prev_closes[valid] - 1.0
        realized_return[1:] = returns
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    short_entries[1:] = (realized_return[1:] < threshold) & (realized_return[:-1] >= threshold)
    return (long_entries, short_entries)

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

STRATEGY = {**{'strategy_id': 'realized_return_zero_down__reversion__reverse', 'hypothesis': '已實現報酬率下穿零時做空，且未設定出場規則。', 'position': 'both', 'signal_parameter_names': ['realized_return_threshold'], 'signal_parameter_specs': [{'name': 'realized_return_threshold', 'family': 'fraction', 'anchor': 0.0}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
