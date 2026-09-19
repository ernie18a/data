import numpy as np


def _data(market, name, size, default=None):
    value = getattr(market, name, None)
    if value is None:
        if default is None:
            raise AttributeError("features.market.%s is required" % name)
        value = default
    value = np.asarray(value, dtype=float).reshape(-1)
    if value.size != size:
        raise ValueError("features.market.%s has wrong length" % name)
    return value


def _ema(x, n):
    x = np.asarray(x, dtype=float)
    out = np.full(x.size, np.nan)
    a = 2.0 / (n + 1.0)
    last = np.nan
    for i, value in enumerate(x):
        if np.isfinite(value):
            last = value if not np.isfinite(last) else a * value + (1.0 - a) * last
        out[i] = last
    return out


def _sma(x, n):
    x = np.asarray(x, dtype=float)
    out = np.full(x.size, np.nan)
    for i in range(n - 1, x.size):
        w = x[i - n + 1:i + 1]
        if np.all(np.isfinite(w)):
            out[i] = np.mean(w)
    return out


def _min(x, n):
    out = np.full(len(x), np.nan)
    for i in range(n - 1, len(x)):
        w = x[i - n + 1:i + 1]
        if np.all(np.isfinite(w)):
            out[i] = np.min(w)
    return out


def _max(x, n):
    out = np.full(len(x), np.nan)
    for i in range(n - 1, len(x)):
        w = x[i - n + 1:i + 1]
        if np.all(np.isfinite(w)):
            out[i] = np.max(w)
    return out


def _atr(high, low, close, n=14):
    previous = np.roll(close, 1)
    previous[0] = close[0]
    tr = np.maximum(high - low, np.maximum(abs(high - previous), abs(low - previous)))
    return _ema(tr, n)


def _rsi(close, n=14):
    delta = np.diff(close, prepend=close[0])
    gain = _ema(np.maximum(delta, 0.0), n)
    loss = _ema(np.maximum(-delta, 0.0), n)
    out = np.full(len(close), 50.0)
    good = loss > 0.0
    out[good] = 100.0 - 100.0 / (1.0 + gain[good] / loss[good])
    out[(loss == 0.0) & (gain > 0.0)] = 100.0
    return out


def _cci(high, low, close, n=20):
    typical = (high + low + close) / 3.0
    mean = _sma(typical, n)
    dev = np.full(len(close), np.nan)
    for i in range(n - 1, len(close)):
        w = typical[i - n + 1:i + 1]
        if np.all(np.isfinite(w)):
            dev[i] = np.mean(np.abs(w - mean[i]))
    return np.divide(typical - mean, 0.015 * dev, out=np.zeros(len(close)), where=dev > 0.0)


def _qqe(close):
    rsi_ma = _ema(_rsi(close, 14), 5)
    dar = _ema(_ema(np.abs(np.diff(rsi_ma, prepend=rsi_ma[0])), 27), 27) * 4.238
    lower = np.full(len(close), np.nan)
    upper = np.full(len(close), np.nan)
    state = np.ones(len(close), dtype=np.int8)
    for i in range(len(close)):
        if not np.isfinite(rsi_ma[i]) or not np.isfinite(dar[i]):
            if i:
                state[i] = state[i - 1]
            continue
        new_lower = rsi_ma[i] - dar[i]
        new_upper = rsi_ma[i] + dar[i]
        if i == 0 or not np.isfinite(lower[i - 1]):
            lower[i], upper[i] = new_lower, new_upper
            continue
        lower[i] = max(lower[i - 1], new_lower) if rsi_ma[i - 1] > lower[i - 1] and rsi_ma[i] > lower[i - 1] else new_lower
        upper[i] = min(upper[i - 1], new_upper) if rsi_ma[i - 1] < upper[i - 1] and rsi_ma[i] < upper[i - 1] else new_upper
        state[i] = state[i - 1]
        if rsi_ma[i] > upper[i - 1] and rsi_ma[i - 1] <= upper[i - 1]:
            state[i] = 1
        elif rsi_ma[i] < lower[i - 1] and rsi_ma[i - 1] >= lower[i - 1]:
            state[i] = -1
    return state


def _pivots(high, low, legs):
    ph = np.full(len(high), np.nan)
    pl = np.full(len(low), np.nan)
    for t in range(2 * legs, len(high)):
        c = t - legs
        if high[c] >= np.max(high[c - legs:c + legs + 1]):
            ph[t] = high[c]
        if low[c] <= np.min(low[c - legs:c + legs + 1]):
            pl[t] = low[c]
    return ph, pl


def _leg(high, low, close, open_, atr, legs, fallback):
    ph, pl = _pivots(high, low, legs)
    size = len(close)
    ready = np.zeros(size, dtype=bool)
    seek_low = np.zeros(size, dtype=bool)
    risk = np.full(size, np.nan)
    lows = np.full(size, np.nan)
    highs = np.full(size, np.nan)
    last_kind, last_price, last_bar = 0, np.nan, -1
    for t in range(size):
        if np.isfinite(ph[t]):
            last_kind, last_price, last_bar, highs[t] = 1, ph[t], t - legs, ph[t]
        if np.isfinite(pl[t]):
            last_kind, last_price, last_bar, lows[t] = -1, pl[t], t - legs, pl[t]
        if t:
            if not np.isfinite(lows[t]):
                lows[t] = lows[t - 1]
            if not np.isfinite(highs[t]):
                highs[t] = highs[t - 1]
        if last_kind == 0:
            continue
        ready[t] = True
        seek_low[t] = last_kind == 1
        start = last_bar + 1
        if start > t:
            continue
        if seek_low[t]:
            endpoint = np.min(low[start:t + 1])
            extreme = start + int(np.argmin(low[start:t + 1]))
            counter = np.max(high[extreme:t + 1])
            rejection = close[t] > open_[t] and (min(open_[t], close[t]) - low[t]) >= abs(close[t] - open_[t]) * 0.8
            shift1 = t > 0 and close[t] > high[t - 1]
            shift2 = t > 1 and close[t] > max(high[t - 1], high[t - 2])
        else:
            endpoint = np.max(high[start:t + 1])
            extreme = start + int(np.argmax(high[start:t + 1]))
            counter = np.min(low[extreme:t + 1])
            rejection = close[t] < open_[t] and (high[t] - max(open_[t], close[t])) >= abs(close[t] - open_[t]) * 0.8
            shift1 = t > 0 and close[t] < low[t - 1]
            shift2 = t > 1 and close[t] < min(low[t - 1], low[t - 2])
        leg_range = abs(endpoint - last_price)
        a = max(float(atr[t]) if np.isfinite(atr[t]) else 1e-9, 1e-9)
        retrace = max(0.0, (counter - endpoint) if seek_low[t] else (endpoint - counter)) / max(leg_range, 1e-9)
        stale = max(0, t - extreme)
        leg_atr = leg_range / a
        extension = leg_range / max(a * fallback, 1e-9)
        risk[t] = np.clip(min(40.0, retrace / 0.382 * 40.0) + min(20.0, stale / max(2.0, legs * 0.5) * 20.0) + (14.0 if rejection else 0.0) + (20.0 if shift2 else 12.0 if shift1 else 0.0) + (6.0 if extension >= 1.20 or leg_atr >= fallback * 1.35 else 0.0), 0.0, 100.0)
    return ready, seek_low, risk, lows, highs


def _micro(high, low, close, open_, atr):
    ph, pl = _pivots(high, low, 2)
    size = len(close)
    recent_up = np.zeros(size, dtype=bool)
    recent_down = np.zeros(size, dtype=bool)
    retest_up = np.zeros(size, dtype=bool)
    retest_down = np.zeros(size, dtype=bool)
    choch_retest_up = np.zeros(size, dtype=bool)
    choch_retest_down = np.zeros(size, dtype=bool)
    protected_low = np.full(size, np.nan)
    last_high = last_low = np.nan
    direction = 0
    last_break_bar = last_break_dir = last_break_type = -1
    last_retest_bar = last_retest_dir = last_retest_type = -1
    pending_level = np.nan
    pending_dir = pending_type = 0
    pending_bar = -1
    have_high = have_low = False
    ready = np.zeros(size, dtype=bool)
    for t in range(size):
        if np.isfinite(ph[t]):
            last_high, have_high = ph[t], True
        if np.isfinite(pl[t]):
            last_low, have_low = pl[t], True
        ready[t] = have_high and have_low
        previous = close[t - 1] if t else close[t]
        break_dir, level = 0, np.nan
        if np.isfinite(last_high) and close[t] > last_high and previous <= last_high:
            break_dir, level = 1, last_high
        elif np.isfinite(last_low) and close[t] < last_low and previous >= last_low:
            break_dir, level = -1, last_low
        if break_dir:
            break_type = 2 if direction == -break_dir else 1
            direction = break_dir
            last_break_bar, last_break_dir, last_break_type = t, break_dir, break_type
            pending_level, pending_dir, pending_type, pending_bar = level, break_dir, break_type, t
            if break_dir == 1 and np.isfinite(last_low):
                protected_low[t] = last_low
        if t and not np.isfinite(protected_low[t]):
            protected_low[t] = protected_low[t - 1]
        if pending_dir and t > pending_bar:
            tol = (atr[t] if np.isfinite(atr[t]) else 0.0) * 0.15
            touched = low[t] <= pending_level + tol and high[t] >= pending_level - tol
            held = (close[t] > pending_level and close[t] > open_[t]) if pending_dir == 1 else (close[t] < pending_level and close[t] < open_[t])
            failed = close[t] < pending_level - tol if pending_dir == 1 else close[t] > pending_level + tol
            if failed or t - pending_bar > 20:
                pending_dir, pending_type, pending_bar = 0, 0, -1
            elif touched and held:
                last_retest_bar, last_retest_dir, last_retest_type = t, pending_dir, pending_type
                pending_dir, pending_type, pending_bar = 0, 0, -1
        if last_break_bar >= 0 and t - last_break_bar <= 6:
            recent_up[t] = last_break_dir == 1
            recent_down[t] = last_break_dir == -1
        if last_retest_bar >= 0 and t - last_retest_bar <= 6:
            retest_up[t] = last_retest_dir == 1
            retest_down[t] = last_retest_dir == -1
            choch_retest_up[t] = retest_up[t] and last_retest_type == 2
            choch_retest_down[t] = retest_down[t] and last_retest_type == 2
    return ready, recent_up, recent_down, retest_up, retest_down, choch_retest_up, choch_retest_down, protected_low


def _core(features, p):
    market = features.market
    n = int(market.size)
    close = _data(market, "closes", n)
    high = _data(market, "highs", n)
    low = _data(market, "lows", n)
    fallback_open = np.roll(close, 1)
    fallback_open[0] = close[0]
    open_ = _data(market, "opens", n, fallback_open)
    volume = _data(market, "volumes", n, np.ones(n))
    atr = _atr(high, low, close)
    safe_atr = np.maximum(np.nan_to_num(atr, nan=0.0), 1e-12)
    threshold = float(p.get("candle_confirm_threshold", 68.0))
    pivot_threshold = float(p.get("pivot_watch_threshold", 60.0))
    volume_threshold = float(p.get("volume_counter_flow_limit", 35.0))
    mode = str(p.get("micro_trigger_mode", "Break + Retest"))

    body = abs(close - open_)
    rng = np.maximum(high - low, 1e-12)
    prev_close, prev_open = np.roll(close, 1), np.roll(open_, 1)
    prev_body = np.roll(body, 1)
    two_close, two_open = np.roll(close, 2), np.roll(open_, 2)
    prev_close[0] = prev_open[0] = prev_body[0] = np.nan
    two_close[:2] = two_open[:2] = np.nan
    upper = high - np.maximum(open_, close)
    lower = np.minimum(open_, close) - low
    bull_engulf = (close > open_) & (prev_close < prev_open) & (open_ <= prev_close) & (close >= prev_open) & (body >= prev_body * 0.90)
    bull_hammer = (lower >= body * 2.0) & (upper <= rng * 0.25) & (close >= low + rng * 0.60)
    morning = (two_close < two_open) & (abs(prev_close - prev_open) <= abs(two_close - two_open) * 0.55) & (close > open_) & (close >= (two_open + two_close) * 0.50)
    piercing = (prev_close < prev_open) & (close > open_) & (open_ <= prev_close) & (close >= (prev_open + prev_close) * 0.50) & (close < prev_open)
    bull_pattern = bull_engulf | bull_hammer | morning | piercing
    bull_quality = np.where(bull_engulf | morning, 35.0, np.where(bull_hammer | piercing, 28.0, 0.0))
    bear_engulf = (close < open_) & (prev_close > prev_open) & (open_ >= prev_close) & (close <= prev_open) & (body >= prev_body * 0.90)
    bear_star = (upper >= body * 2.0) & (lower <= rng * 0.25) & (close <= low + rng * 0.40)
    evening = (two_close > two_open) & (abs(prev_close - prev_open) <= abs(two_close - two_open) * 0.55) & (close < open_) & (close <= (two_open + two_close) * 0.50)
    dark_cloud = (prev_close > prev_open) & (close < open_) & (open_ >= prev_close) & (close <= (prev_open + prev_close) * 0.50) & (close > prev_open)
    bear_pattern = bear_engulf | bear_star | evening | dark_cloud
    bear_quality = np.where(bear_engulf | evening, 35.0, np.where(bear_star | dark_cloud, 28.0, 0.0))

    past_low, past_high = _min(low, 20), _max(high, 20)
    bull_sweep = (low < np.roll(past_low, 1)) & (close > np.roll(past_low, 1)) & (close > open_)
    bear_sweep = (high > np.roll(past_high, 1)) & (close < np.roll(past_high, 1)) & (close < open_)
    bull_sweep[0] = bear_sweep[0] = False

    qqe = _qqe(close)
    rsi = _rsi(close)
    cci = _cci(high, low, close)
    bull_votes = (qqe == 1).astype(int) + (rsi > _ema(rsi, 5)).astype(int) + (cci > _ema(cci, 13)).astype(int)
    bear_votes = (qqe == -1).astype(int) + (rsi < _ema(rsi, 5)).astype(int) + (cci < _ema(cci, 13)).astype(int)
    momentum_bull = (bull_votes >= 2) & (bull_votes > bear_votes)
    momentum_bear = (bear_votes >= 2) & (bear_votes > bull_votes)

    vol = np.maximum(np.nan_to_num(volume, nan=0.0), 0.0)
    vol_mean = _sma(vol, 50)
    vol_flow = _ema(vol * np.clip((close - open_) / rng * 0.65 + (2.0 * close - high - low) / rng * 0.35, -1.0, 1.0), 14)
    vol_smooth = _ema(vol, 14)
    cmf_mean = _sma(vol, 20)
    cmf = np.divide(_sma(vol * (2.0 * close - high - low) / rng, 20), cmf_mean, out=np.zeros(n), where=cmf_mean > 0.0)
    signed_flow = np.clip((np.divide(vol_flow, vol_smooth, out=np.zeros(n), where=vol_smooth > 0.0) * 0.65 + cmf * 0.35) * 100.0, -100.0, 100.0)
    bull_bias = 50.0 + signed_flow * 0.50
    bear_bias = 50.0 - signed_flow * 0.50
    volume_ready = np.isfinite(vol_mean) & (vol_mean > 0.0) & (vol > 0.0)

    di_up = _ema(np.maximum(high - np.roll(high, 1), 0.0), 14)
    di_dn = _ema(np.maximum(np.roll(low, 1) - low, 0.0), 14)
    di_up[0] = di_dn[0] = 0.0
    dtotal = np.maximum(di_up + di_dn, 1e-12)
    dx = 100.0 * abs(di_up - di_dn) / dtotal
    adx = _ema(dx, 14)
    direction = np.where(abs(di_up - di_dn) / dtotal < 0.05, 0, np.where(di_up > di_dn, 1, -1))
    chop_mean = _sma(high - low, 14)
    chop = np.clip(100.0 * np.log10(np.maximum(chop_mean * 14.0 / np.maximum(_max(high, 14) - _min(low, 14), 1e-12), 1.0)) / np.log10(14.0), 0.0, 100.0)
    travel_mean = _sma(abs(np.diff(close, prepend=close[0])), 20)
    efficiency = np.divide(abs(close - np.roll(close, 20)), travel_mean * 20.0, out=np.zeros(n), where=travel_mean > 0.0)
    regime_ready = np.isfinite(adx) & np.isfinite(chop) & (np.arange(n) >= 99)
    regime_trend = regime_ready & (adx >= 20.0) & (chop < 55.0) & (efficiency >= 0.20)
    exhaustion = regime_ready & (safe_atr > _sma(safe_atr, 100) * 1.8) & (efficiency < 0.28) & (adx < _ema(adx, 3))
    strong_down = regime_trend & (direction == -1) & ~exhaustion
    strong_up = regime_trend & (direction == 1) & ~exhaustion

    htf_fast, htf_slow = _ema(close, 34), _ema(close, 89)
    htf_ready = np.isfinite(htf_slow)
    htf_down = htf_ready & (htf_fast < htf_slow)
    htf_up = htf_ready & (htf_fast > htf_slow)

    major = _leg(high, low, close, open_, atr, 18, 3.0)
    swing = _leg(high, low, close, open_, atr, 7, 1.5)
    major_ready, major_seek, major_risk, major_lows, major_highs = major
    swing_ready, swing_seek, swing_risk, swing_lows, swing_highs = swing
    bull_context = (major_ready & major_seek & (major_risk >= pivot_threshold)) | (swing_ready & swing_seek & (swing_risk >= pivot_threshold))
    bear_context = (major_ready & ~major_seek & (major_risk >= pivot_threshold)) | (swing_ready & ~swing_seek & (swing_risk >= pivot_threshold))

    micro_ready, micro_up, micro_down, micro_retest_up, micro_retest_down, micro_choch_up, micro_choch_down, protected_low = _micro(high, low, close, open_, atr)
    if mode == "Break + Retest":
        bull_micro_ok, bear_micro_ok = (~micro_ready) | micro_choch_up, (~micro_ready) | micro_choch_down
    elif mode in ("破結構", "Break"):
        bull_micro_ok, bear_micro_ok = (~micro_ready) | micro_up, (~micro_ready) | micro_down
    else:
        bull_micro_ok, bear_micro_ok = (~micro_ready) | (micro_up | micro_retest_up), (~micro_ready) | (micro_down | micro_retest_down)

    support = _min(low, 50)
    support = np.minimum(support, np.where(np.isfinite(swing_lows), swing_lows, np.inf))
    resistance = _max(high, 50)
    buy_room = np.divide(resistance - close, safe_atr, out=np.full(n, np.nan), where=np.isfinite(resistance))
    buy_dist = np.divide(close - support, safe_atr, out=np.full(n, np.nan), where=np.isfinite(support))
    buy_score = np.where(~np.isfinite(buy_dist), 50.0, np.where(buy_dist <= 0.45, 88.0, np.where(buy_dist <= 1.5, 72.0, 45.0)))
    location_ok = (~np.isfinite(support) | ~np.isfinite(resistance)) | ((np.isnan(buy_room) | (buy_room >= 0.35)) & (buy_score >= 30.0))

    bull_evidence = bull_pattern | bull_sweep | micro_choch_up
    bear_evidence = bear_pattern | bear_sweep | micro_choch_down
    bull_score = np.clip(bull_quality + np.where(bull_sweep, 20.0, 0.0) + bull_votes / 3.0 * 20.0 + np.where(bull_context, 25.0, 0.0) + np.where(major_ready & major_seek, 10.0, 0.0) + np.where(swing_ready & swing_seek, 10.0, 0.0) + np.where(buy_score >= 70.0, 8.0, np.where(buy_score < 35.0, -8.0, 0.0)) + np.where(~micro_ready, 0.0, np.where(micro_retest_up, 14.0, np.where(micro_up, 9.0, -10.0))), 0.0, 100.0)
    bear_score = np.clip(bear_quality + np.where(bear_sweep, 20.0, 0.0) + bear_votes / 3.0 * 20.0 + np.where(bear_context, 25.0, 0.0) + np.where(major_ready & ~major_seek, 10.0, 0.0) + np.where(swing_ready & ~swing_seek, 10.0, 0.0) + np.where(~micro_ready, 0.0, np.where(micro_retest_down, 14.0, np.where(micro_down, 9.0, -10.0))), 0.0, 100.0)
    long_entries = bull_evidence & bull_context & momentum_bull
    long_entries &= (~volume_ready | (bull_bias >= volume_threshold))
    long_entries &= (~regime_ready | ~strong_down | exhaustion)
    long_entries &= (~htf_ready | ~htf_down) & location_ok & bull_micro_ok & (bull_score >= threshold)
    opposite = bear_evidence & bear_context & momentum_bear
    opposite &= (~volume_ready | (bear_bias >= volume_threshold))
    opposite &= (~regime_ready | ~strong_up | exhaustion)
    opposite &= (~htf_ready | ~htf_up) & bear_micro_ok & (bear_score >= threshold)
    return long_entries.astype(bool), opposite.astype(bool), atr, support, protected_low, exhaustion, htf_up, htf_down


def _exit(features, entries, opposite, p, atr, support, protected_low, exhaustion, htf_up, htf_down):
    market = features.market
    n = int(market.size)
    close = np.asarray(market.closes, dtype=float)
    high = np.asarray(market.highs, dtype=float)
    low = np.asarray(market.lows, dtype=float)
    max_bars = int(p.get("max_bars", 160))
    base = float(p.get("trail_atr_multiplier", 2.15))
    tick = float(p.get("mintick", 1e-8))
    fallback_support = np.where(np.isfinite(support), support, _min(low, 20))
    atr_mean = _sma(np.maximum(np.nan_to_num(atr, nan=0.0), tick), 50)
    long_exits = np.zeros(n, dtype=bool)
    in_position = False
    entry_price = entry_atr = stop = risk = 0.0
    entry_bar = -1
    best = -np.inf
    for t in range(n):
        if in_position:
            a = max(float(atr[t]) if np.isfinite(atr[t]) else entry_atr, tick)
            age = t - entry_bar
            if low[t] <= stop or opposite[t] or age >= max_bars:
                long_exits[t] = True
                in_position = False
                continue
            move = close[t] - entry_price
            if move >= 0.95 * risk:
                stop = max(stop, entry_price + 0.03 * risk)
            if move >= 1.75 * risk or a < entry_atr * 0.75:
                stop = max(stop, entry_price + 0.50 * risk)
            multiplier = base + (0.25 if htf_up[t] else 0.0) - (0.25 if htf_down[t] else 0.0) - (0.35 if exhaustion[t] else 0.0)
            if np.isfinite(atr_mean[t]) and a < atr_mean[t] * 0.75:
                multiplier -= 0.15
            multiplier = float(np.clip(multiplier, 1.15, 3.40))
            best = max(best, high[t])
            trail = (best + low[t]) * 0.5 - a * multiplier
            if np.isfinite(fallback_support[t]):
                trail = max(trail, fallback_support[t] - 0.08 * a)
            stop = max(stop, trail)
        if not in_position and entries[t]:
            entry_price = close[t]
            entry_atr = max(float(atr[t]) if np.isfinite(atr[t]) else 0.0, tick)
            candidates = [low[t]]
            for candidate in (protected_low[t], support[t], fallback_support[t]):
                if np.isfinite(candidate) and candidate < entry_price:
                    candidates.append(float(candidate))
            nearest = max(candidates)
            risk = min(max(entry_price - nearest + max(2.0 * tick, 0.08 * entry_atr), 0.35 * entry_atr), 2.50 * entry_atr)
            stop = entry_price - risk
            entry_bar, best, in_position = t, high[t], True
    return long_exits, np.zeros(n, dtype=bool)


def generate_signals(features, signal_params):
    n = int(features.market.size)
    if n == 0:
        empty = np.zeros(0, dtype=np.bool_)
        return empty, empty.copy(), empty.copy(), empty.copy()
    entries, opposite, atr, support, protected_low, exhaustion, htf_up, htf_down = _core(features, signal_params)
    exits, short_exits = _exit(features, entries, opposite, signal_params, atr, support, protected_low, exhaustion, htf_up, htf_down)
    return entries.astype(np.bool_), exits.astype(np.bool_), np.zeros(n, dtype=np.bool_), short_exits.astype(np.bool_)


STRATEGY = {
    "strategy_id": "zz_reversal_long",
    "hypothesis": "Major/Swing ZigZag 低點風險升高且反轉、動能與量能確認同步時做多，以自適應結構停損管理反轉。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["candle_confirm_threshold", "pivot_watch_threshold", "volume_counter_flow_limit", "micro_trigger_mode", "trail_atr_multiplier", "max_bars", "mintick"],
    "signal_parameter_sets": [{"candle_confirm_threshold": 68.0, "pivot_watch_threshold": 60.0, "volume_counter_flow_limit": 35.0, "micro_trigger_mode": "Break + Retest", "trail_atr_multiplier": 2.15, "max_bars": 160, "mintick": 1e-8}],
}
