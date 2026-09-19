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

def _clamp01(value):
    return max(0.0, min(1.0, float(value)))

def _line_value(x1, y1, x2, y2, x):
    return y1 + (y2 - y1) / max(float(x2 - x1), 1.0) * (x - x1)

def _add_pivot(types, bars, prices, pivot_type, pivot_bar, pivot_price):
    if types and types[-1] == pivot_type:
        replace = pivot_type == 1 and pivot_price > prices[-1] or (pivot_type == -1 and pivot_price < prices[-1])
        if replace:
            bars[-1] = pivot_bar
            prices[-1] = pivot_price
            return True
        return False
    types.append(pivot_type)
    bars.append(pivot_bar)
    prices.append(pivot_price)
    if len(types) > 20:
        del types[0]
        del bars[0]
        del prices[0]
    return True

def _scan_structure(types, bars, prices, atr_value):
    if len(types) < 4 or not np.isfinite(atr_value) or atr_value <= 0.0:
        return None
    first = max(0, len(types) - 10)
    best = None
    best_quality = -1.0
    for i in range(first, len(types) - 3):
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
                    tail_pivots = len(types) - 1 - m
                    if not (18 <= span <= 180 and tail_pivots <= 2):
                        continue
                    y1, y2, y3, y4 = (prices[i], prices[j], prices[k], prices[m])
                    if t1 == 1:
                        upper = (x1, y1, x3, y3)
                        lower = (x2, y2, x4, y4)
                    else:
                        lower = (x1, y1, x3, y3)
                        upper = (x2, y2, x4, y4)
                    upper_slope = (upper[3] - upper[1]) / max(float(upper[2] - upper[0]), 1.0)
                    lower_slope = (lower[3] - lower[1]) / max(float(lower[2] - lower[0]), 1.0)
                    upper_slope_atr = upper_slope / atr_value
                    lower_slope_atr = lower_slope / atr_value
                    convergence_atr = lower_slope_atr - upper_slope_atr
                    upper_start = _line_value(*upper, x1)
                    lower_start = _line_value(*lower, x1)
                    upper_end = _line_value(*upper, x4)
                    lower_end = _line_value(*lower, x4)
                    width_start = upper_start - lower_start
                    width_end = upper_end - lower_end
                    end_ratio = width_end / width_start if width_start > 0.0 else 999.0
                    if width_start < 1.1 * atr_value or width_end <= 0.0 or (not 0.0 < end_ratio <= 0.82) or (convergence_atr < 0.012):
                        continue
                    if upper_slope_atr <= -0.008 and lower_slope_atr >= 0.008:
                        kind = 1
                        slope_shape = _clamp01(min(abs(upper_slope_atr), abs(lower_slope_atr)) / 0.032)
                    elif abs(upper_slope_atr) <= 0.03 and lower_slope_atr >= 0.008:
                        kind = 2
                        slope_shape = 0.5 * _clamp01(1.0 - abs(upper_slope_atr) / 0.03) + 0.5 * _clamp01(lower_slope_atr / 0.032)
                    elif upper_slope_atr <= -0.008 and abs(lower_slope_atr) <= 0.03:
                        kind = 3
                        slope_shape = 0.5 * _clamp01(1.0 - abs(lower_slope_atr) / 0.03) + 0.5 * _clamp01(abs(upper_slope_atr) / 0.032)
                    else:
                        continue
                    closing_speed = lower_slope - upper_slope
                    apex_ahead = width_end / closing_speed if closing_speed > 0.0 else 280.0
                    quality = min(100.0, _clamp01((0.82 - end_ratio) / 0.72) * 27.0 + slope_shape * 25.0 + _clamp01(width_start / (1.1 * atr_value * 2.5)) * 16.0 + _clamp01(span / (180.0 * 0.65)) * 12.0 + _clamp01(1.0 - tail_pivots / 3.0) * 10.0 + _clamp01(1.0 - apex_ahead / 140.0) * 10.0)
                    if quality > best_quality:
                        best_quality = quality
                        best = {'upper': upper, 'lower': lower}
    return best if best_quality >= 72.0 else None

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = getattr(market, 'opens', None)
    if opens is None:
        opens = market.open
    opens = np.asarray(opens, dtype=float)
    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    volumes = np.asarray(market.volumes, dtype=float)
    atr = np.asarray(features.atr(14), dtype=float)
    arrays = (opens, highs, lows, closes, volumes, atr)
    if any((array.ndim != 1 or array.size != size for array in arrays)):
        raise ValueError('market data and ATR must match market.size as one-dimensional arrays')
    pivot_types = []
    pivot_bars = []
    pivot_prices = []
    for t in range(size):
        pivot_bar = t - 3
        if pivot_bar >= 3:
            left = pivot_bar - 3
            right = pivot_bar + 4
            high_window = highs[left:right]
            low_window = lows[left:right]
            if np.all(np.isfinite(high_window)) and highs[pivot_bar] >= np.max(high_window):
                _add_pivot(pivot_types, pivot_bars, pivot_prices, 1, pivot_bar, highs[pivot_bar])
            if np.all(np.isfinite(low_window)) and lows[pivot_bar] <= np.min(low_window):
                _add_pivot(pivot_types, pivot_bars, pivot_prices, -1, pivot_bar, lows[pivot_bar])
        structure = _scan_structure(pivot_types, pivot_bars, pivot_prices, atr[t])
        if structure is None or t == 0 or (not np.isfinite(atr[t - 1])) or (atr[t - 1] <= 0.0):
            continue
        upper = structure['upper']
        lower = structure['lower']
        upper_now = _line_value(*upper, t)
        lower_now = _line_value(*lower, t)
        upper_prev = _line_value(*upper, t - 1)
        lower_prev = _line_value(*lower, t - 1)
        long_cross = closes[t] > upper_now + 0.06 * atr[t] and closes[t - 1] <= upper_prev + 0.06 * atr[t - 1]
        short_cross = closes[t] < lower_now - 0.06 * atr[t] and closes[t - 1] >= lower_prev - 0.06 * atr[t - 1]
        body_ok = abs(closes[t] - opens[t]) >= 0.15 * atr[t]
        long_entries[t] = bool(long_cross and closes[t] > opens[t] and body_ok)
        short_entries[t] = bool(short_cross and closes[t] < opens[t] and body_ok)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'triangle_breakout_both', 'hypothesis': '三角形收斂後的確認突破具有方向性延續優勢。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': [], 'signal_parameter_sets': [{}]}
