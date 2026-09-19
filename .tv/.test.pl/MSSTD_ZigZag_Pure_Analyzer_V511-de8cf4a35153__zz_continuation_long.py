import numpy as np


def _series(values, size):
    values = np.asarray(values, dtype=float).reshape(-1)
    result = np.full(size, np.nan, dtype=float)
    result[:min(size, values.size)] = values[:size]
    return result


def _sma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length < 1:
        raise ValueError("window must be positive")
    for i in range(length - 1, values.size):
        window = values[i - length + 1:i + 1]
        if np.all(np.isfinite(window)):
            result[i] = np.mean(window)
    return result


def _std(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length < 1:
        raise ValueError("window must be positive")
    for i in range(length - 1, values.size):
        window = values[i - length + 1:i + 1]
        if np.all(np.isfinite(window)):
            result[i] = np.std(window, ddof=0)
    return result


def _ema(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if length < 1:
        raise ValueError("length must be positive")
    alpha = 2.0 / (length + 1.0)
    previous = np.nan
    for i, value in enumerate(values):
        if not np.isfinite(value):
            continue
        previous = value if not np.isfinite(previous) else alpha * value + (1.0 - alpha) * previous
        result[i] = previous
    return result


def _rsi(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    if values.size <= length:
        return result
    delta = np.diff(values)
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
    gain = np.mean(gains[:length])
    loss = np.mean(losses[:length])
    result[length] = 100.0 if loss == 0.0 and gain > 0.0 else 50.0 if loss == 0.0 else 100.0 - 100.0 / (1.0 + gain / loss)
    for i in range(length + 1, values.size):
        gain = (gain * (length - 1) + gains[i - 1]) / length
        loss = (loss * (length - 1) + losses[i - 1]) / length
        result[i] = 100.0 if loss == 0.0 and gain > 0.0 else 50.0 if loss == 0.0 else 100.0 - 100.0 / (1.0 + gain / loss)
    return result


def _atr(highs, lows, closes, length):
    previous_close = np.concatenate(([np.nan], closes[:-1]))
    true_range = np.maximum(highs - lows, np.maximum(np.abs(highs - previous_close), np.abs(lows - previous_close)))
    result = np.full(closes.size, np.nan, dtype=float)
    if closes.size < length:
        return result
    for i in range(length - 1, closes.size):
        window = true_range[i - length + 1:i + 1]
        if np.all(np.isfinite(window)):
            result[i] = np.mean(window)
    for i in range(length, closes.size):
        if np.isfinite(result[i - 1]) and np.isfinite(true_range[i]):
            result[i] = (result[i - 1] * (length - 1) + true_range[i]) / length
    return result


def _cci(highs, lows, closes, length):
    typical = (highs + lows + closes) / 3.0
    result = np.full(closes.size, np.nan, dtype=float)
    for i in range(length - 1, closes.size):
        window = typical[i - length + 1:i + 1]
        if np.all(np.isfinite(window)):
            mean = np.mean(window)
            deviation = np.mean(np.abs(window - mean))
            result[i] = 0.0 if deviation == 0.0 else (typical[i] - mean) / (0.015 * deviation)
    return result


def _percentile_rank(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for i in range(length - 1, values.size):
        window = values[i - length + 1:i + 1]
        if np.all(np.isfinite(window)):
            result[i] = 100.0 * np.mean(window <= window[-1])
    return result


def _dmi(highs, lows, closes, length):
    previous_high = np.concatenate(([np.nan], highs[:-1]))
    previous_low = np.concatenate(([np.nan], lows[:-1]))
    previous_close = np.concatenate(([np.nan], closes[:-1]))
    tr = np.maximum(highs - lows, np.maximum(np.abs(highs - previous_close), np.abs(lows - previous_close)))
    up = highs - previous_high
    down = previous_low - lows
    plus = np.where((up > down) & (up > 0.0), up, 0.0)
    minus = np.where((down > up) & (down > 0.0), down, 0.0)
    tr_mean = _ema(tr, length)
    plus_mean = _ema(plus, length)
    minus_mean = _ema(minus, length)
    plus_di = 100.0 * plus_mean / np.maximum(tr_mean, 1e-12)
    minus_di = 100.0 * minus_mean / np.maximum(tr_mean, 1e-12)
    dx = 100.0 * np.abs(plus_di - minus_di) / np.maximum(plus_di + minus_di, 1e-12)
    return plus_di, minus_di, _ema(dx, length)


def _pivot_flags(values, left, right, is_high):
    result = np.zeros(values.size, dtype=np.bool_)
    for i in range(left, values.size - right):
        window = values[i - left:i + right + 1]
        if np.all(np.isfinite(window)):
            result[i] = values[i] >= np.max(window) if is_high else values[i] <= np.min(window)
    return result


def _zigzag(highs, lows, atr, legs, deviation, backstep):
    size = highs.size
    ph = _pivot_flags(highs, legs, legs, True)
    pl = _pivot_flags(lows, legs, legs, False)
    ready = np.zeros(size, dtype=np.bool_)
    seeking_high = np.zeros(size, dtype=np.bool_)
    endpoint = np.full(size, np.nan, dtype=float)
    strength = np.full(size, np.nan, dtype=float)
    risk = np.full(size, np.nan, dtype=float)
    retracement = np.full(size, np.nan, dtype=float)
    pivot_price = np.full(size, np.nan, dtype=float)
    pivot_bar = np.full(size, -1, dtype=int)
    completed_ranges = []
    current_price = np.nan
    current_bar = -1
    was_high = False
    prior_same = np.nan
    trend = 0
    fallback = 1.5 if legs <= 10 else 3.0
    for t in range(size):
        candidate_bar = t - legs
        candidate_high = candidate_bar >= 0 and ph[candidate_bar]
        candidate_low = candidate_bar >= 0 and pl[candidate_bar]
        if candidate_high and candidate_low:
            candidate_high = abs(highs[candidate_bar] - closes[t]) >= abs(lows[candidate_bar] - closes[t])
            candidate_low = not candidate_high
        if candidate_high or candidate_low:
            is_high = bool(candidate_high)
            price = highs[candidate_bar] if is_high else lows[candidate_bar]
            min_move = (atr[t] if np.isfinite(atr[t]) else 0.0) * deviation
            if current_bar < 0:
                current_price, current_bar, was_high = price, candidate_bar, is_high
                prior_same = price
            elif is_high == was_high and candidate_bar > current_bar and ((is_high and price > current_price) or (not is_high and price < current_price)):
                current_price, current_bar = price, candidate_bar
            elif is_high != was_high and candidate_bar > current_bar and abs(price - current_price) >= min_move and candidate_bar - current_bar >= backstep:
                completed_ranges.append(abs(price - current_price))
                current_price, current_bar, was_high = price, candidate_bar, is_high
                prior_same = price
                trend = 1 if is_high else -1
        if current_bar >= 0:
            ready[t] = True
            seeking_high[t] = not was_high
            pivot_price[t] = current_price
            pivot_bar[t] = current_bar
            if seeking_high[t]:
                extreme = np.nanmax(highs[current_bar:t + 1])
                extreme_bar = current_bar + int(np.nanargmax(highs[current_bar:t + 1]))
                counter = np.nanmin(lows[extreme_bar:t + 1])
                aligned = trend >= 0
            else:
                extreme = np.nanmin(lows[current_bar:t + 1])
                extreme_bar = current_bar + int(np.nanargmin(lows[current_bar:t + 1]))
                counter = np.nanmax(highs[extreme_bar:t + 1])
                aligned = trend <= 0
            endpoint[t] = extreme
            leg_range = abs(extreme - current_price)
            safe_atr = max(float(atr[t]) if np.isfinite(atr[t]) else 0.0, 1e-12)
            leg_atr = leg_range / safe_atr
            baseline = np.mean(completed_ranges[-8:]) if completed_ranges else safe_atr * fallback
            relative_progress = leg_range / max(baseline, 1e-12)
            bars_to_extreme = max(1, extreme_bar - current_bar)
            bars_since = max(0, t - extreme_bar)
            retr = abs(extreme - counter) / max(leg_range, 1e-12)
            strength[t] = np.clip(leg_atr / fallback * 24.0 + relative_progress * 24.0 + leg_atr / np.sqrt(bars_to_extreme) / 0.65 * 20.0 + np.clip(16.0 - bars_since / max(2.0, legs * 0.5) * 16.0, 0.0, 16.0) + (8.0 if aligned else 0.0) - np.clip(retr / 0.5 * 28.0, 0.0, 28.0) - np.clip(bars_since / max(3.0, legs * 0.7) * 12.0, 0.0, 12.0), 0.0, 100.0)
            body = max(abs(closes[t] - (closes[t - 1] if t else closes[t])), 1e-12)
            upper = highs[t] - max(closes[t], closes[t - 1] if t else closes[t])
            lower = min(closes[t], closes[t - 1] if t else closes[t]) - lows[t]
            rejection = (not seeking_high[t] and lower >= body * 0.8) or (seeking_high[t] and upper >= body * 0.8)
            shift = (not seeking_high[t] and t > 0 and closes[t] < lows[t - 1]) or (seeking_high[t] and t > 0 and closes[t] > highs[t - 1])
            risk[t] = np.clip(retr / 0.382 * 40.0 + bars_since / max(2.0, legs * 0.5) * 20.0 + (14.0 if rejection else 0.0) + (12.0 if shift else 0.0) + (6.0 if relative_progress >= 1.2 or leg_atr >= fallback * 1.35 else 0.0), 0.0, 100.0)
            retracement[t] = retr
    return ready, seeking_high, endpoint, strength, risk, retracement, pivot_price, pivot_bar


def _micro(highs, lows, opens, closes, atr, left=2, right=2, expiry=20, tolerance=0.15, memory=6):
    size = closes.size
    ph = _pivot_flags(highs, left, right, True)
    pl = _pivot_flags(lows, left, right, False)
    direction = np.zeros(size, dtype=int)
    protected_low = np.full(size, np.nan)
    protected_high = np.full(size, np.nan)
    retest_up = np.zeros(size, dtype=np.bool_)
    retest_down = np.zeros(size, dtype=np.bool_)
    choch_up = np.zeros(size, dtype=np.bool_)
    choch_down = np.zeros(size, dtype=np.bool_)
    last_high = np.nan
    last_low = np.nan
    last_direction = 0
    pending_direction = 0
    pending_level = np.nan
    pending_bar = -1
    last_retest_up = -100000
    last_retest_down = -100000
    last_high_bar = -1
    last_low_bar = -1
    seen_high = False
    seen_low = False
    for t in range(size):
        p = t - right
        if p >= 0 and ph[p]:
            last_high, last_high_bar = highs[p], p
            seen_high = True
        if p >= 0 and pl[p]:
            last_low, last_low_bar = lows[p], p
            seen_low = True
        previous = closes[t - 1] if t else np.nan
        break_up = np.isfinite(last_high) and np.isfinite(previous) and previous <= last_high < closes[t]
        break_down = np.isfinite(last_low) and np.isfinite(previous) and previous >= last_low > closes[t]
        if break_up:
            choch_up[t] = last_direction == -1
            last_direction = 1
            protected_low[t] = last_low
            pending_direction, pending_level, pending_bar = 1, last_high, t
        elif break_down:
            choch_down[t] = last_direction == 1
            last_direction = -1
            protected_high[t] = last_high
            pending_direction, pending_level, pending_bar = -1, last_low, t
        if pending_direction and t > pending_bar:
            tol = max(float(atr[t]) if np.isfinite(atr[t]) else 0.0, 1e-12) * tolerance
            touched = lows[t] <= pending_level + tol and highs[t] >= pending_level - tol
            held = (pending_direction == 1 and closes[t] > pending_level and closes[t] > opens[t]) or (pending_direction == -1 and closes[t] < pending_level and closes[t] < opens[t])
            failed = (pending_direction == 1 and closes[t] < pending_level - tol) or (pending_direction == -1 and closes[t] > pending_level + tol)
            if failed or t - pending_bar > expiry:
                pending_direction, pending_level, pending_bar = 0, np.nan, -1
            elif touched and held:
                if pending_direction == 1:
                    retest_up[t] = True
                    last_retest_up = t
                else:
                    retest_down[t] = True
                    last_retest_down = t
                pending_direction, pending_level, pending_bar = 0, np.nan, -1
        direction[t] = last_direction
        if t and not np.isfinite(protected_low[t]):
            protected_low[t] = protected_low[t - 1]
        if t and not np.isfinite(protected_high[t]):
            protected_high[t] = protected_high[t - 1]
        retest_up[t] = retest_up[t] or t - last_retest_up <= memory
        retest_down[t] = retest_down[t] or t - last_retest_down <= memory
    ready = np.zeros(size, dtype=np.bool_)
    high_seen = False
    low_seen = False
    for t in range(size):
        p = t - right
        if p >= 0 and ph[p]:
            high_seen = True
        if p >= 0 and pl[p]:
            low_seen = True
        ready[t] = high_seen and low_seen
    return ready, direction, protected_low, protected_high, retest_up, retest_down, choch_up, choch_down


def _volume_scores(opens, highs, lows, closes, volumes):
    safe = np.where(np.isfinite(volumes), np.maximum(volumes, 0.0), 0.0)
    average = _sma(safe, 50)
    mean = _sma(safe, 100)
    deviation = _std(safe, 100)
    rvol = safe / np.maximum(average, 1e-12)
    z = (safe - mean) / np.maximum(deviation, 1e-12)
    activity = np.clip(50.0 + (rvol - 1.0) * 35.0, 0.0, 100.0) * 0.4 + np.clip(50.0 + z * 15.0, 0.0, 100.0) * 0.3 + 50.0 * 0.3
    bar_range = np.maximum(highs - lows, 1e-12)
    pressure = np.clip((closes - opens) / bar_range, -1.0, 1.0) * 0.65 + np.clip((2.0 * closes - highs - lows) / bar_range, -1.0, 1.0) * 0.35
    delta = safe * np.clip(pressure, -1.0, 1.0)
    signed = np.clip(_ema(delta, 14) / np.maximum(_ema(safe, 14), 1e-12), -1.0, 1.0) * 65.0 + np.clip(_sma(safe * np.clip((2.0 * closes - highs - lows) / bar_range, -1.0, 1.0), 20) / np.maximum(_sma(safe, 20), 1e-12), -1.0, 1.0) * 35.0
    signed = np.clip(signed, -100.0, 100.0)
    ready = np.isfinite(average) & (average > 0.0) & (safe > 0.0)
    return ready, np.clip(50.0 + signed * 0.5, 0.0, 100.0), np.clip(50.0 - signed * 0.5, 0.0, 100.0), safe


def _regime(highs, lows, closes, atr):
    plus, minus, adx = _dmi(highs, lows, closes, 14)
    direction = np.where(np.abs(plus - minus) < 5.0, 0, np.where(plus > minus, 1, -1))
    tr = np.maximum(highs - lows, np.maximum(np.abs(highs - np.concatenate(([np.nan], closes[:-1]))), np.abs(lows - np.concatenate(([np.nan], closes[:-1])))))
    tr_sum = _sma(tr, 14) * 14.0
    price_range = np.full(closes.size, np.nan)
    for i in range(13, closes.size):
        price_range[i] = np.max(highs[i - 13:i + 1]) - np.min(lows[i - 13:i + 1])
    chop = 100.0 * np.log10(np.maximum(tr_sum / np.maximum(price_range, 1e-12), 1.0)) / np.log10(14.0)
    net = closes - np.concatenate((np.full(20, np.nan), closes[:-20]))
    travel = _sma(np.abs(np.diff(closes, prepend=np.nan)), 20) * 20.0
    efficiency = np.abs(net) / np.maximum(travel, 1e-12) * 100.0
    atr_rank = _percentile_rank(atr, 100)
    basis = _sma(closes, 20)
    width = 2.0 * _std(closes, 20) / np.maximum(np.abs(basis), 1e-12)
    width_rank = _percentile_rank(width, 100)
    slope = width_rank - np.concatenate((np.full(3, np.nan), width_rank[:-3]))
    ready = np.isfinite(adx) & np.isfinite(chop) & np.isfinite(efficiency) & np.isfinite(atr_rank) & np.isfinite(width_rank)
    compression = ready & (width_rank <= 15.0) & (atr_rank <= 30.0)
    high_vol = ready & ((atr_rank >= 85.0) | (width_rank >= 85.0))
    adx_falling = adx < _ema(adx, 3)
    exhaustion = high_vol & (efficiency < 28.0) & (adx_falling | (slope < -2.0))
    trend = ready & (adx >= 20.0) & (chop < 55.0) & (efficiency >= 20.0)
    range_mode = ready & ~compression & ~((slope >= 4.0) & (width_rank >= 50.0)) & ((chop >= 55.0) | ~trend)
    return ready, direction, compression, range_mode, exhaustion, trend


def _squeeze(closes, highs, lows, atr):
    basis = _sma(closes, 20)
    deviation = _std(closes, 20) * 2.0
    tr = np.maximum(highs - lows, np.maximum(np.abs(highs - np.concatenate(([np.nan], closes[:-1]))), np.abs(lows - np.concatenate(([np.nan], closes[:-1])))))
    tr_average = _sma(tr, 20)
    on = (basis - deviation > basis - tr_average * 1.5) & (basis + deviation < basis + tr_average * 1.5)
    off = (basis - deviation < basis - tr_average * 1.5) & (basis + deviation > basis + tr_average * 1.5)
    midpoint = (_sma((np.maximum.accumulate(highs) + np.minimum.accumulate(lows)) / 2.0, 20) + basis) / 2.0
    value = closes - midpoint
    slope = value - np.concatenate(([np.nan], value[:-1]))
    direction = np.where(value > 0.0, 1, np.where(value < 0.0, -1, np.where(slope > 0.0, 1, np.where(slope < 0.0, -1, 0))))
    release_up = off & np.concatenate(([False], on[:-1])) & (direction == 1) & (slope > 0.0)
    release_down = off & np.concatenate(([False], on[:-1])) & (direction == -1) & (slope < 0.0)
    return on, value, slope, direction, release_up, release_down


def _param(params, name, default, cast=float):
    value = cast(params.get(name, default))
    if isinstance(value, float) and not np.isfinite(value):
        raise ValueError(name + " must be finite")
    return value


def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return empty, empty.copy(), empty.copy(), empty.copy()
    market = features.market
    opens = _series(market.opens, size)
    highs = _series(market.highs, size)
    lows = _series(market.lows, size)
    closes = _series(market.closes, size)
    volumes = _series(market.volumes, size)
    params = signal_params or {}
    atr_length = _param(params, "atr_length", 14, int)
    swing_legs = _param(params, "swing_legs", 7, int)
    major_legs = _param(params, "major_legs", 18, int)
    threshold = _param(params, "candle_confirm_threshold", 68.0)
    pivot_threshold = _param(params, "pivot_watch_threshold", 60.0)
    min_pullback = _param(params, "min_pullback_ratio", 0.12)
    max_pullback = _param(params, "max_pullback_ratio", 0.52)
    block_atr = _param(params, "location_block_atr", 0.50)
    micro_mode = str(params.get("micro_trigger_mode", "Break + Retest"))
    max_bars = _param(params, "max_bars", 160, int)
    base_multiplier = _param(params, "base_atr_multiplier", 2.15)
    breakeven_r = _param(params, "breakeven_r", 0.95)
    tighten_r = _param(params, "tighten_r", 1.75)
    min_risk_atr = _param(params, "min_risk_atr", 0.35)
    max_risk_atr = _param(params, "max_risk_atr", 2.50)
    exit_on_opposite = bool(params.get("exit_on_opposite_trigger", True))
    if min_risk_atr <= 0.0 or max_risk_atr < min_risk_atr or swing_legs < 1 or major_legs < swing_legs:
        raise ValueError("invalid strategy parameters")

    atr = _atr(highs, lows, closes, atr_length)
    safe_atr = np.where(np.isfinite(atr) & (atr > 0.0), atr, np.nan)
    swing = _zigzag(highs, lows, safe_atr, swing_legs, 0.50, max(2, int(round(swing_legs * 0.35))))
    major = _zigzag(highs, lows, safe_atr, major_legs, 1.25, max(swing_legs, int(round(major_legs * 0.35))))
    micro = _micro(highs, lows, opens, closes, safe_atr)
    volume_ready, volume_bull, volume_bear, safe_volume = _volume_scores(opens, highs, lows, closes, volumes)
    regime = _regime(highs, lows, closes, safe_atr)
    squeeze = _squeeze(closes, highs, lows, safe_atr)
    rsi = _rsi(closes, 14)
    rsi_signal = _ema(rsi, 5)
    cci = _cci(highs, lows, closes, 20)
    cci_signal = _ema(cci, 13)
    qqe_up = rsi > rsi_signal
    momentum_bull_votes = qqe_up.astype(int) + (rsi > rsi_signal).astype(int) + (cci > cci_signal).astype(int)
    momentum_bear_votes = (~qqe_up).astype(int) + (rsi < rsi_signal).astype(int) + (cci < cci_signal).astype(int)
    momentum_direction = np.where((momentum_bull_votes >= 2) & (momentum_bull_votes > momentum_bear_votes), 1, np.where((momentum_bear_votes >= 2) & (momentum_bear_votes > momentum_bull_votes), -1, 0))

    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    bull_trigger = np.zeros(size, dtype=np.bool_)
    bear_trigger = np.zeros(size, dtype=np.bool_)
    body = np.maximum(np.abs(closes - opens), 1e-12)
    previous_body = np.maximum(np.concatenate(([np.nan], body[:-1])), 1e-12)
    candle_range = np.maximum(highs - lows, 1e-12)
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows
    bull_engulfing = (closes > opens) & (np.concatenate(([False], closes[:-1] < opens[:-1]))) & (opens <= np.concatenate(([np.nan], closes[:-1]))) & (closes >= np.concatenate(([np.nan], opens[:-1]))) & (body >= previous_body * 0.90)
    bear_engulfing = (closes < opens) & (np.concatenate(([False], closes[:-1] > opens[:-1]))) & (opens >= np.concatenate(([np.nan], closes[:-1]))) & (closes <= np.concatenate(([np.nan], opens[:-1]))) & (body >= previous_body * 0.90)
    bull_hammer = (lower_wick >= body * 2.0) & (upper_wick <= candle_range * 0.25) & (closes >= lows + candle_range * 0.60)
    bear_star = (upper_wick >= body * 2.0) & (lower_wick <= candle_range * 0.25) & (closes <= lows + candle_range * 0.40)
    morning = np.zeros(size, dtype=np.bool_)
    evening = np.zeros(size, dtype=np.bool_)
    piercing = np.zeros(size, dtype=np.bool_)
    dark_cloud = np.zeros(size, dtype=np.bool_)
    if size >= 3:
        morning[2:] = (closes[:-2] < opens[:-2]) & (body[1:-1] <= body[:-2] * 0.55) & (closes[2:] > opens[2:]) & (closes[2:] >= (opens[:-2] + closes[:-2]) * 0.50)
        evening[2:] = (closes[:-2] > opens[:-2]) & (body[1:-1] <= body[:-2] * 0.55) & (closes[2:] < opens[2:]) & (closes[2:] <= (opens[:-2] + closes[:-2]) * 0.50)
    if size >= 2:
        piercing[1:] = (closes[:-1] < opens[:-1]) & (closes[1:] > opens[1:]) & (opens[1:] <= closes[:-1]) & (closes[1:] >= (opens[:-1] + closes[:-1]) * 0.50) & (closes[1:] < opens[:-1])
        dark_cloud[1:] = (closes[:-1] > opens[:-1]) & (closes[1:] < opens[1:]) & (opens[1:] >= closes[:-1]) & (closes[1:] <= (opens[:-1] + closes[:-1]) * 0.50) & (closes[1:] > opens[:-1])
    bull_pattern = bull_engulfing | morning | bull_hammer | piercing
    bear_pattern = bear_engulfing | evening | bear_star | dark_cloud
    bull_quality = np.where(bull_engulfing | morning, 35.0, np.where(bull_hammer | piercing, 28.0, 0.0))
    bear_quality = np.where(bear_engulfing | evening, 35.0, np.where(bear_star | dark_cloud, 28.0, 0.0))
    recent_high = np.full(size, np.nan)
    recent_low = np.full(size, np.nan)
    for i in range(20, size):
        recent_high[i] = np.max(highs[i - 20:i])
        recent_low[i] = np.min(lows[i - 20:i])
    bull_sweep = (lows < recent_low) & (closes > recent_low) & (closes > opens)
    bear_sweep = (highs > recent_high) & (closes < recent_high) & (closes < opens)
    micro_ready, micro_direction, protected_low, protected_high, recent_retest_up, recent_retest_down, micro_choch_up, micro_choch_down = micro
    if micro_mode == "同意":
        micro_bull_ok = (~micro_ready) | (micro_direction == 1)
        micro_bear_ok = (~micro_ready) | (micro_direction == -1)
    elif micro_mode == "Break":
        micro_bull_ok = (~micro_ready) | recent_retest_up | (micro_direction == 1)
        micro_bear_ok = (~micro_ready) | recent_retest_down | (micro_direction == -1)
    else:
        micro_bull_ok = (~micro_ready) | recent_retest_up
        micro_bear_ok = (~micro_ready) | recent_retest_down

    nearest_resistance = np.full(size, np.nan)
    nearest_support = np.full(size, np.nan)
    for t in range(size):
        candidates_up = [highs[t - j] for j in range(1, min(t, 100) + 1) if np.isfinite(highs[t - j]) and highs[t - j] >= closes[t]]
        candidates_down = [lows[t - j] for j in range(1, min(t, 100) + 1) if np.isfinite(lows[t - j]) and lows[t - j] <= closes[t]]
        if candidates_up:
            nearest_resistance[t] = min(candidates_up)
        if candidates_down:
            nearest_support[t] = max(candidates_down)
    room = (nearest_resistance - closes) / np.maximum(safe_atr, 1e-12)
    location_score = np.where(np.isfinite(room), np.clip(50.0 + (room - block_atr) * 18.0, 0.0, 100.0), 50.0)
    htf_fast = _ema(closes, 50)
    htf_slow = _ema(closes, 200)
    htf_ready = np.isfinite(htf_fast) & np.isfinite(htf_slow)
    htf_direction = np.where(htf_fast > htf_slow, 1, np.where(htf_fast < htf_slow, -1, 0))
    htf_strong_opposite = htf_ready & (htf_direction == -1) & ((htf_slow - htf_fast) / np.maximum(safe_atr, 1e-12) > 1.0)
    swing_ready, swing_seek_high, swing_endpoint, swing_strength, swing_risk, swing_retrace, swing_pivot, swing_bar = swing
    major_ready, major_seek_high, major_endpoint, major_strength, major_risk, major_retrace, major_pivot, major_bar = major
    regime_ready, regime_direction, regime_compression, regime_range, regime_exhaustion, regime_trend = regime
    squeeze_on, squeeze_value, squeeze_slope, squeeze_direction, squeeze_release_up, squeeze_release_down = squeeze
    recent_release_up = np.zeros(size, dtype=np.bool_)
    recent_release_down = np.zeros(size, dtype=np.bool_)
    for t in range(size):
        recent_release_up[t] = np.any(squeeze_release_up[max(0, t - 6):t + 1])
        recent_release_down[t] = np.any(squeeze_release_down[max(0, t - 6):t + 1])
    for t in range(size):
        valid = np.isfinite(opens[t]) and np.isfinite(highs[t]) and np.isfinite(lows[t]) and np.isfinite(closes[t]) and np.isfinite(safe_atr[t])
        bull_cont_context = valid and swing_ready[t] and swing_seek_high[t] and swing_strength[t] >= 50.0 and swing_risk[t] < pivot_threshold and min_pullback <= swing_retrace[t] <= max_pullback
        bear_cont_context = valid and swing_ready[t] and not swing_seek_high[t] and swing_strength[t] >= 50.0 and swing_risk[t] < pivot_threshold and min_pullback <= swing_retrace[t] <= max_pullback
        bull_reversal_context = valid and ((swing_ready[t] and not swing_seek_high[t] and swing_risk[t] >= pivot_threshold and lows[t] <= swing_endpoint[t] + safe_atr[t] * 0.45) or (major_ready[t] and not major_seek_high[t] and major_risk[t] >= pivot_threshold and lows[t] <= major_endpoint[t] + safe_atr[t] * 0.45))
        bear_reversal_context = valid and ((swing_ready[t] and swing_seek_high[t] and swing_risk[t] >= pivot_threshold and highs[t] >= swing_endpoint[t] - safe_atr[t] * 0.45) or (major_ready[t] and major_seek_high[t] and major_risk[t] >= pivot_threshold and highs[t] >= major_endpoint[t] - safe_atr[t] * 0.45))
        bull_reversal = (bull_pattern[t] or bull_sweep[t] or micro_choch_up[t]) and bull_reversal_context and momentum_direction[t] == 1 and micro_bull_ok[t]
        bear_reversal = (bear_pattern[t] or bear_sweep[t] or micro_choch_down[t]) and bear_reversal_context and momentum_direction[t] == -1 and micro_bear_ok[t]
        bull_score = max(bull_quality[t], 30.0 if recent_retest_up[t] else 0.0) + (20.0 if bull_sweep[t] else 0.0) + momentum_bull_votes[t] / 3.0 * 20.0 + (25.0 if bull_reversal_context else 20.0 if bull_cont_context else 0.0) + (10.0 if major_ready[t] and major_seek_high[t] else 0.0) + (10.0 if swing_ready[t] and swing_seek_high[t] else 0.0) + (8.0 if location_score[t] >= 70.0 else -8.0 if location_score[t] < 35.0 else 0.0) + (14.0 if recent_retest_up[t] else 9.0 if micro_direction[t] == 1 else -10.0 if micro_direction[t] == -1 else 0.0)
        bear_score = max(bear_quality[t], 30.0 if recent_retest_down[t] else 0.0) + (20.0 if bear_sweep[t] else 0.0) + momentum_bear_votes[t] / 3.0 * 20.0 + (25.0 if bear_reversal_context else 20.0 if bear_cont_context else 0.0) + (10.0 if major_ready[t] and not major_seek_high[t] else 0.0) + (10.0 if swing_ready[t] and not swing_seek_high[t] else 0.0) + (8.0 if location_score[t] >= 70.0 else -8.0 if location_score[t] < 35.0 else 0.0) + (14.0 if recent_retest_down[t] else 9.0 if micro_direction[t] == -1 else -10.0 if micro_direction[t] == 1 else 0.0)
        regime_bull_ok = (not regime_ready[t]) or (not regime_compression[t] and not (regime_range[t] and np.isfinite(regime_direction[t]) and regime_direction[t] == -1 and not regime_exhaustion[t]))
        regime_bear_ok = (not regime_ready[t]) or (not regime_compression[t] and not (regime_range[t] and regime_direction[t] == 1 and not regime_exhaustion[t]))
        htf_bull_ok = (not htf_strong_opposite[t])
        htf_bear_ok = (not htf_ready[t]) or htf_direction[t] != 1
        location_bull_ok = not np.isfinite(room[t]) or room[t] >= block_atr
        location_bear_ok = True
        volume_bull_ok = (not volume_ready[t]) or volume_bull[t] >= 35.0
        volume_bear_ok = (not volume_ready[t]) or volume_bear[t] >= 35.0
        bull_trigger[t] = bool(bull_pattern[t] or recent_retest_up[t]) and bull_cont_context and momentum_direction[t] == 1 and volume_bull_ok and regime_bull_ok and htf_bull_ok and location_bull_ok and micro_bull_ok[t] and bull_score >= threshold and not bull_reversal
        bear_trigger[t] = bool(bear_pattern[t] or recent_retest_down[t]) and bear_cont_context and momentum_direction[t] == -1 and volume_bear_ok and regime_bear_ok and htf_bear_ok and location_bear_ok and micro_bear_ok[t] and bear_score >= threshold and not bear_reversal
        long_entries[t] = bull_trigger[t]
        short_entries[t] = False

    long_exits = np.zeros(size, dtype=np.bool_)
    position = 0
    entry_price = 0.0
    initial_stop = 0.0
    trail = 0.0
    risk_price = 0.0
    best_price = 0.0
    start_bar = -1
    breakeven_locked = False
    for t in range(size):
        if position == 1:
            current_r = (closes[t] - entry_price) / max(risk_price, 1e-12)
            if t > start_bar:
                if lows[t] <= trail or (exit_on_opposite and bear_trigger[t]) or t - start_bar > max_bars:
                    long_exits[t] = True
                    position = 0
                    continue
                best_price = max(best_price, highs[t])
                mfe_r = (best_price - entry_price) / max(risk_price, 1e-12)
                risk_off = (htf_ready[t] and htf_direction[t] == -1) or (regime_exhaustion[t]) or (np.isfinite(room[t]) and room[t] < block_atr) or (micro_direction[t] == -1) or recent_release_down[t] or (squeeze_value[t] > 0.0 and squeeze_slope[t] < 0.0)
                trend_hold = ((htf_ready[t] and htf_direction[t] == 1) or recent_release_up[t] or (regime_trend[t] and regime_direction[t] == 1 and not regime_exhaustion[t]))
                multiplier = base_multiplier + (0.25 if trend_hold else 0.0) - (0.30 if regime_ready[t] and (regime_range[t] or regime_compression[t]) else 0.0) - (0.35 if risk_off else 0.0) - (0.30 if mfe_r >= tighten_r else 0.0)
                multiplier = float(np.clip(multiplier, 1.15, 3.40))
                candidate = (highs[t] + lows[t]) * 0.5 - safe_atr[t] * multiplier
                structural = [protected_low[t], nearest_support[t]]
                structural = [x - safe_atr[t] * 0.08 for x in structural if np.isfinite(x) and x < closes[t]]
                if structural:
                    candidate = max(candidate, max(structural))
                if mfe_r >= breakeven_r:
                    candidate = max(candidate, entry_price + risk_price * 0.03)
                    breakeven_locked = True
                if mfe_r >= tighten_r and mfe_r >= 1.0:
                    locked_r = min(max(mfe_r * (0.42 if risk_off else 0.30), 0.30 if risk_off else 0.20), 1.50 if risk_off else 1.00)
                    candidate = max(candidate, entry_price + risk_price * locked_r)
                candidate = min(candidate, closes[t] - safe_atr[t] * 0.08)
                trail = max(trail, candidate)
        if position == 0 and long_entries[t] and not short_entries[t]:
            entry_price = closes[t]
            stop_candidates = [lows[t], protected_low[t], nearest_support[t]]
            valid_stops = [x for x in stop_candidates if np.isfinite(x) and x < entry_price]
            structural = max(valid_stops) if valid_stops else entry_price - safe_atr[t] * 1.05
            buffer = max(max(abs(entry_price), 1.0) * 1e-8, safe_atr[t] * 0.08)
            raw_risk = entry_price - (structural - buffer)
            clamped = float(np.clip(raw_risk, safe_atr[t] * min_risk_atr, safe_atr[t] * max_risk_atr))
            initial_stop = entry_price - clamped
            trail = initial_stop
            risk_price = max(entry_price - initial_stop, max(abs(entry_price), 1.0) * 1e-8)
            best_price = entry_price
            start_bar = t
            breakeven_locked = False
            position = 1
    short_exits = np.zeros(size, dtype=np.bool_)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))


STRATEGY = {
    "strategy_id": "zz_continuation_long",
    "hypothesis": "ZigZag swing 上行延續中的回測確認，配合動能、量能與結構過濾後做多。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["atr_length", "swing_legs", "major_legs", "candle_confirm_threshold", "pivot_watch_threshold", "min_pullback_ratio", "max_pullback_ratio", "location_block_atr", "micro_trigger_mode", "max_bars", "base_atr_multiplier", "breakeven_r", "tighten_r", "min_risk_atr", "max_risk_atr", "exit_on_opposite_trigger"],
    "signal_parameter_sets": [{"atr_length": 14, "swing_legs": 7, "major_legs": 18, "candle_confirm_threshold": 68.0, "pivot_watch_threshold": 60.0, "min_pullback_ratio": 0.12, "max_pullback_ratio": 0.52, "location_block_atr": 0.50, "micro_trigger_mode": "Break + Retest", "max_bars": 160, "base_atr_multiplier": 2.15, "breakeven_r": 0.95, "tighten_r": 1.75, "min_risk_atr": 0.35, "max_risk_atr": 2.50, "exit_on_opposite_trigger": True}],
}