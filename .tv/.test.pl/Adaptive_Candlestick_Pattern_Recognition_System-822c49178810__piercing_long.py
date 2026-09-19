import numpy as np

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

def _sma(values, period):
    if period <= 0:
        raise ValueError('ma_length must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    if values.size >= period:
        result[period - 1:] = np.convolve(values, np.ones(period, dtype=float), mode='valid') / period
    return result

def generate_signals(features, signal_params):
    params = {'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}
    if signal_params:
        params.update(signal_params)
    market = features.market
    size = int(market.size)
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if any((values.size != size for values in (opens, lows, closes))):
        raise ValueError('market arrays must match features.market.size')
    ma = _sma(closes, int(params['ma_length']))
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size > 1:
        previous_bearish = closes[:-1] < opens[:-1]
        current_bullish = closes[1:] > opens[1:]
        opens_below_previous_low = opens[1:] < lows[:-1]
        closes_above_midpoint = closes[1:] > (opens[:-1] + closes[:-1]) / 2.0
        closes_below_previous_open = closes[1:] < opens[:-1]
        downtrend = closes[:-1] < ma[:-1]
        long_entries[1:] = previous_bearish & current_bullish & opens_below_previous_low & closes_above_midpoint & closes_below_previous_open & downtrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'piercing_long', 'hypothesis': '下行 MA 趨勢中的 Piercing 形態，預期價格反轉上行。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
