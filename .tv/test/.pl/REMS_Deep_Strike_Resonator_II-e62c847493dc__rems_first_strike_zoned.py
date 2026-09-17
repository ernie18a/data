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

def _rolling(values, window, operation):
    result = np.full(values.size, np.nan, dtype=float)
    if window <= 0:
        return result
    for index in range(window - 1, values.size):
        part = values[index - window + 1:index + 1]
        if not np.all(np.isfinite(part)):
            continue
        if operation == 'mean':
            result[index] = np.mean(part)
        elif operation == 'std':
            result[index] = np.std(part, ddof=0)
        elif operation == 'min':
            result[index] = np.min(part)
        elif operation == 'max':
            result[index] = np.max(part)
    return result

def _wma(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    weights = np.arange(1, window + 1, dtype=float)
    denominator = float(np.sum(weights))
    for index in range(window - 1, values.size):
        part = values[index - window + 1:index + 1]
        if np.all(np.isfinite(part)):
            result[index] = float(np.dot(part, weights) / denominator)
    return result

def _ema(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    finite = np.flatnonzero(np.isfinite(values))
    if finite.size == 0:
        return result
    first = int(finite[0])
    result[first] = values[first]
    alpha = 2.0 / (length + 1.0)
    for index in range(first + 1, values.size):
        if np.isfinite(values[index]):
            result[index] = alpha * values[index] + (1.0 - alpha) * result[index - 1]
    return result

def _cross(left, right):
    result = np.zeros(left.size, dtype=np.bool_)
    if left.size < 2:
        return result
    usable = np.isfinite(left[1:]) & np.isfinite(right[1:]) & np.isfinite(left[:-1]) & np.isfinite(right[:-1])
    result[1:] = usable & ((left[1:] > right[1:]) & (left[:-1] <= right[:-1]) | (left[1:] < right[1:]) & (left[:-1] >= right[:-1]))
    return result

def _stoch_rsi(rsi, rsi_window=8, k_window=3, d_window=3):
    lows = _rolling(rsi, rsi_window, 'min')
    highs = _rolling(rsi, rsi_window, 'max')
    denominator = np.maximum(highs - lows, 1e-10)
    raw = np.full(rsi.size, np.nan, dtype=float)
    usable = np.isfinite(rsi) & np.isfinite(lows) & np.isfinite(highs)
    raw[usable] = (rsi[usable] - lows[usable]) / denominator[usable] * 100.0
    k = _rolling(raw, k_window, 'mean')
    d = _rolling(k, d_window, 'mean')
    return (k, d)

def _session_vwap(market):
    closes = np.asarray(market.closes, dtype=float)
    volumes = np.asarray(market.volumes, dtype=float)
    result = np.full(closes.size, np.nan, dtype=float)
    starts = getattr(market, 'session_starts', None)
    price_volume = 0.0
    volume_sum = 0.0
    for index in range(closes.size):
        if starts is not None and index == int(starts[index]):
            price_volume = 0.0
            volume_sum = 0.0
        price_volume += closes[index] * volumes[index]
        volume_sum += volumes[index]
        if volume_sum > 0.0:
            result[index] = price_volume / volume_sum
    return result

def _range_bounds(features, range_mode):
    market = features.market
    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    if range_mode == 'Donchian':
        return (_rolling(highs, 25, 'max'), _rolling(lows, 25, 'min'))
    if range_mode == 'Bollinger':
        basis = _wma(closes, 21)
        deviation = _rolling(closes, 21, 'std')
        return (basis + 2.0 * deviation, basis - 2.0 * deviation)
    if range_mode == 'Keltner Channels':
        basis = np.asarray(features.ema(21), dtype=float)
        width = 2.0 * np.asarray(features.atr(10), dtype=float)
        return (basis + width, basis - width)
    if range_mode == 'VWAP Bands':
        basis = _session_vwap(market)
        deviation = _rolling(closes, 21, 'std')
        return (basis + deviation, basis - deviation)
    return (np.full(closes.size, np.nan), np.full(closes.size, np.nan))

def _zone_blocks(features, range_mode):
    market = features.market
    closes = np.asarray(market.closes, dtype=float)
    upper, lower = _range_bounds(features, range_mode)
    size = closes.size
    block_long = np.zeros(size, dtype=np.bool_)
    block_short = np.zeros(size, dtype=np.bool_)
    usable = np.isfinite(upper) & np.isfinite(lower)
    width = np.maximum(upper - lower, 1e-12)
    short_start = upper - width * 0.35
    long_end = lower + width * 0.35
    in_long = usable & (closes <= long_end)
    in_short = usable & (closes >= short_start)
    block_long[usable] = ~in_long[usable]
    block_short[usable] = ~in_short[usable]
    block_long[~usable] = True
    block_short[~usable] = True
    return (block_long, block_short)

def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    params = signal_params or {}
    rsi = np.asarray(features.rsi(14), dtype=float)
    rsi_ma = _rolling(rsi, 20, 'mean')
    ema_fast = np.asarray(features.ema(8), dtype=float)
    ema_slow = np.asarray(features.ema(21), dtype=float)
    macd_line = np.asarray(features.ema(12), dtype=float) - np.asarray(features.ema(26), dtype=float)
    macd_signal = _ema(macd_line, 9)
    macd_hist = macd_line - macd_signal
    stoch_k, stoch_d = _stoch_rsi(rsi)
    previous_rsi = np.full(size, np.nan, dtype=float)
    previous_rsi[1:] = rsi[:-1]
    previous_hist = np.full(size, np.nan, dtype=float)
    previous_hist[1:] = macd_hist[:-1]
    finite_rsi = np.isfinite(rsi) & np.isfinite(previous_rsi)
    finite_hist = np.isfinite(macd_hist) & np.isfinite(previous_hist)
    finite_stoch = np.isfinite(stoch_k) & np.isfinite(stoch_d)
    raw_long = finite_rsi & finite_hist & finite_stoch & (rsi > previous_rsi) & (macd_hist > previous_hist) & (stoch_k > stoch_d)
    raw_short = finite_rsi & finite_hist & finite_stoch & (rsi < previous_rsi) & (macd_hist < previous_hist) & (stoch_k < stoch_d)
    reset_event = _cross(rsi, rsi_ma) | _cross(ema_fast, ema_slow) | _cross(macd_line, macd_signal) | _cross(stoch_k, stoch_d)
    range_mode = str(params.get('range_mode', 'Donchian'))
    if range_mode == 'Off':
        block_long = np.zeros(size, dtype=np.bool_)
        block_short = np.zeros(size, dtype=np.bool_)
    else:
        block_long, block_short = _zone_blocks(features, range_mode)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    long_cooldown = False
    short_cooldown = False
    for index in range(size):
        long_ready = not long_cooldown or bool(reset_event[index])
        short_ready = not short_cooldown or bool(reset_event[index])
        if raw_long[index] and long_ready and (not block_long[index]):
            long_entries[index] = True
        if raw_short[index] and short_ready and (not block_short[index]):
            short_entries[index] = True
        if raw_long[index]:
            long_cooldown = True
        elif reset_event[index]:
            long_cooldown = False
        if raw_short[index]:
            short_cooldown = True
        elif reset_event[index]:
            short_cooldown = False
    exit_params = {'k_base': float(params.get('k_base', 2.0)), 'gamma': float(params.get('gamma', 1.0)), 'n_base': float(params.get('n_base', 2000.0))}
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'rems_first_strike_zoned', 'hypothesis': 'REMS First Strike 的多週期動能共振，配合動態價格區間可篩除不利位置並改善進場品質。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['range_mode', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'range_mode': 'Donchian', 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}, {'range_mode': 'Bollinger', 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}, {'range_mode': 'Keltner Channels', 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}, {'range_mode': 'VWAP Bands', 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
