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

def _read_consensus_down(features, size):
    owners = (features, getattr(features, 'market', None))
    names = ('_cDn', 'cDn', 'c_dn', 'consensus_down', 'down_consensus', 'bearish_consensus_count')
    for owner in owners:
        if owner is None:
            continue
        for name in names:
            if not hasattr(owner, name):
                continue
            value = getattr(owner, name)
            if callable(value):
                value = value()
            try:
                array = np.asarray(value, dtype=float)
            except (TypeError, ValueError):
                continue
            if array.ndim == 1 and array.size == size:
                return array
    raise AttributeError('features 必須提供六尺度下行共識計數 _cDn 或 cDn')

def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    consensus_down = _read_consensus_down(features, size)
    short_entries = np.zeros(size, dtype=np.bool_)
    current_is_five = np.isfinite(consensus_down) & (consensus_down == 5.0)
    if size > 1:
        previous = consensus_down[:-1]
        previous_is_not_five = np.isfinite(previous) & (previous != 5.0)
        short_entries[1:] = current_is_five[1:] & previous_is_not_five
    long_entries = empty.copy()
    params = dict(signal_params or {})
    params.setdefault('k_base', 2.0)
    params.setdefault('gamma', 1.0)
    params.setdefault('n_base', 2000.0)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'strong_bearish_scale_consensus', 'hypothesis': '六尺度中恰有五個結構方向看跌時，捕捉新形成的強烈看空共識。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
