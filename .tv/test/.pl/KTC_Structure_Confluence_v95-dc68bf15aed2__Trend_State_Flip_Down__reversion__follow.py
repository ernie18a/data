import numpy as np

def generate_entries(features, signal_params):
    pivot_left_bars = signal_params['pivot_left_bars']
    pivot_right_bars = signal_params['pivot_right_bars']
    breakout_atr_buffer = signal_params['breakout_atr_buffer']
    min_body_atr = signal_params['min_body_atr']
    n = features.market.size
    closes = np.asarray(features.market.closes)
    opens = np.asarray(features.market.opens)
    atr = np.asarray(features.atr(22))
    pivot_highs = np.asarray(features.pivot_high(pivot_left_bars, pivot_right_bars))
    pivot_lows = np.asarray(features.pivot_low(pivot_left_bars, pivot_right_bars))
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    last_high = np.nan
    last_low = np.nan
    high_broken = False
    low_broken = False
    trend = 0
    for t in range(n):
        previous_high = last_high
        previous_low = last_low
        previous_high_broken = high_broken
        previous_low_broken = low_broken
        previous_trend = trend
        up_raw = False
        down_raw = False
        if t > 0 and np.isfinite(atr[t]):
            body = abs(closes[t] - opens[t])
            body_ok = body >= atr[t] * min_body_atr
            if np.isfinite(previous_high):
                up_raw = not previous_high_broken and closes[t] > previous_high + atr[t] * breakout_atr_buffer and (closes[t - 1] <= previous_high) and body_ok
            if np.isfinite(previous_low):
                down_raw = not previous_low_broken and closes[t] < previous_low - atr[t] * breakout_atr_buffer and (closes[t - 1] >= previous_low) and body_ok
        if up_raw:
            trend = 1
        elif down_raw:
            trend = -1
        short_entries[t] = trend == -1 and previous_trend != -1
        high_broken = False if np.isfinite(pivot_highs[t]) else previous_high_broken
        low_broken = False if np.isfinite(pivot_lows[t]) else previous_low_broken
        if up_raw:
            high_broken = True
        if down_raw:
            low_broken = True
        if np.isfinite(pivot_highs[t]):
            last_high = pivot_highs[t]
        if np.isfinite(pivot_lows[t]):
            last_low = pivot_lows[t]
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Trend_State_Flip_Down__reversion__follow', 'hypothesis': '以確認的樞紐高低點作為突破基準，收盤越過 ATR 緩衝且 K 棒實體達 ATR 門檻時更新趨勢，並在趨勢轉為空頭時觸發。', 'position': 'both', 'signal_parameter_names': ['pivot_left_bars', 'pivot_right_bars', 'breakout_atr_buffer', 'min_body_atr'], 'signal_parameter_specs': [{'name': 'pivot_left_bars', 'family': 'lookback', 'anchor': 5}, {'name': 'pivot_right_bars', 'family': 'lookback', 'anchor': 5}, {'name': 'breakout_atr_buffer', 'family': 'multiplier', 'anchor': 2.0}, {'name': 'min_body_atr', 'family': 'multiplier', 'anchor': 2.0}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivot_left_bars': [5, 2, 10], 'pivot_right_bars': [5, 2, 10], 'breakout_atr_buffer': [2.0, 1.0, 1.5, 3.0], 'min_body_atr': [2.0, 1.0, 1.5, 3.0]}}, 'generate_signals': generate_signals}
