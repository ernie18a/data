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

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    tall_window = 14
    tall_multiplier = 1.5
    ranges = highs - lows
    prefix = np.concatenate((np.zeros(1, dtype=float), np.cumsum(ranges)))
    tall = np.zeros(size, dtype=np.bool_)
    if size > tall_window:
        previous_mean = (prefix[tall_window:size] - prefix[:size - tall_window]) / tall_window
        tall[tall_window:] = ranges[tall_window:] >= tall_multiplier * previous_mean
    bullish_marubozu = (closes >= opens) & (lows == np.minimum(opens, closes)) & (highs == np.maximum(opens, closes))
    bearish_marubozu = (closes < opens) & (lows == np.minimum(opens, closes)) & (highs == np.maximum(opens, closes))
    require_gap = bool(signal_params.get('require_gap', True))
    if size >= 2:
        short_entries[1:] = tall[:-1] & tall[1:] & bullish_marubozu[:-1] & bearish_marubozu[1:] & (highs[1:] < lows[:-1] if require_gap else True)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bearish_kicking_short', 'hypothesis': '高波動看跌 Kicking 形態後做空，預期缺口反轉延續下跌。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['require_gap', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'require_gap': True, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
