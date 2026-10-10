import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    n = features.market.size
    closes = features.market.closes
    ema200 = features.ema(signal_params['ema200Len'])
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    if n > 1:
        long_entries[1:] = (closes[1:] > ema200[1:]) & (closes[:-1] <= ema200[:-1])
        short_entries[1:] = (closes[1:] < ema200[1:]) & (closes[:-1] >= ema200[:-1])
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'price_ema_cross_2__reversion', 'hypothesis': '已確認的 K 棒上，收盤價上穿 EMA200 做多、下穿 EMA200 做空。', 'position': 'both', 'signal_parameter_names': ['ema200Len'], 'signal_parameter_specs': [{'name': 'ema200Len', 'family': 'lookback', 'anchor': 200}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'ema200Len': [200, 100, 400]}}, 'generate_signals': generate_signals}
