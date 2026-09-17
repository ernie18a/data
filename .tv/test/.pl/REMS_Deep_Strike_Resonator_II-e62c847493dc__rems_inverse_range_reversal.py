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

def _ema(values, length):
    values = np.asarray(values, dtype=np.float64)
    result = np.full(values.size, np.nan, dtype=np.float64)
    if values.size == 0:
        return result
    alpha = 2.0 / (length + 1.0)
    result[0] = values[0]
    for index in range(1, values.size):
        result[index] = alpha * values[index] + (1.0 - alpha) * result[index - 1]
    return result

def _sma(values, length):
    values = np.asarray(values, dtype=np.float64)
    result = np.full(values.size, np.nan, dtype=np.float64)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _rsi(closes, length):
    closes = np.asarray(closes, dtype=np.float64)
    result = np.full(closes.size, np.nan, dtype=np.float64)
    if closes.size <= length:
        return result
    changes = np.diff(closes)
    gains = np.maximum(changes, 0.0)
    losses = np.maximum(-changes, 0.0)
    average_gain = np.mean(gains[:length])
    average_loss = np.mean(losses[:length])
    result[length] = 100.0 if average_loss == 0.0 else 100.0 - 100.0 / (1.0 + average_gain / average_loss)
    for index in range(length + 1, closes.size):
        average_gain = (average_gain * (length - 1) + gains[index - 1]) / length
        average_loss = (average_loss * (length - 1) + losses[index - 1]) / length
        result[index] = 100.0 if average_loss == 0.0 else 100.0 - 100.0 / (1.0 + average_gain / average_loss)
    return result

def _rolling_extreme(values, length, maximum):
    values = np.asarray(values, dtype=np.float64)
    result = np.full(values.size, np.nan, dtype=np.float64)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.max(window) if maximum else np.min(window)
    return result

def _stoch_rsi(closes, rsi_length, stochastic_length, k_length, d_length):
    rsi = _rsi(closes, rsi_length)
    lowest = _rolling_extreme(rsi, stochastic_length, False)
    highest = _rolling_extreme(rsi, stochastic_length, True)
    raw = np.full(rsi.size, np.nan, dtype=np.float64)
    usable = np.isfinite(rsi) & np.isfinite(lowest) & np.isfinite(highest)
    varying = usable & (highest != lowest)
    raw[varying] = 100.0 * (rsi[varying] - lowest[varying]) / (highest[varying] - lowest[varying])
    raw[usable & (highest == lowest)] = 0.0
    return (_sma(raw, k_length), _sma(_sma(raw, k_length), d_length))

def _cross(first, second):
    result = np.zeros(first.size, dtype=np.bool_)
    if first.size > 1:
        previous = first[:-1] - second[:-1]
        current = first[1:] - second[1:]
        result[1:] = (current > 0.0) & (previous <= 0.0) | (current < 0.0) & (previous >= 0.0)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    closes = np.asarray(features.market.closes, dtype=np.float64)[:size]
    highs = np.asarray(features.market.highs, dtype=np.float64)[:size]
    lows = np.asarray(features.market.lows, dtype=np.float64)[:size]
    rsi = _rsi(closes, 14)
    rsi_sma = _sma(rsi, 20)
    ema_fast = _ema(closes, 8)
    ema_slow = _ema(closes, 21)
    macd_line = _ema(closes, 12) - _ema(closes, 26)
    macd_signal = _ema(macd_line, 9)
    macd_histogram = macd_line - macd_signal
    stoch_k, stoch_d = _stoch_rsi(closes, 14, 8, 3, 3)
    finite = np.isfinite(rsi) & np.isfinite(rsi_sma) & np.isfinite(ema_fast) & np.isfinite(ema_slow) & np.isfinite(macd_line) & np.isfinite(macd_signal) & np.isfinite(macd_histogram) & np.isfinite(stoch_k) & np.isfinite(stoch_d)
    rsi_delta = np.diff(rsi, prepend=np.nan)
    hist_delta = np.diff(macd_histogram, prepend=np.nan)
    native_long_raw = finite & (rsi_delta > 0.0) & (hist_delta > 0.0) & (stoch_k > stoch_d)
    native_short_raw = finite & (rsi_delta < 0.0) & (hist_delta < 0.0) & (stoch_k < stoch_d)
    reset = _cross(rsi, rsi_sma) | _cross(ema_fast, ema_slow) | _cross(macd_line, macd_signal) | _cross(stoch_k, stoch_d)
    native_long = np.zeros(size, dtype=np.bool_)
    native_short = np.zeros(size, dtype=np.bool_)
    long_cooled = False
    short_cooled = False
    for index in range(size):
        native_long[index] = native_long_raw[index] and (not long_cooled or reset[index])
        native_short[index] = native_short_raw[index] and (not short_cooled or reset[index])
        if native_long_raw[index]:
            long_cooled = True
        elif reset[index]:
            long_cooled = False
        if native_short_raw[index]:
            short_cooled = True
        elif reset[index]:
            short_cooled = False
    range_high = _rolling_extreme(highs, 25, True)
    range_low = _rolling_extreme(lows, 25, False)
    range_valid = np.isfinite(range_high) & np.isfinite(range_low)
    range_size = np.maximum(range_high - range_low, np.finfo(np.float64).eps)
    short_zone_start = range_high - 0.35 * range_size
    long_zone_end = range_low + 0.35 * range_size
    in_long_zone = range_valid & (closes <= long_zone_end)
    in_short_zone = range_valid & (closes >= short_zone_start)
    in_any_zone = in_long_zone | in_short_zone
    block_long = range_valid & ~in_long_zone
    block_short = range_valid & ~in_short_zone
    long_entries = native_short & block_short & in_any_zone
    short_entries = native_long & block_long & in_any_zone
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'rems_inverse_range_reversal', 'hypothesis': '區間反向訊號可捕捉原生動能訊號在錯配區域受阻後的均值回歸。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'mult'], 'signal_parameter_sets': [{'k_base': 2.0, 'mult': 2.0}]}
