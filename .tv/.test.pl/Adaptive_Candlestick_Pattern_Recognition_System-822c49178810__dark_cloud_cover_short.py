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

def _sma(values, length):
    if length < 1:
        raise ValueError('ma_length must be positive')
    result = np.full(values.size, np.nan, dtype=np.float64)
    if values.size >= length:
        cumulative = np.cumsum(values, dtype=np.float64)
        previous = np.concatenate(([0.0], cumulative[:-length]))
        result[length - 1:] = (cumulative[length - 1:] - previous) / float(length)
    return result

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    opens = np.asarray(market.opens, dtype=np.float64).reshape(-1)
    highs = np.asarray(market.highs, dtype=np.float64).reshape(-1)
    lows = np.asarray(market.lows, dtype=np.float64).reshape(-1)
    closes = np.asarray(market.closes, dtype=np.float64).reshape(-1)
    if any((series.size != size for series in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match market.size')
    params = dict(signal_params or {})
    sample = int(params.get('i_TCSample', 14))
    tolerance = float(params.get('i_TCTol', 1.5))
    setting = str(params.get('i_TCSetting', 'RANGE')).upper()
    ma_length = int(params.get('ma_length', 20))
    k_base = float(params.get('k_base', 2.0))
    mult = float(params.get('mult', 2.0))
    if sample < 1 or ma_length < 1:
        raise ValueError('i_TCSample and ma_length must be positive')
    if setting not in ('RANGE', 'BODY'):
        raise ValueError('i_TCSetting must be RANGE or BODY')
    if not np.isfinite(tolerance) or tolerance <= 0.0:
        raise ValueError('i_TCTol must be finite and positive')
    if not np.isfinite(k_base) or k_base <= 0.0:
        raise ValueError('k_base must be finite and positive')
    if not np.isfinite(mult) or mult <= 0.0:
        raise ValueError('mult must be finite and positive')
    candle_size = highs - lows if setting == 'RANGE' else np.abs(closes - opens)
    moving_average = _sma(closes, ma_length)
    trend_up = np.isfinite(closes) & np.isfinite(moving_average) & (closes > moving_average)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for t in range(sample + 1, size):
        previous = t - 1
        baseline = candle_size[t - 1 - sample:t - 1]
        if not np.all(np.isfinite(baseline)) or not np.isfinite(candle_size[previous]):
            continue
        tall_previous = candle_size[previous] >= tolerance * float(np.mean(baseline))
        pattern = np.isfinite(opens[previous]) and np.isfinite(highs[previous]) and np.isfinite(closes[previous]) and np.isfinite(opens[t]) and np.isfinite(closes[t]) and (closes[previous] >= opens[previous]) and tall_previous and (closes[t] < opens[t]) and (opens[t] > highs[previous]) and (closes[t] < (opens[previous] + closes[previous]) * 0.5) and (closes[t] > opens[previous]) and trend_up[t]
        short_entries[t] = bool(pattern)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, params)
    return (long_entries.astype(np.bool_, copy=False), np.asarray(long_exits, dtype=np.bool_).reshape(-1), short_entries.astype(np.bool_, copy=False), np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'dark_cloud_cover_short', 'hypothesis': '上行趨勢中的 Dark Cloud Cover 可能預示空頭反轉，捕捉後續下跌。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_TCSample', 'i_TCTol', 'i_TCSetting', 'ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'i_TCSample': 14, 'i_TCTol': 1.5, 'i_TCSetting': 'RANGE', 'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
