import numpy as np

def generate_entries(features, signal_params):
    import numpy as np
    n = features.market.size
    pivot_len = signal_params['pivot_len']
    break_buffer_multiplier = signal_params['break_buffer_multiplier']
    body_atr_multiplier = signal_params['body_atr_multiplier']
    atr = features.atr(22)
    ph = features.pivot_high(pivot_len, pivot_len)
    opens = features.market.opens
    highs = features.market.highs
    closes = features.market.closes
    body = np.abs(closes - opens)
    break_buffer = atr * break_buffer_multiplier
    body_ok = body >= atr * body_atr_multiplier
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    last_high = np.nan
    high_broken = False
    trend = 0
    for t in range(n):
        prev_last_high = last_high
        prev_high_broken = high_broken
        prev_trend = trend
        up_raw = t > 0 and np.isfinite(prev_last_high) and (not prev_high_broken) and (closes[t] > prev_last_high + break_buffer[t]) and (closes[t - 1] <= prev_last_high) and body_ok[t]
        bull_break = up_raw
        long_entries[t] = up_raw and prev_trend == 1
        if np.isfinite(ph[t]):
            last_high = ph[t]
            high_broken = False
        if bull_break:
            high_broken = True
            trend = 1
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Bullish_BOS__trend__reverse', 'hypothesis': '價格以足夠實體突破前一個已確認的樞軸高點及其 ATR 緩衝，且前一趨勢為多頭時，視為多頭 BOS。', 'position': 'both', 'signal_parameter_names': ['pivot_len', 'break_buffer_multiplier', 'body_atr_multiplier'], 'signal_parameter_specs': [{'name': 'pivot_len', 'family': 'lookback', 'anchor': 5}, {'name': 'break_buffer_multiplier', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'body_atr_multiplier', 'family': 'multiplier', 'anchor': 0.15}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivot_len': [5, 2, 10], 'break_buffer_multiplier': [0.1, 0.06999999999999999, 0.13999999999999999], 'body_atr_multiplier': [0.15, 0.105, 0.21]}}, 'generate_signals': generate_signals}
