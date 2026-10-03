def generate_entries(features, signal_params):
    import numpy as np
    n = features.market.size
    threshold = signal_params['predicted_return_threshold']
    closes = np.asarray(features.market.closes, dtype=np.float64)
    predicted_return = np.full(n, np.nan, dtype=np.float64)
    if n > 1:
        previous_closes = closes[:-1]
        valid = np.isfinite(closes[1:]) & np.isfinite(previous_closes) & (previous_closes != 0.0)
        returns = np.full(n - 1, np.nan, dtype=np.float64)
        returns[valid] = closes[1:][valid] / previous_closes[valid] - 1.0
        predicted_return[1:] = returns
    previous_return = np.full(n, np.nan, dtype=np.float64)
    if n > 1:
        previous_return[1:] = predicted_return[:-1]
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.isfinite(predicted_return) & np.isfinite(previous_return) & (predicted_return < threshold) & (previous_return >= threshold)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    import numpy as np
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'predicted_return_threshold': 0.0}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'predicted_return_zero_down__reversion__reverse', 'hypothesis': '當預測報酬由非負轉為負值時做空，未指定出場條件。', 'position': 'both', 'signal_parameter_names': ['predicted_return_threshold'], 'signal_parameter_specs': [{'name': 'predicted_return_threshold', 'family': 'fraction', 'anchor': 0.0}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
