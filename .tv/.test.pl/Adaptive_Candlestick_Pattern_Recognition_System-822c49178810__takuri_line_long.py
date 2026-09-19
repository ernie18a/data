import numpy as np

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    mult = float(signal_params.get('mult', 2.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    entry_price = 0.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif closes[t] >= entry_price + mult * atr[t]:
                long_exits[t] = True
                position = 0
            elif closes[t] < entry_price - mult * atr[t]:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif closes[t] <= entry_price - mult * atr[t]:
                short_exits[t] = True
                position = 0
            elif closes[t] > entry_price + mult * atr[t]:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                entry_price = closes[t]
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                entry_price = closes[t]
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
    return (long_exits, short_exits)

def _rolling_sma(values, length):
    output = np.full(values.size, np.nan, dtype=np.float64)
    if length <= 0 or values.size < length:
        return output
    cumulative = np.cumsum(values, dtype=np.float64)
    previous = np.concatenate((np.array([0.0]), cumulative[:-length]))
    output[length - 1:] = (cumulative[length - 1:] - previous) / length
    return output

def generate_signals(features, signal_params):
    size = features.market.size
    opens = np.asarray(features.market.opens, dtype=np.float64).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=np.float64).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=np.float64).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=np.float64).reshape(-1)
    ma_window = int(signal_params.get('ma_window', 20))
    hammer_tolerance = float(signal_params.get('hammer_tolerance', 0.35))
    moving_average = _rolling_sma(closes, ma_window)
    candle_range = highs - lows
    body = np.abs(closes - opens)
    body_midpoint = (opens + closes) / 2.0
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    valid = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & np.isfinite(moving_average) & (candle_range > 0.0) & (body > 0.0)
    body_in_upper_half = body_midpoint > lows + 0.5 * candle_range
    long_entries = (valid & (lower_wick / body >= 3.0) & (upper_wick / body <= hammer_tolerance) & (closes <= moving_average) & body_in_upper_half).astype(np.bool_, copy=False)
    short_entries = np.zeros(size, dtype=np.bool_)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'takuri_line_long', 'hypothesis': '下行動態 MA 中的 Takuri Line 可能預示價格反轉回升。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_window', 'hammer_tolerance', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_window': 20, 'hammer_tolerance': 0.35, 'k_base': 2.0, 'mult': 2.0}]}
