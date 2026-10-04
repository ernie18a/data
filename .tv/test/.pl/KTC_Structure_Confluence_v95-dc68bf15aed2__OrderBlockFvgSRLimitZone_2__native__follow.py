import numpy as np
from numba import njit

import numpy as np
from numba import njit

@njit
def _zone_entries(lows, highs, long_zone, short_zone):
    n = lows.size
    long_entries = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    long_level = np.nan
    short_level = np.nan
    long_live = False
    short_live = False
    for i in range(n):
        if long_zone[i]:
            long_level = long_zone[i]
            long_live = True
        if short_zone[i]:
            short_level = short_zone[i]
            short_live = True
        if long_live and lows[i] <= long_level and (long_level <= highs[i]):
            long_entries[i] = True
            long_live = False
        if short_live and lows[i] <= short_level and (short_level <= highs[i]):
            short_entries[i] = True
            short_live = False
    return (long_entries, short_entries)

def generate_signals(features, signal_params):
    pivot_lookback = signal_params['pivot_lookback']
    ob_max_atr_multiplier = signal_params['ob_max_atr_multiplier']
    fvg_min_atr_multiplier = signal_params['fvg_min_atr_multiplier']
    sr_buffer_atr_multiplier = signal_params['sr_buffer_atr_multiplier']
    stop_distance_atr_multiplier = signal_params['stop_distance_atr_multiplier']
    tp1_risk_multiplier = signal_params['tp1_risk_multiplier']
    tp2_risk_multiplier = signal_params['tp2_risk_multiplier']
    tp3_risk_multiplier = signal_params['tp3_risk_multiplier']
    ent_point_size = signal_params['ent_point_size']
    n = features.market.size
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    opens = features.market.opens
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    atr = features.atr(22)
    bull_ob = np.zeros(n, dtype=np.bool_)
    bear_ob = np.zeros(n, dtype=np.bool_)
    bull_fvg = np.zeros(n, dtype=np.bool_)
    bear_fvg = np.zeros(n, dtype=np.bool_)
    bull_ob[2:] = (closes[:-2] < opens[:-2]) & (closes[1:-1] > opens[1:-1]) & (lows[2:] > highs[:-2]) & (highs[:-2] - lows[2:] < atr[2:] * ob_max_atr_multiplier)
    bear_ob[2:] = (closes[:-2] > opens[:-2]) & (closes[1:-1] < opens[1:-1]) & (highs[2:] < lows[:-2]) & (highs[:-2] - lows[2:] < atr[2:] * ob_max_atr_multiplier)
    bull_fvg[2:] = (lows[2:] > highs[:-2]) & (lows[2:] - highs[:-2] >= atr[2:] * fvg_min_atr_multiplier)
    bear_fvg[2:] = (highs[2:] < lows[:-2]) & (lows[:-2] - highs[2:] >= atr[2:] * fvg_min_atr_multiplier)
    long_levels = np.full(n, np.nan, dtype=np.float64)
    short_levels = np.full(n, np.nan, dtype=np.float64)
    long_levels[bull_ob] = highs[:-2][bull_ob[2:]]
    long_levels[bull_fvg] = lows[2:][bull_fvg[2:]]
    short_levels[bear_ob] = lows[:-2][bear_ob[2:]]
    short_levels[bear_fvg] = lows[:-2][bear_fvg[2:]]
    long_entries, short_entries = _zone_entries(lows, highs, long_levels, short_levels)
    stop_distances[long_entries | short_entries] = atr[long_entries | short_entries] * stop_distance_atr_multiplier
    target_distances[long_entries | short_entries] = stop_distances[long_entries | short_entries] * tp1_risk_multiplier
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

STRATEGY = {**{'strategy_id': 'OrderBlockFvgSRLimitZone_2__native__follow', 'hypothesis': '在確認 K 線上建立符合條件的多空 OB 或 FVG 限價區，依區間觸價進場，並以固定點數停損及 1、2、3 倍風險距離分批停利。', 'position': 'both', 'signal_parameter_names': ['pivot_lookback', 'ob_max_atr_multiplier', 'fvg_min_atr_multiplier', 'sr_buffer_atr_multiplier', 'stop_distance_atr_multiplier', 'tp1_risk_multiplier', 'tp2_risk_multiplier', 'tp3_risk_multiplier', 'ent_point_size'], 'signal_parameter_specs': [{'name': 'pivot_lookback', 'family': 'lookback', 'anchor': 7}, {'name': 'ob_max_atr_multiplier', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'fvg_min_atr_multiplier', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'sr_buffer_atr_multiplier', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'stop_distance_atr_multiplier', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'tp1_risk_multiplier', 'family': 'multiplier', 'anchor': 1.0}, {'name': 'tp2_risk_multiplier', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'tp3_risk_multiplier', 'family': 'multiplier', 'anchor': 3.0}, {'name': 'ent_point_size', 'family': 'multiplier', 'anchor': 0.01}], 'signal_parameter_relations': [['tp1_risk_multiplier', 'lt', 'tp2_risk_multiplier'], ['tp2_risk_multiplier', 'lt', 'tp3_risk_multiplier']], 'signal_parameter_candidates': {'pivot_lookback': [7, 4, 14], 'ob_max_atr_multiplier': [2.0, 1.4, 2.8], 'fvg_min_atr_multiplier': [0.2, 0.13999999999999999, 0.27999999999999997], 'sr_buffer_atr_multiplier': [2.0, 1.0, 1.5, 3.0], 'stop_distance_atr_multiplier': [2.0, 1.0, 1.5, 3.0], 'tp1_risk_multiplier': [1.0, 0.7, 1.4], 'tp2_risk_multiplier': [2.0, 1.4, 2.8], 'tp3_risk_multiplier': [3.0, 2.0999999999999996, 4.199999999999999], 'ent_point_size': [0.01, 0.006999999999999999, 0.013999999999999999]}}, 'generate_signals': generate_signals}
