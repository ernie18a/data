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

def _sma(values, length):
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
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, long_entries.copy(), short_entries, short_entries.copy())
    market = features.market
    opens = _series(market, 'opens', size)
    highs = _series(market, 'highs', size)
    lows = _series(market, 'lows', size)
    closes = _series(market, 'closes', size)
    params = dict(signal_params or {})
    ma_length = int(params.get('ma_length', 20))
    if ma_length < 1:
        raise ValueError('ma_length must be positive')
    moving_average = _sma(closes, ma_length)
    candle_range = highs - lows
    body_size = np.abs(closes - opens)
    body_position = ((opens + closes) * 0.5 - lows) / candle_range
    upper_shadow = highs - np.maximum(opens, closes)
    lower_shadow = np.minimum(opens, closes) - lows
    finite_ohlc = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    inverted_hammer = finite_ohlc & (candle_range > 0.0) & (body_size > 0.0) & np.isfinite(body_position) & (body_position <= 0.5) & (upper_shadow >= 3.0 * body_size) & (lower_shadow <= 0.35 * body_size)
    uptrend_before_pattern = np.zeros(size, dtype=np.bool_)
    if size >= 3:
        uptrend_before_pattern[2:] = np.isfinite(closes[:-2]) & np.isfinite(moving_average[:-2]) & (closes[:-2] > moving_average[:-2])
        short_entries[2:] = (closes[1:-1] > opens[1:-1]) & inverted_hammer[2:] & uptrend_before_pattern[2:]
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, params)
    return (long_entries.astype(np.bool_, copy=False), np.asarray(long_exits, dtype=np.bool_).reshape(-1), short_entries.astype(np.bool_, copy=False), np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'shooting_star_two_lines_short', 'hypothesis': '上行動態 MA 中，前一根陽線後形成具長上影線的倒錘形，可能預示空頭反轉。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'k_base': 2.0, 'mult': 2.0}]}
