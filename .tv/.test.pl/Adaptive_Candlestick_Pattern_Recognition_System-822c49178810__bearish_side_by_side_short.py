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

def _sma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length <= 0:
        raise ValueError('i_MA1Length must be positive')
    if values.size >= length:
        result[length - 1:] = np.convolve(values, np.ones(length, dtype=float) / length, mode='valid')
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    tolerance = float(signal_params.get('i_SBSTolerance', 0.15))
    ma_length = int(signal_params.get('i_MA1Length', 20))
    if tolerance < 0.0:
        raise ValueError('i_SBSTolerance must be non-negative')
    moving_average = _sma(closes, ma_length)
    for t in range(2, size):
        first = t - 2
        second = t - 1
        trend_bar = t - 3
        if trend_bar < 0 or not np.isfinite(moving_average[trend_bar]):
            continue
        first_bearish = closes[first] < opens[first]
        second_bullish = closes[second] > opens[second]
        third_bullish = closes[t] > opens[t]
        both_closes_below_first = closes[second] < closes[first] and closes[t] < closes[first]
        second_body = closes[second] - opens[second]
        similar_open = abs(opens[t] - opens[second]) <= second_body * tolerance
        similar_close = abs(closes[t] - closes[second]) <= second_body * tolerance
        downtrend = closes[trend_bar] <= moving_average[trend_bar]
        short_entries[t] = first_bearish and second_bullish and third_bullish and both_closes_below_first and similar_open and similar_close and downtrend
    exit_params = dict(signal_params)
    exit_params.setdefault('k_base', 2.0)
    exit_params.setdefault('gamma', 1.0)
    exit_params.setdefault('n_base', 2000.0)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bearish_side_by_side_short', 'hypothesis': 'A bearish side-by-side pattern below the dynamic moving average may precede downward price movement.', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_SBSTolerance', 'i_MA1Length'], 'signal_parameter_sets': [{'i_SBSTolerance': 0.15, 'i_MA1Length': 20}]}
