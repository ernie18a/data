import numpy as np

def i5_illiquidity(return_t: float, close: float, volume: float) -> float:
    return abs(return_t) / (close * volume)

def i5_liquidity_k(illiq: float, mean: float, std: float, k_base: float, phi: float) -> float:
    return k_base * (1.0 + phi * max(0.0, (illiq - mean) / std))

def i5_order_flow(delta_close: float, std: float) -> float:
    from math import erf, sqrt
    return erf(delta_close / (std * sqrt(2.0)))

def i5_stop(side: int, previous_stop: float, best: float, k: float, atr: float) -> float:
    return side * max(side * previous_stop, side * (best - side * k * atr))

def i5_stop_touched(side: int, low: float, high: float, stop: float) -> bool:
    return side == 1 and low < stop or (side == -1 and high > stop)

def i5_trend(cumulative_volume: float, n_base: float, atr_entry: float, atr: float, gamma: float, flow_factor: float) -> bool:
    return cumulative_volume >= n_base * (atr_entry / atr) ** gamma * flow_factor

def _clamp01(value: float) -> float:
    return max(0.0, min(1.0, value))

def _line_value(x1: int, y1: float, x2: int, y2: float, x: int) -> float:
    return y1 + (y2 - y1) / max(x2 - x1, 1) * (x - x1)

def _add_pivot(types: list[int], bars: list[int], prices: list[float], kind: int, bar: int, price: float) -> None:
    if types and types[-1] == kind:
        if kind == 1 and price > prices[-1] or (kind == -1 and price < prices[-1]):
            bars[-1] = bar
            prices[-1] = price
        return
    types.append(kind)
    bars.append(bar)
    prices.append(price)
    if len(types) > 20:
        del types[0]
        del bars[0]
        del prices[0]

def _confirmed_pivot(highs: np.ndarray, lows: np.ndarray, t: int, left: int, right: int, types: list[int], bars: list[int], prices: list[float]) -> None:
    pivot = t - right
    if pivot < left or t >= highs.size or (not np.isfinite(highs[pivot])) or (not np.isfinite(lows[pivot])):
        return
    high_window = highs[pivot - left:pivot + right + 1]
    low_window = lows[pivot - left:pivot + right + 1]
    if high_window.size != left + right + 1 or low_window.size != left + right + 1:
        return
    if highs[pivot] == np.max(high_window):
        _add_pivot(types, bars, prices, 1, pivot, float(highs[pivot]))
    elif lows[pivot] == np.min(low_window):
        _add_pivot(types, bars, prices, -1, pivot, float(lows[pivot]))

def _scan_structure(types: list[int], bars: list[int], prices: list[float], atr: float, is_macro: bool) -> dict | None:
    if len(types) < 4 or not np.isfinite(atr) or atr <= 0.0:
        return None
    start = max(0, len(types) - 10)
    best: dict | None = None
    best_rank = -np.inf
    for i in range(start, len(types) - 3):
        for j in range(i + 1, len(types) - 2):
            for k in range(j + 1, len(types) - 1):
                for m in range(k + 1, len(types)):
                    t1, t2, t3, t4 = (types[i], types[j], types[k], types[m])
                    if not (t1 != t2 and t2 != t3 and (t3 != t4) and (t1 == t3) and (t2 == t4)):
                        continue
                    x1, x2, x3, x4 = (bars[i], bars[j], bars[k], bars[m])
                    if x2 - x1 < 3 or x3 - x2 < 3 or x4 - x3 < 3:
                        continue
                    span = x4 - x1
                    tail = len(types) - 1 - m
                    if span < 18 or span > 180 or tail > 2:
                        continue
                    y1, y2, y3, y4 = (prices[i], prices[j], prices[k], prices[m])
                    if t1 == 1:
                        ux1, uy1, ux2, uy2 = (x1, y1, x3, y3)
                        lx1, ly1, lx2, ly2 = (x2, y2, x4, y4)
                    else:
                        lx1, ly1, lx2, ly2 = (x1, y1, x3, y3)
                        ux1, uy1, ux2, uy2 = (x2, y2, x4, y4)
                    upper_slope = (uy2 - uy1) / max(ux2 - ux1, 1)
                    lower_slope = (ly2 - ly1) / max(lx2 - lx1, 1)
                    upper_slope_atr = upper_slope / atr
                    lower_slope_atr = lower_slope / atr
                    convergence = lower_slope_atr - upper_slope_atr
                    upper_start = _line_value(ux1, uy1, ux2, uy2, x1)
                    lower_start = _line_value(lx1, ly1, lx2, ly2, x1)
                    upper_end = _line_value(ux1, uy1, ux2, uy2, x4)
                    lower_end = _line_value(lx1, ly1, lx2, ly2, x4)
                    width_start = upper_start - lower_start
                    width_end = upper_end - lower_end
                    if width_start < 1.1 * atr or width_end <= 0.0:
                        continue
                    end_ratio = width_end / width_start if width_start > 0.0 else np.inf
                    if end_ratio <= 0.0 or end_ratio > 0.82 or convergence < 0.012:
                        continue
                    if upper_slope_atr <= -0.008 and lower_slope_atr >= 0.008:
                        kind = 1
                    elif abs(upper_slope_atr) <= 0.03 and lower_slope_atr >= 0.008:
                        kind = 2
                    elif upper_slope_atr <= -0.008 and abs(lower_slope_atr) <= 0.03:
                        kind = 3
                    elif upper_slope_atr >= 0.008 and lower_slope_atr >= 0.008 and (lower_slope_atr > upper_slope_atr):
                        kind = 4
                    elif upper_slope_atr <= -0.008 and lower_slope_atr <= -0.008 and (lower_slope_atr > upper_slope_atr):
                        kind = 5
                    else:
                        continue
                    compression = _clamp01((0.82 - end_ratio) / max(0.82 - 0.1, 0.01))
                    if kind == 1:
                        slope_shape = _clamp01(min(abs(upper_slope_atr), abs(lower_slope_atr)) / max(0.008 * 4.0, 0.001))
                    elif kind == 2:
                        slope_shape = 0.5 * _clamp01(1.0 - abs(upper_slope_atr) / 0.03) + 0.5 * _clamp01(lower_slope_atr / (0.008 * 4.0))
                    elif kind == 3:
                        slope_shape = 0.5 * _clamp01(1.0 - abs(lower_slope_atr) / 0.03) + 0.5 * _clamp01(abs(upper_slope_atr) / (0.008 * 4.0))
                    else:
                        slope_shape = _clamp01(convergence / (0.012 * 4.0))
                    height = _clamp01(width_start / max(1.1 * atr * 2.5, np.finfo(float).tiny))
                    span_score = _clamp01(span / (180.0 * 0.65))
                    tail_score = _clamp01(1.0 - tail / 3.0)
                    closing_speed = lower_slope - upper_slope
                    apex_ahead = width_end / closing_speed if closing_speed > 0.0 else 280.0
                    apex_score = _clamp01(1.0 - apex_ahead / 140.0)
                    quality = min(100.0, compression * 27.0 + slope_shape * 25.0 + height * 16.0 + span_score * 12.0 + tail_score * 10.0 + apex_score * 10.0)
                    rank = quality + (6.0 if is_macro else 0.0)
                    if rank > best_rank:
                        best_rank = rank
                        best = {'kind': kind, 'quality': quality, 'bias': 1 if kind in (2, 5) else -1 if kind in (3, 4) else 0, 'upper': (ux1, uy1, ux2, uy2), 'lower': (lx1, ly1, lx2, ly2), 'start': x1, 'end': x4, 'span': span, 'opening': width_start, 'pivot_right': 7 if is_macro else 3}
    return best

def _flow_factor(of_value: float, base: float) -> float:
    return base * (1.0 + abs(of_value))

def _rolling_mean_std(values: np.ndarray, end: int, window: int) -> tuple[float, float] | None:
    start = end - window + 1
    if start < 0:
        return None
    sample = values[start:end + 1]
    if sample.size != window or not np.all(np.isfinite(sample)):
        return None
    mean = float(np.mean(sample))
    std = float(np.std(sample, ddof=0))
    return (mean, std)

def iter_signal_parameter_sets():
    for k_base in (1.5, 2.5, 3.5):
        for phi in (0.0, 0.5):
            for gamma in (0.5, 1.0):
                for n_base in (1000.0, 2000.0, 4000.0):
                    for flow_factor in (0.5, 1.5):
                        yield {'k_base': k_base, 'phi': phi, 'gamma': gamma, 'n_base': n_base, 'flow_factor': flow_factor}

def generate_signals(features, signal_params):
    market = features.market
    opens = market.opens
    highs = market.highs
    lows = market.lows
    closes = market.closes
    volumes = market.volumes
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    atr = features.atr(14)
    micro_types: list[int] = []
    micro_bars: list[int] = []
    micro_prices: list[float] = []
    macro_types: list[int] = []
    macro_bars: list[int] = []
    macro_prices: list[float] = []
    last_signal_bar = -10 ** 9
    last_signal_key: int | None = None
    for t in range(size):
        _confirmed_pivot(highs, lows, t, 3, 3, micro_types, micro_bars, micro_prices)
        _confirmed_pivot(highs, lows, t, 7, 7, macro_types, macro_bars, macro_prices)
        if t < 14 or not np.isfinite(atr[t]) or atr[t] <= 0.0:
            continue
        micro = _scan_structure(micro_types, micro_bars, micro_prices, float(atr[t]), False)
        macro = _scan_structure(macro_types, macro_bars, macro_prices, float(atr[t]), True)
        if macro is not None and (micro is None or macro['quality'] + 6.0 >= micro['quality']):
            structure = macro
        else:
            structure = micro
        if structure is None:
            continue
        lifetime = max(12, min(220, int(round(structure['span'] * 1.8))))
        if t - structure['end'] > lifetime:
            continue
        upper = structure['upper']
        lower = structure['lower']
        upper_now = _line_value(*upper, t)
        lower_now = _line_value(*lower, t)
        upper_prev = _line_value(*upper, t - 1)
        lower_prev = _line_value(*lower, t - 1)
        kind = structure['kind']
        allowed_long = kind <= 3 or kind == 5
        allowed_short = kind <= 3 or kind == 4
        key = structure['end'] * 10 + kind
        cooldown_ok = t - last_signal_bar > 14
        unique_ok = last_signal_key is None or key != last_signal_key
        if t < 1 or not np.isfinite(atr[t - 1]):
            continue
        long_body = closes[t] > opens[t] and abs(closes[t] - opens[t]) >= 0.15 * atr[t]
        short_body = closes[t] < opens[t] and abs(closes[t] - opens[t]) >= 0.15 * atr[t]
        long_cross = closes[t] > upper_now + 0.06 * atr[t] and closes[t - 1] <= upper_prev + 0.06 * atr[t - 1]
        short_cross = closes[t] < lower_now - 0.06 * atr[t] and closes[t - 1] >= lower_prev - 0.06 * atr[t - 1]
        delayed_long = structure['pivot_right'] <= t - structure['end'] <= structure['pivot_right'] + 2 and closes[t] > upper_now + 0.12 * atr[t]
        delayed_short = structure['pivot_right'] <= t - structure['end'] <= structure['pivot_right'] + 2 and closes[t] < lower_now - 0.12 * atr[t]
        long_signal = structure['quality'] >= 72.0 and allowed_long and cooldown_ok and unique_ok and (long_body and long_cross or delayed_long)
        short_signal = structure['quality'] >= 72.0 and allowed_short and cooldown_ok and unique_ok and (short_body and short_cross or delayed_short)
        if long_signal and (not short_signal):
            long_entries[t] = True
            last_signal_bar = t
            last_signal_key = key
        elif short_signal and (not long_signal):
            short_entries[t] = True
            last_signal_bar = t
            last_signal_key = key
    k_base = float(signal_params['k_base'])
    phi = float(signal_params['phi'])
    gamma = float(signal_params['gamma'])
    n_base = float(signal_params['n_base'])
    flow_base = float(signal_params['flow_factor'])
    window = 20
    returns = np.full(size, np.nan, dtype=np.float64)
    delta_close = np.full(size, np.nan, dtype=np.float64)
    for t in range(1, size):
        if np.isfinite(closes[t]) and np.isfinite(closes[t - 1]) and (closes[t - 1] != 0.0):
            returns[t] = closes[t] / closes[t - 1] - 1.0
            delta_close[t] = closes[t] - closes[t - 1]
    illiq_series = np.full(size, np.nan, dtype=np.float64)
    for t in range(1, size):
        if np.isfinite(returns[t]) and np.isfinite(closes[t]) and (closes[t] > 0.0) and np.isfinite(volumes[t]) and (volumes[t] > 0.0):
            illiq_series[t] = i5_illiquidity(float(returns[t]), float(closes[t]), float(volumes[t]))
    position = 0
    best = 0.0
    previous_stop = 0.0
    entry_atr = 0.0
    cumulative_volume = 0.0
    for t in range(size):
        if position == 0 and t > 0 and np.isfinite(opens[t]):
            if long_entries[t - 1] and (not short_entries[t - 1]) and np.isfinite(atr[t - 1]) and (atr[t - 1] > 0.0):
                position = 1
                best = float(opens[t])
                previous_stop = -np.inf
                entry_atr = float(atr[t - 1])
                cumulative_volume = 0.0
            elif short_entries[t - 1] and (not long_entries[t - 1]) and np.isfinite(atr[t - 1]) and (atr[t - 1] > 0.0):
                position = -1
                best = float(opens[t])
                previous_stop = np.inf
                entry_atr = float(atr[t - 1])
                cumulative_volume = 0.0
        if position == 0:
            continue
        if not (np.isfinite(highs[t]) and np.isfinite(lows[t]) and np.isfinite(atr[t]) and (atr[t] > 0.0) and np.isfinite(volumes[t]) and (volumes[t] > 0.0)):
            continue
        cumulative_volume += float(volumes[t])
        side = position
        best = max(best, float(highs[t])) if side == 1 else min(best, float(lows[t]))
        liquidity_stats = _rolling_mean_std(illiq_series, t, window)
        stop_ready = liquidity_stats is not None and liquidity_stats[1] > 0.0
        if stop_ready:
            mean_illiq, std_illiq = liquidity_stats
            k = i5_liquidity_k(float(illiq_series[t]), mean_illiq, std_illiq, k_base, phi)
            stop = i5_stop(side, previous_stop, best, k, float(atr[t]))
            previous_stop = stop
            touched = i5_stop_touched(side, float(lows[t]), float(highs[t]), stop)
        else:
            touched = False
        delta_stats = _rolling_mean_std(delta_close, t, window)
        trend_ready = delta_stats is not None and delta_stats[1] > 0.0 and (n_base > 0.0) and (entry_atr > 0.0)
        trend_hit = False
        if trend_ready:
            _, delta_std = delta_stats
            of = i5_order_flow(float(delta_close[t]), delta_std)
            flow_factor = _flow_factor(of, flow_base)
            trend_hit = i5_trend(cumulative_volume, n_base, entry_atr, float(atr[t]), gamma, flow_factor)
        if touched or trend_hit:
            if side == 1:
                long_exits[t] = True
            else:
                short_exits[t] = True
            position = 0
            best = 0.0
            previous_stop = 0.0
            entry_atr = 0.0
            cumulative_volume = 0.0
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'converging_structure_breakout', 'hypothesis': 'Confirmed causal triangle and wedge boundary breakouts are traded in their permitted direction with adaptive liquidity and trend exits.', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'phi', 'gamma', 'n_base', 'flow_factor'], 'signal_parameter_sets': iter_signal_parameter_sets}
