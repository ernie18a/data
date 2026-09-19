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

def _array(market, name, fallback=None):
    value = getattr(market, name, fallback)
    if value is None:
        raise AttributeError(f'features.market.{name} is required')
    return np.asarray(value, dtype=float)

def _aggregate(opens, highs, lows, closes, volumes, factor):
    size = len(closes)
    factor = max(1, int(factor))
    groups = size // factor
    if groups == 0:
        return tuple((np.empty(0, dtype=float) for _ in range(6)))
    ao = np.empty(groups, dtype=float)
    ah = np.empty(groups, dtype=float)
    al = np.empty(groups, dtype=float)
    ac = np.empty(groups, dtype=float)
    av = np.empty(groups, dtype=float)
    ends = np.empty(groups, dtype=int)
    for group in range(groups):
        start = group * factor
        end = start + factor
        ao[group] = opens[start]
        ah[group] = np.max(highs[start:end])
        al[group] = np.min(lows[start:end])
        ac[group] = closes[end - 1]
        av[group] = np.sum(volumes[start:end])
        ends[group] = end - 1
    return (ao, ah, al, ac, av, ends)

def _ema(values, length):
    result = np.empty(len(values), dtype=float)
    if not len(values):
        return result
    alpha = 2.0 / (max(1, int(length)) + 1.0)
    result[0] = values[0]
    for index in range(1, len(values)):
        result[index] = alpha * values[index] + (1.0 - alpha) * result[index - 1]
    return result

def _pivots(highs, lows, length):
    length = max(1, int(length))
    size = len(highs)
    pivot_high = np.full(size, np.nan, dtype=float)
    pivot_low = np.full(size, np.nan, dtype=float)
    width = 2 * length + 1
    for index in range(width - 1, size):
        center = index - length
        high_window = highs[index - width + 1:index + 1]
        low_window = lows[index - width + 1:index + 1]
        if highs[center] >= np.max(high_window):
            pivot_high[index] = highs[center]
        if lows[center] <= np.min(low_window):
            pivot_low[index] = lows[center]
    return (pivot_high, pivot_low)

def _nearest_zone(zones, close):
    bull_distance = np.inf
    bear_distance = np.inf
    for direction, top, bottom in zones:
        if direction == 1:
            bull_distance = min(bull_distance, abs(top - close))
        else:
            bear_distance = min(bear_distance, abs(bottom - close))
    if bull_distance < bear_distance and np.isfinite(bull_distance):
        return 1
    if np.isfinite(bear_distance):
        return -1
    return 0

def _components(opens, highs, lows, closes, volumes, params):
    size = len(closes)
    structure = np.zeros(size, dtype=float)
    order_block = np.zeros(size, dtype=float)
    fvg = np.zeros(size, dtype=float)
    ema_direction = np.zeros(size, dtype=float)
    swing_position = np.zeros(size, dtype=float)
    if size == 0:
        return (structure, order_block, fvg, ema_direction, swing_position)
    swing_length = max(1, int(params.get('swing_length', 5)))
    ob_lookback = max(1, int(params.get('ob_lookback', 6)))
    fvg_lookback = max(1, int(params.get('fvg_lookback', 6)))
    pivot_high, pivot_low = _pivots(highs, lows, swing_length)
    ema = _ema(closes, int(params.get('ema_length', 9)))
    previous_high = current_high = np.nan
    previous_low = current_low = np.nan
    high_type = low_type = 0
    last_pivot_high = last_pivot_low = np.nan
    last_pivot_high_bar = last_pivot_low_bar = -1
    zones = []
    fvgs = []
    green = np.zeros(size, dtype=bool)
    red = np.zeros(size, dtype=bool)
    if size > 1:
        green[1:] = (closes[1:] > opens[1:]) | (closes[1:] > closes[:-1])
        red[1:] = (closes[1:] < opens[1:]) | (closes[1:] < closes[:-1])
    for index in range(size):
        if np.isfinite(pivot_high[index]):
            previous_high = current_high
            current_high = pivot_high[index]
            if np.isfinite(previous_high):
                high_type = 1 if current_high > previous_high else -1
            last_pivot_high = pivot_high[index]
            last_pivot_high_bar = index - swing_length
        if np.isfinite(pivot_low[index]):
            previous_low = current_low
            current_low = pivot_low[index]
            if np.isfinite(previous_low):
                low_type = 1 if current_low > previous_low else -1
            last_pivot_low = pivot_low[index]
            last_pivot_low_bar = index - swing_length
        runtime_high_type = high_type
        runtime_low_type = low_type
        if np.isfinite(previous_low) and closes[index] < previous_low:
            runtime_low_type = -1
        if np.isfinite(previous_high) and closes[index] > previous_high:
            runtime_high_type = 1
        if runtime_high_type == 1 and runtime_low_type == 1:
            structure[index] = 1
        elif runtime_high_type == -1 and runtime_low_type == -1:
            structure[index] = -1
        if np.isfinite(current_high) and np.isfinite(current_low):
            swing_range = max(current_high - current_low, np.finfo(float).eps)
            swing_pct = (closes[index] - current_low) / swing_range * 100.0
            if swing_pct < 0.0:
                swing_position[index] = -1
            elif swing_pct > 100.0:
                swing_position[index] = 1
            elif swing_pct < 30.0:
                swing_position[index] = 1
            elif swing_pct > 70.0:
                swing_position[index] = -1
        previous_close = closes[index - 1] if index else np.nan
        bull_break = np.isfinite(last_pivot_high) and np.isfinite(previous_close) and (previous_close <= last_pivot_high) and (closes[index] > last_pivot_high)
        bear_break = np.isfinite(last_pivot_low) and np.isfinite(previous_close) and (previous_close >= last_pivot_low) and (closes[index] < last_pivot_low)
        for direction, pivot_bar in ((1, last_pivot_high_bar), (-1, last_pivot_low_bar)):
            if direction == 1 and (not bull_break) or (direction == -1 and (not bear_break)):
                continue
            bars_back = max(0, index - pivot_bar - 1)
            start = max(0, index - min(bars_back, 50))
            if direction == 1:
                candle = start + int(np.argmin(lows[start:index + 1]))
            else:
                candle = start + int(np.argmax(highs[start:index + 1]))
            top = highs[candle]
            bottom = lows[candle]
            overlaps = any((old_direction == direction and top >= old_bottom and (bottom <= old_top) for old_direction, old_top, old_bottom in zones))
            if not overlaps:
                zones.insert(0, (direction, top, bottom))
                del zones[ob_lookback:]
        zones = [zone for zone in zones if not (zone[0] == 1 and closes[index] < zone[2]) and (not (zone[0] == -1 and closes[index] > zone[1]))]
        order_block[index] = _nearest_zone(zones, closes[index])
        if index >= 3:
            bull_gap = lows[index - 1] > highs[index - 3] and green[index - 2] and (lows[index - 1] < highs[index - 2]) and (lows[index - 2] < highs[index - 3])
            bear_gap = highs[index - 1] < lows[index - 3] and red[index - 2] and (highs[index - 1] > lows[index - 2]) and (highs[index - 2] > lows[index - 3])
            if bull_gap:
                fvgs.insert(0, (1, lows[index - 1], highs[index - 3]))
                del fvgs[fvg_lookback:]
            if bear_gap:
                fvgs.insert(0, (-1, lows[index - 3], highs[index - 1]))
                del fvgs[fvg_lookback:]
        fvgs = [zone for zone in fvgs if not (zone[0] == 1 and lows[index] < zone[2]) and (not (zone[0] == -1 and highs[index] > zone[1]))]
        fvg[index] = _nearest_zone(fvgs, closes[index])
        ema_direction[index] = 1 if closes[index] > ema[index] else -1
    return (structure, order_block, fvg, ema_direction, swing_position)

def _align(values, size, factor):
    result = np.zeros(size, dtype=float)
    if not len(values):
        return result
    for index in range(size):
        completed = (index + 1) // factor - 1
        if completed >= 0:
            result[index] = values[min(completed, len(values) - 1)]
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    market = features.market
    closes = _array(market, 'closes')
    highs = _array(market, 'highs')
    lows = _array(market, 'lows')
    volumes = _array(market, 'volumes')
    opens = _array(market, 'opens', closes)
    if not len(closes) == len(highs) == len(lows) == len(volumes) == size:
        raise ValueError('market OHLCV arrays must match features.market.size')
    factor_defaults = (1, 5, 15, 60, 240, 1440, 10080)
    weight_defaults = (1, 1, 2, 2, 2, 3, 4)
    factor_names = ('use_structure', 'use_order_block', 'use_fvg', 'use_ema', 'use_swing')
    factor_defaults_enabled = (True, True, True, False, True)
    factor_enabled = tuple((bool(signal_params.get(name, default)) for name, default in zip(factor_names, factor_defaults_enabled)))
    factor_count = sum(factor_enabled)
    points = np.zeros(size, dtype=float)
    max_score = 0.0
    for slot in range(1, 8):
        if not bool(signal_params.get(f'tf{slot}_enabled', True)):
            continue
        weight = max(0.0, float(signal_params.get(f'tf{slot}_weight', weight_defaults[slot - 1])))
        factor = max(1, int(signal_params.get(f'tf{slot}_bars', factor_defaults[slot - 1])))
        if weight <= 0.0 or factor_count == 0:
            continue
        aggregated = _aggregate(opens, highs, lows, closes, volumes, factor)
        components = _components(*aggregated[:5], signal_params)
        for use, values in zip(factor_enabled, components):
            if use:
                points += weight * _align(values, size, factor)
        max_score += weight * factor_count
    bias_pct = np.divide(points * 100.0, max_score, out=np.zeros(size, dtype=float), where=max_score > 0.0)
    previous_bias = np.empty(size, dtype=float)
    if size:
        previous_bias[0] = bias_pct[0]
        previous_bias[1:] = bias_pct[:-1]
    long_entries = (bias_pct > 20.0) & (previous_bias <= 20.0)
    short_entries = (bias_pct < -20.0) & (previous_bias >= -20.0)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'weighted_mtf_bias_cross', 'hypothesis': '多時間框架的加權結構、供需區、缺口、EMA 與擺動位置共振突破偏壓門檻時，方向延續機率較高。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['tf1_enabled', 'tf1_bars', 'tf1_weight', 'tf2_enabled', 'tf2_bars', 'tf2_weight', 'tf3_enabled', 'tf3_bars', 'tf3_weight', 'tf4_enabled', 'tf4_bars', 'tf4_weight', 'tf5_enabled', 'tf5_bars', 'tf5_weight', 'tf6_enabled', 'tf6_bars', 'tf6_weight', 'tf7_enabled', 'tf7_bars', 'tf7_weight', 'use_structure', 'use_order_block', 'use_fvg', 'use_ema', 'use_swing', 'ema_length', 'swing_length', 'ob_lookback', 'fvg_lookback', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'tf1_enabled': True, 'tf1_bars': 1, 'tf1_weight': 1, 'tf2_enabled': True, 'tf2_bars': 5, 'tf2_weight': 1, 'tf3_enabled': True, 'tf3_bars': 15, 'tf3_weight': 2, 'tf4_enabled': True, 'tf4_bars': 60, 'tf4_weight': 2, 'tf5_enabled': True, 'tf5_bars': 240, 'tf5_weight': 2, 'tf6_enabled': True, 'tf6_bars': 1440, 'tf6_weight': 3, 'tf7_enabled': True, 'tf7_bars': 10080, 'tf7_weight': 4, 'use_structure': True, 'use_order_block': True, 'use_fvg': True, 'use_ema': False, 'use_swing': True, 'ema_length': 9, 'swing_length': 5, 'ob_lookback': 6, 'fvg_lookback': 6, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
