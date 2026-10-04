import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    fast = features.ema(signal_params['fast_ema_length'], 'closes')
    slow = features.ema(signal_params['slow_ema_length'], 'closes')
    prev_fast = np.concatenate(([np.nan], fast[:-1]))
    prev_slow = np.concatenate(([np.nan], slow[:-1]))
    long_entries = np.zeros(n, dtype=bool)
    short_entries = (fast < slow) & (prev_fast >= prev_slow)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'EMA_20_50_Crossunder__trend__reverse', 'hypothesis': '收盤價的短期 EMA 向下穿越長期 EMA 時進場，規則未明載出場條件。', 'position': 'both', 'signal_parameter_names': ['fast_ema_length', 'slow_ema_length'], 'signal_parameter_specs': [{'name': 'fast_ema_length', 'family': 'lookback', 'anchor': 20}, {'name': 'slow_ema_length', 'family': 'lookback', 'anchor': 50}], 'signal_parameter_relations': [['fast_ema_length', 'lt', 'slow_ema_length']], 'signal_parameter_candidates': {'fast_ema_length': [20, 10, 40], 'slow_ema_length': [50, 25, 100]}}, 'generate_signals': generate_signals}
