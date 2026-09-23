import numpy as np

def generate_entries(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=bool)
    short_entries = np.zeros(size, dtype=bool)
    return (long_entries, short_entries)

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
    n_base = float(signal_params.get('n_base', 20.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    cum_vol = 0.0
    target_vol = 0.0
    entry_atr = 1.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif cum_vol >= target_vol * (entry_atr / max(1e-06, atr[t])) ** gamma:
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
            elif cum_vol >= target_vol * (entry_atr / max(1e-06, atr[t])) ** gamma:
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
                target_vol = n_base * max(1e-06, float(np.mean(volumes[max(0, t - 19):t + 1])))
                entry_atr = max(1e-06, atr[t])
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
                cum_vol = volumes[t]
                target_vol = n_base * max(1e-06, float(np.mean(volumes[max(0, t - 19):t + 1])))
                entry_atr = max(1e-06, atr[t])
    return (long_exits, short_exits)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)

def iter_signal_parameter_sets():
    from itertools import product
    for values in product(*[]):
        yield dict(zip([], values))
STRATEGY = {'strategy_id': 'intraday_r_breaker', 'hypothesis': '以前一交易日高低價與前收計算 R-Breaker 水位，捕捉觀察線反轉或突破線突破。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': [], 'signal_parameter_sets': iter_signal_parameter_sets}
