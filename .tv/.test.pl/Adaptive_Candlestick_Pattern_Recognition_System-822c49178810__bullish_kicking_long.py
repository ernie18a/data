def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    mult = float(signal_params.get('mult', 2.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    entry_price = 0.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif closes[t] >= entry_price + mult * atr[t]:
                long_exits[t] = True
                position = 0
            elif closes[t] < entry_price - mult * atr[t]:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif closes[t] <= entry_price - mult * atr[t]:
                short_exits[t] = True
                position = 0
            elif closes[t] > entry_price + mult * atr[t]:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                entry_price = closes[t]
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                entry_price = closes[t]
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
    return (long_exits, short_exits)
import numpy as np

def _tall_mask(values, sample_size, multiplier):
    values = np.asarray(values, dtype=float)
    size = values.size
    result = np.zeros(size, dtype=np.bool_)
    for index in range(sample_size, size):
        window = values[index - sample_size:index]
        if np.all(np.isfinite(window)) and np.isfinite(values[index]):
            baseline = float(np.mean(window))
            result[index] = values[index] >= multiplier * baseline
    return result

def generate_signals(features, signal_params):
    size = features.market.size
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    sample_size = int(signal_params.get('sample_size', 14))
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    tall_measure = str(signal_params.get('tall_measure', 'range')).lower()
    marubozu_type = str(signal_params.get('marubozu_type', 'exclusive')).lower()
    require_gap = bool(signal_params.get('require_gap', True))
    if sample_size < 1 or tall_multiplier <= 0.0:
        raise ValueError('sample_size and tall_multiplier must be positive')
    if tall_measure not in ('range', 'body'):
        raise ValueError("tall_measure must be 'range' or 'body'")
    if marubozu_type not in ('exclusive', 'inclusive'):
        raise ValueError("marubozu_type must be 'exclusive' or 'inclusive'")
    measure = highs - lows if tall_measure == 'range' else np.abs(closes - opens)
    tall = _tall_mask(measure, sample_size, tall_multiplier)
    bullish = closes >= opens
    bearish = closes < opens
    if marubozu_type == 'exclusive':
        bullish_maru = bullish & (lows == opens) & (highs == closes)
        bearish_maru = bearish & (highs == opens) & (lows == closes)
    else:
        bullish_maru = bullish & ((lows == opens) | (highs == closes))
        bearish_maru = bearish & ((highs == opens) | (lows == closes))
    long_entries = np.zeros(size, dtype=np.bool_)
    if size > 1:
        long_entries[1:] = bearish_maru[:-1] & bullish_maru[1:] & tall[:-1] & tall[1:]
        if require_gap:
            long_entries[1:] &= lows[1:] > highs[:-1]
    short_entries = np.zeros(size, dtype=np.bool_)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_kicking_long', 'hypothesis': '高波動陰性 Marubozu 後接高波動陽性 Marubozu，尤其在向上缺口時，可能預示多方延續。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['sample_size', 'tall_multiplier', 'tall_measure', 'marubozu_type', 'require_gap'], 'signal_parameter_sets': [{'sample_size': 14, 'tall_multiplier': 1.5, 'tall_measure': 'range', 'marubozu_type': 'exclusive', 'require_gap': True}, {'sample_size': 14, 'tall_multiplier': 1.5, 'tall_measure': 'range', 'marubozu_type': 'exclusive', 'require_gap': False}, {'sample_size': 14, 'tall_multiplier': 1.5, 'tall_measure': 'range', 'marubozu_type': 'inclusive', 'require_gap': True}, {'sample_size': 14, 'tall_multiplier': 1.5, 'tall_measure': 'range', 'marubozu_type': 'inclusive', 'require_gap': False}]}
