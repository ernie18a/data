def generate_signals(features, signal_params):
    import numpy as np
    size = features.market.size
    closes = np.asarray(features.market.closes, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    length = int(signal_params['lookback'])
    multiplier = float(signal_params['multiplier'])
    long_entries = np.zeros(size, dtype=bool)
    long_exits = np.zeros(size, dtype=bool)
    short_entries = np.zeros(size, dtype=bool)
    short_exits = np.zeros(size, dtype=bool)
    if length <= 0 or size < 2:
        return (long_entries, long_exits, short_entries, short_exits)
    true_range = np.zeros(size, dtype=float)
    if size:
        true_range[0] = highs[0] - lows[0]
    for i in range(1, size):
        true_range[i] = max(highs[i] - lows[i], abs(highs[i] - closes[i - 1]), abs(lows[i] - closes[i - 1]))
    smoothed_atr = np.full(size, np.nan, dtype=float)
    alpha = 2.0 / (length + 1.0)
    if size:
        smoothed_atr[0] = true_range[0]
    for i in range(1, size):
        smoothed_atr[i] = alpha * true_range[i] + (1.0 - alpha) * smoothed_atr[i - 1]
    raw_long_stop = np.full(size, np.nan, dtype=float)
    raw_short_stop = np.full(size, np.nan, dtype=float)
    for i in range(length - 1, size):
        start = i - length + 1
        raw_long_stop[i] = np.max(closes[start:i + 1]) - multiplier * smoothed_atr[i]
        raw_short_stop[i] = np.min(closes[start:i + 1]) + multiplier * smoothed_atr[i]
    long_stop = np.full(size, np.nan, dtype=float)
    short_stop = np.full(size, np.nan, dtype=float)
    direction = np.ones(size, dtype=np.int8)
    if size and np.isfinite(raw_long_stop[0]):
        long_stop[0] = raw_long_stop[0]
        short_stop[0] = raw_short_stop[0]
    for i in range(1, size):
        if np.isfinite(raw_long_stop[i]):
            if np.isfinite(long_stop[i - 1]) and closes[i - 1] > long_stop[i - 1]:
                long_stop[i] = max(raw_long_stop[i], long_stop[i - 1])
            else:
                long_stop[i] = raw_long_stop[i]
            if np.isfinite(short_stop[i - 1]) and closes[i - 1] < short_stop[i - 1]:
                short_stop[i] = min(raw_short_stop[i], short_stop[i - 1])
            else:
                short_stop[i] = raw_short_stop[i]
        direction[i] = direction[i - 1]
        if np.isfinite(short_stop[i - 1]) and closes[i] > short_stop[i - 1]:
            direction[i] = 1
        elif np.isfinite(long_stop[i - 1]) and closes[i] < long_stop[i - 1]:
            direction[i] = -1
        if direction[i - 1] == -1 and direction[i] == 1 and (i + 1 < size):
            long_entries[i + 1] = True
            short_exits[i + 1] = True
        elif direction[i - 1] == 1 and direction[i] == -1 and (i + 1 < size):
            short_entries[i + 1] = True
            long_exits[i + 1] = True
    return (long_entries, long_exits, short_entries, short_exits)

def iter_signal_parameter_sets():
    from itertools import product
    for values in product(*[]):
        yield dict(zip([], values))
STRATEGY = {'strategy_id': 'noldo_chandelier_exit', 'hypothesis': '收盤價穿越前一根追蹤停損線時反轉方向，並於下一根開盤進場；方向反轉時同步出場。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': [], 'signal_parameter_sets': iter_signal_parameter_sets}
