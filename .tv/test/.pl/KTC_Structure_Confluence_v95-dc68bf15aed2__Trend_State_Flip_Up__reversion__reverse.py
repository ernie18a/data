import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    pivot_left = signal_params['pivot_left']
    pivot_right = signal_params['pivot_right']
    breakout_atr_buffer = signal_params['breakout_atr_buffer']
    min_body_atr = signal_params['min_body_atr']
    opens = features.market.opens
    closes = features.market.closes
    atr = features.atr(22)
    pivot_highs = features.pivot_high(pivot_left, pivot_right)
    pivot_lows = features.pivot_low(pivot_left, pivot_right)
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    last_high = np.nan
    last_low = np.nan
    high_broken = False
    low_broken = False
    trend = 0
    for t in range(n):
        previous_trend = trend
        previous_high = last_high
        previous_low = last_low
        previous_high_broken = high_broken
        previous_low_broken = low_broken
        up_raw = False
        down_raw = False
        if t > 0 and (not np.isnan(previous_high)) and (not previous_high_broken) and (not np.isnan(atr[t])):
            up_raw = closes[t] > previous_high + atr[t] * breakout_atr_buffer and closes[t - 1] <= previous_high and (abs(closes[t] - opens[t]) >= atr[t] * min_body_atr)
        if t > 0 and (not np.isnan(previous_low)) and (not previous_low_broken) and (not np.isnan(atr[t])):
            down_raw = closes[t] < previous_low - atr[t] * breakout_atr_buffer and closes[t - 1] >= previous_low and (abs(closes[t] - opens[t]) >= atr[t] * min_body_atr)
        if up_raw:
            trend = 1
        elif down_raw:
            trend = -1
        long_entries[t] = trend == 1 and previous_trend != 1
        if not np.isnan(pivot_highs[t]):
            last_high = pivot_highs[t]
            high_broken = False
        if not np.isnan(pivot_lows[t]):
            last_low = pivot_lows[t]
            low_broken = False
        if up_raw:
            high_broken = True
        if down_raw:
            low_broken = True
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Trend_State_Flip_Up__reversion__reverse', 'hypothesis': '已確認的收盤價突破最近樞紐高點且實體達到 ATR 門檻時，策略切換為多頭並觸發進場。', 'position': 'both', 'signal_parameter_names': ['pivot_left', 'pivot_right', 'breakout_atr_buffer', 'min_body_atr'], 'signal_parameter_specs': [{'name': 'pivot_left', 'family': 'lookback', 'anchor': 5}, {'name': 'pivot_right', 'family': 'lookback', 'anchor': 5}, {'name': 'breakout_atr_buffer', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'min_body_atr', 'family': 'multiplier', 'anchor': 0.15}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivot_left': [5, 2, 10], 'pivot_right': [5, 2, 10], 'breakout_atr_buffer': [0.1, 0.06999999999999999, 0.13999999999999999], 'min_body_atr': [0.15, 0.105, 0.21]}}, 'generate_signals': generate_signals}
