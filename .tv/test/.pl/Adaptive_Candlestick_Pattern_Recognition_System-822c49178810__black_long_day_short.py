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

def generate_signals(features, signal_params):
    import numpy as np
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens)
    highs = np.asarray(features.market.highs)
    lows = np.asarray(features.market.lows)
    closes = np.asarray(features.market.closes)
    sample = int(signal_params.get('i_TCSample', 14))
    for t in range(sample, size):
        previous_ranges = highs[t - sample:t] - lows[t - sample:t]
        previous_bodies = np.abs(closes[t - sample:t] - opens[t - sample:t])
        average_range = np.mean(previous_ranges)
        average_body = np.mean(previous_bodies)
        current_range = highs[t] - lows[t]
        current_body = abs(closes[t] - opens[t])
        if closes[t] < opens[t] and (current_range >= 3.0 * average_range or current_body >= 3.0 * average_body):
            short_entries[t] = True
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'black_long_day_short', 'hypothesis': '陰線長日形態後市場走弱，採用短倉。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_TCSample'], 'signal_parameter_sets': [{'i_TCSample': 14}]}
