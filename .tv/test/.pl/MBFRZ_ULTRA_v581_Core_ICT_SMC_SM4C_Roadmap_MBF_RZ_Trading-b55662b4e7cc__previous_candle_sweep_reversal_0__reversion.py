import numpy as np
from numba import njit

def generate_entries(features, signal_params):
    n = features.market.size
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    if n > 1:
        lows = features.market.lows
        highs = features.market.highs
        opens = features.market.opens
        closes = features.market.closes
        long_entries[1:] = (lows[1:] < lows[:-1]) & (closes[1:] > opens[:-1])
        short_entries[1:] = (highs[1:] > highs[:-1]) & (closes[1:] < opens[:-1])
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'previous_candle_sweep_reversal_0__reversion', 'hypothesis': '價格突破前一根 K 棒的高低點後，若收盤反轉至前一根開盤價的另一側，則順反轉方向進場。', 'position': 'both', 'signal_parameter_names': [], 'signal_parameter_specs': [], 'signal_parameter_relations': [], 'signal_parameter_candidates': {}}, 'generate_signals': generate_signals}
