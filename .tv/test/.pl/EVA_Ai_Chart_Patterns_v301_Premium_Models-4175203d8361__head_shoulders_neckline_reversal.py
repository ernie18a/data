import numpy as np

def i5_illiquidity(return_t: float, close: float, volume: float) -> float:
    return abs(return_t) / (close * volume)

def i5_liquidity_k(illiq: float, mean: float, std: float, k_base: float, phi: float) -> float:
    return k_base * (1.0 + phi * max(0.0, (illiq - mean) / std))

def i5_reversion(side: int, previous_z: float, z: float, z_entry: float, mult: float, cumulative_volume: float, volume_target: float) -> bool:
    return side * previous_z <= 0.0 < side * z or abs(z) > mult * abs(z_entry) or cumulative_volume >= volume_target

def i5_stop(side: int, previous_stop: float, best: float, k: float, atr: float) -> float:
    return side * max(side * previous_stop, side * (best - side * k * atr))

def i5_stop_touched(side: int, low: float, high: float, stop: float) -> bool:
    return side == 1 and low < stop or (side == -1 and high > stop)

def i5_vwap_z(close: float, volume_sum: float, price_volume_sum: float, centered_square_volume_sum: float) -> float:
    from math import sqrt
    return (close - price_volume_sum / volume_sum) / sqrt(centered_square_volume_sum / volume_sum)

def generate_signals(features, signal_params):
    size = int(features.market.size)
    false_signal = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (false_signal.copy(), false_signal.copy(), false_signal.copy(), false_signal.copy())
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volumes = np.asarray(features.market.volumes, dtype=np.float64)
    atr = np.asarray(features.atr(14), dtype=np.float64)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)

    def finite_positive(value):
        return bool(np.isfinite(value) and value > 0.0)

    def clip01(value):
        return min(1.0, max(0.0, float(value)))

    def pivot_confirmed(values, center, left, right, is_high):
        start = center - left
        end = center + right + 1
        if start < 0 or end > size:
            return False
        window = values[start:end]
        if not np.all(np.isfinite(window)):
            return False
        extreme = np.max(window) if is_high else np.min(window)
        return bool(values[center] == extreme)

    def add_pivot(pivots, pivot_type, pivot_bar, pivot_price):
        if not np.isfinite(pivot_price):
            return False
        if not pivots:
            pivots.append((pivot_type, pivot_bar, float(pivot_price)))
            return True
        last_type, _, last_price = pivots[-1]
        if last_type == pivot_type:
            replace = pivot_type == 1 and pivot_price > last_price or (pivot_type == -1 and pivot_price < last_price)
            if replace:
                pivots[-1] = (pivot_type, pivot_bar, float(pivot_price))
                return True
            return False
        pivots.append((pivot_type, pivot_bar, float(pivot_price)))
        if len(pivots) > 20:
            del pivots[0]
        return True

    def make_candidate(points, a_value, inverse, is_macro, context, interval_high, interval_low):
        if not finite_positive(a_value) or len(points) != 5:
            return None
        expected = [-1, 1, -1, 1, -1] if inverse else [1, -1, 1, -1, 1]
        if [point[0] for point in points] != expected:
            return None
        x1, x2, x3, x4, x5 = [int(point[1]) for point in points]
        y1, y2, y3, y4, y5 = [float(point[2]) for point in points]
        gaps = [x2 - x1, x3 - x2, x4 - x3, x5 - x4]
        span = x5 - x1
        if min(gaps) < 2 or span < (18 if is_macro else 8) or span > 140:
            return None
        time_ratio = max(x3 - x1, x5 - x3) / max(min(x3 - x1, x5 - x3), 1)
        neckline_slope_atr = abs((y4 - y2) / max(x4 - x2, 1)) / a_value
        if time_ratio > 2.0 or neckline_slope_atr > 0.2:
            return None
        neckline_average = (y2 + y4) * 0.5
        if inverse:
            shoulder_depth = min(y2, y4) - max(y1, y5)
            head_height = neckline_average - y3
            head_prominence = min(y1, y5) - y3
        else:
            shoulder_depth = min(y1, y5) - max(y2, y4)
            head_height = y3 - neckline_average
            head_prominence = y3 - max(y1, y5)
        if shoulder_depth < 0.35 * a_value or head_prominence < 0.7 * a_value:
            return None
        if is_macro:
            shoulder_tolerance = max(0.6 * a_value, max(head_height, 0.0) * 0.45)
            if not finite_positive(head_height) or head_prominence / head_height < 0.22:
                return None
            if inverse:
                if interval_low is None:
                    return None
                dominance_deviation = y3 - interval_low
            else:
                if interval_high is None:
                    return None
                dominance_deviation = interval_high - y3
            dominance_tolerance = max(0.15 * a_value, np.finfo(np.float64).eps)
            if dominance_deviation > dominance_tolerance:
                return None
            dominance_score = clip01(1.0 - max(dominance_deviation, 0.0) / dominance_tolerance)
            minimum_head_ratio = 0.22
        else:
            shoulder_tolerance = 0.6 * a_value
            dominance_score = 1.0
            minimum_head_ratio = 0.7 / 1.7
        if abs(y1 - y5) > shoulder_tolerance or context is None:
            return None
        context_type, _, context_price = context
        if inverse:
            if context_type != 1:
                return None
            context_move = context_price - y1
        else:
            if context_type != -1:
                return None
            context_move = y1 - context_price
        if context_move < 0.75 * a_value:
            return None
        head_ratio = head_prominence / head_height if finite_positive(head_height) else 0.0
        quality = min(100.0, clip01(1.0 - abs(y1 - y5) / shoulder_tolerance) * 20.0 + clip01(head_ratio / (minimum_head_ratio * 1.8)) * 22.0 + clip01(1.0 - neckline_slope_atr / 0.2) * 13.0 + clip01(1.0 - (time_ratio - 1.0)) * 14.0 + clip01(shoulder_depth / (0.35 * a_value * 1.8)) * 10.0 + clip01(context_move / (0.75 * a_value * 1.8)) * 10.0 + dominance_score * 6.0 + clip01(span / 140.0) * 5.0)
        if quality < 58.0:
            return None
        return {'x1': x1, 'x2': x2, 'x3': x3, 'x4': x4, 'x5': x5, 'y1': y1, 'y2': y2, 'y3': y3, 'y4': y4, 'y5': y5, 'q': quality, 'macro': bool(is_macro), 'span': span}

    def candidate_rank(candidate):
        return float(candidate['q']) + (6.0 if candidate['macro'] else 0.0)

    def replace_candidate(old, new, last_confirmed_x5):
        if new is None or new['x5'] == last_confirmed_x5:
            return old
        if old is None:
            return new
        if new['x5'] == old['x5'] and new['q'] > old['q']:
            return new
        return new if candidate_rank(new) > candidate_rank(old) + 3.0 else old

    def best_macro_candidates(pivots, a_value, inverse, last_confirmed_x5):
        if len(pivots) < 5:
            return None
        first = max(0, len(pivots) - 10)
        best = None
        for i1 in range(first, len(pivots) - 4):
            for i2 in range(i1 + 1, len(pivots) - 3):
                for i3 in range(i2 + 1, len(pivots) - 2):
                    for i4 in range(i3 + 1, len(pivots) - 1):
                        for i5 in range(i4 + 1, len(pivots)):
                            if len(pivots) - 1 - i5 > 2:
                                continue
                            selected = [pivots[i1], pivots[i2], pivots[i3], pivots[i4], pivots[i5]]
                            interval = pivots[i1:i5 + 1]
                            highs_in_interval = [p[2] for p in interval if p[0] == 1]
                            lows_in_interval = [p[2] for p in interval if p[0] == -1]
                            candidate = make_candidate(selected, a_value, inverse, True, pivots[i1 - 1] if i1 > 0 else None, max(highs_in_interval) if highs_in_interval else None, min(lows_in_interval) if lows_in_interval else None)
                            if candidate is not None and candidate['x5'] != last_confirmed_x5:
                                if best is None or candidate['q'] > best['q']:
                                    best = candidate
        return best
    micro_pivots = []
    macro_pivots = []
    pending_short = None
    pending_long = None
    last_short_x5 = None
    last_long_x5 = None
    for t in range(size):
        micro_center = t - 3
        new_micro = False
        if micro_center >= 13:
            if pivot_confirmed(highs, micro_center, 3, 3, True):
                new_micro = add_pivot(micro_pivots, 1, micro_center, highs[micro_center]) or new_micro
            if pivot_confirmed(lows, micro_center, 3, 3, False):
                new_micro = add_pivot(micro_pivots, -1, micro_center, lows[micro_center]) or new_micro
        macro_center = t - 7
        new_macro = False
        if macro_center >= 13:
            if pivot_confirmed(highs, macro_center, 7, 7, True):
                new_macro = add_pivot(macro_pivots, 1, macro_center, highs[macro_center]) or new_macro
            if pivot_confirmed(lows, macro_center, 7, 7, False):
                new_macro = add_pivot(macro_pivots, -1, macro_center, lows[macro_center]) or new_macro
        if new_micro and finite_positive(atr[micro_center]) and (len(micro_pivots) >= 5):
            points = micro_pivots[-5:]
            context = micro_pivots[-6] if len(micro_pivots) >= 6 else None
            pending_short = replace_candidate(pending_short, make_candidate(points, atr[micro_center], False, False, context, None, None), last_short_x5)
            pending_long = replace_candidate(pending_long, make_candidate(points, atr[micro_center], True, False, context, None, None), last_long_x5)
        if new_macro and finite_positive(atr[macro_center]):
            pending_short = replace_candidate(pending_short, best_macro_candidates(macro_pivots, atr[macro_center], False, last_short_x5), last_short_x5)
            pending_long = replace_candidate(pending_long, best_macro_candidates(macro_pivots, atr[macro_center], True, last_long_x5), last_long_x5)
        current_atr = atr[t]
        if pending_short is not None:
            invalidated = np.isfinite(current_atr) and current_atr > 0.0 and (highs[t] > pending_short['y3'] + 0.6 * current_atr)
            lifetime = max(12, min(220, int(round(pending_short['span'] * (1.45 if pending_short['macro'] else 1.0)))))
            if invalidated or t - pending_short['x5'] > lifetime:
                pending_short = None
        if pending_long is not None:
            invalidated = np.isfinite(current_atr) and current_atr > 0.0 and (lows[t] < pending_long['y3'] - 0.6 * current_atr)
            lifetime = max(12, min(220, int(round(pending_long['span'] * (1.45 if pending_long['macro'] else 1.0)))))
            if invalidated or t - pending_long['x5'] > lifetime:
                pending_long = None
        if t >= 1 and finite_positive(current_atr):
            previous_atr = atr[t - 1]
            if pending_short is not None and finite_positive(previous_atr):
                dx = max(pending_short['x4'] - pending_short['x2'], 1)
                neckline_now = pending_short['y2'] + (pending_short['y4'] - pending_short['y2']) * (t - pending_short['x2']) / dx
                neckline_previous = pending_short['y2'] + (pending_short['y4'] - pending_short['y2']) * (t - 1 - pending_short['x2']) / dx
                normal = not pending_short['macro'] and t > pending_short['x5'] + 3 and (pending_short['q'] >= 68.0) and (closes[t] < neckline_now - 0.05 * current_atr) and (closes[t - 1] >= neckline_previous - 0.05 * previous_atr) and (closes[t] < opens[t]) and (abs(closes[t] - opens[t]) >= 0.18 * current_atr)
                delayed = pending_short['macro'] and t >= pending_short['x5'] + 7 and (pending_short['q'] >= 68.0) and (closes[t] < neckline_now - 0.12 * current_atr)
                if normal or delayed:
                    if t >= 13:
                        short_entries[t] = True
                    last_short_x5 = pending_short['x5']
                    pending_short = None
            if pending_long is not None:
                dx = max(pending_long['x4'] - pending_long['x2'], 1)
                neckline_now = pending_long['y2'] + (pending_long['y4'] - pending_long['y2']) * (t - pending_long['x2']) / dx
                neckline_previous = pending_long['y2'] + (pending_long['y4'] - pending_long['y2']) * (t - 1 - pending_long['x2']) / dx
                normal = not pending_long['macro'] and t > pending_long['x5'] + 3 and (pending_long['q'] >= 68.0) and (closes[t] > neckline_now + 0.05 * current_atr) and (closes[t - 1] <= neckline_previous + 0.05 * previous_atr) and (closes[t] > opens[t]) and (abs(closes[t] - opens[t]) >= 0.18 * current_atr)
                delayed = pending_long['macro'] and t >= pending_long['x5'] + 7 and (pending_long['q'] >= 68.0) and (closes[t] > neckline_now + 0.12 * current_atr)
                if normal or delayed:
                    if t >= 13:
                        long_entries[t] = True
                    last_long_x5 = pending_long['x5']
                    pending_long = None
    k_base = float(signal_params['k_base'])
    phi = float(signal_params['phi'])
    mult = float(signal_params['mult'])
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    illiq = np.full(size, np.nan, dtype=np.float64)
    for t in range(1, size):
        if np.isfinite(closes[t]) and np.isfinite(closes[t - 1]) and np.isfinite(volumes[t]) and (closes[t] > 0.0) and (volumes[t] > 0.0):
            illiq[t] = i5_illiquidity(closes[t] / closes[t - 1] - 1.0, closes[t], volumes[t])
    pending_entry = 0
    position = 0
    entry_price = np.nan
    entry_bar = -1
    best_price = np.nan
    current_stop = np.nan
    cum_volume = 0.0
    volume_sum = 0.0
    price_volume_sum = 0.0
    price_square_volume_sum = 0.0
    volume_target = np.nan
    z_entry = None
    previous_z = None
    for t in range(size):
        if pending_entry:
            position = pending_entry
            pending_entry = 0
            entry_price = float(opens[t])
            entry_bar = t
            best_price = entry_price
            current_stop = np.nan
            cum_volume = 0.0
            volume_sum = 0.0
            price_volume_sum = 0.0
            price_square_volume_sum = 0.0
            volume_target = float(np.mean(volumes[t - 14:t])) if t >= 14 and np.all(np.isfinite(volumes[t - 14:t])) and np.all(volumes[t - 14:t] > 0.0) else np.nan
            z_entry = None
            previous_z = None
        was_active = position != 0
        exited_this_bar = False
        if position:
            side = position
            liq_k = None
            if t >= 14 and np.all(np.isfinite(illiq[t - 13:t + 1])):
                recent = illiq[t - 13:t + 1]
                mean_illiq = float(np.mean(recent))
                std_illiq = float(np.std(recent))
                if std_illiq > 0.0:
                    liq_k = i5_liquidity_k(float(illiq[t]), mean_illiq, std_illiq, k_base, phi)
            if entry_bar == t and liq_k is not None:
                current_stop = entry_price - side * liq_k * atr[t]
            stop_hit = np.isfinite(current_stop) and i5_stop_touched(side, lows[t], highs[t], current_stop)
            next_volume_sum = volume_sum
            next_price_volume_sum = price_volume_sum
            next_price_square_volume_sum = price_square_volume_sum
            next_cum_volume = cum_volume
            current_z = None
            if np.isfinite(closes[t]) and np.isfinite(volumes[t]) and (volumes[t] > 0.0):
                next_volume_sum += volumes[t]
                next_price_volume_sum += closes[t] * volumes[t]
                next_price_square_volume_sum += closes[t] * closes[t] * volumes[t]
                next_cum_volume += volumes[t]
                if next_volume_sum > 0.0:
                    centered = max(0.0, next_price_square_volume_sum - next_price_volume_sum * next_price_volume_sum / next_volume_sum)
                    sigma = np.sqrt(centered / next_volume_sum)
                    if sigma > 0.0 and np.isfinite(sigma):
                        current_z = i5_vwap_z(closes[t], next_volume_sum, next_price_volume_sum, centered)
            reversion_hit = False
            if not stop_hit and np.isfinite(volume_target):
                reversion_hit = next_cum_volume >= volume_target
                if current_z is not None and z_entry is not None and (previous_z is not None):
                    reversion_hit = reversion_hit or i5_reversion(side, previous_z, current_z, z_entry, mult, next_cum_volume, volume_target)
            if stop_hit or reversion_hit:
                (long_exits if side == 1 else short_exits)[t] = True
                position = 0
                exited_this_bar = True
                entry_price = np.nan
                entry_bar = -1
                best_price = np.nan
                current_stop = np.nan
                cum_volume = 0.0
                volume_sum = 0.0
                price_volume_sum = 0.0
                price_square_volume_sum = 0.0
                volume_target = np.nan
                z_entry = None
                previous_z = None
            else:
                volume_sum = next_volume_sum
                price_volume_sum = next_price_volume_sum
                price_square_volume_sum = next_price_square_volume_sum
                cum_volume = next_cum_volume
                if current_z is not None and np.isfinite(current_z):
                    if z_entry is None:
                        z_entry = float(current_z)
                    previous_z = float(current_z)
                if side == 1 and np.isfinite(highs[t]):
                    best_price = max(best_price, highs[t])
                elif side == -1 and np.isfinite(lows[t]):
                    best_price = min(best_price, lows[t])
                if liq_k is not None and np.isfinite(current_stop):
                    current_stop = i5_stop(side, current_stop, best_price, liq_k, atr[t])
        if position == 0 and (not exited_this_bar) and (not was_active) and (t + 1 < size) and (t >= 13):
            long_enter = bool(long_entries[t] and (t == 0 or not long_entries[t - 1]))
            short_enter = bool(short_entries[t] and (t == 0 or not short_entries[t - 1]))
            if long_enter and (not short_enter):
                pending_entry = 1
            elif short_enter and (not long_enter):
                pending_entry = -1
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'head_shoulders_neckline_reversal', 'hypothesis': '經確認的頭肩與反頭肩結構在頸線完成收盤突破後，具有可交易的反轉延續性。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'phi', 'mult'], 'signal_parameter_sets': [{'k_base': 1.5, 'phi': 0.0, 'mult': 1.5}, {'k_base': 1.5, 'phi': 0.0, 'mult': 2.0}, {'k_base': 1.5, 'phi': 0.5, 'mult': 1.5}, {'k_base': 1.5, 'phi': 0.5, 'mult': 2.0}, {'k_base': 2.5, 'phi': 0.0, 'mult': 1.5}, {'k_base': 2.5, 'phi': 0.0, 'mult': 2.0}, {'k_base': 2.5, 'phi': 0.5, 'mult': 1.5}, {'k_base': 2.5, 'phi': 0.5, 'mult': 2.0}, {'k_base': 3.5, 'phi': 0.0, 'mult': 1.5}, {'k_base': 3.5, 'phi': 0.0, 'mult': 2.0}, {'k_base': 3.5, 'phi': 0.5, 'mult': 1.5}, {'k_base': 3.5, 'phi': 0.5, 'mult': 2.0}]}
