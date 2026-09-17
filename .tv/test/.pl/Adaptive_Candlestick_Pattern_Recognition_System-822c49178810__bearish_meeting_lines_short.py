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

def _as_series(market, name, size):
    values = np.asarray(getattr(market, name), dtype=float).reshape(-1)
    if values.size != size:
        raise ValueError(f'features.market.{name} must match features.market.size')
    return values

def _prior_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for t in range(window, values.size):
        sample = values[t - window:t]
        if np.all(np.isfinite(sample)):
            result[t] = np.mean(sample)
    return result

def _sma(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for t in range(window - 1, values.size):
        sample = values[t - window + 1:t + 1]
        if np.all(np.isfinite(sample)):
            result[t] = np.mean(sample)
    return result

def generate_signals(features, signal_params):
    params = dict(signal_params or {})
    market = features.market
    size = int(market.size)
    opens = _as_series(market, 'opens', size)
    highs = _as_series(market, 'highs', size)
    lows = _as_series(market, 'lows', size)
    closes = _as_series(market, 'closes', size)
    sample = int(params.get('i_TCSample', 14))
    setting = str(params.get('i_TCSetting', 'RANGE')).upper()
    tall_tolerance = float(params.get('i_TCTol', 1.5))
    lines_tolerance = float(params.get('i_LinesTol', 0.05))
    ma_length = int(params.get('ma_length', 20))
    if sample < 1 or ma_length < 1:
        raise ValueError('i_TCSample and ma_length must be positive')
    if setting not in ('RANGE', 'BODY'):
        raise ValueError("i_TCSetting must be 'RANGE' or 'BODY'")
    if not np.isfinite(tall_tolerance) or tall_tolerance <= 0.0:
        raise ValueError('i_TCTol must be finite and positive')
    if not np.isfinite(lines_tolerance) or lines_tolerance < 0.0:
        raise ValueError('i_LinesTol must be finite and non-negative')
    candle_range = highs - lows
    candle_body = np.abs(closes - opens)
    candle_size = candle_range if setting == 'RANGE' else candle_body
    prior_size_mean = _prior_mean(candle_size, sample)
    is_tall = np.isfinite(candle_size) & np.isfinite(prior_size_mean) & (candle_size >= tall_tolerance * prior_size_mean)
    moving_average = _sma(closes, ma_length)
    uptrend = np.isfinite(closes) & np.isfinite(moving_average) & (closes > moving_average)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size >= 2:
        previous = slice(None, -1)
        current = slice(1, None)
        close_high = closes[previous] + lines_tolerance * candle_range[previous]
        close_low = closes[previous] - lines_tolerance * candle_range[previous]
        short_entries[1:] = (closes[previous] > opens[previous]) & (closes[current] < opens[current]) & is_tall[previous] & is_tall[current] & np.isfinite(candle_range[previous]) & (candle_range[previous] >= 0.0) & np.isfinite(closes[current]) & (closes[current] >= close_low) & (closes[current] <= close_high) & uptrend[current]
    exit_params = dict(params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (long_entries.reshape(-1).astype(np.bool_, copy=False), np.asarray(long_exits, dtype=np.bool_).reshape(-1), short_entries.reshape(-1).astype(np.bool_, copy=False), np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'bearish_meeting_lines_short', 'hypothesis': '上行動態 MA 中，兩根高波動且收盤相近的陰陽反轉線可能預示下跌。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_TCSample', 'i_TCSetting', 'i_TCTol', 'i_LinesTol', 'ma_length'], 'signal_parameter_sets': [{'i_TCSample': 14, 'i_TCSetting': 'RANGE', 'i_TCTol': 1.5, 'i_LinesTol': 0.05, 'ma_length': 20}]}
