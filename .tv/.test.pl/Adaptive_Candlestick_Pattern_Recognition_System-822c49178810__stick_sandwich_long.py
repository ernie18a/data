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

def _series(market, name, size):
    values = np.asarray(getattr(market, name), dtype=float).reshape(-1)
    if values.size != size:
        raise ValueError(f'features.market.{name} must match features.market.size')
    return values

def _sma(values, length):
    if length < 1:
        raise ValueError('ma_length must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    market = features.market
    params = dict(signal_params or {})
    opens = _series(market, 'opens', size)
    closes = _series(market, 'closes', size)
    tolerance = float(params.get('i_StickSandTol', 0.1))
    ma_length = int(params.get('ma_length', 20))
    if not np.isfinite(tolerance) or tolerance < 0.0:
        raise ValueError('i_StickSandTol must be finite and non-negative')
    if ma_length < 1:
        raise ValueError('ma_length must be positive')
    moving_average = _sma(closes, ma_length)
    finite = np.isfinite(opens) & np.isfinite(closes) & np.isfinite(moving_average)
    downtrend = finite & (closes <= moving_average)
    long_entries = np.zeros(size, dtype=np.bool_)
    if size >= 3:
        first = np.arange(size - 2)
        second = first + 1
        third = first + 2
        first_body = np.abs(closes[first] - opens[first])
        lower = closes[first] - tolerance * first_body
        upper = closes[first] + tolerance * first_body
        pattern = finite[first] & finite[second] & finite[third] & downtrend[third] & (closes[first] < opens[first]) & (closes[second] > opens[second]) & (closes[second] > opens[first]) & (closes[third] < opens[third]) & (closes[third] > lower) & (closes[third] < upper)
        long_entries[2:] = pattern
    short_entries = np.zeros(size, dtype=np.bool_)
    exit_params = dict(params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (np.asarray(long_entries, dtype=np.bool_).reshape(-1), np.asarray(long_exits, dtype=np.bool_).reshape(-1), np.asarray(short_entries, dtype=np.bool_).reshape(-1), np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'stick_sandwich_long', 'hypothesis': '下行動態 MA 中的 Stick Sandwich 形態可能預示多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_StickSandTol', 'ma_length'], 'signal_parameter_sets': [{'i_StickSandTol': 0.1, 'ma_length': 20}]}
