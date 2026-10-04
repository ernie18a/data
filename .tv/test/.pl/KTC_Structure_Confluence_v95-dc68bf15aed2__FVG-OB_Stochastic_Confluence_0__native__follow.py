import numpy as np
from numba import njit

import numpy as np
from numba import njit

@njit
def _build_entries(opens, highs, lows, closes, atr22, k, d, fvg_arm_bars, min_ob_height_pts, sto_os_level, sto_ob_level, sto_zone_bars, fvg_atr_mult, ob_vol_mult, pd_long, pd_short):
    n = closes.size
    long_entries = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    ob_low = np.full(n, np.nan, dtype=np.float64)
    ob_high = np.full(n, np.nan, dtype=np.float64)
    bull_arm = -1
    bear_arm = -1
    bull_fvg_low = np.nan
    bull_fvg_high = np.nan
    bear_fvg_low = np.nan
    bear_fvg_high = np.nan
    active_bull_ob_low = np.nan
    active_bull_ob_high = np.nan
    active_bear_ob_low = np.nan
    active_bear_ob_high = np.nan
    for t in range(n):
        if t >= 2:
            if lows[t - 2] > highs[t - 2]:
                pass
            if lows[t] > highs[t - 2] and lows[t] - highs[t - 2] >= atr22[t] * fvg_atr_mult:
                bull_fvg_low = highs[t - 2]
                bull_fvg_high = lows[t]
            if highs[t] < lows[t - 2] and lows[t - 2] - highs[t] >= atr22[t] * fvg_atr_mult:
                bear_fvg_low = highs[t]
                bear_fvg_high = lows[t - 2]
            if closes[t - 2] < opens[t - 2] and closes[t - 1] > opens[t - 1] and (lows[t] > highs[t - 2]) and (highs[t - 2] - lows[t - 2] < atr22[t] * ob_vol_mult):
                active_bull_ob_low = lows[t - 2]
                active_bull_ob_high = highs[t - 2]
            if closes[t - 2] > opens[t - 2] and closes[t - 1] < opens[t - 1] and (highs[t] < lows[t - 2]) and (highs[t - 2] - lows[t - 2] < atr22[t] * ob_vol_mult):
                active_bear_ob_low = lows[t - 2]
                active_bear_ob_high = highs[t - 2]
        if not np.isnan(bull_fvg_low) and lows[t] <= bull_fvg_high and (highs[t] >= bull_fvg_low):
            bull_arm = t
        if not np.isnan(bear_fvg_low) and highs[t] >= bear_fvg_low and (lows[t] <= bear_fvg_high):
            bear_arm = t
        bull_age = t - bull_arm if bull_arm >= 0 else -1
        bear_age = t - bear_arm if bear_arm >= 0 else -1
        bull_touch = not np.isnan(active_bull_ob_low) and lows[t] <= active_bull_ob_high and (highs[t] >= active_bull_ob_low)
        bear_touch = not np.isnan(active_bear_ob_low) and highs[t] >= active_bear_ob_low and (lows[t] <= active_bear_ob_high)
        bull_cross = t > 0 and k[t] > d[t] and (k[t - 1] <= d[t - 1])
        bear_cross = t > 0 and k[t] < d[t] and (k[t - 1] >= d[t - 1])
        lowest_k = np.inf
        highest_k = -np.inf
        start = max(0, t - sto_zone_bars + 1)
        for j in range(start, t + 1):
            if k[j] < lowest_k:
                lowest_k = k[j]
            if k[j] > highest_k:
                highest_k = k[j]
        bull_height_ok = bull_touch and active_bull_ob_high - active_bull_ob_low >= min_ob_height_pts * 0.01
        bear_height_ok = bear_touch and active_bear_ob_high - active_bear_ob_low >= min_ob_height_pts * 0.01
        long_ok = 1 <= bull_age <= fvg_arm_bars and bull_height_ok and bull_cross and (lowest_k <= sto_os_level) and pd_long[t]
        short_ok = 1 <= bear_age <= fvg_arm_bars and bear_height_ok and bear_cross and (highest_k >= sto_ob_level) and pd_short[t]
        if long_ok and (not short_ok):
            long_entries[t] = True
            ob_low[t] = active_bull_ob_low
            ob_high[t] = active_bull_ob_high
        elif short_ok and (not long_ok):
            short_entries[t] = True
            ob_low[t] = active_bear_ob_low
            ob_high[t] = active_bear_ob_high
    return (long_entries, short_entries, ob_low, ob_high)

@njit
def _manage_exits(long_entries, short_entries, closes, highs, lows, atr22, ob_low, ob_high, tp1_mult, tp2_mult, tp3_mult, be_offset):
    n = closes.size
    long_exits = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    side = 0
    entry = 0.0
    risk = 0.0
    tp1 = 0.0
    tp3 = 0.0
    moved_stop = 0.0
    be_active = False
    for t in range(n):
        if side == 0:
            if long_entries[t]:
                side = 1
                entry = closes[t]
                risk = entry - ob_low[t]
                if risk > 0.0:
                    stop_distances[t] = risk
                    target_distances[t] = risk * tp3_mult
                    tp1 = entry + risk * tp1_mult
                    tp3 = entry + risk * tp3_mult
                    moved_stop = entry + atr22[t] * be_offset
                    be_active = False
                else:
                    side = 0
            elif short_entries[t]:
                side = -1
                entry = closes[t]
                risk = ob_high[t] - entry
                if risk > 0.0:
                    stop_distances[t] = risk
                    target_distances[t] = risk * tp3_mult
                    tp1 = entry - risk * tp1_mult
                    tp3 = entry - risk * tp3_mult
                    moved_stop = entry - atr22[t] * be_offset
                    be_active = False
                else:
                    side = 0
        elif side == 1:
            if not be_active and highs[t] >= tp1:
                be_active = True
            if be_active and lows[t] <= moved_stop:
                long_exits[t] = True
                side = 0
            elif highs[t] >= tp3 or lows[t] <= entry - risk:
                side = 0
        else:
            if not be_active and lows[t] <= tp1:
                be_active = True
            if be_active and highs[t] >= moved_stop:
                short_exits[t] = True
                side = 0
            elif lows[t] <= tp3 or highs[t] >= entry + risk:
                side = 0
    return (long_exits, short_exits, stop_distances, target_distances)

def generate_signals(features, signal_params):
    fvg_arm_bars = signal_params['fvgArmBars']
    min_ob_height_pts = signal_params['minOBHeightPts']
    sto_k_len = signal_params['stoKLen']
    sto_smooth_k = signal_params['stoSmoothK']
    sto_d_len = signal_params['stoDLen']
    sto_os_level = signal_params['stoOSLevel']
    sto_ob_level = signal_params['stoOBLevel']
    sto_zone_bars = signal_params['stoZoneBars']
    fvg_atr_mult = signal_params['fvgAtrMult']
    ob_vol_mult = signal_params['obVolMult']
    pd_len = signal_params['pdLen']
    tp1_risk_mult = signal_params['tp1RiskMult']
    tp2_risk_mult = signal_params['tp2RiskMult']
    tp3_risk_mult = signal_params['tp3RiskMult']
    be_offset = signal_params['beOffset']
    n = features.market.size
    closes = features.market.closes
    highs = features.market.highs
    lows = features.market.lows
    opens = features.market.opens
    atr22 = features.atr(22)
    raw_k = features.stoch(sto_k_len, 1, 1)[0]
    k = features.sma(sto_smooth_k, raw_k)
    d = features.sma(sto_d_len, k)
    highest_prev = np.concatenate(([np.nan], features.highest(pd_len)[:-1]))
    lowest_prev = np.concatenate(([np.nan], features.lowest(pd_len)[:-1]))
    midpoint = (highest_prev + lowest_prev) / 2.0
    pd_long = closes < midpoint
    pd_short = closes > midpoint
    long_entries, short_entries, ob_low, ob_high = _build_entries(opens, highs, lows, closes, atr22, k, d, fvg_arm_bars, min_ob_height_pts, sto_os_level, sto_ob_level, sto_zone_bars, fvg_atr_mult, ob_vol_mult, pd_long, pd_short)
    long_exits, short_exits, stop_distances, target_distances = _manage_exits(long_entries, short_entries, closes, highs, lows, atr22, ob_low, ob_high, tp1_risk_mult, tp2_risk_mult, tp3_risk_mult, be_offset)
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

STRATEGY = {**{'strategy_id': 'FVG-OB_Stochastic_Confluence_0__native__follow', 'hypothesis': '啟用回退進場後，當近期多空 FVG 已觸及且價格回測有效 OB 時，以 OB 高度門檻和 Stochastic 交叉及超買超賣區條件確認方向，並以 OB 風險設定分段停利與移動停損。', 'position': 'both', 'signal_parameter_names': ['fvgArmBars', 'minOBHeightPts', 'stoKLen', 'stoSmoothK', 'stoDLen', 'stoOSLevel', 'stoOBLevel', 'stoZoneBars', 'fvgAtrMult', 'obVolMult', 'pdLen', 'tp1RiskMult', 'tp2RiskMult', 'tp3RiskMult', 'beOffset'], 'signal_parameter_specs': [{'name': 'fvgArmBars', 'family': 'lookback', 'anchor': 3}, {'name': 'minOBHeightPts', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'stoKLen', 'family': 'lookback', 'anchor': 9}, {'name': 'stoSmoothK', 'family': 'lookback', 'anchor': 3}, {'name': 'stoDLen', 'family': 'lookback', 'anchor': 3}, {'name': 'stoOSLevel', 'family': 'threshold_0_100', 'anchor': 20.0}, {'name': 'stoOBLevel', 'family': 'threshold_0_100', 'anchor': 80.0}, {'name': 'stoZoneBars', 'family': 'lookback', 'anchor': 5}, {'name': 'fvgAtrMult', 'family': 'multiplier', 'anchor': 0.2}, {'name': 'obVolMult', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'pdLen', 'family': 'lookback', 'anchor': 100}, {'name': 'tp1RiskMult', 'family': 'multiplier', 'anchor': 1.0}, {'name': 'tp2RiskMult', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'tp3RiskMult', 'family': 'multiplier', 'anchor': 3.0}, {'name': 'beOffset', 'family': 'multiplier', 'anchor': 2.0}], 'signal_parameter_relations': [['tp1RiskMult', 'lt', 'tp2RiskMult'], ['tp2RiskMult', 'lt', 'tp3RiskMult']], 'signal_parameter_candidates': {'fvgArmBars': [3, 2, 6], 'minOBHeightPts': [2.0, 1.0, 1.5, 3.0], 'stoKLen': [9, 4, 18], 'stoSmoothK': [3, 2, 6], 'stoDLen': [3, 2, 6], 'stoOSLevel': [20.0, 10.0, 30.0], 'stoOBLevel': [80.0, 70.0, 90.0], 'stoZoneBars': [5, 2, 10], 'fvgAtrMult': [0.2, 0.13999999999999999, 0.27999999999999997], 'obVolMult': [2.0, 1.4, 2.8], 'pdLen': [100, 50, 200], 'tp1RiskMult': [2.0, 1.0, 1.5, 3.0], 'tp2RiskMult': [2.0, 1.0, 1.5, 3.0], 'tp3RiskMult': [2.0, 1.0, 1.5, 3.0], 'beOffset': [2.0, 1.0, 1.5, 3.0]}}, 'generate_signals': generate_signals}
