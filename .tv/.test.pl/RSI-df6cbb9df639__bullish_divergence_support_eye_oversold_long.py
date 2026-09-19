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

def _wilder_rsi(closes: np.ndarray, length: int) -> np.ndarray:
    rsi = np.full(closes.size, np.nan, dtype=float)
    if closes.size <= length:
        return rsi
    delta = np.diff(closes)
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
    avg_gain = float(np.mean(gains[:length]))
    avg_loss = float(np.mean(losses[:length]))

    def value(gain: float, loss: float) -> float:
        if loss == 0.0:
            return 50.0 if gain == 0.0 else 100.0
        return 100.0 - 100.0 / (1.0 + gain / loss)
    rsi[length] = value(avg_gain, avg_loss)
    for i in range(length + 1, closes.size):
        avg_gain = (avg_gain * (length - 1) + gains[i - 1]) / length
        avg_loss = (avg_loss * (length - 1) + losses[i - 1]) / length
        rsi[i] = value(avg_gain, avg_loss)
    return rsi

def _atr(highs: np.ndarray, lows: np.ndarray, closes: np.ndarray, length: int) -> np.ndarray:
    atr = np.full(closes.size, np.nan, dtype=float)
    if closes.size == 0:
        return atr
    true_range = np.full(closes.size, np.nan, dtype=float)
    true_range[0] = highs[0] - lows[0]
    for i in range(1, closes.size):
        true_range[i] = max(highs[i] - lows[i], abs(highs[i] - closes[i - 1]), abs(lows[i] - closes[i - 1]))
    if closes.size < length:
        return atr
    atr[length - 1] = float(np.mean(true_range[:length]))
    for i in range(length, closes.size):
        atr[i] = (atr[i - 1] * (length - 1) + true_range[i]) / length
    return atr

def _bollinger_lower(closes: np.ndarray, length: int, multiplier: float) -> np.ndarray:
    lower = np.full(closes.size, np.nan, dtype=float)
    for i in range(length - 1, closes.size):
        window = closes[i - length + 1:i + 1]
        if np.all(np.isfinite(window)):
            lower[i] = float(np.mean(window) - multiplier * np.std(window, ddof=0))
    return lower

def _right_price_ok(endpoint: float, right_extreme: float, atr_at_endpoint: float, tolerance_pct: float) -> bool:
    if not np.isfinite(endpoint) or not np.isfinite(right_extreme):
        return False
    pct_tolerance = abs(endpoint) * tolerance_pct / 100.0
    if np.isfinite(atr_at_endpoint):
        tolerance = max(1e-12, min(pct_tolerance, atr_at_endpoint * 0.15))
    else:
        tolerance = max(1e-12, pct_tolerance)
    return right_extreme >= endpoint - tolerance

def _path_ok(series: np.ndarray, first_bar: int, first_value: float, last_bar: int, last_value: float, tolerance: float, edge_skip: int) -> bool:
    if last_bar - first_bar < 2:
        return True
    if not np.isfinite(first_value) or not np.isfinite(last_value):
        return False
    span = float(last_bar - first_bar)
    skip = max(0, min(edge_skip, int((last_bar - first_bar - 1) // 4)))
    lower_bound = min(first_value, last_value) - tolerance
    for bar in range(first_bar + 1, last_bar):
        value = series[bar]
        if not np.isfinite(value) or value < lower_bound:
            return False
        middle = bar >= first_bar + 1 + skip and bar <= last_bar - 1 - skip
        line = first_value + (last_value - first_value) * ((bar - first_bar) / span)
        if middle and value < line - tolerance:
            return False
    return True

def _is_pivot_low(values: np.ndarray, index: int, left: int, right: int) -> bool:
    if index < left or index + right >= values.size:
        return False
    value = values[index]
    if not np.isfinite(value):
        return False
    left_values = values[index - left:index]
    right_values = values[index + 1:index + right + 1]
    return np.all(np.isfinite(left_values)) and np.all(np.isfinite(right_values)) and (value <= np.min(left_values)) and (value <= np.min(right_values))

def _bottom_divergence(*, index: int, rsi: np.ndarray, lows: np.ndarray, closes: np.ndarray, atr: np.ndarray, pivots: list[tuple[int, float, float, float, bool, bool]], piv_right: int, n_back: int, gap_min: int, gap_max: int, anchor: str, strict: bool, check_path: bool, check_osc_path: bool, check_price_path: bool, edge_skip: int, osc_tolerance: float, price_tolerance_pct: float, min_rsi_delta: float, oversold: float) -> bool:
    current_rsi = rsi[index]
    current_low = lows[index]
    current_close = closes[index]
    if not np.isfinite(current_rsi) or not np.isfinite(current_low) or (not np.isfinite(current_close)):
        return False
    use_wick = anchor != 'close'
    use_close = anchor != 'hl'
    current_wick_ok = use_wick and _right_price_ok(current_low, lows[index + 1:index + piv_right + 1].min(), atr[index], price_tolerance_pct)
    current_close_ok = use_close and _right_price_ok(current_close, closes[index + 1:index + piv_right + 1].min(), atr[index], price_tolerance_pct)
    if not (current_wick_ok or current_close_ok) or current_rsi > oversold:
        return False
    for old_index, old_low, old_close, old_rsi, old_wick_ok, old_close_ok in reversed(pivots[-n_back:]):
        gap = index - old_index
        if gap > gap_max:
            break
        if gap < gap_min:
            continue
        pair_wick = current_wick_ok and use_wick and old_wick_ok
        pair_close = current_close_ok and use_close and old_close_ok
        if not (pair_wick or pair_close):
            continue
        oscillator_ok = not (check_path and check_osc_path) or _path_ok(rsi, old_index, old_rsi, index, current_rsi, osc_tolerance, edge_skip)
        if current_rsi > old_rsi and current_rsi - old_rsi >= min_rsi_delta and oscillator_ok:
            wick_ok = pair_wick and current_low < old_low and (not (check_path and check_price_path) or _path_ok(lows, old_index, old_low, index, current_low, abs(old_low) * price_tolerance_pct / 100.0, edge_skip))
            close_ok = pair_close and current_close < old_close and (not (check_path and check_price_path) or _path_ok(closes, old_index, old_close, index, current_close, abs(old_close) * price_tolerance_pct / 100.0, edge_skip))
            if wick_ok or close_ok:
                return True
        if strict:
            block_wick = pair_wick and old_low < current_low
            block_close = pair_close and old_close < current_close
            block_rsi = old_rsi > current_rsi
            price_block = (not current_wick_ok or (pair_wick and block_wick)) and (not current_close_ok or (pair_close and block_close))
            if block_rsi and price_block:
                break
    return False

def generate_signals(features, signal_params):
    params = signal_params or {}
    market = features.market
    size = int(market.size)
    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    if highs.ndim != 1 or lows.ndim != 1 or closes.ndim != 1:
        raise ValueError('market OHLC arrays must be one-dimensional')
    if highs.size != size or lows.size != size or closes.size != size:
        raise ValueError('market OHLC arrays must match market.size')
    rsi_length = max(2, int(params.get('rsi_len', 14)))
    piv_left = max(1, int(params.get('piv_left', 4)))
    piv_right = max(1, int(params.get('piv_right', 1)))
    n_back = max(1, int(params.get('n_back', 4)))
    gap_min = max(1, int(params.get('gap_min', 5)))
    gap_max = max(gap_min, int(params.get('gap_max', 60)))
    oversold = float(params.get('oversold', 30.0))
    anchor = str(params.get('anchor', 'mix')).lower()
    strict = bool(params.get('strict', True))
    check_path = bool(params.get('check_path', True))
    check_osc_path = bool(params.get('check_osc_path', True))
    check_price_path = bool(params.get('check_price_path', True))
    edge_skip = max(0, int(params.get('edge_skip', 0)))
    osc_tolerance = max(0.0, float(params.get('osc_tolerance', 1.5)))
    price_tolerance_pct = max(0.0, float(params.get('price_tolerance_pct', 0.5)))
    min_rsi_delta = max(0.0, float(params.get('min_rsi_delta', 0.0)))
    eye_length = max(2, int(params.get('eye_len', 20)))
    eye_multiplier = max(0.1, float(params.get('eye_mult', 2.0)))
    eye_mode = str(params.get('eye_mode', 'wick')).lower()
    use_eye = bool(params.get('use_eye', True))
    rsi = _wilder_rsi(closes, rsi_length)
    atr = _atr(highs, lows, closes, 14)
    lower_band = _bollinger_lower(closes, eye_length, eye_multiplier)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    pivots: list[tuple[int, float, float, float, bool, bool]] = []
    confirmed_eyes: set[int] = set()
    divergence_origins: set[int] = set()
    emitted_origins: set[int] = set()
    eye_active = False
    eye_extreme_index = -1
    eye_extreme_price = np.nan
    for t in range(size):
        outside = False
        if use_eye and np.isfinite(lower_band[t]):
            outside_value = lows[t] if eye_mode != 'close' else closes[t]
            outside = np.isfinite(outside_value) and outside_value < lower_band[t]
        if outside:
            if not eye_active:
                eye_active = True
                eye_extreme_index = t
                eye_extreme_price = lows[t]
            elif lows[t] < eye_extreme_price:
                eye_extreme_index = t
                eye_extreme_price = lows[t]
        elif eye_active:
            confirmed_eyes.add(eye_extreme_index)
            eye_active = False
            eye_extreme_index = -1
            eye_extreme_price = np.nan
        pivot_index = t - piv_right
        if _is_pivot_low(rsi, pivot_index, piv_left, piv_right):
            pivot_low = lows[pivot_index]
            pivot_close = closes[pivot_index]
            pivot_atr = atr[pivot_index]
            right_lows = lows[pivot_index + 1:pivot_index + piv_right + 1]
            right_closes = closes[pivot_index + 1:pivot_index + piv_right + 1]
            wick_valid = _right_price_ok(pivot_low, float(np.min(right_lows)), pivot_atr, price_tolerance_pct)
            close_valid = _right_price_ok(pivot_close, float(np.min(right_closes)), pivot_atr, price_tolerance_pct)
            if wick_valid or close_valid:
                if _bottom_divergence(index=pivot_index, rsi=rsi, lows=lows, closes=closes, atr=atr, pivots=pivots, piv_right=piv_right, n_back=n_back, gap_min=gap_min, gap_max=gap_max, anchor=anchor, strict=strict, check_path=check_path, check_osc_path=check_osc_path, check_price_path=check_price_path, edge_skip=edge_skip, osc_tolerance=osc_tolerance, price_tolerance_pct=price_tolerance_pct, min_rsi_delta=min_rsi_delta, oversold=oversold):
                    divergence_origins.add(pivot_index)
                pivots.append((pivot_index, pivot_low, pivot_close, rsi[pivot_index], wick_valid, close_valid))
                if len(pivots) > n_back:
                    del pivots[:-n_back]
        for origin in tuple(divergence_origins & confirmed_eyes):
            if origin not in emitted_origins and np.isfinite(rsi[origin]) and (rsi[origin] <= oversold):
                long_entries[t] = True
                emitted_origins.add(origin)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_divergence_support_eye_oversold_long', 'hypothesis': 'RSI 底背離、布林下軌支撐眼與超賣同時出現在同一極值低點，代表下跌動能衰竭，逢低做多。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['rsi_len', 'oversold', 'piv_left', 'piv_right', 'n_back', 'gap_min', 'gap_max', 'anchor', 'strict', 'check_path', 'check_osc_path', 'check_price_path', 'edge_skip', 'osc_tolerance', 'price_tolerance_pct', 'min_rsi_delta', 'eye_len', 'eye_mult', 'eye_mode', 'use_eye', 'k_base', 'mult'], 'signal_parameter_sets': [{'rsi_len': 14, 'oversold': 30.0, 'piv_left': 4, 'piv_right': 1, 'n_back': 4, 'gap_min': 5, 'gap_max': 60, 'anchor': 'mix', 'strict': True, 'check_path': True, 'check_osc_path': True, 'check_price_path': True, 'edge_skip': 0, 'osc_tolerance': 1.5, 'price_tolerance_pct': 0.5, 'min_rsi_delta': 0.0, 'eye_len': 20, 'eye_mult': 2.0, 'eye_mode': 'wick', 'use_eye': True, 'k_base': 2.0, 'mult': 2.0}]}
