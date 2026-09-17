def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    volumes = features.market.volumes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    gamma = float(signal_params.get('gamma', 1.0))
    n_base = float(signal_params.get('n_base', 2000.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    cum_vol = 0.0
    entry_atr = 1.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
                cum_vol += volumes[t]
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
                cum_vol += volumes[t]
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
    return (long_exits, short_exits)
import numpy as np

def _series(values, size):
    values = np.asarray(values, dtype=float).reshape(-1)
    result = np.full(size, np.nan, dtype=float)
    result[:min(size, values.size)] = values[:size]
    return result

def _ema(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length < 1:
        raise ValueError('EMA length must be positive')
    previous = np.nan
    alpha = 2.0 / (length + 1.0)
    for i, value in enumerate(values):
        if np.isfinite(value):
            previous = value if not np.isfinite(previous) else alpha * value + (1.0 - alpha) * previous
            result[i] = previous
    return result

def _sma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length < 1:
        raise ValueError('SMA length must be positive')
    for i in range(length - 1, values.size):
        window = values[i - length + 1:i + 1]
        if np.all(np.isfinite(window)):
            result[i] = np.mean(window)
    return result

def _rsi(closes, length):
    result = np.full(closes.size, np.nan, dtype=float)
    if length < 1 or closes.size <= length:
        return result
    delta = np.diff(closes)
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
    gain = np.mean(gains[:length])
    loss = np.mean(losses[:length])
    result[length] = 50.0 if gain == 0.0 and loss == 0.0 else 100.0 if loss == 0.0 else 100.0 - 100.0 / (1.0 + gain / loss)
    for i in range(length + 1, closes.size):
        gain = (gain * (length - 1) + gains[i - 1]) / length
        loss = (loss * (length - 1) + losses[i - 1]) / length
        result[i] = 50.0 if gain == 0.0 and loss == 0.0 else 100.0 if loss == 0.0 else 100.0 - 100.0 / (1.0 + gain / loss)
    return result

def _stoch_rsi(closes, rsi_length, stoch_length, k_length, d_length):
    rsi = _rsi(closes, rsi_length)
    lowest = np.full(closes.size, np.nan, dtype=float)
    highest = np.full(closes.size, np.nan, dtype=float)
    for i in range(stoch_length - 1, closes.size):
        window = rsi[i - stoch_length + 1:i + 1]
        if np.all(np.isfinite(window)):
            lowest[i] = np.min(window)
            highest[i] = np.max(window)
    denominator = np.maximum(highest - lowest, 1e-10)
    raw = (rsi - lowest) / denominator * 100.0
    k = _sma(raw, k_length)
    d = _sma(k, d_length)
    return (k, d)

def _macd_histogram(closes, fast, slow, signal):
    macd = _ema(closes, fast) - _ema(closes, slow)
    return macd - _ema(macd, signal)

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, long_entries.copy(), short_entries, short_entries.copy())
    closes = _series(features.market.closes, size)
    hist_secondary = _macd_histogram(closes, 12, 26, 9)
    k_primary, d_primary = _stoch_rsi(closes, 14, 8, 3, 3)
    k_secondary, d_secondary = _stoch_rsi(closes, 7, 7, 3, 2)
    finite = np.isfinite(hist_secondary) & np.isfinite(k_primary) & np.isfinite(d_primary) & np.isfinite(k_secondary) & np.isfinite(d_secondary)
    if size > 1:
        rising = np.zeros(size, dtype=np.bool_)
        falling = np.zeros(size, dtype=np.bool_)
        rising[1:] = np.isfinite(hist_secondary[1:]) & np.isfinite(hist_secondary[:-1]) & (hist_secondary[1:] > hist_secondary[:-1])
        falling[1:] = np.isfinite(hist_secondary[1:]) & np.isfinite(hist_secondary[:-1]) & (hist_secondary[1:] < hist_secondary[:-1])
        long_entries = finite & rising & (k_primary > d_primary) & (k_secondary > d_secondary)
        short_entries = finite & falling & (k_primary < d_primary) & (k_secondary < d_secondary)
    params = signal_params or {}
    exit_params = {'k_base': float(params.get('k_base', 2.0)), 'gamma': float(params.get('gamma', 1.0)), 'n_base': float(params.get('n_base', 2000.0))}
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'rems_deep_synergy_c2', 'hypothesis': 'Secondary MACD 柱體動能與 Primary、Secondary Stoch RSI 同向時，趨勢共振可提升進場品質。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
