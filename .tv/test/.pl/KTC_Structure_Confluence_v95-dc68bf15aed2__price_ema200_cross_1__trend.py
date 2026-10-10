import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    ema200Len = signal_params['ema200Len']
    n = features.market.size
    close = features.market.closes
    ema200 = features.ema(ema200Len)
    previous_close = np.concatenate(([np.nan], close[:-1]))
    previous_ema200 = np.concatenate(([np.nan], ema200[:-1]))
    long_entries = (close > ema200) & (previous_close <= previous_ema200)
    short_entries = (close < ema200) & (previous_close >= previous_ema200)
    return (long_entries.astype(bool), short_entries.astype(bool))

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'price_ema200_cross_1__trend', 'hypothesis': '收盤價向上穿越 EMA 時做多，向下穿越 EMA 時做空。', 'position': 'both', 'signal_parameter_names': ['ema200Len'], 'signal_parameter_specs': [{'name': 'ema200Len', 'family': 'lookback', 'anchor': 200}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'ema200Len': [200, 100, 400]}}, 'generate_signals': generate_signals}
