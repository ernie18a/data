import numpy as np
from numba import njit

from numba import njit
import numpy as np

@njit
def _rsi_divergence_entries(rsi_pl_found, rsi_ph_found, rsi_lbr, price_low_lbr, price_high_lbr):
    n = rsi_pl_found.size
    long_entries = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    prev_rsi_low = np.nan
    prev_price_low = np.nan
    prev_rsi_high = np.nan
    prev_price_high = np.nan
    for t in range(n):
        if rsi_pl_found[t]:
            long_entries[t] = rsi_lbr[t] > prev_rsi_low and price_low_lbr[t] < prev_price_low
            prev_rsi_low = rsi_lbr[t]
            prev_price_low = price_low_lbr[t]
        if rsi_ph_found[t]:
            short_entries[t] = rsi_lbr[t] < prev_rsi_high and price_high_lbr[t] > prev_price_high
            prev_rsi_high = rsi_lbr[t]
            prev_price_high = price_high_lbr[t]
    return (long_entries, short_entries)

def generate_entries(features, signal_params):
    rsi_length = signal_params['rsiLength']
    rsi_div_left = signal_params['rsiDivLeft']
    rsi_div_right = signal_params['rsiDivRight']
    n = features.market.size
    rsi = features.rsi(rsi_length)
    rsi_pl_found = ~np.isnan(features.pivot_low(rsi_div_left, rsi_div_right, rsi))
    rsi_ph_found = ~np.isnan(features.pivot_high(rsi_div_left, rsi_div_right, rsi))
    rsi_lbr = np.full(n, np.nan, dtype=np.float64)
    price_low_lbr = np.full(n, np.nan, dtype=np.float64)
    price_high_lbr = np.full(n, np.nan, dtype=np.float64)
    if rsi_div_right == 0:
        rsi_lbr[:] = rsi
        price_low_lbr[:] = features.market.lows
        price_high_lbr[:] = features.market.highs
    elif rsi_div_right < n:
        rsi_lbr[rsi_div_right:] = rsi[:-rsi_div_right]
        price_low_lbr[rsi_div_right:] = features.market.lows[:-rsi_div_right]
        price_high_lbr[rsi_div_right:] = features.market.highs[:-rsi_div_right]
    return _rsi_divergence_entries(rsi_pl_found, rsi_ph_found, rsi_lbr, price_low_lbr, price_high_lbr)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'rsi_pivot_divergence_0__trend', 'hypothesis': '以 RSI 樞紐與價格樞紐的背離進場，價格創更低低點而 RSI 創更高低點做多，價格創更高高點而 RSI 創更低高點做空，訊號在樞紐確認時觸發。', 'position': 'both', 'signal_parameter_names': ['rsiLength', 'rsiDivLeft', 'rsiDivRight'], 'signal_parameter_specs': [{'name': 'rsiLength', 'family': 'lookback', 'anchor': 14}, {'name': 'rsiDivLeft', 'family': 'lookback', 'anchor': 5}, {'name': 'rsiDivRight', 'family': 'lookback', 'anchor': 5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'rsiLength': [14, 7, 28], 'rsiDivLeft': [5, 2, 10], 'rsiDivRight': [5, 2, 10]}}, 'generate_signals': generate_signals}
