import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    pivot_len = int(signal_params['pivot_len'])
    break_buffer_atr = float(signal_params['break_buffer_atr'])
    body_min_atr = float(signal_params['body_min_atr'])
    opens = features.market.opens
    highs = features.market.highs
    closes = features.market.closes
    atr = features.atr(22)
    confirmed_pivots = features.pivot_high(pivot_len, pivot_len, 'highs')
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    last_high = np.nan
    high_broken = False
    trend = 0
    for t in range(n):
        previous_high = last_high
        previous_high_broken = high_broken
        previous_trend = trend
        body_ok = abs(closes[t] - opens[t]) >= atr[t] * body_min_atr
        up_raw = not np.isnan(previous_high) and (not previous_high_broken) and (closes[t] > previous_high + atr[t] * break_buffer_atr) and (t == 0 or closes[t - 1] <= previous_high) and body_ok
        bull_choch = up_raw and previous_trend != 1
        long_entries[t] = bull_choch
        if not np.isnan(confirmed_pivots[t]):
            last_high = confirmed_pivots[t]
            high_broken = False
        if up_raw:
            high_broken = True
            trend = 1
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Bullish_CHoCH__reversion__follow', 'hypothesis': '已確認的收盤價突破前一個樞紐高點並超過 ATR 緩衝、且 K 棒實體達到 ATR 門檻時，若趨勢尚非多頭且該高點未被突破，觸發多頭 CHoCH。', 'position': 'both', 'signal_parameter_names': ['pivot_len', 'break_buffer_atr', 'body_min_atr'], 'signal_parameter_specs': [{'name': 'pivot_len', 'family': 'lookback', 'anchor': 5}, {'name': 'break_buffer_atr', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'body_min_atr', 'family': 'multiplier', 'anchor': 0.15}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivot_len': [5, 2, 10], 'break_buffer_atr': [0.1, 0.06999999999999999, 0.13999999999999999], 'body_min_atr': [0.15, 0.105, 0.21]}}, 'generate_signals': generate_signals}
