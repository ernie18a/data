def generate_entries(features, signal_params):
    n = features.market.size
    highest_lookback = signal_params['highest_lookback']
    atr_lookback = signal_params['atr_lookback']
    stop_atr_multiplier = signal_params['stop_atr_multiplier']
    closes = features.market.closes
    long_stop = features.highest(highest_lookback, closes) - stop_atr_multiplier * features.atr(atr_lookback)
    previous_long_stop = np.concatenate(([np.nan], long_stop[:-1]))
    long_entries = np.zeros(n, dtype=bool)
    short_entries = closes < previous_long_stop
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    import numpy as np
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'highest_lookback': 22, 'atr_lookback': 22, 'stop_atr_multiplier': 2.0}, {'highest_lookback': 22, 'atr_lookback': 22, 'stop_atr_multiplier': 1.0}, {'highest_lookback': 22, 'atr_lookback': 22, 'stop_atr_multiplier': 1.5}, {'highest_lookback': 22, 'atr_lookback': 22, 'stop_atr_multiplier': 3.0}, {'highest_lookback': 22, 'atr_lookback': 11, 'stop_atr_multiplier': 2.0}, {'highest_lookback': 22, 'atr_lookback': 11, 'stop_atr_multiplier': 1.0}, {'highest_lookback': 22, 'atr_lookback': 11, 'stop_atr_multiplier': 1.5}, {'highest_lookback': 22, 'atr_lookback': 11, 'stop_atr_multiplier': 3.0}, {'highest_lookback': 22, 'atr_lookback': 44, 'stop_atr_multiplier': 2.0}, {'highest_lookback': 22, 'atr_lookback': 44, 'stop_atr_multiplier': 1.0}, {'highest_lookback': 22, 'atr_lookback': 44, 'stop_atr_multiplier': 1.5}, {'highest_lookback': 22, 'atr_lookback': 44, 'stop_atr_multiplier': 3.0}, {'highest_lookback': 11, 'atr_lookback': 22, 'stop_atr_multiplier': 2.0}, {'highest_lookback': 11, 'atr_lookback': 22, 'stop_atr_multiplier': 1.0}, {'highest_lookback': 11, 'atr_lookback': 22, 'stop_atr_multiplier': 1.5}, {'highest_lookback': 11, 'atr_lookback': 22, 'stop_atr_multiplier': 3.0}, {'highest_lookback': 11, 'atr_lookback': 11, 'stop_atr_multiplier': 2.0}, {'highest_lookback': 11, 'atr_lookback': 11, 'stop_atr_multiplier': 1.0}, {'highest_lookback': 11, 'atr_lookback': 11, 'stop_atr_multiplier': 1.5}, {'highest_lookback': 11, 'atr_lookback': 11, 'stop_atr_multiplier': 3.0}, {'highest_lookback': 11, 'atr_lookback': 44, 'stop_atr_multiplier': 2.0}, {'highest_lookback': 11, 'atr_lookback': 44, 'stop_atr_multiplier': 1.0}, {'highest_lookback': 11, 'atr_lookback': 44, 'stop_atr_multiplier': 1.5}, {'highest_lookback': 11, 'atr_lookback': 44, 'stop_atr_multiplier': 3.0}, {'highest_lookback': 44, 'atr_lookback': 22, 'stop_atr_multiplier': 2.0}, {'highest_lookback': 44, 'atr_lookback': 22, 'stop_atr_multiplier': 1.0}, {'highest_lookback': 44, 'atr_lookback': 22, 'stop_atr_multiplier': 1.5}, {'highest_lookback': 44, 'atr_lookback': 22, 'stop_atr_multiplier': 3.0}, {'highest_lookback': 44, 'atr_lookback': 11, 'stop_atr_multiplier': 2.0}, {'highest_lookback': 44, 'atr_lookback': 11, 'stop_atr_multiplier': 1.0}, {'highest_lookback': 44, 'atr_lookback': 11, 'stop_atr_multiplier': 1.5}, {'highest_lookback': 44, 'atr_lookback': 11, 'stop_atr_multiplier': 3.0}, {'highest_lookback': 44, 'atr_lookback': 44, 'stop_atr_multiplier': 2.0}, {'highest_lookback': 44, 'atr_lookback': 44, 'stop_atr_multiplier': 1.0}, {'highest_lookback': 44, 'atr_lookback': 44, 'stop_atr_multiplier': 1.5}, {'highest_lookback': 44, 'atr_lookback': 44, 'stop_atr_multiplier': 3.0}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'nce_dir_down__trend__reverse', 'hypothesis': '當收盤價跌破前一根以近期最高收盤價減去 ATR 倍數所得的多方追蹤停損線時，策略轉為放空。', 'position': 'both', 'signal_parameter_names': ['highest_lookback', 'atr_lookback', 'stop_atr_multiplier'], 'signal_parameter_specs': [{'name': 'highest_lookback', 'family': 'lookback', 'anchor': 22}, {'name': 'atr_lookback', 'family': 'lookback', 'anchor': 22}, {'name': 'stop_atr_multiplier', 'family': 'multiplier', 'anchor': 2.0}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
