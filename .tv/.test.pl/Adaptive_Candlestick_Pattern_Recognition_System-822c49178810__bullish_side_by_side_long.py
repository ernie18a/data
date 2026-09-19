import numpy as np

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

def _sma(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    if window <= values.size:
        cumulative = np.cumsum(values, dtype=float)
        prior = np.concatenate(([0.0], cumulative[:-window]))
        result[window - 1:] = (cumulative[window - 1:] - prior) / window
    return result

def generate_signals(features, signal_params):
    size = features.market.size
    opens = np.asarray(features.market.opens, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    tolerance = float(signal_params.get('i_SBSTolerance', 0.15))
    ma_window = int(signal_params.get('ma_window', 20))
    if not 0.0 <= tolerance or ma_window <= 0:
        raise ValueError('i_SBSTolerance and ma_window must be non-negative and positive')
    moving_average = _sma(closes, ma_window)
    for t in range(2, size):
        first_open, first_close = (opens[t - 2], closes[t - 2])
        second_open, second_close = (opens[t - 1], closes[t - 1])
        third_open, third_close = (opens[t], closes[t])
        body = abs(second_close - second_open)
        similar_open = abs(third_open - second_open) < body * tolerance
        similar_close = abs(third_close - second_close) < body * tolerance
        trend_index = t - 3
        if first_close > first_open and second_close > second_open and (third_close > third_open) and (second_open > first_close) and (third_open > first_close) and similar_open and similar_close and (trend_index >= 0) and np.isfinite(moving_average[trend_index]) and (closes[trend_index] > moving_average[trend_index]):
            long_entries[t] = True
    exit_params = dict(signal_params)
    exit_params.update({'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0})
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_side_by_side_long', 'hypothesis': 'Bullish side-by-side candles above a dynamic moving average may precede long continuation.', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_SBSTolerance', 'ma_window'], 'signal_parameter_sets': [{'i_SBSTolerance': 0.15, 'ma_window': 20}]}
