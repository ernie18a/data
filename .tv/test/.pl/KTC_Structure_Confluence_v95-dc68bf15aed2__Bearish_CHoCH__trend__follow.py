import numpy as np

def generate_entries(features, signal_params):
    import numpy as np
    n = features.market.size
    pivot_len = int(signal_params['pivot_len'])
    break_buffer_atr_multiplier = float(signal_params['break_buffer_atr_multiplier'])
    body_atr_multiplier = float(signal_params['body_atr_multiplier'])
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    atr = np.asarray(features.atr(22), dtype=np.float64)
    pivot_lows = np.asarray(features.pivot_low(pivot_len, pivot_len), dtype=np.float64)
    pivot_highs = np.asarray(features.pivot_high(pivot_len, pivot_len), dtype=np.float64)
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    last_low = np.nan
    last_high = np.nan
    low_broken = False
    high_broken = False
    trend = 0
    for t in range(n):
        previous_close = closes[t - 1] if t > 0 else np.nan
        break_buffer = atr[t] * break_buffer_atr_multiplier
        body_ok = abs(closes[t] - opens[t]) >= atr[t] * body_atr_multiplier
        dn_raw = t > 0 and (not np.isnan(last_low)) and (not low_broken) and (closes[t] < last_low - break_buffer) and (previous_close >= last_low) and body_ok
        up_raw = t > 0 and (not np.isnan(last_high)) and (not high_broken) and (closes[t] > last_high + break_buffer) and (previous_close <= last_high) and body_ok
        bear_choch = dn_raw and trend != -1
        short_entries[t] = bear_choch
        if not np.isnan(pivot_lows[t]):
            last_low = pivot_lows[t]
            low_broken = False
        if not np.isnan(pivot_highs[t]):
            last_high = pivot_highs[t]
            high_broken = False
        if dn_raw:
            low_broken = True
            high_broken = False
            trend = -1
        if up_raw:
            high_broken = True
            low_broken = False
            trend = 1
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Bearish_CHoCH__trend__follow', 'hypothesis': '價格以足夠大的實體收盤跌破前次確認的 pivot low，且跌破幅度超過 ATR 緩衝時，若前一趨勢並非空頭，則形成看跌 CHoCH。', 'position': 'both', 'signal_parameter_names': ['pivot_len', 'break_buffer_atr_multiplier', 'body_atr_multiplier'], 'signal_parameter_specs': [{'name': 'pivot_len', 'family': 'lookback', 'anchor': 5}, {'name': 'break_buffer_atr_multiplier', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'body_atr_multiplier', 'family': 'multiplier', 'anchor': 0.15}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivot_len': [5, 2, 10], 'break_buffer_atr_multiplier': [0.1, 0.06999999999999999, 0.13999999999999999], 'body_atr_multiplier': [0.15, 0.105, 0.21]}}, 'generate_signals': generate_signals}
