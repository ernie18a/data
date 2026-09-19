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

def _confirmed_pivot(values: np.ndarray, index: int, left: int, right: int, kind: int) -> bool:
    if index < left or index + right >= values.size:
        return False
    window = values[index - left:index + right + 1]
    value = values[index]
    if not np.isfinite(value) or not np.all(np.isfinite(window)):
        return False
    extreme = np.max(window) if kind == 1 else np.min(window)
    return bool(value == extreme and np.count_nonzero(window == extreme) == 1)

def _append_pivot(types: list[int], bars: list[int], prices: list[float], kind: int, bar: int, price: float) -> bool:
    if types and types[-1] == kind:
        more_extreme = price > prices[-1] if kind == 1 else price < prices[-1]
        if more_extreme:
            bars[-1] = bar
            prices[-1] = price
            return True
        return False
    types.append(kind)
    bars.append(bar)
    prices.append(price)
    return True

def _clamp01(value: float) -> float:
    return max(0.0, min(1.0, value))

def _time_quality(ratio: float, maximum_ratio: float) -> float:
    if maximum_ratio <= 1.0:
        return 1.0 if ratio <= 1.0 else 0.0
    return _clamp01(1.0 - (ratio - 1.0) / (maximum_ratio - 1.0))

def _double_bottom_quality(extremum_difference: float, allowed_difference: float, depth: float, minimum_depth: float, time_ratio: float, maximum_time_ratio: float, context_move: float, minimum_context_move: float, span: float, maximum_span: float) -> float:
    equality_score = _clamp01(1.0 - extremum_difference / allowed_difference)
    depth_score = _clamp01(depth / (minimum_depth * 1.8))
    context_score = _clamp01(context_move / (minimum_context_move * 1.8))
    span_score = _clamp01(span / maximum_span)
    return min(100.0, equality_score * 25.0 + depth_score * 25.0 + _time_quality(time_ratio, maximum_time_ratio) * 15.0 + context_score * 15.0 + 10.0 + span_score * 10.0)

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    atr = np.asarray(features.atr(14), dtype=float).reshape(-1)
    pivot_left = 3
    pivot_right = 3
    min_pivot_gap = 2
    min_reversal_span = 8
    max_reversal_span = 140
    double_tolerance_atr = 0.45
    min_double_depth_atr = 0.75
    min_approach_move_atr = 0.75
    max_double_time_ratio = 2.2
    breakout_buffer_atr = 0.05
    min_breakout_body_atr = 0.18
    min_quality = 68.0
    pivot_types: list[int] = []
    pivot_bars: list[int] = []
    pivot_prices: list[float] = []
    pending = None
    for t in range(size):
        pivot_bar = t - pivot_right
        changed = False
        if _confirmed_pivot(highs, pivot_bar, pivot_left, pivot_right, 1):
            changed = _append_pivot(pivot_types, pivot_bars, pivot_prices, 1, pivot_bar, float(highs[pivot_bar])) or changed
        if _confirmed_pivot(lows, pivot_bar, pivot_left, pivot_right, -1):
            changed = _append_pivot(pivot_types, pivot_bars, pivot_prices, -1, pivot_bar, float(lows[pivot_bar])) or changed
        if changed and len(pivot_types) >= 4 and np.isfinite(atr[t]) and (atr[t] > 0.0):
            t1, t2, t3 = pivot_types[-3:]
            x1, x2, x3 = pivot_bars[-3:]
            y1, y2, y3 = pivot_prices[-3:]
            context_type = pivot_types[-4]
            context_price = pivot_prices[-4]
            atr_now = float(atr[t])
            left_span = x2 - x1
            right_span = x3 - x2
            span = x3 - x1
            time_ratio = max(left_span, right_span) / max(min(left_span, right_span), 1.0)
            context_move = context_price - y1 if context_type == 1 else 0.0
            depth = y2 - max(y1, y3)
            extremum_difference = abs(y1 - y3)
            allowed_difference = double_tolerance_atr * atr_now
            geometry_ok = t1 == -1 and t2 == 1 and (t3 == -1) and (left_span >= min_pivot_gap) and (right_span >= min_pivot_gap) and (min_reversal_span <= span <= max_reversal_span) and (time_ratio <= max_double_time_ratio) and (context_type == 1) and (context_move >= min_approach_move_atr * atr_now) and (extremum_difference <= allowed_difference) and (depth >= min_double_depth_atr * atr_now)
            if geometry_ok:
                quality = _double_bottom_quality(extremum_difference, allowed_difference, depth, min_double_depth_atr * atr_now, time_ratio, max_double_time_ratio, context_move, min_approach_move_atr * atr_now, span, max_reversal_span)
                if quality >= min_quality:
                    pending = (x1, x2, x3, y1, y2, y3, quality)
        if pending is not None:
            _, _, x3, _, neckline, _, _ = pending
            if t >= x3 + pivot_right + 3 and t >= 1 and np.isfinite(atr[t]) and (atr[t] > 0.0):
                breakout_level = neckline + breakout_buffer_atr * float(atr[t])
                breakout_ok = np.isfinite(opens[t]) and np.isfinite(closes[t]) and np.isfinite(closes[t - 1]) and (closes[t] > opens[t]) and (closes[t] - opens[t] >= min_breakout_body_atr * float(atr[t])) and (closes[t] > breakout_level) and (closes[t - 1] <= breakout_level)
                if breakout_ok:
                    long_entries[t] = True
                    pending = None
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'double_bottom_breakout_long', 'hypothesis': '確認雙底頸線突破後，預期多頭延續，並以 ATR 趨勢出場管理風險。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
