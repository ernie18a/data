def generate_signals(features, signal_params):
    size = features.market.size
    lookback = signal_params['lookback']
    atr_multiplier = signal_params['atr_multiplier']
    closes = np.asarray(features.market.closes, dtype=float)
    highs = np.asarray(features.highest(lookback), dtype=float)
    lows = np.asarray(features.lowest(lookback), dtype=float)
    atr = np.asarray(features.atr(lookback), dtype=float)
    long_entries = np.zeros(size, dtype=bool)
    long_exits = np.zeros(size, dtype=bool)
    short_entries = np.zeros(size, dtype=bool)
    short_exits = np.zeros(size, dtype=bool)
    raw_long_stop = highs - atr_multiplier * atr
    raw_short_stop = lows + atr_multiplier * atr
    long_stop = np.full(size, np.nan, dtype=float)
    short_stop = np.full(size, np.nan, dtype=float)
    direction = np.zeros(size, dtype=np.int8)
    for i in range(size):
        if not (np.isfinite(closes[i]) and np.isfinite(raw_long_stop[i]) and np.isfinite(raw_short_stop[i])):
            continue
        if i == 0 or direction[i - 1] == 0:
            long_stop[i] = raw_long_stop[i]
            short_stop[i] = raw_short_stop[i]
            direction[i] = 1
            continue
        if np.isfinite(long_stop[i - 1]) and np.isfinite(short_stop[i - 1]):
            if closes[i - 1] > long_stop[i - 1]:
                long_stop[i] = max(raw_long_stop[i], long_stop[i - 1])
            else:
                long_stop[i] = raw_long_stop[i]
            if closes[i - 1] < short_stop[i - 1]:
                short_stop[i] = min(raw_short_stop[i], short_stop[i - 1])
            else:
                short_stop[i] = raw_short_stop[i]
        else:
            long_stop[i] = raw_long_stop[i]
            short_stop[i] = raw_short_stop[i]
        previous_direction = direction[i - 1]
        if previous_direction == -1 and closes[i] > short_stop[i - 1]:
            direction[i] = 1
            long_entries[i] = True
            short_exits[i] = True
        elif previous_direction == 1 and closes[i] < long_stop[i - 1]:
            direction[i] = -1
            short_entries[i] = True
            long_exits[i] = True
        else:
            direction[i] = previous_direction
    return (long_entries, long_exits, short_entries, short_exits)

def iter_signal_parameter_sets():
    from itertools import product
    for values in product(*[]):
        yield dict(zip([], values))
STRATEGY = {'strategy_id': 'chandelier_exit', 'hypothesis': '方向由收盤價穿越前一根 Chandelier 停損線時翻轉；反向翻轉同時出場。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': [], 'signal_parameter_sets': iter_signal_parameter_sets}
