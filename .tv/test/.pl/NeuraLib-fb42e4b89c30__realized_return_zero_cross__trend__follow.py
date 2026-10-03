import numpy as np

def generate_entries(features, signal_params):
    epsilon = signal_params['denominator_epsilon']
    closes = np.asarray(features.market.closes, dtype=np.float64)
    previous_closes = np.concatenate(([np.nan], closes[:-1]))
    r = (closes - previous_closes) / np.maximum(np.abs(previous_closes), epsilon)
    previous_r = np.concatenate(([np.nan], r[:-1]))
    long_entries = (r > 0) & (previous_r <= 0)
    short_entries = (r < 0) & (previous_r >= 0)
    return (long_entries.astype(bool), short_entries.astype(bool))

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'denominator_epsilon': 1e-07}, {'denominator_epsilon': 6.999999999999999e-08}, {'denominator_epsilon': 1.3999999999999998e-07}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'realized_return_zero_cross__trend__follow', 'hypothesis': '以單根價格變動率穿越零軸判斷方向反轉，向上穿越做多、向下穿越做空。', 'position': 'both', 'signal_parameter_names': ['denominator_epsilon'], 'signal_parameter_specs': [{'name': 'denominator_epsilon', 'family': 'multiplier', 'anchor': 1e-07}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
