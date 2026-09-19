from __future__ import annotations
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

def _as_series(values: object, size: int) -> np.ndarray:
    array = np.asarray(values, dtype=float).reshape(-1)
    if array.size != size:
        raise ValueError('行情序列長度必須等於 features.market.size')
    return array

def _wilder_rsi(closes: np.ndarray, length: int) -> np.ndarray:
    result = np.full(closes.size, np.nan, dtype=float)
    if closes.size <= length:
        return result
    changes = np.diff(closes)
    gains = np.maximum(changes, 0.0)
    losses = np.maximum(-changes, 0.0)
    average_gain = float(np.mean(gains[:length]))
    average_loss = float(np.mean(losses[:length]))

    def assign(index: int, gain: float, loss: float) -> None:
        if loss == 0.0:
            result[index] = 100.0 if gain > 0.0 else 50.0
        else:
            result[index] = 100.0 - 100.0 / (1.0 + gain / loss)
    assign(length, average_gain, average_loss)
    for index in range(length + 1, closes.size):
        average_gain = (average_gain * (length - 1) + gains[index - 1]) / length
        average_loss = (average_loss * (length - 1) + losses[index - 1]) / length
        assign(index, average_gain, average_loss)
    return result

def _rsi_series(features: object, closes: np.ndarray, length: int) -> np.ndarray:
    supplied = getattr(features, 'rsi', None)
    if callable(supplied):
        try:
            values = supplied(length)
        except TypeError:
            values = supplied(length=length)
        result = np.asarray(values, dtype=float).reshape(-1)
        if result.size == closes.size:
            return result
    elif supplied is not None:
        result = np.asarray(supplied, dtype=float).reshape(-1)
        if result.size == closes.size:
            return result
    return _wilder_rsi(closes, length)

def _pivot_high(values: np.ndarray, left: int, right: int, index: int) -> bool:
    if index < left or index + right >= values.size:
        return False
    window_left = values[index - left:index]
    window_right = values[index + 1:index + right + 1]
    if not (np.isfinite(values[index]) and np.all(np.isfinite(window_left)) and np.all(np.isfinite(window_right))):
        return False
    return values[index] > np.max(window_left) and values[index] >= np.max(window_right)

def _right_endpoint_ok(endpoint: float, right_extreme: float, atr_at_endpoint: float, price_tolerance_percent: float) -> bool:
    if not (np.isfinite(endpoint) and np.isfinite(right_extreme)):
        return False
    percent_tolerance = abs(endpoint) * price_tolerance_percent / 100.0
    if np.isfinite(atr_at_endpoint):
        tolerance = min(percent_tolerance, max(0.0, atr_at_endpoint) * 0.15)
    else:
        tolerance = percent_tolerance
    epsilon = max(1e-12, abs(endpoint) * 1e-12)
    tolerance = max(epsilon, tolerance)
    return right_extreme <= endpoint + tolerance

def _high_path_ok(series: np.ndarray, first: int, first_value: float, second: int, second_value: float, tolerance: float, edge_skip: int) -> bool:
    if second - first < 2:
        return True
    interior = series[first + 1:second]
    if interior.size != second - first - 1 or not np.all(np.isfinite(interior)):
        return False
    maximum = max(first_value, second_value)
    skip = max(0, min(edge_skip, (second - first - 1) // 4))
    span = float(second - first)
    for offset, value in enumerate(interior, 1):
        if value > maximum + tolerance:
            return False
        if skip <= offset <= second - first - 1 - skip:
            line = first_value + (second_value - first_value) * offset / span
            if value > line + tolerance:
                return False
    return True

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    closes = _as_series(features.market.closes, size)
    highs = _as_series(features.market.highs, size)
    atr = _as_series(features.atr(14), size)
    rsi_length = max(2, min(500, int(signal_params.get('rsi_length', 14))))
    pivot_left = max(1, min(50, int(signal_params.get('pivot_left', 4))))
    pivot_right = max(1, min(50, int(signal_params.get('pivot_right', 1))))
    n_back = max(1, min(10, int(signal_params.get('n_back', 4))))
    gap_a = max(1, int(signal_params.get('min_gap', 5)))
    gap_b = max(1, int(signal_params.get('max_gap', 60)))
    min_gap, max_gap = (min(gap_a, gap_b), max(gap_a, gap_b))
    min_rsi_difference = max(0.0, float(signal_params.get('min_rsi_difference', 0.0)))
    edge_skip = max(0, min(10, int(signal_params.get('edge_skip', 0))))
    rsi_tolerance = max(0.0, float(signal_params.get('rsi_tolerance', 1.5)))
    price_tolerance = max(0.0, float(signal_params.get('price_tolerance', 0.5)))
    strict_blocking = bool(signal_params.get('strict_blocking', True))
    rsi = _rsi_series(features, closes, rsi_length)
    pivots: list[tuple[int, float, float, float, bool, bool]] = []
    for confirmation in range(size):
        pivot = confirmation - pivot_right
        if pivot >= pivot_left and _pivot_high(rsi, pivot_left, pivot_right, pivot):
            endpoint_high = highs[pivot]
            endpoint_close = closes[pivot]
            right_high = highs[pivot + 1:confirmation + 1]
            right_close = closes[pivot + 1:confirmation + 1]
            if right_high.size == pivot_right and np.all(np.isfinite(right_high)):
                high_valid = _right_endpoint_ok(endpoint_high, float(np.max(right_high)), atr[pivot], price_tolerance)
            else:
                high_valid = False
            if right_close.size == pivot_right and np.all(np.isfinite(right_close)):
                close_valid = _right_endpoint_ok(endpoint_close, float(np.max(right_close)), atr[pivot], price_tolerance)
            else:
                close_valid = False
            if high_valid or close_valid:
                current_rsi = rsi[pivot]
                signal_found = False
                for old_index, old_high, old_close, old_rsi, old_high_valid, old_close_valid in reversed(pivots):
                    gap = pivot - old_index
                    if gap > max_gap:
                        break
                    if gap < min_gap:
                        continue
                    if not (np.isfinite(current_rsi) and np.isfinite(old_rsi)):
                        continue
                    pair_high = high_valid and old_high_valid
                    pair_close = close_valid and old_close_valid
                    if current_rsi <= old_rsi or current_rsi - old_rsi < min_rsi_difference:
                        hidden = False
                    else:
                        rsi_ok = _high_path_ok(rsi, old_index, old_rsi, pivot, current_rsi, rsi_tolerance, edge_skip)
                        high_ok = pair_high and endpoint_high < old_high and _high_path_ok(highs, old_index, old_high, pivot, endpoint_high, abs(old_high) * price_tolerance / 100.0, edge_skip)
                        close_ok = pair_close and endpoint_close < old_close and _high_path_ok(closes, old_index, old_close, pivot, endpoint_close, abs(old_close) * price_tolerance / 100.0, edge_skip)
                        hidden = rsi_ok and (high_ok or close_ok)
                    if hidden:
                        signal_found = True
                        break
                    if strict_blocking:
                        blocked_by_high = pair_high and old_high < endpoint_high
                        blocked_by_close = pair_close and old_close < endpoint_close
                        blocked_by_rsi = old_rsi < current_rsi
                        price_blocked = (not high_valid or blocked_by_high) and (not close_valid or blocked_by_close)
                        if blocked_by_rsi and price_blocked:
                            break
                if signal_found:
                    short_entries[confirmation] = True
                pivots.append((pivot, endpoint_high, endpoint_close, current_rsi, high_valid, close_valid))
                if len(pivots) > n_back:
                    del pivots[:-n_back]
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_).reshape(-1), short_entries, np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'rsi_hidden_bearish_divergence_short', 'hypothesis': 'RSI 隱性頂背離顯示下跌趨勢中的反彈可能受阻，尋找做空機會。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['rsi_length', 'pivot_left', 'pivot_right', 'n_back', 'min_gap', 'max_gap', 'min_rsi_difference', 'edge_skip', 'rsi_tolerance', 'price_tolerance', 'strict_blocking', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'rsi_length': 14, 'pivot_left': 4, 'pivot_right': 1, 'n_back': 4, 'min_gap': 5, 'max_gap': 60, 'min_rsi_difference': 0.0, 'edge_skip': 0, 'rsi_tolerance': 1.5, 'price_tolerance': 0.5, 'strict_blocking': True, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
