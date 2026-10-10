import numpy as np
from numba import njit

import numpy as np
from numba import njit

@njit
def _update_structure_signals(opens, highs, lows, closes, zone_atr, pivot_lows, pivot_highs, lowest_lows, highest_highs, bull_reaction, bear_reaction, sr_strength, padding, instant_max_bars, cooldown_bars):
    n = closes.size
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    chart_sup_top = np.nan
    chart_sup_bottom = np.nan
    chart_sup_id = np.nan
    chart_res_top = np.nan
    chart_res_bottom = np.nan
    chart_res_id = np.nan
    last_long_entry_bar = np.nan
    last_short_entry_bar = np.nan
    forming_swing_top = np.nan
    forming_swing_bottom = np.nan
    forming_swing_id = np.nan
    forming_swing_bar = np.nan
    active_origin_top = np.nan
    active_origin_bottom = np.nan
    active_origin_id = np.nan
    forming_swing_direction = 0
    active_origin_direction = 0
    forming_swing_signal_taken = False
    active_origin_validated = False
    recent_origin_low = np.nan
    recent_origin_low_body = np.nan
    recent_origin_low_atr = np.nan
    recent_origin_low_bar = np.nan
    recent_origin_high = np.nan
    recent_origin_high_body = np.nan
    recent_origin_high_atr = np.nan
    recent_origin_high_bar = np.nan
    for i in range(n):
        previous_chart_sup_id = chart_sup_id
        previous_chart_res_id = chart_res_id
        if not np.isnan(pivot_lows[i]):
            pivot_i = i - sr_strength
            chart_sup_bottom = lows[pivot_i]
            chart_sup_top = max(min(opens[pivot_i], closes[pivot_i]), chart_sup_bottom + zone_atr[pivot_i] * padding)
            chart_sup_id = float(pivot_i)
        elif not np.isnan(chart_sup_top) and closes[i] < chart_sup_bottom:
            chart_sup_top = np.nan
            chart_sup_bottom = np.nan
            chart_sup_id = np.nan
        if not np.isnan(pivot_highs[i]):
            pivot_i = i - sr_strength
            chart_res_top = highs[pivot_i]
            chart_res_bottom = min(max(opens[pivot_i], closes[pivot_i]), chart_res_top - zone_atr[pivot_i] * padding)
            chart_res_id = float(pivot_i)
        elif not np.isnan(chart_res_top) and closes[i] > chart_res_top:
            chart_res_top = np.nan
            chart_res_bottom = np.nan
            chart_res_id = np.nan
        new_chart_support_now = not np.isnan(chart_sup_id) and (np.isnan(previous_chart_sup_id) or chart_sup_id != previous_chart_sup_id)
        new_chart_resistance_now = not np.isnan(chart_res_id) and (np.isnan(previous_chart_res_id) or chart_res_id != previous_chart_res_id)
        confirmed_chart_tf_bias = 0
        if not np.isnan(chart_sup_id) and (np.isnan(chart_res_id) or chart_sup_id > chart_res_id):
            confirmed_chart_tf_bias = 1
        elif not np.isnan(chart_res_id) and (np.isnan(chart_sup_id) or chart_res_id > chart_sup_id):
            confirmed_chart_tf_bias = -1
        long_fallback = new_chart_support_now and confirmed_chart_tf_bias == 1 and (not (active_origin_direction == 1 and (not np.isnan(active_origin_id)) and (active_origin_id == chart_sup_id))) and (not np.isnan(chart_sup_top)) and (not np.isnan(chart_sup_bottom)) and (closes[i] > chart_sup_top) and (np.isnan(last_long_entry_bar) or i - last_long_entry_bar >= cooldown_bars)
        short_fallback = new_chart_resistance_now and confirmed_chart_tf_bias == -1 and (not (active_origin_direction == -1 and (not np.isnan(active_origin_id)) and (active_origin_id == chart_res_id))) and (not np.isnan(chart_res_top)) and (not np.isnan(chart_res_bottom)) and (closes[i] < chart_res_bottom) and (np.isnan(last_short_entry_bar) or i - last_short_entry_bar >= cooldown_bars)
        if long_fallback:
            long_entries[i] = True
            active_origin_direction = 1
            active_origin_top = chart_sup_top
            active_origin_bottom = chart_sup_bottom
            active_origin_id = chart_sup_id
            active_origin_validated = True
            last_long_entry_bar = float(i)
        if short_fallback:
            short_entries[i] = True
            active_origin_direction = -1
            active_origin_top = chart_res_top
            active_origin_bottom = chart_res_bottom
            active_origin_id = chart_res_id
            active_origin_validated = True
            last_short_entry_bar = float(i)
        fresh_origin_low_event = lows[i] <= lowest_lows[i]
        fresh_origin_high_event = highs[i] >= highest_highs[i]
        if fresh_origin_low_event:
            recent_origin_low = lows[i]
            recent_origin_low_body = min(opens[i], closes[i])
            recent_origin_low_atr = zone_atr[i]
            recent_origin_low_bar = float(i)
        if fresh_origin_high_event:
            recent_origin_high = highs[i]
            recent_origin_high_body = max(opens[i], closes[i])
            recent_origin_high_atr = zone_atr[i]
            recent_origin_high_bar = float(i)
        recent_support_top = np.nan
        recent_support_bottom = recent_origin_low
        if not np.isnan(recent_origin_low) and (not np.isnan(recent_origin_low_body)) and (not np.isnan(recent_origin_low_atr)):
            recent_support_top = max(recent_origin_low_body, recent_origin_low + recent_origin_low_atr * padding)
        recent_resistance_top = recent_origin_high
        recent_resistance_bottom = np.nan
        if not np.isnan(recent_origin_high) and (not np.isnan(recent_origin_high_body)) and (not np.isnan(recent_origin_high_atr)):
            recent_resistance_bottom = min(recent_origin_high_body, recent_origin_high - recent_origin_high_atr * padding)
        eligible_recent_low = not np.isnan(recent_origin_low_bar) and i - recent_origin_low_bar <= sr_strength and (not np.isnan(recent_support_top)) and (not np.isnan(recent_support_bottom))
        eligible_recent_high = not np.isnan(recent_origin_high_bar) and i - recent_origin_high_bar <= sr_strength and (not np.isnan(recent_resistance_top)) and (not np.isnan(recent_resistance_bottom))
        new_forming_low_origin = eligible_recent_low and (forming_swing_direction != 1 or forming_swing_id != recent_origin_low_bar)
        new_forming_high_origin = eligible_recent_high and (forming_swing_direction != -1 or forming_swing_id != recent_origin_high_bar)
        two_sided_new_origin = new_forming_low_origin and new_forming_high_origin
        if new_forming_low_origin and (not two_sided_new_origin) and (not forming_swing_signal_taken):
            forming_swing_direction = 1
            forming_swing_bottom = recent_support_bottom
            forming_swing_top = recent_support_top
            forming_swing_id = recent_origin_low_bar
            forming_swing_bar = recent_origin_low_bar
        if new_forming_high_origin and (not two_sided_new_origin) and (not forming_swing_signal_taken):
            forming_swing_direction = -1
            forming_swing_top = recent_resistance_top
            forming_swing_bottom = recent_resistance_bottom
            forming_swing_id = recent_origin_high_bar
            forming_swing_bar = recent_origin_high_bar
        if forming_swing_direction != 0 and (not forming_swing_signal_taken) and (not np.isnan(forming_swing_bar)) and (i - forming_swing_bar > sr_strength + 1):
            forming_swing_direction = 0
            forming_swing_top = np.nan
            forming_swing_bottom = np.nan
            forming_swing_id = np.nan
            forming_swing_bar = np.nan
            forming_swing_signal_taken = False
        live_chart_tf_bias = forming_swing_direction if forming_swing_direction != 0 else confirmed_chart_tf_bias
        long_instant = forming_swing_direction == 1 and live_chart_tf_bias == 1 and (not np.isnan(forming_swing_bar)) and (i - forming_swing_bar <= instant_max_bars) and (not forming_swing_signal_taken) and bull_reaction[i] and (not np.isnan(forming_swing_top)) and (closes[i] > forming_swing_top) and (np.isnan(last_long_entry_bar) or i - last_long_entry_bar >= cooldown_bars)
        short_instant = forming_swing_direction == -1 and live_chart_tf_bias == -1 and (not np.isnan(forming_swing_bar)) and (i - forming_swing_bar <= instant_max_bars) and (not forming_swing_signal_taken) and bear_reaction[i] and (not np.isnan(forming_swing_bottom)) and (closes[i] < forming_swing_bottom) and (np.isnan(last_short_entry_bar) or i - last_short_entry_bar >= cooldown_bars)
        if long_instant:
            long_entries[i] = True
            forming_swing_signal_taken = True
            active_origin_direction = 1
            active_origin_top = forming_swing_top
            active_origin_bottom = forming_swing_bottom
            active_origin_id = forming_swing_id
            active_origin_validated = False
            last_long_entry_bar = float(i)
        if short_instant:
            short_entries[i] = True
            forming_swing_signal_taken = True
            active_origin_direction = -1
            active_origin_top = forming_swing_top
            active_origin_bottom = forming_swing_bottom
            active_origin_id = forming_swing_id
            active_origin_validated = False
            last_short_entry_bar = float(i)
        forming_low_confirmed_now = forming_swing_direction == 1 and (not np.isnan(chart_sup_id)) and (chart_sup_id == forming_swing_id)
        forming_high_confirmed_now = forming_swing_direction == -1 and (not np.isnan(chart_res_id)) and (chart_res_id == forming_swing_id)
        if forming_low_confirmed_now and active_origin_direction == 1 and (not active_origin_validated) and (active_origin_id == forming_swing_id):
            active_origin_top = chart_sup_top
            active_origin_bottom = chart_sup_bottom
            active_origin_validated = True
        if forming_high_confirmed_now and active_origin_direction == -1 and (not active_origin_validated) and (active_origin_id == forming_swing_id):
            active_origin_top = chart_res_top
            active_origin_bottom = chart_res_bottom
            active_origin_validated = True
        if forming_low_confirmed_now or forming_high_confirmed_now:
            forming_swing_direction = 0
            forming_swing_top = np.nan
            forming_swing_bottom = np.nan
            forming_swing_id = np.nan
            forming_swing_bar = np.nan
            forming_swing_signal_taken = False
        if forming_swing_signal_taken and (not active_origin_validated) and (not np.isnan(forming_swing_bar)) and (i - forming_swing_bar > sr_strength + 2):
            if active_origin_id == forming_swing_id:
                active_origin_direction = 0
                active_origin_top = np.nan
                active_origin_bottom = np.nan
                active_origin_id = np.nan
                active_origin_validated = False
            forming_swing_direction = 0
            forming_swing_top = np.nan
            forming_swing_bottom = np.nan
            forming_swing_id = np.nan
            forming_swing_bar = np.nan
            forming_swing_signal_taken = False
        if active_origin_direction == 1 and (not active_origin_validated) and (not np.isnan(chart_sup_id)) and (chart_sup_id == active_origin_id):
            active_origin_top = chart_sup_top
            active_origin_bottom = chart_sup_bottom
            active_origin_validated = True
        if active_origin_direction == -1 and (not active_origin_validated) and (not np.isnan(chart_res_id)) and (chart_res_id == active_origin_id):
            active_origin_top = chart_res_top
            active_origin_bottom = chart_res_bottom
            active_origin_validated = True
        long_invalidated = active_origin_direction == 1 and (not np.isnan(active_origin_bottom)) and (closes[i] < active_origin_bottom)
        short_invalidated = active_origin_direction == -1 and (not np.isnan(active_origin_top)) and (closes[i] > active_origin_top)
        if long_invalidated:
            long_exits[i] = True
            forming_swing_direction = 0
            forming_swing_top = np.nan
            forming_swing_bottom = np.nan
            forming_swing_id = np.nan
            forming_swing_bar = np.nan
            forming_swing_signal_taken = False
            active_origin_direction = 0
            active_origin_top = np.nan
            active_origin_bottom = np.nan
            active_origin_id = np.nan
            active_origin_validated = False
        elif short_invalidated:
            short_exits[i] = True
            forming_swing_direction = 0
            forming_swing_top = np.nan
            forming_swing_bottom = np.nan
            forming_swing_id = np.nan
            forming_swing_bar = np.nan
            forming_swing_signal_taken = False
            active_origin_direction = 0
            active_origin_top = np.nan
            active_origin_bottom = np.nan
            active_origin_id = np.nan
            active_origin_validated = False
    return (long_entries, long_exits, short_entries, short_exits)

def generate_signals(features, signal_params):
    sr_strength = int(signal_params['srPivotStrength'])
    padding = float(signal_params['srMinimumPaddingATR'])
    micro_length = int(signal_params['microLength'])
    rejection_wick_body = float(signal_params['rejectionWickBody'])
    strong_close_location = float(signal_params['strongCloseLocation'])
    displacement_atr = float(signal_params['displacementATR'])
    displacement_body_pct = float(signal_params['displacementBodyPct'])
    instant_max_bars = int(signal_params['instantSwingMaxBars'])
    cooldown_bars = int(signal_params['entryCooldownBars'])
    n = features.market.size
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    zone_atr = np.asarray(features.atr(14), dtype=np.float64)
    atr = np.asarray(features.atr(14), dtype=np.float64)
    pivot_lows = np.asarray(features.pivot_low(sr_strength, sr_strength), dtype=np.float64)
    pivot_highs = np.asarray(features.pivot_high(sr_strength, sr_strength), dtype=np.float64)
    lowest_lows = np.asarray(features.lowest(sr_strength + 1, 'lows'), dtype=np.float64)
    highest_highs = np.asarray(features.highest(sr_strength + 1, 'highs'), dtype=np.float64)
    previous_highs = np.full(n, np.nan, dtype=np.float64)
    previous_lows = np.full(n, np.nan, dtype=np.float64)
    if n > 1:
        previous_highs[1:] = highs[:-1]
        previous_lows[1:] = lows[:-1]
    micro_high = np.asarray(features.highest(micro_length, previous_highs), dtype=np.float64)
    micro_low = np.asarray(features.lowest(micro_length, previous_lows), dtype=np.float64)
    candle_range = np.maximum(highs - lows, np.finfo(np.float64).tiny)
    body_size = np.abs(closes - opens)
    body_pct = body_size / candle_range
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    close_location = (closes - lows) / candle_range
    bull_reject = (closes > opens) & (lower_wick >= body_size * rejection_wick_body) & (close_location >= strong_close_location)
    bear_reject = (closes < opens) & (upper_wick >= body_size * rejection_wick_body) & (close_location <= 1.0 - strong_close_location)
    bull_displacement = (closes > opens) & (candle_range >= atr * displacement_atr) & (body_pct >= displacement_body_pct)
    bear_displacement = (closes < opens) & (candle_range >= atr * displacement_atr) & (body_pct >= displacement_body_pct)
    bull_micro_shift = closes > micro_high
    bear_micro_shift = closes < micro_low
    bull_reaction = np.asarray(bull_reject | bull_displacement | bull_micro_shift, dtype=np.bool_)
    bear_reaction = np.asarray(bear_reject | bear_displacement | bear_micro_shift, dtype=np.bool_)
    long_entries, long_exits, short_entries, short_exits = _update_structure_signals(opens, highs, lows, closes, zone_atr, pivot_lows, pivot_highs, lowest_lows, highest_highs, bull_reaction, bear_reaction, sr_strength, padding, instant_max_bars, cooldown_bars)
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

STRATEGY = {**{'strategy_id': 'support_resistance_swing_reaction_0__native', 'hypothesis': '沿結構方向在已確認或形成中的支撐阻力位出現突破與價格反應時進場，並在進場結構失效時出場。', 'position': 'both', 'signal_parameter_names': ['srPivotStrength', 'srMinimumPaddingATR', 'microLength', 'rejectionWickBody', 'strongCloseLocation', 'displacementATR', 'displacementBodyPct', 'instantSwingMaxBars', 'entryCooldownBars'], 'signal_parameter_specs': [{'name': 'srPivotStrength', 'family': 'lookback', 'anchor': 3}, {'name': 'srMinimumPaddingATR', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'microLength', 'family': 'lookback', 'anchor': 2}, {'name': 'rejectionWickBody', 'family': 'multiplier', 'anchor': 1.2}, {'name': 'strongCloseLocation', 'family': 'fraction', 'anchor': 0.65}, {'name': 'displacementATR', 'family': 'multiplier', 'anchor': 0.8}, {'name': 'displacementBodyPct', 'family': 'fraction', 'anchor': 0.6}, {'name': 'instantSwingMaxBars', 'family': 'count', 'anchor': 1}, {'name': 'entryCooldownBars', 'family': 'count', 'anchor': 5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'srPivotStrength': [3, 2, 6], 'srMinimumPaddingATR': [0.1, 0.06999999999999999, 0.13999999999999999], 'microLength': [2, 1, 4], 'rejectionWickBody': [1.2, 0.84, 1.68], 'strongCloseLocation': [0.65, 0.325, 1.3], 'displacementATR': [0.8, 0.5599999999999999, 1.1199999999999999], 'displacementBodyPct': [0.6, 0.3, 1.2], 'instantSwingMaxBars': [1, 2], 'entryCooldownBars': [5, 2, 10]}}, 'generate_signals': generate_signals}
