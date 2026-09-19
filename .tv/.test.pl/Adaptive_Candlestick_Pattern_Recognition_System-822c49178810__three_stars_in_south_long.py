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
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _series(market, name, size):
    values = np.asarray(getattr(market, name), dtype=float).reshape(-1)
    if values.size != size:
        raise ValueError(f'features.market.{name} must match features.market.size')
    return values

def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    market = features.market
    params = dict(signal_params or {})
    opens = _series(market, 'opens', size)
    highs = _series(market, 'highs', size)
    lows = _series(market, 'lows', size)
    closes = _series(market, 'closes', size)
    sit_candle1 = float(params.get('i_SITSCandle1', 0.6))
    sit_candle2 = float(params.get('i_SITSCandle2', 0.2))
    sit_candle2_max_prop = float(params.get('i_SITSC2MaxProp', 0.75))
    ma_length = int(params.get('ma_length', 20))
    maru_type = str(params.get('i_MaruType', 'EXCLUSIVE')).upper()
    if not np.isfinite(sit_candle1):
        raise ValueError('i_SITSCandle1 must be finite')
    if not np.isfinite(sit_candle2) or sit_candle2 < 0.0:
        raise ValueError('i_SITSCandle2 must be finite and non-negative')
    if not np.isfinite(sit_candle2_max_prop) or sit_candle2_max_prop < 0.0:
        raise ValueError('i_SITSC2MaxProp must be finite and non-negative')
    if maru_type not in ('EXCLUSIVE', 'INCLUSIVE'):
        raise ValueError('i_MaruType must be EXCLUSIVE or INCLUSIVE')
    moving_average = _sma(closes, ma_length)
    candle_range = highs - lows
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & (candle_range > 0.0)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for t in range(2, size):
        first = t - 2
        second = t - 1
        trend_index = t - 3
        if trend_index < 0 or not (finite[first] and finite[second] and finite[t]):
            continue
        if not np.isfinite(moving_average[trend_index]):
            continue
        first_body = closes[first] - opens[first]
        second_body = closes[second] - opens[second]
        third_body = closes[t] - opens[t]
        if not (first_body < 0.0 and second_body < 0.0 and (third_body < 0.0)):
            continue
        first_position = ((opens[first] + closes[first]) * 0.5 - lows[first]) / candle_range[first]
        second_position = ((opens[second] + closes[second]) * 0.5 - lows[second]) / candle_range[second]
        first_body_ratio = first_body / candle_range[first]
        second_body_ratio = second_body / candle_range[second]
        second_position_valid = second_position >= first_position * (1.0 - sit_candle2) and second_position <= first_position * (1.0 + sit_candle2)
        second_body_valid = second_body_ratio >= first_body_ratio * (1.0 - sit_candle2) and second_body_ratio <= first_body_ratio * (1.0 + sit_candle2)
        if maru_type == 'EXCLUSIVE':
            third_is_maru = opens[t] == highs[t] and closes[t] == lows[t]
        else:
            third_is_maru = opens[t] == highs[t] or closes[t] == lows[t]
        long_entries[t] = bool(first_position >= sit_candle1 and second_position_valid and second_body_valid and (lows[second] > lows[first]) and (candle_range[second] / candle_range[first] <= sit_candle2_max_prop) and third_is_maru and (lows[second] < lows[t] < highs[second]) and (lows[second] < highs[t] < highs[second]) and (closes[trend_index] <= moving_average[trend_index]))
    exit_params = dict(params)
    exit_params['k_base'] = 2.0
    exit_params['mult'] = 2.0
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_).reshape(-1), short_entries, np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'three_stars_in_south_long', 'hypothesis': '下行動態 MA 中的 Three Stars in the South 形態可能預示多頭反轉。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_SITSCandle1', 'i_SITSCandle2', 'i_SITSC2MaxProp', 'ma_length', 'i_MaruType'], 'signal_parameter_sets': [{'i_SITSCandle1': 0.6, 'i_SITSCandle2': 0.2, 'i_SITSC2MaxProp': 0.75, 'ma_length': 20, 'i_MaruType': 'EXCLUSIVE'}]}
