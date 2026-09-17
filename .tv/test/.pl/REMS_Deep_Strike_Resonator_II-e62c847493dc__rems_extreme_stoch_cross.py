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

def _sma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length <= 0:
        return result
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _rsi(closes, length):
    result = np.full(closes.size, np.nan, dtype=float)
    if closes.size <= length:
        return result
    delta = np.diff(closes)
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
    average_gain = np.mean(gains[:length])
    average_loss = np.mean(losses[:length])

    def value(gain, loss):
        if loss == 0.0:
            return 50.0 if gain == 0.0 else 100.0
        return 100.0 - 100.0 / (1.0 + gain / loss)
    result[length] = value(average_gain, average_loss)
    for index in range(length + 1, closes.size):
        average_gain = (average_gain * (length - 1) + gains[index - 1]) / length
        average_loss = (average_loss * (length - 1) + losses[index - 1]) / length
        result[index] = value(average_gain, average_loss)
    return result

def _primary_stoch_rsi(closes):
    rsi = _rsi(closes, 14)
    raw = np.full(closes.size, np.nan, dtype=float)
    for index in range(7, closes.size):
        window = rsi[index - 7:index + 1]
        if np.all(np.isfinite(window)):
            denominator = max(float(np.max(window) - np.min(window)), 1e-10)
            raw[index] = (rsi[index] - np.min(window)) / denominator * 100.0
    k = _sma(raw, 3)
    d = _sma(k, 3)
    return (k, d)

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    closes = np.asarray(features.market.closes, dtype=float)
    k_primary, d_primary = _primary_stoch_rsi(closes)
    for index in range(1, size):
        previous_k = k_primary[index - 1]
        previous_d = d_primary[index - 1]
        current_k = k_primary[index]
        current_d = d_primary[index]
        if np.isfinite(previous_k) and np.isfinite(previous_d) and np.isfinite(current_k) and np.isfinite(current_d):
            long_entries[index] = current_k > current_d and previous_k <= previous_d and (previous_k <= 30.0)
            short_entries[index] = current_k < current_d and previous_k >= previous_d and (previous_k >= 70.0)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'rems_extreme_stoch_cross', 'hypothesis': 'Primary Stoch RSI 在極端區域發生 K/D 交叉，預示價格反轉。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'mult'], 'signal_parameter_sets': [{'k_base': 2.0, 'mult': 2.0}]}
