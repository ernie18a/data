import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    pivot_len = signal_params['pivot_len']
    break_buffer_atr_multiplier = signal_params['break_buffer_atr_multiplier']
    body_atr_multiplier = signal_params['body_atr_multiplier']
    opens = features.market.opens
    closes = features.market.closes
    atr = features.atr(22)
    pivot_lows = features.pivot_low(pivot_len, pivot_len)
    body = np.abs(closes - opens)
    break_buffer = atr * break_buffer_atr_multiplier
    body_ok = body >= atr * body_atr_multiplier
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    last_low = np.full(n, np.nan, dtype=np.float64)
    low_broken = np.zeros(n, dtype=bool)
    trend = np.zeros(n, dtype=np.int8)
    for t in range(n):
        previous_last_low = last_low[t - 1] if t > 0 else np.nan
        previous_low_broken = low_broken[t - 1] if t > 0 else False
        previous_trend = trend[t - 1] if t > 0 else 0
        has_new_pivot = not np.isnan(pivot_lows[t])
        if has_new_pivot:
            last_low[t] = pivot_lows[t]
            low_broken[t] = False
        elif t > 0:
            last_low[t] = last_low[t - 1]
            low_broken[t] = low_broken[t - 1]
        dn_raw = t > 0 and (not np.isnan(previous_last_low)) and (not previous_low_broken) and (closes[t] < previous_last_low - break_buffer[t]) and (closes[t - 1] >= previous_last_low) and body_ok[t]
        if dn_raw:
            low_broken[t] = True
            trend[t] = -1
        else:
            trend[t] = previous_trend
        short_entries[t] = dn_raw and previous_trend == -1
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Bearish_BOS__reversion__reverse', 'hypothesis': '價格以實體幅度確認跌破最近已確認的樞軸低點，且前一趨勢為空頭時觸發空頭 BOS。', 'position': 'both', 'signal_parameter_names': ['pivot_len', 'break_buffer_atr_multiplier', 'body_atr_multiplier'], 'signal_parameter_specs': [{'name': 'pivot_len', 'family': 'lookback', 'anchor': 5}, {'name': 'break_buffer_atr_multiplier', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'body_atr_multiplier', 'family': 'multiplier', 'anchor': 0.15}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivot_len': [5, 2, 10], 'break_buffer_atr_multiplier': [0.1, 0.06999999999999999, 0.13999999999999999], 'body_atr_multiplier': [0.15, 0.105, 0.21]}}, 'generate_signals': generate_signals}
