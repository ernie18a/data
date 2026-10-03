import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    pivot_len = signal_params['pivotLen']
    atr_len = signal_params['atrLen']
    atr_buf_mult = signal_params['atrBufMult']
    min_body_atr = signal_params['minBodyATR']
    opens = np.asarray(features.market.opens, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    atr = np.asarray(features.atr(atr_len), dtype=np.float64)
    pivot_lows = np.asarray(features.pivot_low(pivot_len, pivot_len), dtype=np.float64)
    pivot_highs = np.asarray(features.pivot_high(pivot_len, pivot_len), dtype=np.float64)
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    use_atr_buf = True
    use_body_flt = True
    trend = 0
    low_broken = False
    last_low = np.nan
    last_high = np.nan
    for t in range(n):
        if np.isfinite(pivot_lows[t]):
            last_low = pivot_lows[t]
            low_broken = False
        if np.isfinite(pivot_highs[t]):
            last_high = pivot_highs[t]
        has_prev = t > 0
        prev_close = closes[t - 1] if has_prev else np.nan
        break_buffer = atr[t] * atr_buf_mult if use_atr_buf else 0.0
        body_ok = not use_body_flt or abs(closes[t] - opens[t]) >= atr[t] * min_body_atr
        down_break = has_prev and np.isfinite(last_low) and (not low_broken) and (closes[t] < last_low - break_buffer) and (prev_close >= last_low)
        short_entries[t] = bool(down_break and trend != -1 and body_ok)
        up_break = has_prev and np.isfinite(last_high) and (closes[t] > last_high) and (prev_close <= last_high)
        if up_break:
            trend = 1
        if down_break:
            trend = -1
            low_broken = True
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

_SIGNAL_PARAMETER_SETS = [{'pivotLen': 5, 'atrLen': 14, 'atrBufMult': 0.1, 'minBodyATR': 0.15}, {'pivotLen': 5, 'atrLen': 14, 'atrBufMult': 0.1, 'minBodyATR': 0.105}, {'pivotLen': 5, 'atrLen': 14, 'atrBufMult': 0.1, 'minBodyATR': 0.21}, {'pivotLen': 5, 'atrLen': 14, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 5, 'atrLen': 14, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 5, 'atrLen': 14, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 5, 'atrLen': 14, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 5, 'atrLen': 14, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 5, 'atrLen': 14, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 5, 'atrLen': 7, 'atrBufMult': 0.1, 'minBodyATR': 0.15}, {'pivotLen': 5, 'atrLen': 7, 'atrBufMult': 0.1, 'minBodyATR': 0.105}, {'pivotLen': 5, 'atrLen': 7, 'atrBufMult': 0.1, 'minBodyATR': 0.21}, {'pivotLen': 5, 'atrLen': 7, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 5, 'atrLen': 7, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 5, 'atrLen': 7, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 5, 'atrLen': 7, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 5, 'atrLen': 7, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 5, 'atrLen': 7, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 5, 'atrLen': 28, 'atrBufMult': 0.1, 'minBodyATR': 0.15}, {'pivotLen': 5, 'atrLen': 28, 'atrBufMult': 0.1, 'minBodyATR': 0.105}, {'pivotLen': 5, 'atrLen': 28, 'atrBufMult': 0.1, 'minBodyATR': 0.21}, {'pivotLen': 5, 'atrLen': 28, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 5, 'atrLen': 28, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 5, 'atrLen': 28, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 5, 'atrLen': 28, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 5, 'atrLen': 28, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 5, 'atrLen': 28, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 2, 'atrLen': 14, 'atrBufMult': 0.1, 'minBodyATR': 0.15}, {'pivotLen': 2, 'atrLen': 14, 'atrBufMult': 0.1, 'minBodyATR': 0.105}, {'pivotLen': 2, 'atrLen': 14, 'atrBufMult': 0.1, 'minBodyATR': 0.21}, {'pivotLen': 2, 'atrLen': 14, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 2, 'atrLen': 14, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 2, 'atrLen': 14, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 2, 'atrLen': 14, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 2, 'atrLen': 14, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 2, 'atrLen': 14, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 2, 'atrLen': 7, 'atrBufMult': 0.1, 'minBodyATR': 0.15}, {'pivotLen': 2, 'atrLen': 7, 'atrBufMult': 0.1, 'minBodyATR': 0.105}, {'pivotLen': 2, 'atrLen': 7, 'atrBufMult': 0.1, 'minBodyATR': 0.21}, {'pivotLen': 2, 'atrLen': 7, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 2, 'atrLen': 7, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 2, 'atrLen': 7, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 2, 'atrLen': 7, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 2, 'atrLen': 7, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 2, 'atrLen': 7, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 2, 'atrLen': 28, 'atrBufMult': 0.1, 'minBodyATR': 0.15}, {'pivotLen': 2, 'atrLen': 28, 'atrBufMult': 0.1, 'minBodyATR': 0.105}, {'pivotLen': 2, 'atrLen': 28, 'atrBufMult': 0.1, 'minBodyATR': 0.21}, {'pivotLen': 2, 'atrLen': 28, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 2, 'atrLen': 28, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 2, 'atrLen': 28, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 2, 'atrLen': 28, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 2, 'atrLen': 28, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 2, 'atrLen': 28, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 10, 'atrLen': 14, 'atrBufMult': 0.1, 'minBodyATR': 0.15}, {'pivotLen': 10, 'atrLen': 14, 'atrBufMult': 0.1, 'minBodyATR': 0.105}, {'pivotLen': 10, 'atrLen': 14, 'atrBufMult': 0.1, 'minBodyATR': 0.21}, {'pivotLen': 10, 'atrLen': 14, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 10, 'atrLen': 14, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 10, 'atrLen': 14, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 10, 'atrLen': 14, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 10, 'atrLen': 14, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 10, 'atrLen': 14, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 10, 'atrLen': 7, 'atrBufMult': 0.1, 'minBodyATR': 0.15}, {'pivotLen': 10, 'atrLen': 7, 'atrBufMult': 0.1, 'minBodyATR': 0.105}, {'pivotLen': 10, 'atrLen': 7, 'atrBufMult': 0.1, 'minBodyATR': 0.21}, {'pivotLen': 10, 'atrLen': 7, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 10, 'atrLen': 7, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 10, 'atrLen': 7, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 10, 'atrLen': 7, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 10, 'atrLen': 7, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 10, 'atrLen': 7, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 10, 'atrLen': 28, 'atrBufMult': 0.1, 'minBodyATR': 0.15}, {'pivotLen': 10, 'atrLen': 28, 'atrBufMult': 0.1, 'minBodyATR': 0.105}, {'pivotLen': 10, 'atrLen': 28, 'atrBufMult': 0.1, 'minBodyATR': 0.21}, {'pivotLen': 10, 'atrLen': 28, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 10, 'atrLen': 28, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 10, 'atrLen': 28, 'atrBufMult': 0.06999999999999999, 'minBodyATR': 0.21}, {'pivotLen': 10, 'atrLen': 28, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.15}, {'pivotLen': 10, 'atrLen': 28, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.105}, {'pivotLen': 10, 'atrLen': 28, 'atrBufMult': 0.13999999999999999, 'minBodyATR': 0.21}]

def iter_signal_parameter_sets():
    for values in _SIGNAL_PARAMETER_SETS:
        yield dict(values)

STRATEGY = {**{'strategy_id': 'bearish_choch__reversion__follow', 'hypothesis': '收盤價確認跌破最近擺動低點且跌破幅度與實體大小符合 ATR 緩衝條件時做空，並要求目前趨勢狀態不為向下。', 'position': 'both', 'signal_parameter_names': ['pivotLen', 'atrLen', 'atrBufMult', 'minBodyATR'], 'signal_parameter_specs': [{'name': 'pivotLen', 'family': 'lookback', 'anchor': 5}, {'name': 'atrLen', 'family': 'lookback', 'anchor': 14}, {'name': 'atrBufMult', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'minBodyATR', 'family': 'multiplier', 'anchor': 0.15}], 'signal_parameter_relations': []}, 'generate_signals': generate_signals, 'signal_parameter_sets': iter_signal_parameter_sets}
