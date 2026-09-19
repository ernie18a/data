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
    closes = np.asarray(features.market.closes, dtype=float)
    ema_length = int(signal_params['emaLength'])
    if ema_length < 1:
        raise ValueError('emaLength must be positive')
    if size:
        ema = np.empty(size, dtype=float)
        ema[0] = closes[0]
        alpha = 2.0 / (ema_length + 1.0)
        for t in range(1, size):
            ema[t] = alpha * closes[t] + (1.0 - alpha) * ema[t - 1]
        if size > 1:
            long_entries[1:] = (closes[1:] > ema[1:]) & (closes[:-1] <= ema[:-1])
            short_entries[1:] = (closes[1:] < ema[1:]) & (closes[:-1] >= ema[:-1])
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'ema_trend_flip', 'hypothesis': '價格穿越 EMA 時的方向翻轉可捕捉短期趨勢起始段。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['emaLength', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'emaLength': 9, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
