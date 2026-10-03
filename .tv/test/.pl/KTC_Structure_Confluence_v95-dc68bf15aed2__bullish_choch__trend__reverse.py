import numpy as np

def generate_entries(features, signal_params):
    import numpy as np
    pivot_len = signal_params['pivot_len']
    atr_len = signal_params['atr_len']
    atr_buf_mult = signal_params['atr_buf_mult']
    min_body_atr = signal_params['min_body_atr']
    n = features.market.size
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    closes = np.asarray(features.market.closes)
    opens = np.asarray(features.market.opens)
    pivot_highs = features.pivot_high(pivot_len, pivot_len)
    atr_for_buffer = features.atr(22)
    atr_for_body = features.atr(atr_len)
    last_high = np.nan
    high_broken = False
    trend = 0
    for t in range(n):
        if not np.isnan(pivot_highs[t]):
            last_high = pivot_highs[t]
            high_broken = False
        if t == 0 or np.isnan(last_high):
            continue
        break_buffer = atr_for_buffer[t] * atr_buf_mult
        body_ok = abs(closes[t] - opens[t]) >= atr_for_body[t] * min_body_atr
        crossed_above = closes[t] > last_high + break_buffer and closes[t - 1] <= last_high
        if not high_broken and trend != 1 and crossed_above and body_ok:
            long_entries[t] = True
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

_SIGNAL_PARAMETER_SETS = [{'pivot_len': 5, 'atr_len': 14, 'atr_buf_mult': 0.1, 'min_body_atr': 0.15}, {'pivot_len': 5, 'atr_len': 14, 'atr_buf_mult': 0.1, 'min_body_atr': 0.105}, {'pivot_len': 5, 'atr_len': 14, 'atr_buf_mult': 0.1, 'min_body_atr': 0.21}, {'pivot_len': 5, 'atr_len': 14, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 5, 'atr_len': 14, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 5, 'atr_len': 14, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 5, 'atr_len': 14, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 5, 'atr_len': 14, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 5, 'atr_len': 14, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 5, 'atr_len': 7, 'atr_buf_mult': 0.1, 'min_body_atr': 0.15}, {'pivot_len': 5, 'atr_len': 7, 'atr_buf_mult': 0.1, 'min_body_atr': 0.105}, {'pivot_len': 5, 'atr_len': 7, 'atr_buf_mult': 0.1, 'min_body_atr': 0.21}, {'pivot_len': 5, 'atr_len': 7, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 5, 'atr_len': 7, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 5, 'atr_len': 7, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 5, 'atr_len': 7, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 5, 'atr_len': 7, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 5, 'atr_len': 7, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 5, 'atr_len': 28, 'atr_buf_mult': 0.1, 'min_body_atr': 0.15}, {'pivot_len': 5, 'atr_len': 28, 'atr_buf_mult': 0.1, 'min_body_atr': 0.105}, {'pivot_len': 5, 'atr_len': 28, 'atr_buf_mult': 0.1, 'min_body_atr': 0.21}, {'pivot_len': 5, 'atr_len': 28, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 5, 'atr_len': 28, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 5, 'atr_len': 28, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 5, 'atr_len': 28, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 5, 'atr_len': 28, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 5, 'atr_len': 28, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 2, 'atr_len': 14, 'atr_buf_mult': 0.1, 'min_body_atr': 0.15}, {'pivot_len': 2, 'atr_len': 14, 'atr_buf_mult': 0.1, 'min_body_atr': 0.105}, {'pivot_len': 2, 'atr_len': 14, 'atr_buf_mult': 0.1, 'min_body_atr': 0.21}, {'pivot_len': 2, 'atr_len': 14, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 2, 'atr_len': 14, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 2, 'atr_len': 14, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 2, 'atr_len': 14, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 2, 'atr_len': 14, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 2, 'atr_len': 14, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 2, 'atr_len': 7, 'atr_buf_mult': 0.1, 'min_body_atr': 0.15}, {'pivot_len': 2, 'atr_len': 7, 'atr_buf_mult': 0.1, 'min_body_atr': 0.105}, {'pivot_len': 2, 'atr_len': 7, 'atr_buf_mult': 0.1, 'min_body_atr': 0.21}, {'pivot_len': 2, 'atr_len': 7, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 2, 'atr_len': 7, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 2, 'atr_len': 7, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 2, 'atr_len': 7, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 2, 'atr_len': 7, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 2, 'atr_len': 7, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 2, 'atr_len': 28, 'atr_buf_mult': 0.1, 'min_body_atr': 0.15}, {'pivot_len': 2, 'atr_len': 28, 'atr_buf_mult': 0.1, 'min_body_atr': 0.105}, {'pivot_len': 2, 'atr_len': 28, 'atr_buf_mult': 0.1, 'min_body_atr': 0.21}, {'pivot_len': 2, 'atr_len': 28, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 2, 'atr_len': 28, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 2, 'atr_len': 28, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 2, 'atr_len': 28, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 2, 'atr_len': 28, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 2, 'atr_len': 28, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 10, 'atr_len': 14, 'atr_buf_mult': 0.1, 'min_body_atr': 0.15}, {'pivot_len': 10, 'atr_len': 14, 'atr_buf_mult': 0.1, 'min_body_atr': 0.105}, {'pivot_len': 10, 'atr_len': 14, 'atr_buf_mult': 0.1, 'min_body_atr': 0.21}, {'pivot_len': 10, 'atr_len': 14, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 10, 'atr_len': 14, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 10, 'atr_len': 14, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 10, 'atr_len': 14, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 10, 'atr_len': 14, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 10, 'atr_len': 14, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 10, 'atr_len': 7, 'atr_buf_mult': 0.1, 'min_body_atr': 0.15}, {'pivot_len': 10, 'atr_len': 7, 'atr_buf_mult': 0.1, 'min_body_atr': 0.105}, {'pivot_len': 10, 'atr_len': 7, 'atr_buf_mult': 0.1, 'min_body_atr': 0.21}, {'pivot_len': 10, 'atr_len': 7, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 10, 'atr_len': 7, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 10, 'atr_len': 7, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 10, 'atr_len': 7, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 10, 'atr_len': 7, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 10, 'atr_len': 7, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 10, 'atr_len': 28, 'atr_buf_mult': 0.1, 'min_body_atr': 0.15}, {'pivot_len': 10, 'atr_len': 28, 'atr_buf_mult': 0.1, 'min_body_atr': 0.105}, {'pivot_len': 10, 'atr_len': 28, 'atr_buf_mult': 0.1, 'min_body_atr': 0.21}, {'pivot_len': 10, 'atr_len': 28, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 10, 'atr_len': 28, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 10, 'atr_len': 28, 'atr_buf_mult': 0.06999999999999999, 'min_body_atr': 0.21}, {'pivot_len': 10, 'atr_len': 28, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.15}, {'pivot_len': 10, 'atr_len': 28, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.105}, {'pivot_len': 10, 'atr_len': 28, 'atr_buf_mult': 0.13999999999999999, 'min_body_atr': 0.21}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'bullish_choch__trend__reverse', 'hypothesis': '收盤價帶有足夠的 ATR 緩衝且實體達標地突破最近確認的擺動高點時進場做多，並避免趨勢已為多頭時重複進場。', 'position': 'both', 'signal_parameter_names': ['pivot_len', 'atr_len', 'atr_buf_mult', 'min_body_atr'], 'signal_parameter_specs': [{'name': 'pivot_len', 'family': 'lookback', 'anchor': 5}, {'name': 'atr_len', 'family': 'lookback', 'anchor': 14}, {'name': 'atr_buf_mult', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'min_body_atr', 'family': 'multiplier', 'anchor': 0.15}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
