import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    ema_fast = features.ema(signal_params['ema_fast_length'])
    ema_slow = features.ema(signal_params['ema_slow_length'])
    long_entries = np.zeros(n, dtype=bool)
    long_entries[1:] = (ema_fast[1:] > ema_slow[1:]) & (ema_fast[:-1] <= ema_slow[:-1])
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'EMA_20_50_Crossover__trend__reverse', 'hypothesis': '當 20 期 EMA 向上穿越 50 期 EMA 時進場。', 'position': 'both', 'signal_parameter_names': ['ema_fast_length', 'ema_slow_length'], 'signal_parameter_specs': [{'name': 'ema_fast_length', 'family': 'lookback', 'anchor': 20}, {'name': 'ema_slow_length', 'family': 'lookback', 'anchor': 50}], 'signal_parameter_relations': [['ema_fast_length', 'lt', 'ema_slow_length']], 'signal_parameter_candidates': {'ema_fast_length': [20, 10, 40], 'ema_slow_length': [50, 25, 100]}}, 'generate_signals': generate_signals}
