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

def _series(value, size):
    try:
        result = np.asarray(value, dtype=float)
    except (TypeError, ValueError):
        return None
    if result.ndim != 1 or result.size != size:
        return None
    return result

def _market_series(market, names, size):
    for name in names:
        if not hasattr(market, name):
            continue
        value = getattr(market, name)
        if callable(value):
            try:
                value = value()
            except TypeError:
                continue
        result = _series(value, size)
        if result is not None:
            return result
    raise ValueError('market 缺少所需的一維數列')

def _feature_indicator(features, name, length, size):
    method = getattr(features, name, None)
    if not callable(method):
        return None
    argument_sets = [(length,)]
    market_closes = getattr(features.market, 'closes', None)
    if market_closes is not None:
        argument_sets.append((market_closes, length))
    for arguments in argument_sets:
        try:
            result = _series(method(*arguments), size)
        except (AttributeError, TypeError, ValueError):
            continue
        if result is not None:
            return result
    return None

def _ema_array(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length < 1 or values.size < length:
        return result
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
            break
    finite_result = np.flatnonzero(np.isfinite(result))
    if finite_result.size == 0:
        return result
    first = int(finite_result[0])
    alpha = 2.0 / (length + 1.0)
    for index in range(first + 1, values.size):
        if np.isfinite(values[index]) and np.isfinite(result[index - 1]):
            result[index] = alpha * values[index] + (1.0 - alpha) * result[index - 1]
    return result

def _ema(features, closes, length):
    result = _feature_indicator(features, 'ema', length, closes.size)
    return result if result is not None else _ema_array(closes, length)

def _rsi_array(closes, length):
    result = np.full(closes.size, np.nan, dtype=float)
    if length < 1 or closes.size <= length:
        return result
    changes = np.diff(closes)
    if not np.all(np.isfinite(changes[:length])):
        return result
    gains = np.maximum(changes, 0.0)
    losses = np.maximum(-changes, 0.0)
    average_gain = float(np.mean(gains[:length]))
    average_loss = float(np.mean(losses[:length]))
    if average_loss == 0.0:
        result[length] = 100.0 if average_gain > 0.0 else 50.0
    else:
        relative_strength = average_gain / average_loss
        result[length] = 100.0 - 100.0 / (1.0 + relative_strength)
    for index in range(length + 1, closes.size):
        if not np.isfinite(changes[index - 1]):
            continue
        average_gain = (average_gain * (length - 1.0) + gains[index - 1]) / length
        average_loss = (average_loss * (length - 1.0) + losses[index - 1]) / length
        if average_loss == 0.0:
            result[index] = 100.0 if average_gain > 0.0 else 50.0
        else:
            relative_strength = average_gain / average_loss
            result[index] = 100.0 - 100.0 / (1.0 + relative_strength)
    return result

def _rsi(features, closes, length):
    result = _feature_indicator(features, 'rsi', length, closes.size)
    return result if result is not None else _rsi_array(closes, length)

def _vwap(features, market, closes, volumes):
    size = closes.size
    for owner in (features, market):
        for name in ('session_vwap', 'futures_session_vwap', 'vwap'):
            if not hasattr(owner, name):
                continue
            value = getattr(owner, name)
            if callable(value):
                try:
                    value = value()
                except TypeError:
                    continue
            result = _series(value, size)
            if result is not None:
                return result
    raw_starts = getattr(market, 'session_starts', None)
    starts = _series(raw_starts, size) if raw_starts is not None else None
    result = np.full(size, np.nan, dtype=float)
    volume_sum = 0.0
    price_volume_sum = 0.0
    for index in range(size):
        new_session = index == 0
        if starts is not None:
            if np.asarray(raw_starts).dtype == np.bool_:
                new_session = new_session or bool(starts[index])
            else:
                new_session = new_session or int(starts[index]) == index
        if new_session:
            volume_sum = 0.0
            price_volume_sum = 0.0
        if np.isfinite(closes[index]) and np.isfinite(volumes[index]) and (volumes[index] > 0.0):
            volume_sum += volumes[index]
            price_volume_sum += closes[index] * volumes[index]
        if volume_sum > 0.0:
            result[index] = price_volume_sum / volume_sum
    return result

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    params = dict(signal_params or {})
    ema_fast_length = max(2, int(params.get('ema_fast', 9)))
    ema_medium_length = max(2, int(params.get('ema_medium', 21)))
    ema_slow_length = max(2, int(params.get('ema_slow', 50)))
    macd_fast_length = max(2, int(params.get('macd_fast', 12)))
    macd_slow_length = max(2, int(params.get('macd_slow', 26)))
    macd_signal_length = max(2, int(params.get('macd_signal', 9)))
    rsi_length = max(2, int(params.get('rsi_length', 14)))
    rsi_oversold = float(params.get('rsi_oversold', 30.0))
    rsi_overbought = float(params.get('rsi_overbought', 70.0))
    closes = _market_series(market, ('closes', 'close'), size)
    volumes = _market_series(market, ('volumes', 'volume'), size)
    ema_fast = _ema(features, closes, ema_fast_length)
    ema_medium = _ema(features, closes, ema_medium_length)
    ema_slow = _ema(features, closes, ema_slow_length)
    macd_fast = _ema(features, closes, macd_fast_length)
    macd_slow = _ema(features, closes, macd_slow_length)
    macd_line = macd_fast - macd_slow
    macd_signal = _ema_array(macd_line, macd_signal_length)
    macd_histogram = macd_line - macd_signal
    rsi = _rsi(features, closes, rsi_length)
    vwap = _vwap(features, market, closes, volumes)
    previous_ema_fast = np.roll(ema_fast, 1)
    previous_ema_medium = np.roll(ema_medium, 1)
    previous_histogram = np.roll(macd_histogram, 1)
    previous_rsi = np.roll(rsi, 1)
    previous_ema_fast[0] = np.nan
    previous_ema_medium[0] = np.nan
    previous_histogram[0] = np.nan
    previous_rsi[0] = np.nan
    long_entries = (ema_fast > ema_medium) & (ema_medium > ema_slow) & (closes > ema_slow) & (previous_ema_fast <= previous_ema_medium) & (macd_histogram > 0.0) & (macd_histogram > previous_histogram) & (macd_line >= 0.0) & (closes > vwap) & (previous_rsi <= rsi_oversold) & (rsi > rsi_oversold)
    short_entries = (ema_fast < ema_medium) & (ema_medium < ema_slow) & (closes < ema_slow) & (previous_ema_fast >= previous_ema_medium) & (macd_histogram < 0.0) & (macd_histogram < previous_histogram) & (macd_line < 0.0) & (closes < vwap) & (previous_rsi >= rsi_overbought) & (rsi < rsi_overbought)
    long_entries = np.asarray(long_entries, dtype=np.bool_)
    short_entries = np.asarray(short_entries, dtype=np.bool_)
    conflicting = long_entries & short_entries
    long_entries[conflicting] = False
    short_entries[conflicting] = False
    exit_params = {'k_base': float(params.get('k_base', 2.0)), 'gamma': float(params.get('gamma', 1.0)), 'n_base': float(params.get('n_base', 2000.0))}
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'ema_macd_rsi_vwap_confluence', 'hypothesis': 'EMA 趨勢排列下，MACD、VWAP 與 RSI 同步確認可提高順勢訊號品質。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['ema_fast', 'ema_medium', 'ema_slow', 'macd_fast', 'macd_slow', 'macd_signal', 'rsi_length', 'rsi_oversold', 'rsi_overbought', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'ema_fast': 9, 'ema_medium': 21, 'ema_slow': 50, 'macd_fast': 12, 'macd_slow': 26, 'macd_signal': 9, 'rsi_length': 14, 'rsi_oversold': 30.0, 'rsi_overbought': 70.0, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
