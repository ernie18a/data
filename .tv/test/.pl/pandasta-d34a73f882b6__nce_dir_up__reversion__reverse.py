def generate_entries(features, signal_params):
    short_stop_lookback = signal_params['short_stop_lookback']
    atr_lookback = signal_params['atr_lookback']
    stop_atr_multiplier = signal_params['stop_atr_multiplier']
    n = features.market.size
    closes = np.asarray(features.market.closes)
    short_stop = features.lowest(short_stop_lookback, 'closes') + stop_atr_multiplier * features.atr(atr_lookback)
    previous_short_stop = np.concatenate(([np.nan], short_stop[:-1]))
    long_entries = np.asarray(closes > previous_short_stop, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    import numpy as np
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'short_stop_lookback': 22, 'atr_lookback': 22, 'stop_atr_multiplier': 2.0}, {'short_stop_lookback': 22, 'atr_lookback': 22, 'stop_atr_multiplier': 1.0}, {'short_stop_lookback': 22, 'atr_lookback': 22, 'stop_atr_multiplier': 1.5}, {'short_stop_lookback': 22, 'atr_lookback': 22, 'stop_atr_multiplier': 3.0}, {'short_stop_lookback': 22, 'atr_lookback': 11, 'stop_atr_multiplier': 2.0}, {'short_stop_lookback': 22, 'atr_lookback': 11, 'stop_atr_multiplier': 1.0}, {'short_stop_lookback': 22, 'atr_lookback': 11, 'stop_atr_multiplier': 1.5}, {'short_stop_lookback': 22, 'atr_lookback': 11, 'stop_atr_multiplier': 3.0}, {'short_stop_lookback': 22, 'atr_lookback': 44, 'stop_atr_multiplier': 2.0}, {'short_stop_lookback': 22, 'atr_lookback': 44, 'stop_atr_multiplier': 1.0}, {'short_stop_lookback': 22, 'atr_lookback': 44, 'stop_atr_multiplier': 1.5}, {'short_stop_lookback': 22, 'atr_lookback': 44, 'stop_atr_multiplier': 3.0}, {'short_stop_lookback': 11, 'atr_lookback': 22, 'stop_atr_multiplier': 2.0}, {'short_stop_lookback': 11, 'atr_lookback': 22, 'stop_atr_multiplier': 1.0}, {'short_stop_lookback': 11, 'atr_lookback': 22, 'stop_atr_multiplier': 1.5}, {'short_stop_lookback': 11, 'atr_lookback': 22, 'stop_atr_multiplier': 3.0}, {'short_stop_lookback': 11, 'atr_lookback': 11, 'stop_atr_multiplier': 2.0}, {'short_stop_lookback': 11, 'atr_lookback': 11, 'stop_atr_multiplier': 1.0}, {'short_stop_lookback': 11, 'atr_lookback': 11, 'stop_atr_multiplier': 1.5}, {'short_stop_lookback': 11, 'atr_lookback': 11, 'stop_atr_multiplier': 3.0}, {'short_stop_lookback': 11, 'atr_lookback': 44, 'stop_atr_multiplier': 2.0}, {'short_stop_lookback': 11, 'atr_lookback': 44, 'stop_atr_multiplier': 1.0}, {'short_stop_lookback': 11, 'atr_lookback': 44, 'stop_atr_multiplier': 1.5}, {'short_stop_lookback': 11, 'atr_lookback': 44, 'stop_atr_multiplier': 3.0}, {'short_stop_lookback': 44, 'atr_lookback': 22, 'stop_atr_multiplier': 2.0}, {'short_stop_lookback': 44, 'atr_lookback': 22, 'stop_atr_multiplier': 1.0}, {'short_stop_lookback': 44, 'atr_lookback': 22, 'stop_atr_multiplier': 1.5}, {'short_stop_lookback': 44, 'atr_lookback': 22, 'stop_atr_multiplier': 3.0}, {'short_stop_lookback': 44, 'atr_lookback': 11, 'stop_atr_multiplier': 2.0}, {'short_stop_lookback': 44, 'atr_lookback': 11, 'stop_atr_multiplier': 1.0}, {'short_stop_lookback': 44, 'atr_lookback': 11, 'stop_atr_multiplier': 1.5}, {'short_stop_lookback': 44, 'atr_lookback': 11, 'stop_atr_multiplier': 3.0}, {'short_stop_lookback': 44, 'atr_lookback': 44, 'stop_atr_multiplier': 2.0}, {'short_stop_lookback': 44, 'atr_lookback': 44, 'stop_atr_multiplier': 1.0}, {'short_stop_lookback': 44, 'atr_lookback': 44, 'stop_atr_multiplier': 1.5}, {'short_stop_lookback': 44, 'atr_lookback': 44, 'stop_atr_multiplier': 3.0}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'nce_dir_up__reversion__reverse', 'hypothesis': '當收盤價突破前一根由近期最低收盤價加上 ATR 緩衝形成的 shortStop 時，策略將方向翻為做多。', 'position': 'both', 'signal_parameter_names': ['short_stop_lookback', 'atr_lookback', 'stop_atr_multiplier'], 'signal_parameter_specs': [{'name': 'short_stop_lookback', 'family': 'lookback', 'anchor': 22}, {'name': 'atr_lookback', 'family': 'lookback', 'anchor': 22}, {'name': 'stop_atr_multiplier', 'family': 'multiplier', 'anchor': 2.0}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
