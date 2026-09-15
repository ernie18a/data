import numpy as np

def i5_illiquidity(return_t: float, close: float, volume: float) -> float:
    return abs(return_t) / (close * volume)

def i5_liquidity_k(illiq: float, mean: float, std: float, k_base: float, phi: float) -> float:
    return k_base * (1.0 + phi * max(0.0, (illiq - mean) / std))

def i5_stop(side: int, previous_stop: float, best: float, k: float, atr: float) -> float:
    return side * max(side * previous_stop, side * (best - side * k * atr))

def i5_stop_touched(side: int, low: float, high: float, stop: float) -> bool:
    return side == 1 and low < stop or (side == -1 and high > stop)

def i5_vwap_z(close: float, volume_sum: float, price_volume_sum: float, centered_square_volume_sum: float) -> float:
    from math import sqrt
    return (close - price_volume_sum / volume_sum) / sqrt(centered_square_volume_sum / volume_sum)

def i5_reversion(side: int, previous_z: float, z: float, z_entry: float, mult: float, cumulative_volume: float, volume_target: float) -> bool:
    return side * previous_z <= 0.0 < side * z or abs(z) > mult * abs(z_entry) or cumulative_volume >= volume_target

def generate_signals(features, signal_params):
    market = features.market
    opens = np.asarray(market.opens, dtype=np.float64)
    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    closes = np.asarray(market.closes, dtype=np.float64)
    volumes = np.asarray(market.volumes, dtype=np.float64)
    n = int(market.size)
    empty = np.zeros(n, dtype=np.bool_)
    if n == 0:
        return (empty.copy(), empty.copy(), empty.copy(), empty.copy())

    def lag(values, steps):
        result = np.empty_like(values)
        result.fill(False if values.dtype == np.bool_ else np.nan)
        if steps == 0:
            result[:] = values
        elif steps < n:
            result[steps:] = values[:-steps]
        return result
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & np.isfinite(volumes)
    ranges = highs - lows
    bodies = closes - opens
    body_high = np.maximum(opens, closes)
    body_low = np.minimum(opens, closes)
    upper_wick = highs - body_high
    lower_wick = body_low - lows
    mids = (opens + closes) / 2.0
    body_pos = (mids - lows) / ranges
    valid0 = finite & (ranges > 0.0)
    rv = np.where(np.isfinite(ranges), ranges, 0.0)
    rg = np.isfinite(ranges)
    rs = np.concatenate((np.array([0.0]), np.cumsum(rv)))
    rc = np.concatenate(np.array([0], dtype=np.int64), np.cumsum(rg.astype(np.int64)))
    prev_range = np.full(n, np.nan)
    if n > 14:
        prev_range[14:] = (rs[14:] - rs[:-14]) / 14.0
        prev_range[14:][rc[14:] - rc[:-14] != 14] = np.nan
    tall0 = valid0 & np.isfinite(prev_range) & (ranges >= 1.5 * prev_range)
    us = np.concatenate((np.array([0.0]), np.cumsum(np.where(np.isfinite(upper_wick), upper_wick, 0.0))))
    ls = np.concatenate((np.array([0.0]), np.cumsum(np.where(np.isfinite(lower_wick), lower_wick, 0.0))))
    uc = np.concatenate(np.array([0], dtype=np.int64), np.cumsum(np.isfinite(upper_wick).astype(np.int64)))
    lc = np.concatenate(np.array([0], dtype=np.int64), np.cumsum(np.isfinite(lower_wick).astype(np.int64)))
    prev_uw = np.full(n, np.nan)
    prev_lw = np.full(n, np.nan)
    if n > 14:
        prev_uw[14:] = (us[14:] - us[:-14]) / 14.0
        prev_lw[14:] = (ls[14:] - ls[:-14]) / 14.0
        prev_uw[14:][uc[14:] - uc[:-14] != 14] = np.nan
        prev_lw[14:][lc[14:] - lc[:-14] != 14] = np.nan
    sma = np.asarray(features.sma(20), dtype=np.float64)
    trend_valid = np.zeros(n, dtype=np.bool_)
    up1 = np.zeros(n, dtype=np.bool_)
    if n > 1:
        trend_valid[1:] = np.isfinite(closes[:-1]) & np.isfinite(sma[:-1])
        up1[1:] = trend_valid[1:] & (closes[:-1] > sma[:-1])
    down1 = trend_valid & ~up1
    up2, up3, up4, up5 = (lag(up1, 1), lag(up1, 2), lag(up1, 3), lag(up1, 4))
    down2, down3, down4, down5 = (lag(down1, 1), lag(down1, 2), lag(down1, 3), lag(down1, 4))
    tall2, tall3, tall4, tall5 = (lag(tall0, 1), lag(tall0, 2), lag(tall0, 3), lag(tall0, 4))
    bull0 = valid0 & (bodies >= 0.0)
    bear0 = valid0 & (bodies < 0.0)
    doji0 = valid0 & (np.abs(bodies) / ranges <= 0.04)
    high_body = body_pos > 0.5
    used_wick = np.where(high_body, lower_wick, upper_wick)
    discarded_wick = np.where(high_body, upper_wick, lower_wick)
    hammer = valid0 & (np.abs(bodies) > 0.0) & (used_wick / np.abs(bodies) >= 2.0) & (discarded_wick / np.abs(bodies) <= 0.35)
    takuri = hammer & high_body & (used_wick / np.abs(bodies) >= 3.0)
    one_long = down1 & hammer | down1 & takuri | bull0 & (ranges >= 3.0 * prev_range) | down1 & doji0 & (highs < lag(lows, 1)) | down1 & doji0 | doji0 & (lower_wick >= 3.0 * prev_lw) & (highs == body_high)
    one_short = up1 & hammer | bear0 & (ranges >= 3.0 * prev_range) | up1 & doji0 & (lows > lag(highs, 1)) | up1 & doji0 | doji0 & (upper_wick >= 3.0 * prev_uw) & (lows == body_low)

    def within(value, first, second):
        return (value > np.minimum(first, second)) & (value < np.maximum(first, second))
    o2, h2, l2, c2 = (lag(opens, 1), lag(highs, 1), lag(lows, 1), lag(closes, 1))
    r2, b2 = (lag(ranges, 1), lag(bodies, 1))
    bh2, bl2 = (lag(body_high, 1), lag(body_low, 1))
    uw2, lw2, mid2 = (lag(upper_wick, 1), lag(lower_wick, 1), lag(mids, 1))
    bull2, bear2, doji2, tall2 = (lag(bull0, 1), lag(bear0, 1), lag(doji0, 1), lag(tall0, 1))
    engulfs2 = (body_high > bh2) & (body_low < bl2)
    in_body2 = within(opens, bh2, bl2) & within(closes, bh2, bl2)
    alt2 = bear2 & bull0 | bull2 & bear0
    maru2 = (h2 == bh2) & (l2 == bl2)
    maru0 = (highs == body_high) & (lows == body_low)
    long2 = down2 & bear2 & bull0 & engulfs2 | down2 & bear2 & tall2 & doji0 & (highs < c2) | down2 & bear2 & tall2 & bull0 & in_body2 | down2 & bear2 & bear0 & tall2 & in_body2 | tall2 & tall0 & bear2 & bull0 & maru2 & maru0 & (lows > h2) | down2 & bear2 & bull0 & tall0 & (np.abs(closes - c2) <= r2 * 0.05) | down2 & bear2 & bull0 & tall0 & (np.abs(opens - o2) <= r2 * 0.05) | down2 & bear2 & bear0 & tall2 & ~tall0 & (closes == c2) | down2 & bear2 & bull0 & (opens < l2) & (closes > mid2) & (closes < o2) | down2 & bear2 & bull0 & (opens >= mid2) & (closes >= mid2) | down2 & alt2 & (np.abs(lows - l2) <= r2 * 0.025) | up2 & (h2 < lows)
    short2 = up2 & bull2 & bear0 & engulfs2 | up2 & bull2 & tall2 & doji0 & (lows > c2) | up2 & bull2 & tall2 & bear0 & in_body2 | tall2 & tall0 & bull2 & bear0 & maru2 & maru0 & (highs < l2) | up2 & bull2 & bear0 & tall2 & ((np.abs(opens - o2) <= r2 * 0.05) | (np.abs(closes - c2) <= r2 * 0.05)) | down2 & bear2 & bull0 & tall2 & ~tall0 & (lw2 / r2 <= 0.1) & (closes < c2) & (closes > c2 - lw2 * 0.5) | down2 & bear2 & bull0 & tall2 & ~tall0 & (opens < l2) & within(closes, c2, c2 + np.abs(b2) * 0.15) | down2 & bear2 & bull0 & (opens < l2) & within(closes, mid2, mid2 - 0.5 * (b2 / 2.0)) | up2 & alt2 & (np.abs(highs - h2) <= r2 * 0.025) | down2 & (lag(lows, 2) > h2) & bear2 & bear0 & (highs < h2) | down2 & (l2 > highs)
    o3, h3, l3, c3 = (lag(opens, 2), lag(highs, 2), lag(lows, 2), lag(closes, 2))
    r3, b3 = (lag(ranges, 2), lag(bodies, 2))
    bh3, bl3 = (lag(body_high, 2), lag(body_low, 2))
    uw3, mid3, pos3 = (lag(upper_wick, 2), lag(mids, 2), lag(body_pos, 2))
    bull3, bear3, doji3, tall3 = (lag(bull0, 2), lag(bear0, 2), lag(doji0, 2), lag(tall0, 2))
    inside3 = within(o2, bh3, bl3) & within(c2, bh3, bl3)
    engulf3 = (bh2 > bh3) & (bl2 < bl3)
    long3 = down3 & bear3 & doji2 & bull0 & (h2 < l3) & (h2 < lows) | down3 & bear3 & bull2 & bull0 & tall3 & inside3 & (closes > c2) | down3 & bear3 & bull2 & bull0 & engulf3 & (closes > c2) | up3 & bull3 & bull2 & bull0 & (o2 > c3) & (opens > c3) & (np.abs(opens - o2) <= np.abs(b2) * 0.15) & (np.abs(closes - c2) <= np.abs(b2) * 0.15) | down3 & bear3 & bull2 & bear0 & (c2 > o3) & (np.abs(closes - c3) <= np.abs(b3) * 0.1) | up3 & bull3 & bull2 & bear0 & (l2 > h3) & within(opens, o2, c2) & within(closes, l2, h3) | down3 & bull3 & bull2 & bull0 & tall3 & tall2 & tall0 & (closes >= highs - ranges * 0.03) & (c2 >= h2 - r2 * 0.03) & (c3 >= h3 - r3 * 0.03) & within(o2, o3, c3) & within(opens, o2, c2) & (c2 > c3) & (closes > c2) | down3 & bear3 & bear2 & bear0 & (pos3 >= 0.6) & (lag(body_pos, 1) >= pos3 * 0.8) & (lag(body_pos, 1) <= pos3 * 1.2) & (r2 / r3 <= 0.75) & (l2 > l3) & maru0 & within(lows, h2, l2) & within(highs, h2, l2) | down3 & doji3 & doji2 & doji0 & (h2 < np.minimum(l3, lows)) | down3 & bear3 & tall3 & bear2 & within(o2, o3, c3) & (l2 < l3) & bull0 & ~tall0 & (closes < c2)
    short3 = up3 & bull3 & doji2 & bear0 & (l2 > h3) & (l2 > highs) | up3 & bull3 & bull2 & bull0 & within(o2, o3, c3) & within(opens, o2, c2) & (uw2 > uw3) & (upper_wick > uw2) | up3 & bull3 & doji2 & (h2 < l3) & bear0 & (l2 > highs) | up3 & bull3 & bull2 & bull0 & tall3 & tall2 & (c2 > c3) & (np.abs(opens - c2) <= np.abs(b2) * 0.1) & (opens > c2) & (np.abs(bodies) <= (np.abs(b3) + np.abs(b2)) / 2.0 * 0.33) | down3 & bear3 & bear2 & bull0 & tall3 & tall2 & (h2 < l3) & within(opens, o2, c2) & within(closes, o3, c3) | up3 & bull3 & bear2 & bear0 & ((h2 > bh3) | within(o2, o3, c3)) & (closes < c2) | down3 & bear3 & bear2 & bear0 & (c2 < c3) & (closes < c3) & (np.abs(opens - o2) <= np.abs(b2) * 0.15) & (np.abs(closes - c2) <= np.abs(b2) * 0.15) | up3 & bull3 & bear0 & tall3 & tall0 & (np.minimum(o2, c2) > c3) & (np.minimum(o2, c2) > opens) & (closes < mid3) | up3 & bear3 & bear2 & bear0 & tall3 & tall2 & tall0 & (closes <= lows + ranges * 0.03) & (c2 <= l2 + r2 * 0.03) & (c3 <= l3 + r3 * 0.03) & (l2 < l3) & (lows < l2) | up3 & bull3 & tall3 & bear2 & bear0 & (l2 > c3) & within(opens, o2, c2) & within(closes, o3, c3) | up3 & bull3 & tall3 & bear2 & bear0 & (l2 > c3) & (bh2 > bh3) & (bl2 < bl3) & (closes > c3) | up3 & doji3 & doji2 & doji0 & (l2 > np.maximum(h3, highs))
    o4, h4, l4, c4 = (lag(opens, 3), lag(highs, 3), lag(lows, 3), lag(closes, 3))
    bull4, bear4, tall4 = (lag(bull0, 3), lag(bear0, 3), lag(tall0, 3))
    four_long = down4 & bear4 & bear3 & bear2 & bear0 & tall4 & tall3 & (np.abs(b2) / np.where(lag(upper_wick, 1) > 0.0, lag(upper_wick, 1), np.nan) <= 0.5) & within(h2, o3, c3) & (highs == body_high) & (lows == body_low) & (highs >= h2) & (lows <= l2) | up4 & bull4 & bull3 & bull2 & bear0 & (h3 > h4) & (h2 > h3) & tall0 & (opens > c2) & (closes < o4)
    four_short = down4 & bear4 & bear3 & bear2 & bull0 & (l3 < l4) & (l2 < l3) & (lows < l2) & tall0 & (opens < c2) & (closes > o4)
    o5, h5, l5, c5 = (lag(opens, 4), lag(highs, 4), lag(lows, 4), lag(closes, 4))
    bull5, bear5, tall5 = (lag(bull0, 4), lag(bear0, 4), lag(tall0, 4))
    five_long = down5 & bear5 & bear4 & within(o3, o4, c4) & bear3 & (c3 < np.minimum(o3, c3)) & bear2 & bull0 & (closes > o4) & (closes < c5) | down5 & bear5 & bear4 & bear3 & bear2 & bull0 & tall5 & tall4 & tall3 & (o4 < c5) & (c4 < c5) & (o3 < o4) & (c3 < c4) & (lag(upper_wick, 1) / lag(ranges, 1) >= 0.5) & (lag(upper_wick, 1) / lag(ranges, 1) <= 0.9) & (opens > o2) | up5 & bull5 & tall5 & bear4 & (c4 > c5) & (lag(body_high, 2) < o4) & bear2 & (o2 < lag(body_high, 2)) & bull0 & tall0 & (closes > np.maximum.reduce([h5, h4, h3, h2])) | up5 & bull5 & tall5 & bear4 & bear3 & bear2 & (h3 < h5) & (l3 > l5) & (h2 < h5) & (l2 > l5) & bull0 & tall0 & (closes > c5)
    five_short = up5 & bull5 & bull4 & within(o3, o5, c5) & bull3 & (c3 > c4) & bull2 & bear0 & (closes < o4) & (closes > c5) | down5 & bear5 & tall5 & bear4 & bear3 & bear2 & (o4 < o5) & (c4 < c5) & (o3 < o4) & (c3 < c4) & (o2 < o3) & (c2 < c3) & (h3 < h5) & (l3 > l5) & (h2 < h5) & (l2 > l5) & bear0 & (closes < c5)
    selected = np.zeros(n, dtype=np.int8)
    raw_long = np.zeros(n, dtype=np.bool_)
    raw_short = np.zeros(n, dtype=np.bool_)
    for size, lm, sm in ((5, five_long, five_short), (4, four_long, four_short), (3, long3, short3), (2, long2, short2), (1, one_long, one_short)):
        take = (selected == 0) & (lm | sm)
        raw_long |= take & lm
        raw_short |= take & sm
        selected[take] = size
    conflict = raw_long & raw_short
    q_long, q_short = (raw_long & ~conflict, raw_short & ~conflict)
    long_entries, short_entries = (q_long.copy(), q_short.copy())
    long_entries[0] = short_entries[0] = False
    if n > 1:
        long_entries[1:] &= ~q_long[:-1]
        short_entries[1:] &= ~q_short[:-1]
    conflict = long_entries & short_entries
    long_entries[conflict] = short_entries[conflict] = False
    long_exits = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    atr = np.asarray(features.atr(14), dtype=np.float64)
    returns = np.full(n, np.nan)
    if n > 1:
        good = np.isfinite(closes[1:]) & np.isfinite(closes[:-1]) & (closes[:-1] > 0.0)
        returns[1:][good] = (closes[1:][good] - closes[:-1][good]) / closes[:-1][good]
    mean_w = np.full(n, np.nan)
    std_w = np.full(n, np.nan)
    vol_target = np.full(n, np.nan)
    for t in range(14, n):
        rr = returns[t - 13:t + 1]
        vv = volumes[t - 13:t + 1]
        if np.all(np.isfinite(rr)) and np.all(np.isfinite(vv)):
            mean_w[t] = np.mean(rr)
            std_w[t] = np.std(rr)
            vol_target[t] = np.mean(vv)
    k_base = float(signal_params.get('k_base', 2.5))
    phi = float(signal_params.get('phi', 0.5))
    mult = float(signal_params.get('mult', 2.0))
    position = 0
    pending_side = 0
    exit_pending = False
    initialized = False
    just_initialized = False
    best = previous_stop = np.nan
    cumulative_volume = volume_sum = price_volume_sum = price_square_volume_sum = 0.0
    z_entry = previous_z = volume_target = np.nan
    for t in range(n):
        just_initialized = False
        if exit_pending:
            position = pending_side = 0
            exit_pending = initialized = False
            best = previous_stop = z_entry = previous_z = volume_target = np.nan
            cumulative_volume = volume_sum = price_volume_sum = price_square_volume_sum = 0.0
        if position == 0 and pending_side != 0:
            position, pending_side = (pending_side, 0)
        if position != 0 and (not initialized):
            ok = np.isfinite(highs[t]) and np.isfinite(lows[t]) and np.isfinite(closes[t]) and np.isfinite(volumes[t]) and (volumes[t] > 0.0) and np.isfinite(atr[t]) and (atr[t] > 0.0) and np.isfinite(mean_w[t]) and np.isfinite(std_w[t]) and (std_w[t] > 0.0) and np.isfinite(vol_target[t]) and (vol_target[t] > 0.0) and np.isfinite(returns[t]) and (closes[t] > 0.0)
            if ok:
                illiq = i5_illiquidity(float(returns[t]), float(closes[t]), float(volumes[t]))
                k = i5_liquidity_k(illiq, float(mean_w[t]), float(std_w[t]), k_base, phi)
                if np.isfinite(k) and k > 0.0:
                    best = highs[t] if position == 1 else lows[t]
                    previous_stop = i5_stop(position, best - position * k * atr[t], best, k, atr[t])
                    cumulative_volume = volume_sum = volumes[t]
                    price_volume_sum = closes[t] * volumes[t]
                    price_square_volume_sum = closes[t] * closes[t] * volumes[t]
                    volume_target = vol_target[t]
                    initialized = np.isfinite(previous_stop)
                    just_initialized = initialized
        if position != 0 and initialized:
            best = max(best, highs[t]) if position == 1 else min(best, lows[t])
            valid = np.isfinite(returns[t]) and np.isfinite(closes[t]) and (closes[t] > 0.0) and np.isfinite(volumes[t]) and (volumes[t] > 0.0) and np.isfinite(mean_w[t]) and np.isfinite(std_w[t]) and (std_w[t] > 0.0) and np.isfinite(atr[t]) and (atr[t] > 0.0)
            stop_hit = False
            if valid:
                illiq = i5_illiquidity(float(returns[t]), float(closes[t]), float(volumes[t]))
                k = i5_liquidity_k(illiq, float(mean_w[t]), float(std_w[t]), k_base, phi)
                if np.isfinite(k) and k > 0.0:
                    previous_stop = i5_stop(position, previous_stop, best, k, atr[t])
                    stop_hit = i5_stop_touched(position, float(lows[t]), float(highs[t]), float(previous_stop))
            if stop_hit:
                long_exits[t] = position == 1
                short_exits[t] = position == -1
                exit_pending = True
            else:
                if not just_initialized and np.isfinite(volumes[t]) and (volumes[t] > 0.0) and np.isfinite(closes[t]):
                    cumulative_volume += volumes[t]
                    volume_sum += volumes[t]
                    price_volume_sum += closes[t] * volumes[t]
                    price_square_volume_sum += closes[t] * closes[t] * volumes[t]
                if volume_sum > 0.0:
                    vwap = price_volume_sum / volume_sum
                    centered = price_square_volume_sum - price_volume_sum * price_volume_sum / volume_sum
                    if centered > 0.0 and np.isfinite(centered):
                        z = i5_vwap_z(float(closes[t]), float(volume_sum), float(price_volume_sum), float(centered))
                        if np.isfinite(z):
                            if not np.isfinite(z_entry):
                                z_entry = previous_z = z
                            else:
                                previous_z = z
                                if i5_reversion(position, float(previous_z), float(z), float(z_entry), mult, float(cumulative_volume), float(volume_target)):
                                    long_exits[t] = position == 1
                                    short_exits[t] = position == -1
                                    exit_pending = True
                if not exit_pending and cumulative_volume >= volume_target:
                    long_exits[t] = position == 1
                    short_exits[t] = position == -1
                    exit_pending = True
        if position == 0 and pending_side == 0 and (not exit_pending):
            if long_entries[t] and (not short_entries[t]):
                pending_side = 1
            elif short_entries[t] and (not long_entries[t]):
                pending_side = -1
    return (long_entries, long_exits, short_entries, short_exits)

def iter_signal_parameter_sets():
    for k in (1.5, 2.5, 3.5):
        for p in (0.0, 0.5):
            for m in (1.5, 2.0):
                yield {'k_base': k, 'phi': p, 'mult': m}
STRATEGY = {'strategy_id': 'candlestick_pattern_classic', 'hypothesis': '已完成 K 棒的多空經典燭線形態，在相應趨勢背景下可預示短期反轉或延續；以流動性調整停損與 anchored-VWAP 回歸退出。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'phi', 'mult'], 'signal_parameter_sets': iter_signal_parameter_sets}
