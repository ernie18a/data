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
    if period < 1:
        raise ValueError('ma_length must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    if values.size >= period:
        cumulative = np.concatenate(([0.0], np.cumsum(values, dtype=float)))
        result[period - 1:] = (cumulative[period:] - cumulative[:-period]) / period
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if any((series.size != size for series in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must equal features.market.size')
    params = dict(signal_params or {})
    ma_length = int(params.get('ma_length', 20))
    engulfing_mode = str(params.get('engulfing_mode', 'BODY')).upper()
    inclusive_engulfing = bool(params.get('inclusive_engulfing', False))
    if engulfing_mode not in {'BODY', 'RANGE', 'BOTH'}:
        raise ValueError('engulfing_mode must be BODY, RANGE, or BOTH')
    ma = _sma(closes, ma_length)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size > 1:
        previous_bearish = closes[1:] < opens[1:]
        current_bullish = closes[1:] > opens[1:]
        if engulfing_mode in {'BODY', 'BOTH'}:
            current_body_high = np.maximum(opens[1:], closes[1:])
            current_body_low = np.minimum(opens[1:], closes[1:])
            previous_body_high = np.maximum(opens[:-1], closes[:-1])
            previous_body_low = np.minimum(opens[:-1], closes[:-1])
            if inclusive_engulfing:
                body_engulfing = (current_body_high >= previous_body_high) & (current_body_low <= previous_body_low)
            else:
                body_engulfing = (current_body_high > previous_body_high) & (current_body_low < previous_body_low)
        else:
            body_engulfing = np.zeros(size - 1, dtype=np.bool_)
        if engulfing_mode in {'RANGE', 'BOTH'}:
            if inclusive_engulfing:
                range_engulfing = (highs[1:] >= highs[:-1]) & (lows[1:] <= lows[:-1])
            else:
                range_engulfing = (highs[1:] > highs[:-1]) & (lows[1:] < lows[:-1])
        else:
            range_engulfing = np.zeros(size - 1, dtype=np.bool_)
        short_entries[1:] = previous_bearish & current_bullish & (body_engulfing | range_engulfing) & (closes[1:] > ma[1:])
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'last_engulfing_top_short', 'hypothesis': '上行趨勢中的最後吞沒頂形態可能反轉，做空以捕捉回落。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'engulfing_mode', 'inclusive_engulfing', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'engulfing_mode': 'BODY', 'inclusive_engulfing': False, 'k_base': 2.0, 'mult': 2.0}]}
