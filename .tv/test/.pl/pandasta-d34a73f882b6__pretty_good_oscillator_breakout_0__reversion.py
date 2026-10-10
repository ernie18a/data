import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    sma_length = signal_params['sma_length']
    atr_ema_length = signal_params['atr_ema_length']
    n = features.market.size
    closes = features.market.closes
    pgo = (closes - features.sma(sma_length)) / features.ema(atr_ema_length, features.atr(14))
    long_entries = np.asarray(pgo > 3.0, dtype=bool)
    short_entries = np.asarray(pgo < -3.0, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'pretty_good_oscillator_breakout_0__reversion', 'hypothesis': '以收盤價相對均線的 ATR 正規化偏離（PGO）作為方向訊號，偏離高於 3 做多、低於 -3 做空。', 'position': 'both', 'signal_parameter_names': ['sma_length', 'atr_ema_length'], 'signal_parameter_specs': [{'name': 'sma_length', 'family': 'lookback', 'anchor': 14}, {'name': 'atr_ema_length', 'family': 'lookback', 'anchor': 14}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'sma_length': [14, 7, 28], 'atr_ema_length': [14, 7, 28]}}, 'generate_signals': generate_signals}
