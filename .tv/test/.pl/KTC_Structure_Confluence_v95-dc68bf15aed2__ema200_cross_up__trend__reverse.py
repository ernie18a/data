import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    ema_period = signal_params['ema_period']
    closes = features.market.closes
    ema = features.ema(ema_period)
    prev_closes = np.concatenate(([np.nan], closes[:-1]))
    prev_ema = np.concatenate(([np.nan], ema[:-1]))
    long_entries = (closes > ema) & (prev_closes <= prev_ema)
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'ema_period': 200}, {'ema_period': 100}, {'ema_period': 400}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'ema200_cross_up__trend__reverse', 'hypothesis': '收盤價由下向上突破200期EMA時做多。', 'position': 'both', 'signal_parameter_names': ['ema_period'], 'signal_parameter_specs': [{'name': 'ema_period', 'family': 'lookback', 'anchor': 200}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
