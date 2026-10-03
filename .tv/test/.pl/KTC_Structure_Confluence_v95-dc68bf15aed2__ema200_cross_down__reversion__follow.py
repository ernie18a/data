import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    ema_period = signal_params['ema_period']
    closes = features.market.closes
    ema200 = features.ema(ema_period)
    previous_closes = np.concatenate(([np.nan], closes[:-1]))
    previous_ema = np.concatenate(([np.nan], ema200[:-1]))
    long_entries = np.zeros(n, dtype=bool)
    short_entries = (closes < ema200) & (previous_closes >= previous_ema)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'ema_period': 200}, {'ema_period': 100}, {'ema_period': 400}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'ema200_cross_down__reversion__follow', 'hypothesis': '收盤價向下跌破 200 期 EMA 時做空。', 'position': 'both', 'signal_parameter_names': ['ema_period'], 'signal_parameter_specs': [{'name': 'ema_period', 'family': 'lookback', 'anchor': 200}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
