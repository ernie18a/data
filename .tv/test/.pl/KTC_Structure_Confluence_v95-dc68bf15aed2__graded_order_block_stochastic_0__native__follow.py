import numpy as np
from numba import njit

import numpy as np
from numba import njit

@njit
def _read_fvg_ob(opens, highs, lows, closes, atr, gap_mult, ob_max_mult, ob_overlap, min_width):
    n = closes.size
    bull_ready = np.zeros(n, dtype=np.bool_)
    bear_ready = np.zeros(n, dtype=np.bool_)
    bull_bot = np.full(n, np.nan, dtype=np.float64)
    bear_top = np.full(n, np.nan, dtype=np.float64)
    bull_arm = -1
    bear_arm = -1
    max_zones = n
    bbot = np.empty(max_zones, dtype=np.float64)
    btop = np.empty(max_zones, dtype=np.float64)
    bactive = np.zeros(max_zones, dtype=np.bool_)
    sbot = np.empty(max_zones, dtype=np.float64)
    stop = np.empty(max_zones, dtype=np.float64)
    sactive = np.zeros(max_zones, dtype=np.bool_)
    nb = 0
    ns = 0
    for t in range(n):
        if t >= 2 and np.isfinite(atr[t]):
            if lows[t] > highs[t - 2] and lows[t] - highs[t - 2] >= atr[t] * gap_mult:
                bbot[nb] = highs[t - 2]
                btop[nb] = lows[t]
                bactive[nb] = True
                nb += 1
            if highs[t] < lows[t - 2] and lows[t - 2] - highs[t] >= atr[t] * gap_mult:
                sbot[ns] = highs[t]
                stop[ns] = lows[t - 2]
                sactive[ns] = True
                ns += 1
        for j in range(nb):
            if bactive[j] and lows[t] <= btop[j] and (highs[t] >= bbot[j]):
                bull_arm = t
                btop[j] = max(bbot[j], lows[t])
                if btop[j] <= bbot[j]:
                    bactive[j] = False
        for j in range(ns):
            if sactive[j] and highs[t] >= sbot[j] and (lows[t] <= stop[j]):
                bear_arm = t
                sbot[j] = min(stop[j], highs[t])
                if sbot[j] >= stop[j]:
                    sactive[j] = False
        if bull_arm >= 0:
            bull_ready[t] = t - bull_arm >= 1 and t - bull_arm <= 3
        if bear_arm >= 0:
            bear_ready[t] = t - bear_arm >= 1 and t - bear_arm <= 3
        if t >= 2 and np.isfinite(atr[t]):
            width = highs[t - 2] - lows[t - 2]
            overlap = min(highs[t - 2], highs[t]) - max(lows[t - 2], lows[t])
            qualifies = width > 0.0 and width < atr[t] * ob_max_mult and (width >= min_width) and (overlap >= width * ob_overlap)
            if qualifies and closes[t - 2] < opens[t - 2] and (closes[t - 1] > opens[t - 1]) and (lows[t] > highs[t - 2]):
                if lows[t] <= highs[t - 2] and highs[t] >= lows[t - 2]:
                    pass
                bull_bot[t] = lows[t - 2]
            if qualifies and closes[t - 2] > opens[t - 2] and (closes[t - 1] < opens[t - 1]) and (highs[t] < lows[t - 2]):
                bear_top[t] = highs[t - 2]
    return (bull_ready, bear_ready, bull_bot, bear_top)

def generate_signals(features, signal_params):
    stoch_raw_length = signal_params['stoch_raw_length']
    stoch_k_smoothing_length = signal_params['stoch_k_smoothing_length']
    stoch_d_smoothing_length = signal_params['stoch_d_smoothing_length']
    stoch_recent_window = signal_params['stoch_recent_window']
    stoch_long_threshold = signal_params['stoch_long_threshold']
    stoch_short_threshold = signal_params['stoch_short_threshold']
    fvg_pattern_bars = signal_params['fvg_pattern_bars']
    fvg_min_gap_atr_multiple = signal_params['fvg_min_gap_atr_multiple']
    fvg_ready_min_bars_since_touch = signal_params['fvg_ready_min_bars_since_touch']
    fvg_ready_max_bars_since_touch = signal_params['fvg_ready_max_bars_since_touch']
    ob_pattern_bars = signal_params['ob_pattern_bars']
    ob_max_width_atr_multiple = signal_params['ob_max_width_atr_multiple']
    ob_overlap_fraction = signal_params['ob_overlap_fraction']
    ob_min_width_atr_multiple = signal_params['ob_min_width_atr_multiple']
    pd_range_lookback = signal_params['pd_range_lookback']
    ema_fast_length = signal_params['ema_fast_length']
    ema_slow_length = signal_params['ema_slow_length']
    ema_trend_length = signal_params['ema_trend_length']
    structure_pivot_length = signal_params['structure_pivot_length']
    structure_break_atr_multiple = signal_params['structure_break_atr_multiple']
    structure_body_atr_multiple = signal_params['structure_body_atr_multiple']
    sar_start = signal_params['sar_start']
    sar_increment = signal_params['sar_increment']
    sar_maximum = signal_params['sar_maximum']
    lrc_length = signal_params['lrc_length']
    sr_pivot_left_length = signal_params['sr_pivot_left_length']
    sr_pivot_right_length = signal_params['sr_pivot_right_length']
    sr_touch_atr_multiple = signal_params['sr_touch_atr_multiple']
    pin_bar_shadow_fraction = signal_params['pin_bar_shadow_fraction']
    pin_bar_opposite_shadow_max_fraction = signal_params['pin_bar_opposite_shadow_max_fraction']
    morning_star_small_body_max_fraction = signal_params['morning_star_small_body_max_fraction']
    star_retracement_multiplier = signal_params['star_retracement_multiplier']
    stop_to_entry_offset_atr_multiple = signal_params['stop_to_entry_offset_atr_multiple']
    tp1_risk_multiple = signal_params['tp1_risk_multiple']
    tp2_risk_multiple = signal_params['tp2_risk_multiple']
    tp3_risk_multiple = signal_params['tp3_risk_multiple']
    n = features.market.size
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    atr = np.asarray(features.atr(22), dtype=np.float64)
    sto_k, sto_d = features.stoch(stoch_raw_length, stoch_k_smoothing_length, stoch_d_smoothing_length)
    sto_k = np.asarray(sto_k, dtype=np.float64)
    sto_d = np.asarray(sto_d, dtype=np.float64)
    ema_fast = np.asarray(features.ema(ema_fast_length), dtype=np.float64)
    ema_slow = np.asarray(features.ema(ema_slow_length), dtype=np.float64)
    ema_trend = np.asarray(features.ema(ema_trend_length), dtype=np.float64)
    bull_ready, bear_ready, bull_ob_bot, bear_ob_top = _read_fvg_ob(opens, highs, lows, closes, atr, fvg_min_gap_atr_multiple, ob_max_width_atr_multiple, ob_overlap_fraction, 75.0 * 0.01)
    bull_ob = np.isfinite(bull_ob_bot) & (highs >= bull_ob_bot) & (lows <= bull_ob_bot + np.maximum(atr * ob_max_width_atr_multiple, 0.0))
    bear_ob = np.isfinite(bear_ob_top) & (highs >= bear_ob_top - np.maximum(atr * ob_max_width_atr_multiple, 0.0)) & (lows <= bear_ob_top)
    kmin = np.asarray(features.lowest(stoch_recent_window, sto_k), dtype=np.float64)
    kmax = np.asarray(features.highest(stoch_recent_window, sto_k), dtype=np.float64)
    cross_up = np.zeros(n, dtype=np.bool_)
    cross_dn = np.zeros(n, dtype=np.bool_)
    if n > 1:
        cross_up[1:] = (sto_k[1:] > sto_d[1:]) & (sto_k[:-1] <= sto_d[:-1])
        cross_dn[1:] = (sto_k[1:] < sto_d[1:]) & (sto_k[:-1] >= sto_d[:-1])
    bull_sto = cross_up & (kmin <= stoch_long_threshold)
    bear_sto = cross_dn & (kmax >= stoch_short_threshold)
    pd_eq = (np.asarray(features.highest(pd_range_lookback), dtype=np.float64) + np.asarray(features.lowest(pd_range_lookback), dtype=np.float64)) * 0.5
    pd_ok_bull = closes < pd_eq
    pd_ok_bear = closes > pd_eq
    trend_up = (closes > ema_trend) & (ema_fast > ema_slow)
    trend_dn = (closes < ema_trend) & (ema_fast < ema_slow)
    body = np.abs(closes - opens)
    full = np.maximum(highs - lows, 1e-12)
    lower_shadow = np.minimum(opens, closes) - lows
    upper_shadow = highs - np.maximum(opens, closes)
    prev_bull = closes > opens
    prev_bear = closes < opens
    engulf_bull = np.zeros(n, dtype=np.bool_)
    engulf_bear = np.zeros(n, dtype=np.bool_)
    pin_bull = np.zeros(n, dtype=np.bool_)
    pin_bear = np.zeros(n, dtype=np.bool_)
    morning = np.zeros(n, dtype=np.bool_)
    evening = np.zeros(n, dtype=np.bool_)
    if n > 1:
        engulf_bull[1:] = prev_bull[1:] & prev_bear[:-1] & (closes[1:] >= opens[:-1]) & (opens[1:] <= closes[:-1])
        engulf_bear[1:] = prev_bear[1:] & prev_bull[:-1] & (closes[1:] <= opens[:-1]) & (opens[1:] >= closes[:-1])
    pin_bull = (closes > opens) & (lower_shadow >= full * pin_bar_shadow_fraction) & (upper_shadow <= full * pin_bar_opposite_shadow_max_fraction)
    pin_bear = (closes < opens) & (upper_shadow >= full * pin_bar_shadow_fraction) & (lower_shadow <= full * pin_bar_opposite_shadow_max_fraction)
    if n > 2:
        morning[2:] = (closes[:-2] < opens[:-2]) & (body[1:-1] <= full[1:-1] * morning_star_small_body_max_fraction) & (closes[2:] > opens[2:]) & (closes[2:] >= opens[:-2] + (closes[:-2] - opens[:-2]) * -star_retracement_multiplier)
        evening[2:] = (closes[:-2] > opens[:-2]) & (body[1:-1] <= full[1:-1] * morning_star_small_body_max_fraction) & (closes[2:] < opens[2:]) & (closes[2:] <= opens[:-2] - (opens[:-2] - closes[:-2]) * -star_retracement_multiplier)
    bull_pattern = engulf_bull | pin_bull | morning
    bear_pattern = engulf_bear | pin_bear | evening
    bull_sr = np.asarray(features.pivot_low(sr_pivot_left_length, sr_pivot_right_length), dtype=np.float64)
    bear_sr = np.asarray(features.pivot_high(sr_pivot_left_length, sr_pivot_right_length), dtype=np.float64)
    sr_touch_bull = np.isfinite(bull_sr) & (np.abs(np.minimum(opens, closes) - bull_sr) <= atr * sr_touch_atr_multiple) & (lows <= bull_sr + atr * sr_touch_atr_multiple) & (highs >= bull_sr - atr * sr_touch_atr_multiple)
    sr_touch_bear = np.isfinite(bear_sr) & (np.abs(np.maximum(opens, closes) - bear_sr) <= atr * sr_touch_atr_multiple) & (highs >= bear_sr - atr * sr_touch_atr_multiple) & (lows <= bear_sr + atr * sr_touch_atr_multiple)
    long_d = bull_sto & bull_ready & bull_ob & pd_ok_bull
    short_d = bear_sto & bear_ready & bear_ob & pd_ok_bear
    long_c = long_d & trend_up
    short_c = short_d & trend_dn
    long_b = long_c & sr_touch_bull
    short_b = short_c & sr_touch_bear
    long_a = long_b & bull_pattern
    short_a = short_b & bear_pattern
    long_grade = np.where(long_a, 4, np.where(long_b, 3, np.where(long_c, 2, np.where(long_d, 1, 0))))
    short_grade = np.where(short_a, 4, np.where(short_b, 3, np.where(short_c, 2, np.where(short_d, 1, 0))))
    long_entries = (long_grade > 0) & (long_grade > short_grade)
    short_entries = (short_grade > 0) & (short_grade > long_grade)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    risk_long = closes - bull_ob_bot
    risk_short = bear_ob_top - closes
    valid_long = long_entries & np.isfinite(risk_long) & (risk_long > 0.0)
    valid_short = short_entries & np.isfinite(risk_short) & (risk_short > 0.0)
    stop_distances[valid_long] = risk_long[valid_long]
    target_distances[valid_long] = risk_long[valid_long] * tp3_risk_multiple
    stop_distances[valid_short] = risk_short[valid_short]
    target_distances[valid_short] = risk_short[valid_short] * tp3_risk_multiple
    long_entries &= valid_long
    short_entries &= valid_short
    return (long_entries.astype(np.bool_), long_exits, short_entries.astype(np.bool_), short_exits, stop_distances.astype(np.float64), target_distances.astype(np.float64))

STRATEGY = {**{'strategy_id': 'graded_order_block_stochastic_0__native__follow', 'hypothesis': '策略以隨機指標交叉及近期超買超賣條件觸發，結合 FVG、訂單區與可選趨勢、區間及價格型態篩選進場，並以訂單區設定止損、按風險距離分批止盈。', 'position': 'both', 'signal_parameter_names': ['stoch_raw_length', 'stoch_k_smoothing_length', 'stoch_d_smoothing_length', 'stoch_recent_window', 'stoch_long_threshold', 'stoch_short_threshold', 'fvg_pattern_bars', 'fvg_min_gap_atr_multiple', 'fvg_ready_min_bars_since_touch', 'fvg_ready_max_bars_since_touch', 'ob_pattern_bars', 'ob_max_width_atr_multiple', 'ob_overlap_fraction', 'ob_min_width_atr_multiple', 'pd_range_lookback', 'ema_fast_length', 'ema_slow_length', 'ema_trend_length', 'structure_pivot_length', 'structure_break_atr_multiple', 'structure_body_atr_multiple', 'sar_start', 'sar_increment', 'sar_maximum', 'lrc_length', 'sr_pivot_left_length', 'sr_pivot_right_length', 'sr_touch_atr_multiple', 'pin_bar_shadow_fraction', 'pin_bar_opposite_shadow_max_fraction', 'morning_star_small_body_max_fraction', 'star_retracement_multiplier', 'stop_to_entry_offset_atr_multiple', 'tp1_risk_multiple', 'tp2_risk_multiple', 'tp3_risk_multiple'], 'signal_parameter_specs': [{'name': 'stoch_raw_length', 'family': 'lookback', 'anchor': 9}, {'name': 'stoch_k_smoothing_length', 'family': 'lookback', 'anchor': 3}, {'name': 'stoch_d_smoothing_length', 'family': 'lookback', 'anchor': 3}, {'name': 'stoch_recent_window', 'family': 'lookback', 'anchor': 5}, {'name': 'stoch_long_threshold', 'family': 'threshold_0_100', 'anchor': 20.0}, {'name': 'stoch_short_threshold', 'family': 'threshold_0_100', 'anchor': 80.0}, {'name': 'fvg_pattern_bars', 'family': 'count', 'anchor': 3}, {'name': 'fvg_min_gap_atr_multiple', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'fvg_ready_min_bars_since_touch', 'family': 'count', 'anchor': 1}, {'name': 'fvg_ready_max_bars_since_touch', 'family': 'count', 'anchor': 3}, {'name': 'ob_pattern_bars', 'family': 'count', 'anchor': 3}, {'name': 'ob_max_width_atr_multiple', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'ob_overlap_fraction', 'family': 'fraction', 'anchor': 0.5}, {'name': 'ob_min_width_atr_multiple', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'pd_range_lookback', 'family': 'lookback', 'anchor': 100}, {'name': 'ema_fast_length', 'family': 'lookback', 'anchor': 50}, {'name': 'ema_slow_length', 'family': 'lookback', 'anchor': 100}, {'name': 'ema_trend_length', 'family': 'lookback', 'anchor': 200}, {'name': 'structure_pivot_length', 'family': 'lookback', 'anchor': 5}, {'name': 'structure_break_atr_multiple', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'structure_body_atr_multiple', 'family': 'multiplier', 'anchor': 0.15}, {'name': 'sar_start', 'family': 'multiplier', 'anchor': 0.02}, {'name': 'sar_increment', 'family': 'multiplier', 'anchor': 0.02}, {'name': 'sar_maximum', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'lrc_length', 'family': 'lookback', 'anchor': 100}, {'name': 'sr_pivot_left_length', 'family': 'lookback', 'anchor': 7}, {'name': 'sr_pivot_right_length', 'family': 'lookback', 'anchor': 7}, {'name': 'sr_touch_atr_multiple', 'family': 'multiplier', 'anchor': 0.15}, {'name': 'pin_bar_shadow_fraction', 'family': 'fraction', 'anchor': 0.55}, {'name': 'pin_bar_opposite_shadow_max_fraction', 'family': 'fraction', 'anchor': 0.2}, {'name': 'morning_star_small_body_max_fraction', 'family': 'fraction', 'anchor': 0.25}, {'name': 'star_retracement_multiplier', 'family': 'multiplier', 'anchor': 0.6}, {'name': 'stop_to_entry_offset_atr_multiple', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'tp1_risk_multiple', 'family': 'multiplier', 'anchor': 1.0}, {'name': 'tp2_risk_multiple', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'tp3_risk_multiple', 'family': 'multiplier', 'anchor': 3.0}], 'signal_parameter_relations': [['stoch_k_smoothing_length', 'lt', 'stoch_raw_length'], ['ema_fast_length', 'lt', 'ema_slow_length'], ['fvg_ready_min_bars_since_touch', 'lte', 'fvg_ready_max_bars_since_touch'], ['tp1_risk_multiple', 'lt', 'tp2_risk_multiple'], ['tp2_risk_multiple', 'lt', 'tp3_risk_multiple']], 'signal_parameter_candidates': {'stoch_raw_length': [9, 4, 18], 'stoch_k_smoothing_length': [3, 2, 6], 'stoch_d_smoothing_length': [3, 2, 6], 'stoch_recent_window': [5, 2, 10], 'stoch_long_threshold': [20.0, 10.0, 30.0], 'stoch_short_threshold': [80.0, 70.0, 90.0], 'fvg_pattern_bars': [3, 2, 6], 'fvg_min_gap_atr_multiple': [0.2, 0.13999999999999999, 0.27999999999999997], 'fvg_ready_min_bars_since_touch': [1, 2], 'fvg_ready_max_bars_since_touch': [3, 2, 6], 'ob_pattern_bars': [3, 2, 6], 'ob_max_width_atr_multiple': [2.0, 1.4, 2.8], 'ob_overlap_fraction': [0.5, 0.25, 1.0], 'ob_min_width_atr_multiple': [2.0, 1.0, 1.5, 3.0], 'pd_range_lookback': [100, 50, 200], 'ema_fast_length': [50, 25, 100], 'ema_slow_length': [100, 50, 200], 'ema_trend_length': [200, 100, 400], 'structure_pivot_length': [5, 2, 10], 'structure_break_atr_multiple': [0.1, 0.06999999999999999, 0.13999999999999999], 'structure_body_atr_multiple': [0.15, 0.105, 0.21], 'sar_start': [0.02, 0.013999999999999999, 0.027999999999999997], 'sar_increment': [0.02, 0.013999999999999999, 0.027999999999999997], 'sar_maximum': [0.2, 0.13999999999999999, 0.27999999999999997], 'lrc_length': [100, 50, 200], 'sr_pivot_left_length': [7, 4, 14], 'sr_pivot_right_length': [7, 4, 14], 'sr_touch_atr_multiple': [0.15, 0.105, 0.21], 'pin_bar_shadow_fraction': [0.55, 0.275, 1.1], 'pin_bar_opposite_shadow_max_fraction': [0.2, 0.1, 0.4], 'morning_star_small_body_max_fraction': [0.25, 0.125, 0.5], 'star_retracement_multiplier': [0.6, 0.42, 0.84], 'stop_to_entry_offset_atr_multiple': [2.0, 1.0, 1.5, 3.0], 'tp1_risk_multiple': [2.0, 1.0, 1.5, 3.0], 'tp2_risk_multiple': [2.0, 1.0, 1.5, 3.0], 'tp3_risk_multiple': [2.0, 1.0, 1.5, 3.0]}}, 'generate_signals': generate_signals}
