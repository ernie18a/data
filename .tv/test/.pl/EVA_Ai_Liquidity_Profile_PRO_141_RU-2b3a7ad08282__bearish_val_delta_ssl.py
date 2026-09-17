import numpy as np


def _array(market, name, size):
    value = np.asarray(getattr(market, name), dtype=float)
    if value.ndim != 1 or value.size != size:
        raise ValueError(f'market.{name} must be one-dimensional with size {size}')
    return value


def _param(params, name, default):
    value = float(params.get(name, default))
    if not np.isfinite(value):
        raise ValueError(f'{name} must be finite')
    return value


def _profile(t, highs, lows, closes, opens, volumes, window, fraction):
    start = max(0, t - window + 1)
    h = highs[start:t + 1]
    l = lows[start:t + 1]
    c = closes[start:t + 1]
    o = opens[start:t + 1]
    v = volumes[start:t + 1]
    valid = np.isfinite(h) & np.isfinite(l) & np.isfinite(c) & np.isfinite(o) & np.isfinite(v) & (v > 0.0)
    if not np.any(valid):
        return np.nan, np.nan, np.nan
    h, l, c, o, v = h[valid], l[valid], c[valid], o[valid], v[valid]
    h, l = np.maximum(h, l), np.minimum(h, l)
    raw_low, raw_high = float(np.min(l)), float(np.max(h))
    total = float(np.sum(v))
    if raw_high <= raw_low:
        delta = float(np.sum(np.where(c >= o, v, -v))) / total * 100.0
        return raw_low, raw_high, delta
    rows = 36 if v.size < 300 else 48 if v.size < 900 else 60 if v.size < 2400 else 72 if v.size < 6000 else 80
    step = (raw_high - raw_low) / max(1, rows - 1)
    first = np.clip(np.floor((l - raw_low) / step).astype(int), 0, rows - 1)
    last = np.clip(np.floor((h - raw_low) / step).astype(int), 0, rows - 1)
    span = np.maximum(h - l, np.finfo(float).eps)
    profile = np.zeros(rows, dtype=float)
    up = np.zeros(rows, dtype=float)
    down = np.zeros(rows, dtype=float)
    diff = np.zeros(rows + 1, dtype=float)
    up_diff = np.zeros(rows + 1, dtype=float)
    down_diff = np.zeros(rows + 1, dtype=float)
    same = first == last
    overlap = np.maximum(0.0, np.minimum(h, raw_low + (first + 1) * step) - np.maximum(l, raw_low + first * step))
    np.add.at(profile, first[same], v[same] * overlap[same] / span[same])
    np.add.at(up, first[same], np.where(c[same] >= o[same], v[same] * overlap[same] / span[same], 0.0))
    np.add.at(down, first[same], np.where(c[same] < o[same], v[same] * overlap[same] / span[same], 0.0))
    multi = ~same
    last_overlap = np.maximum(0.0, np.minimum(h, raw_low + (last + 1) * step) - np.maximum(l, raw_low + last * step))
    first_volume = v * overlap / span
    last_volume = v * last_overlap / span
    np.add.at(profile, first[multi], first_volume[multi])
    np.add.at(profile, last[multi], last_volume[multi])
    np.add.at(diff, first[multi] + 1, v[multi] * step / span[multi])
    np.add.at(diff, last[multi], -v[multi] * step / span[multi])
    np.add.at(up, first[multi], np.where(c[multi] >= o[multi], first_volume[multi], 0.0))
    np.add.at(up, last[multi], np.where(c[multi] >= o[multi], last_volume[multi], 0.0))
    np.add.at(down, first[multi], np.where(c[multi] < o[multi], first_volume[multi], 0.0))
    np.add.at(down, last[multi], np.where(c[multi] < o[multi], last_volume[multi], 0.0))
    np.add.at(up_diff, first[multi] + 1, np.where(c[multi] >= o[multi], v[multi] * step / span[multi], 0.0))
    np.add.at(up_diff, last[multi], np.where(c[multi] >= o[multi], -v[multi] * step / span[multi], 0.0))
    np.add.at(down_diff, first[multi] + 1, np.where(c[multi] < o[multi], v[multi] * step / span[multi], 0.0))
    np.add.at(down_diff, last[multi], np.where(c[multi] < o[multi], -v[multi] * step / span[multi], 0.0))
    profile += np.cumsum(diff[:-1])
    up += np.cumsum(up_diff[:-1])
    down += np.cumsum(down_diff[:-1])
    poc = int(np.flatnonzero(np.isclose(profile, np.max(profile), rtol=1e-10, atol=1e-10 * max(1.0, np.max(profile))))[0])
    target = total * fraction
    left = right = poc
    covered = float(profile[poc])
    while covered < target and (left > 0 or right < rows - 1):
        lower = profile[left - 1] if left > 0 else -1.0
        upper = profile[right + 1] if right < rows - 1 else -1.0
        choose_upper = right == rows - 1 or (left > 0 and upper <= lower)
        chosen = max(0.0, upper if choose_upper else lower)
        if covered + chosen > target + max(1e-10, total * 1e-10):
            break
        if choose_upper:
            right += 1
        else:
            left -= 1
        covered += chosen
    delta = (float(np.sum(up)) - float(np.sum(down))) / total * 100.0
    return raw_low + left * step, raw_low + (right + 1) * step, delta


def _ssl_levels(highs, lows, closes, opens, volumes, atr, pivot, width, quality_limit, lookback, visibility):
    size = closes.size
    result = np.full(size, np.nan, dtype=float)
    candidates = []
    zones = []
    tick = 1e-12
    for t in range(size):
        candidates = [x for x in candidates if t - x[3] <= lookback and not (t > x[3] + pivot and lows[t] <= x[0] - x[1])]
        kept = []
        for z in zones:
            if t - z['created'] > lookback or (t > z['created'] and lows[t] <= z['bottom']):
                continue
            if t > z['created'] and lows[t] <= z['top']:
                z['tested'] = True
            kept.append(z)
        zones = kept
        center = t - pivot
        if center >= pivot:
            left = lows[center - pivot:center]
            right = lows[center + 1:center + pivot + 1]
            price = lows[center]
            if np.isfinite(price) and np.all(np.isfinite(left)) and np.all(np.isfinite(right)) and price <= np.min(left) and price <= np.min(right):
                pivot_atr = atr[center] if np.isfinite(atr[center]) and atr[center] > 0.0 else tick * 10.0
                half = max(tick * 2.0, pivot_atr * width)
                candle_range = max(tick, highs[center] - lows[center])
                wick = max(0.0, min(opens[center], closes[center]) - lows[center])
                wick_ratio = wick / candle_range
                v0 = volumes[center]
                vwin = volumes[max(0, center - 19):center + 1]
                mean = float(np.mean(vwin)) if vwin.size == 20 and np.all(np.isfinite(vwin)) and np.mean(vwin) > 0.0 else v0
                if np.isfinite(v0) and v0 > 0.0 and np.isfinite(mean) and mean > 0.0:
                    evidence = min(25.0, max(0.0, (v0 / mean) / 1.5 * 25.0)) + min(20.0, max(0.0, wick_ratio / 0.45 * 20.0))
                    matches = [(i, abs(price - old[0])) for i, old in enumerate(candidates) if center - old[3] >= pivot * 2 and center - old[3] <= lookback and abs(price - old[0]) <= max(half, old[1]) * 1.25]
                    if matches:
                        index = min(matches, key=lambda x: x[1])[0]
                        old_price, old_half, old_evidence, old_index = candidates[index]
                        separation = center - old_index
                        q = min(100.0, 45.0 + (evidence + old_evidence) * 0.5 + min(10.0, separation / max(1.0, pivot * 8.0) * 10.0))
                        if q >= quality_limit:
                            level = (price + old_price) * 0.5
                            matched = next((z for z in zones if abs(level - z['center']) <= max(half, z['half']) * 1.25), None)
                            if matched is None:
                                zones.append({'center': level, 'half': half, 'quality': q, 'touches': 2, 'tested': False, 'created': t})
                            else:
                                n = matched['touches'] + 1
                                matched['center'] = (matched['center'] * matched['touches'] + level) / n
                                matched['half'] = max(matched['half'], half)
                                matched['quality'] = min(100.0, max(matched['quality'], q) + min(8.0, max(0.0, (n - 2.0) * 3.0)))
                                matched['touches'] = n
                                matched['tested'] = False
                                matched['created'] = t
                    candidates.append((float(price), half, evidence, center))
                    candidates = candidates[-24:]
        if np.isfinite(closes[t]):
            safe_atr = atr[t] if np.isfinite(atr[t]) and atr[t] > 0.0 else tick * 10.0
            visible = [z['center'] for z in zones if z['center'] < closes[t] and abs(z['center'] - closes[t]) / safe_atr <= visibility]
            if visible:
                result[t] = max(visible)
    return result


def generate_signals(features, signal_params):
    import numpy as np
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return long_entries, long_exits, short_entries, short_exits
    highs = _array(features.market, 'highs', size)
    lows = _array(features.market, 'lows', size)
    closes = _array(features.market, 'closes', size)
    volumes = _array(features.market, 'volumes', size)
    raw_opens = getattr(features.market, 'opens', None)
    opens = _array(features.market, 'opens', size) if raw_opens is not None else np.r_[closes[0], closes[:-1]]
    atr = np.asarray(features.atr(14), dtype=float)
    if atr.ndim != 1 or atr.size != size:
        raise ValueError('features.atr(14) must match market.size')
    profile_window = int(_param(signal_params, 'profile_window', 3000.0))
    value_area_fraction = _param(signal_params, 'value_area_fraction', 0.70)
    pivot_window = int(_param(signal_params, 'pivot_window', 4.0))
    zone_width_atr = _param(signal_params, 'zone_width_atr', 0.10)
    quality_limit = _param(signal_params, 'quality_limit', 72.0)
    liquidity_lookback = int(_param(signal_params, 'liquidity_lookback', 500.0))
    visibility_atr = _param(signal_params, 'visibility_atr', 8.0)
    if profile_window < 1 or pivot_window < 2 or not 0.5 <= value_area_fraction <= 0.95 or zone_width_atr <= 0.0 or quality_limit < 0.0 or liquidity_lookback < 1 or visibility_atr <= 0.0:
        raise ValueError('invalid signal parameters')
    vals = np.full(size, np.nan, dtype=float)
    vahs = np.full(size, np.nan, dtype=float)
    deltas = np.full(size, np.nan, dtype=float)
    for t in range(size):
        vals[t], vahs[t], deltas[t] = _profile(t, highs, lows, closes, opens, volumes, profile_window, value_area_fraction)
    ssl = _ssl_levels(highs, lows, closes, opens, volumes, atr, pivot_window, zone_width_atr, quality_limit, liquidity_lookback, visibility_atr)
    crossed_below = (closes[1:] < vals[1:]) & (closes[:-1] >= vals[:-1])
    valid_ssl = np.isfinite(ssl[1:]) & (closes[1:] > ssl[1:])
    short_entries[1:] = crossed_below & (deltas[1:] < 0.0) & valid_ssl
    returned_to_value = (closes[1:] >= vals[1:]) & (closes[1:] <= vahs[1:])
    short_exits[1:] = returned_to_value & (closes[:-1] < vals[:-1])
    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'bearish_val_delta_ssl',
    'hypothesis': '價格下穿 Value Area 下緣且 Down Volume 優勢、下方仍有有效 SSL 時，偏向延續下跌。',
    'position': 'short',
    'generate_signals': generate_signals,
    'signal_parameter_names': ['profile_window', 'value_area_fraction', 'pivot_window', 'zone_width_atr', 'quality_limit', 'liquidity_lookback', 'visibility_atr'],
    'signal_parameter_sets': [{'profile_window': 3000, 'value_area_fraction': 0.70, 'pivot_window': 4, 'zone_width_atr': 0.10, 'quality_limit': 72.0, 'liquidity_lookback': 500, 'visibility_atr': 8.0}],
}