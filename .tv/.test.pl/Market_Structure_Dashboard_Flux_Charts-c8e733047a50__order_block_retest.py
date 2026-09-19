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

def _read_market_series(market, names, size):
    for name in names:
        if not hasattr(market, name):
            continue
        value = getattr(market, name)
        if callable(value):
            value = value()
        array = np.asarray(value, dtype=float)
        if array.ndim == 1 and array.size == size:
            return array
    raise ValueError(f'market.{names[0]} 必須是與 market.size 等長的一維陣列')

def _confirmed_swing_high(highs, center, length):
    window = highs[center - length:center + length + 1]
    if window.size != 2 * length + 1 or not np.all(np.isfinite(window)):
        return False
    center_value = window[length]
    return bool(center_value > np.max(np.concatenate((window[:length], window[length + 1:]))))

def _confirmed_swing_low(lows, center, length):
    window = lows[center - length:center + length + 1]
    if window.size != 2 * length + 1 or not np.all(np.isfinite(window)):
        return False
    center_value = window[length]
    return bool(center_value < np.min(np.concatenate((window[:length], window[length + 1:]))))

def _make_order_block(direction, pivot_bar, breakout_bar, highs, lows):
    start = int(pivot_bar)
    stop = int(breakout_bar)
    if start < 0 or stop <= start:
        return None
    values = lows[start:stop] if direction == 1 else highs[start:stop]
    if values.size == 0 or not np.all(np.isfinite(values)):
        return None
    offset = int(np.argmin(values) if direction == 1 else np.argmax(values))
    bar = start + offset
    top = float(highs[bar])
    bottom = float(lows[bar])
    if not np.isfinite(top) or not np.isfinite(bottom) or top < bottom:
        return None
    return (direction, top, bottom, bar)

def _add_order_block(zones, zone, max_zones):
    direction, top, bottom, _ = zone
    for old_direction, old_top, old_bottom, _ in zones:
        if old_direction == direction and top >= old_bottom and (bottom <= old_top):
            return
    zones.insert(0, zone)
    del zones[max_zones:]

def _nearest_zone(zones, close):
    nearest_bull = None
    nearest_bear = None
    for zone in zones:
        direction, top, bottom, _ = zone
        if direction == 1:
            distance = top - close
            candidate = (abs(distance), zone)
            if nearest_bull is None or candidate[0] < nearest_bull[0]:
                nearest_bull = candidate
        else:
            distance = bottom - close
            candidate = (abs(distance), zone)
            if nearest_bear is None or candidate[0] < nearest_bear[0]:
                nearest_bear = candidate
    if nearest_bull is not None and (nearest_bear is None or nearest_bull[0] < nearest_bear[0]):
        return (1, nearest_bull[1])
    if nearest_bear is not None:
        return (-1, nearest_bear[1])
    return (0, None)

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    params = dict(signal_params or {})
    swing_length = max(1, int(params.get('swing_length', 5)))
    max_zones = max(1, int(params.get('ob_lookback', 6)))
    highs = _read_market_series(market, ('highs', 'high'), size)
    lows = _read_market_series(market, ('lows', 'low'), size)
    closes = _read_market_series(market, ('closes', 'close'), size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    zones = []
    last_swing_high = None
    last_swing_high_bar = None
    last_swing_low = None
    last_swing_low_bar = None
    for t in range(size):
        center = t - swing_length
        if center >= swing_length:
            if _confirmed_swing_high(highs, center, swing_length):
                last_swing_high = float(highs[center])
                last_swing_high_bar = center
            if _confirmed_swing_low(lows, center, swing_length):
                last_swing_low = float(lows[center])
                last_swing_low_bar = center
        previous_close = closes[t - 1] if t > 0 else np.nan
        bull_break = last_swing_high is not None and np.isfinite(previous_close) and np.isfinite(closes[t]) and (closes[t] > last_swing_high) and (previous_close <= last_swing_high)
        bear_break = last_swing_low is not None and np.isfinite(previous_close) and np.isfinite(closes[t]) and (closes[t] < last_swing_low) and (previous_close >= last_swing_low)
        if bull_break:
            zone = _make_order_block(1, last_swing_high_bar, t, highs, lows)
            if zone is not None:
                _add_order_block(zones, zone, max_zones)
            last_swing_high = None
            last_swing_high_bar = None
        if bear_break:
            zone = _make_order_block(-1, last_swing_low_bar, t, highs, lows)
            if zone is not None:
                _add_order_block(zones, zone, max_zones)
            last_swing_low = None
            last_swing_low_bar = None
        if np.isfinite(closes[t]):
            zones = [zone for zone in zones if not (zone[0] == 1 and closes[t] < zone[2] or (zone[0] == -1 and closes[t] > zone[1]))]
            nearest_direction, nearest = _nearest_zone(zones, closes[t])
            if nearest is not None:
                if nearest_direction == 1 and nearest[1] - closes[t] >= 0.0:
                    long_entries[t] = True
                elif nearest_direction == -1 and nearest[2] - closes[t] <= 0.0:
                    short_entries[t] = True
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'order_block_retest', 'hypothesis': '結構突破後形成的訂單塊回測，可能提供順勢支撐或阻力反應。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['swing_length', 'ob_lookback', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'swing_length': 5, 'ob_lookback': 6, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
