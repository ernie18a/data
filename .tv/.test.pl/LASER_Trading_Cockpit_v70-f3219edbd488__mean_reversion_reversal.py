import numpy as np


def _numeric(value, size):
    try:
        array = np.asarray(value, dtype=float)
    except (TypeError, ValueError):
        return None
    if array.ndim == 0:
        return np.full(size, float(array), dtype=float)
    if array.ndim != 1 or array.size != size:
        return None
    return array.astype(float, copy=False)


def _read_series(features, names, size):
    owners = (features, getattr(features, "market", None))
    for owner in owners:
        if owner is None:
            continue
        for name in names:
            if not hasattr(owner, name):
                continue
            value = getattr(owner, name)
            if callable(value):
                try:
                    value = value()
                except TypeError:
                    continue
            result = _numeric(value, size)
            if result is not None:
                return result
    return np.full(size, np.nan, dtype=float)


def _rolling_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        part = values[index - window + 1 : index + 1]
        if np.all(np.isfinite(part)):
            result[index] = np.mean(part)
    return result


def _rolling_std(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        part = values[index - window + 1 : index + 1]
        if np.all(np.isfinite(part)):
            result[index] = np.std(part, ddof=0)
    return result


def _rolling_min(values, window, include_current=True):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(values.size):
        end = index + 1 if include_current else index
        start = end - window
        if start >= 0 and end > start:
            part = values[start:end]
            if np.all(np.isfinite(part)):
                result[index] = np.min(part)
    return result


def _rolling_max(values, window, include_current=True):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(values.size):
        end = index + 1 if include_current else index
        start = end - window
        if start >= 0 and end > start:
            part = values[start:end]
            if np.all(np.isfinite(part)):
                result[index] = np.max(part)
    return result


def _linreg_slope(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    x = np.arange(window, dtype=float)
    x_centered = x - np.mean(x)
    denominator = float(np.sum(x_centered * x_centered))
    for index in range(window - 1, values.size):
        part = values[index - window + 1 : index + 1]
        if denominator > 0.0 and np.all(np.isfinite(part)):
            result[index] = np.sum(x_centered * (part - np.mean(part))) / denominator
    return result


def _atr(features, highs, lows, closes, window):
    method = getattr(features, "atr", None)
    if callable(method):
        try:
            result = _numeric(method(window), closes.size)
            if result is not None:
                return result
        except (TypeError, ValueError, AttributeError):
            pass
    true_range = np.full(closes.size, np.nan, dtype=float)
    if closes.size:
        true_range[0] = highs[0] - lows[0]
    if closes.size > 1:
        true_range[1:] = np.maximum(
            highs[1:] - lows[1:],
            np.maximum(np.abs(highs[1:] - closes[:-1]), np.abs(lows[1:] - closes[:-1])),
        )
    return _rolling_mean(true_range, window)


def _rsi(closes, window):
    result = np.full(closes.size, np.nan, dtype=float)
    if closes.size <= window:
        return result
    delta = np.diff(closes)
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
    avg_gain = np.mean(gains[:window])
    avg_loss = np.mean(losses[:window])
    result[window] = 100.0 if avg_loss == 0.0 and avg_gain > 0.0 else 50.0 if avg_loss == 0.0 else 100.0 - 100.0 / (1.0 + avg_gain / avg_loss)
    for index in range(window + 1, closes.size):
        avg_gain = (avg_gain * (window - 1.0) + gains[index - 1]) / window
        avg_loss = (avg_loss * (window - 1.0) + losses[index - 1]) / window
        if avg_loss == 0.0:
            result[index] = 100.0 if avg_gain > 0.0 else 50.0
        else:
            result[index] = 100.0 - 100.0 / (1.0 + avg_gain / avg_loss)
    return result


def _bars_since(condition):
    result = np.full(condition.size, np.inf, dtype=float)
    last = -1
    for index, value in enumerate(condition):
        if value:
            last = index
        if last >= 0:
            result[index] = index - last
    return result


def _optional_level(features, names, size):
    return _read_series(features, names, size)


def _close_confirmed(features, size):
    return _read_series(features, ("closed", "is_closed", "bar_closed", "confirmed"), size)


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return empty, empty.copy(), empty.copy(), empty.copy()

    params = signal_params or {}
    atr_length = max(1, int(params.get("atr_length", 14)))
    rsi_length = max(2, int(params.get("rsi_length", 14)))
    momentum_window = max(2, int(params.get("rsi_roc_window", 4)))
    structure_window = max(3, int(params.get("structure_lookback", 12)))
    micro_window = max(2, int(params.get("micro_lookback", 4)))
    impulse_window = max(5, int(params.get("mature_impulse_lookback", 20)))
    location_atr = float(params.get("location_atr", 0.25))
    mature_impulse_atr = float(params.get("mature_impulse_atr", 2.5))
    stop_buffer_atr = float(params.get("stop_buffer_atr", 0.10))
    required_score = float(params.get("required_score", 70.0))
    minimum_room_r = float(params.get("minimum_room_r", 1.0))
    cooldown_bars = max(0, int(params.get("cooldown_bars", 3)))
    rsi_shock = float(params.get("rsi_shock", 4.0))
    divergence_memory = max(1, int(params.get("divergence_memory_bars", 12)))
    pivot_left = max(1, int(params.get("divergence_pivot_left", 5)))
    pivot_right = max(1, int(params.get("divergence_pivot_right", 5)))
    strong_div_atr = float(params.get("strong_divergence_atr", 0.30))
    track_tp2 = bool(params.get("track_tp2", False))
    tp1_r = float(params.get("tp1_r", 1.0))
    tp2_r = float(params.get("tp2_r", 2.0))
    require_closed = bool(params.get("require_closed_candle", True))

    opens = _read_series(features, ("opens", "open"), size)
    highs = _read_series(features, ("highs", "high"), size)
    lows = _read_series(features, ("lows", "low"), size)
    closes = _read_series(features, ("closes", "close"), size)
    volumes = _read_series(features, ("volumes", "volume"), size)
    if any(array.ndim != 1 or array.size != size for array in (opens, highs, lows, closes, volumes)):
        raise ValueError("market OHLCV 必須是與 market.size 等長的一維陣列")

    atr = _atr(features, highs, lows, closes, atr_length)
    rsi = _rsi(closes, rsi_length)
    rsi_roc = rsi - np.roll(rsi, 1)
    rsi_roc[0] = np.nan
    rsi_slope = _linreg_slope(rsi, momentum_window)

    volume_average = _rolling_mean(volumes, 20)
    relative_volume = np.divide(volumes, volume_average, out=np.full(size, np.nan), where=volume_average > 0.0)
    candle_range = np.maximum(highs - lows, np.finfo(float).eps)
    body = np.abs(closes - opens)
    lower_wick = np.minimum(opens, closes) - lows
    upper_wick = highs - np.maximum(opens, closes)
    candle_mid = (highs + lows) / 2.0
    body_pct = body / candle_range * 100.0
    lower_wick_pct = lower_wick / candle_range * 100.0
    upper_wick_pct = upper_wick / candle_range * 100.0
    bull_reject = (closes > opens) & (lower_wick > np.maximum(body, np.finfo(float).eps))
    bear_reject = (closes < opens) & (upper_wick > np.maximum(body, np.finfo(float).eps))
    selling_absorbed = (
        (relative_volume >= float(params.get("absorption_volume", 1.50)))
        & (body_pct <= float(params.get("absorption_max_body_pct", 40.0)))
        & (lower_wick_pct >= float(params.get("absorption_min_wick_pct", 35.0)))
        & (lower_wick >= upper_wick * float(params.get("absorption_wick_dominance", 1.50)))
        & (closes >= candle_mid)
    )
    buying_absorbed = (
        (relative_volume >= float(params.get("absorption_volume", 1.50)))
        & (body_pct <= float(params.get("absorption_max_body_pct", 40.0)))
        & (upper_wick_pct >= float(params.get("absorption_min_wick_pct", 35.0)))
        & (upper_wick >= lower_wick * float(params.get("absorption_wick_dominance", 1.50)))
        & (closes <= candle_mid)
    )
    final_bull_move = (
        (closes > opens) & (relative_volume >= float(params.get("move_volume", 1.65)))
        & (candle_range >= atr * float(params.get("move_range_atr", 0.90)))
        & (body_pct >= float(params.get("move_body_pct", 60.0)))
        & (closes >= highs - candle_range * float(params.get("move_close_pct", 20.0)) / 100.0)
        & ~selling_absorbed & ~buying_absorbed
    )
    final_bear_move = (
        (closes < opens) & (relative_volume >= float(params.get("move_volume", 1.65)))
        & (candle_range >= atr * float(params.get("move_range_atr", 0.90)))
        & (body_pct >= float(params.get("move_body_pct", 60.0)))
        & (closes <= lows + candle_range * float(params.get("move_close_pct", 20.0)) / 100.0)
        & ~selling_absorbed & ~buying_absorbed
    )

    bb_length = max(1, int(params.get("bb_length", 20)))
    kc_length = max(1, int(params.get("kc_length", 20)))
    bb_basis = _rolling_mean(closes, bb_length)
    bb_deviation = float(params.get("bb_mult", 2.0)) * _rolling_std(closes, bb_length)
    kc_basis = _rolling_mean(closes, kc_length)
    true_range = np.maximum(
        highs - lows,
        np.maximum(np.abs(highs - np.roll(closes, 1)), np.abs(lows - np.roll(closes, 1))),
    )
    true_range[0] = highs[0] - lows[0]
    kc_range = _rolling_mean(true_range, kc_length)
    squeeze_on = (bb_basis - bb_deviation > kc_basis - kc_range * float(params.get("kc_mult", 1.5))) & (bb_basis + bb_deviation < kc_basis + kc_range * float(params.get("kc_mult", 1.5)))
    squeeze_off = (bb_basis - bb_deviation < kc_basis - kc_range * float(params.get("kc_mult", 1.5))) & (bb_basis + bb_deviation > kc_basis + kc_range * float(params.get("kc_mult", 1.5)))
    squeeze_fired = np.roll(squeeze_on, 1) & squeeze_off
    squeeze_fired[0] = False
    range_middle = (_rolling_max(highs, kc_length) + _rolling_min(lows, kc_length)) / 2.0
    momentum_basis = (range_middle + kc_basis) / 2.0
    sqz_momentum = _linreg_slope(closes - momentum_basis, kc_length)
    sqz_roc = sqz_momentum - np.roll(sqz_momentum, 1)
    sqz_accel = sqz_roc - np.roll(sqz_roc, 1)
    sqz_bull_accel = (sqz_momentum > 0.0) & (sqz_roc > 0.0)
    sqz_bull_decel = (sqz_momentum > 0.0) & (sqz_roc < 0.0)
    sqz_bear_accel = (sqz_momentum < 0.0) & (sqz_roc < 0.0)
    sqz_bear_decel = (sqz_momentum < 0.0) & (sqz_roc > 0.0)
    bull_zero_cross = (sqz_momentum > 0.0) & (np.roll(sqz_momentum, 1) <= 0.0)
    bear_zero_cross = (sqz_momentum < 0.0) & (np.roll(sqz_momentum, 1) >= 0.0)
    bull_zero_cross[0] = False
    bear_zero_cross[0] = False
    sqz_bull_reaccel = sqz_bull_accel & (sqz_accel > 0.0)
    sqz_bear_reaccel = sqz_bear_accel & (sqz_accel < 0.0)
    negative_run = np.zeros(size, dtype=int)
    positive_run = np.zeros(size, dtype=int)
    for index in range(size):
        negative_run[index] = negative_run[index - 1] + 1 if index and sqz_momentum[index] < 0.0 else int(sqz_momentum[index] < 0.0)
        positive_run[index] = positive_run[index - 1] + 1 if index and sqz_momentum[index] > 0.0 else int(sqz_momentum[index] > 0.0)
    recent_release = _bars_since(squeeze_fired) <= int(params.get("recent_release_bars", 6))

    prior_resistance = _rolling_max(highs, structure_window, include_current=False)
    prior_support = _rolling_min(lows, structure_window, include_current=False)
    micro_resistance = _rolling_max(highs, micro_window, include_current=False)
    micro_support = _rolling_min(lows, micro_window, include_current=False)
    sweep_high = (highs > prior_resistance) & (closes < prior_resistance)
    sweep_low = (lows < prior_support) & (closes > prior_support)
    fresh_sweep_high = _bars_since(sweep_high) <= 1
    fresh_sweep_low = _bars_since(sweep_low) <= 1
    micro_bull_break = closes > micro_resistance
    micro_bear_break = closes < micro_support
    higher_low = (lows > np.roll(lows, 1)) & (np.roll(lows, 1) >= np.roll(lows, 2))
    lower_high = (highs < np.roll(highs, 1)) & (np.roll(highs, 1) <= np.roll(highs, 2))
    higher_low[:2] = False
    lower_high[:2] = False
    bullish_disagreement = (closes - np.roll(closes, momentum_window - 1) <= -5.0) & (_linreg_slope(closes, momentum_window) < 0.0) & (rsi_slope > 0.0) & (_linreg_slope(sqz_momentum, momentum_window) > 0.0)
    bearish_disagreement = (closes - np.roll(closes, momentum_window - 1) >= 5.0) & (_linreg_slope(closes, momentum_window) > 0.0) & (rsi_slope < 0.0) & (_linreg_slope(sqz_momentum, momentum_window) < 0.0)

    vwap = _optional_level(features, ("session_vwap", "futures_session_vwap", "vwap"), size)
    rolling_vwap = _rolling_mean(closes * volumes, 20) / _rolling_mean(volumes, 20)
    vwap = np.where(np.isfinite(vwap), vwap, rolling_vwap)
    vah = _optional_level(features, ("vah", "active_vah", "value_area_high", "globex_vah"), size)
    val = _optional_level(features, ("val", "active_val", "value_area_low", "globex_val"), size)
    poc = _optional_level(features, ("poc", "active_poc", "point_of_control", "globex_poc"), size)
    rolling_high = _rolling_max(highs, impulse_window)
    rolling_low = _rolling_min(lows, impulse_window)
    fallback_range = rolling_high - rolling_low
    vah = np.where(np.isfinite(vah), vah, rolling_low + fallback_range * 0.85)
    val = np.where(np.isfinite(val), val, rolling_low + fallback_range * 0.15)
    poc = np.where(np.isfinite(poc), poc, vwap)

    key_levels = [vah, val, poc, prior_resistance, prior_support]
    for names in (
        ("previous_globex_high", "globex_high", "prev_globex_high"),
        ("previous_globex_low", "globex_low", "prev_globex_low"),
        ("previous_week_high", "week_high", "pwh"),
        ("previous_week_low", "week_low", "pwl"),
        ("previous_asia_high", "asia_high", "prev_asia_high"),
        ("previous_asia_low", "asia_low", "prev_asia_low"),
        ("previous_london_high", "london_high", "prev_london_high"),
        ("previous_london_low", "london_low", "prev_london_low"),
        ("previous_nyse_high", "nyse_high", "prev_nyse_high"),
        ("previous_nyse_low", "nyse_low", "prev_nyse_low"),
    ):
        level = _optional_level(features, names, size)
        if np.any(np.isfinite(level)):
            key_levels.append(level)

    support_location = np.zeros(size, dtype=float)
    resistance_location = np.zeros(size, dtype=float)
    for level in key_levels:
        near = np.isfinite(level) & np.isfinite(atr) & (np.abs(closes - level) <= atr * location_atr)
        support_location += np.where(near & (closes >= level), 4.0, 0.0)
        resistance_location += np.where(near & (closes <= level), 4.0, 0.0)
    near_val = np.isfinite(val) & (np.abs(closes - val) <= atr * location_atr)
    near_vah = np.isfinite(vah) & (np.abs(closes - vah) <= atr * location_atr)
    support_location = np.minimum(support_location, 10.0)
    resistance_location = np.minimum(resistance_location, 10.0)

    failed_val = (lows < val) & (closes > val) & (selling_absorbed | bull_reject | (rsi_roc > 0.0))
    failed_vah = (highs > vah) & (closes < vah) & (buying_absorbed | bear_reject | (rsi_roc < 0.0))
    recent_failed_val = _bars_since(failed_val) <= int(params.get("failed_auction_memory", 5))
    recent_failed_vah = _bars_since(failed_vah) <= int(params.get("failed_auction_memory", 5))
    mature_bear_impulse = (rolling_high - closes) >= atr * mature_impulse_atr
    mature_bull_impulse = (closes - rolling_low) >= atr * mature_impulse_atr
    mature_bear_momentum = np.roll(negative_run, 1) >= int(params.get("mature_momentum_bars", 6))
    mature_bull_momentum = np.roll(positive_run, 1) >= int(params.get("mature_momentum_bars", 6))
    mature_bear_momentum[0] = False
    mature_bull_momentum[0] = False
    bullish_div = np.zeros(size, dtype=bool)
    bearish_div = np.zeros(size, dtype=bool)
    bull_div_overshoot = np.full(size, np.nan)
    bear_div_overshoot = np.full(size, np.nan)
    last_low_pivot = None
    last_high_pivot = None
    for index in range(pivot_left + pivot_right, size):
        pivot = index - pivot_right
        left = pivot - pivot_left
        right = pivot + pivot_right + 1
        if left < 0 or not np.all(np.isfinite(rsi[left:right])):
            continue
        if rsi[pivot] <= np.min(rsi[left:right]) and rsi[pivot] == np.min(rsi[left:right]):
            current = (rsi[pivot], lows[pivot], atr[pivot])
            if last_low_pivot is not None and current[0] > last_low_pivot[0] and current[1] < last_low_pivot[1]:
                bullish_div[index] = True
                if np.isfinite(current[2]) and current[2] > 0.0:
                    bull_div_overshoot[index] = (last_low_pivot[1] - current[1]) / current[2]
            last_low_pivot = current
        if rsi[pivot] >= np.max(rsi[left:right]) and rsi[pivot] == np.max(rsi[left:right]):
            current = (rsi[pivot], highs[pivot], atr[pivot])
            if last_high_pivot is not None and current[0] < last_high_pivot[0] and current[1] > last_high_pivot[1]:
                bearish_div[index] = True
                if np.isfinite(current[2]) and current[2] > 0.0:
                    bear_div_overshoot[index] = (current[1] - last_high_pivot[1]) / current[2]
            last_high_pivot = current
    recent_bull_div = _bars_since(bullish_div) <= divergence_memory
    recent_bear_div = _bars_since(bearish_div) <= divergence_memory
    last_bull_overshoot = np.full(size, np.nan)
    last_bear_overshoot = np.full(size, np.nan)
    for index in range(size):
        if index and np.isfinite(last_bull_overshoot[index - 1]):
            last_bull_overshoot[index] = last_bull_overshoot[index - 1]
        if index and np.isfinite(last_bear_overshoot[index - 1]):
            last_bear_overshoot[index] = last_bear_overshoot[index - 1]
        if np.isfinite(bull_div_overshoot[index]):
            last_bull_overshoot[index] = bull_div_overshoot[index]
        if np.isfinite(bear_div_overshoot[index]):
            last_bear_overshoot[index] = bear_div_overshoot[index]
    bull_div_strong = recent_bull_div & (last_bull_overshoot >= strong_div_atr)
    bear_div_strong = recent_bear_div & (last_bear_overshoot >= strong_div_atr)
    long_rotation = sqz_bear_decel | (rsi_roc >= rsi_shock) | bullish_disagreement | bull_zero_cross | recent_bull_div
    short_rotation = sqz_bull_decel | (rsi_roc <= -rsi_shock) | bearish_disagreement | bear_zero_cross | recent_bear_div
    long_excursion = mature_bear_impulse & (near_val | (support_location >= 4.0) | fresh_sweep_low)
    short_excursion = mature_bull_impulse & (near_vah | (resistance_location >= 4.0) | fresh_sweep_high)
    long_reaction = selling_absorbed | bull_reject | recent_failed_val
    short_reaction = buying_absorbed | bear_reject | recent_failed_vah
    long_change = micro_bull_break | ((closes > opens) & (closes > np.roll(closes, 1))) | bull_zero_cross
    short_change = micro_bear_break | ((closes < opens) & (closes < np.roll(closes, 1))) | bear_zero_cross
    long_eligible = long_excursion & long_reaction & long_rotation & long_change
    short_eligible = short_excursion & short_reaction & short_rotation & short_change

    long_stop = np.full(size, np.nan)
    short_stop = np.full(size, np.nan)
    fallback_low_3 = _rolling_min(lows, 3)
    fallback_high_3 = _rolling_max(highs, 3)
    recent_low_5 = _rolling_min(lows, 5, include_current=False)
    recent_high_5 = _rolling_max(highs, 5, include_current=False)
    last_sweep_low = np.full(size, np.nan)
    last_sweep_high = np.full(size, np.nan)
    for index in range(size):
        if index and np.isfinite(last_sweep_low[index - 1]):
            last_sweep_low[index] = last_sweep_low[index - 1]
        if index and np.isfinite(last_sweep_high[index - 1]):
            last_sweep_high[index] = last_sweep_high[index - 1]
        if sweep_low[index]:
            last_sweep_low[index] = lows[index]
        if sweep_high[index]:
            last_sweep_high[index] = highs[index]
        low_base = last_sweep_low[index] if fresh_sweep_low[index] else fallback_low_3[index]
        high_base = last_sweep_high[index] if fresh_sweep_high[index] else fallback_high_3[index]
        long_stop[index] = low_base - atr[index] * stop_buffer_atr
        short_stop[index] = high_base + atr[index] * stop_buffer_atr

    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    closed = _close_confirmed(features, size)
    closed = np.where(np.isfinite(closed), closed > 0.0, True)
    position = 0
    entry_bar = -1
    entry_price = np.nan
    entry_stop = np.nan
    entry_risk = np.nan
    tp1_done = False
    last_entry_bar = -10**9
    for index in range(size):
        if position == 1 and index > entry_bar:
            stop_touched = np.isfinite(entry_stop) and lows[index] <= entry_stop
            tp1_touched = highs[index] >= entry_price + entry_risk * tp1_r
            tp2_touched = highs[index] >= entry_price + entry_risk * tp2_r
            if not tp1_done:
                if stop_touched:
                    long_exits[index] = True
                    position = 0
                elif tp1_touched and not track_tp2:
                    long_exits[index] = True
                    position = 0
                elif tp1_touched:
                    tp1_done = True
                    if tp2_touched:
                        long_exits[index] = True
                        position = 0
            elif stop_touched or tp2_touched:
                long_exits[index] = True
                position = 0
        elif position == -1 and index > entry_bar:
            stop_touched = np.isfinite(entry_stop) and highs[index] >= entry_stop
            tp1_touched = lows[index] <= entry_price - entry_risk * tp1_r
            tp2_touched = lows[index] <= entry_price - entry_risk * tp2_r
            if not tp1_done:
                if stop_touched:
                    short_exits[index] = True
                    position = 0
                elif tp1_touched and not track_tp2:
                    short_exits[index] = True
                    position = 0
                elif tp1_touched:
                    tp1_done = True
                    if tp2_touched:
                        short_exits[index] = True
                        position = 0
            elif stop_touched or tp2_touched:
                short_exits[index] = True
                position = 0

        if position != 0 or not closed[index] or index - last_entry_bar <= cooldown_bars:
            continue
        long_risk = closes[index] - long_stop[index]
        short_risk = short_stop[index] - closes[index]
        level_above = [level[index] for level in key_levels if np.isfinite(level[index]) and level[index] > closes[index]]
        level_below = [level[index] for level in key_levels if np.isfinite(level[index]) and level[index] < closes[index]]
        long_room = (min(level_above) - closes[index]) / long_risk if level_above and long_risk > 0.0 else 10.0
        short_room = (closes[index] - max(level_below)) / short_risk if level_below and short_risk > 0.0 else 10.0
        long_score = 0.0
        short_score = 0.0
        if long_eligible[index]:
            long_score = 25.0 + min(support_location[index] * 2.0, 20.0)
            long_score += 10.0 if mature_bear_momentum[index] else 0.0
            long_score += 20.0 if selling_absorbed[index] else 0.0
            long_score += 10.0 if ((lows[index] >= recent_low_5[index]) and (bull_reject[index] or selling_absorbed[index] or closes[index] > opens[index])) else 0.0
            long_score += 10.0 if sqz_bear_decel[index] else 0.0
            long_score += 8.0 if rsi_roc[index] >= rsi_shock else 0.0
            long_score += 8.0 if recent_bull_div[index] else 0.0
            long_score += 4.0 if bull_div_strong[index] else 0.0
            long_score += 10.0 if micro_bull_break[index] else 0.0
            long_score += 8.0 if bull_zero_cross[index] else 0.0
            long_score -= 15.0 if final_bear_move[index] else 0.0
            long_score += 10.0 if long_risk > 0.0 and long_room >= minimum_room_r else 0.0
        if short_eligible[index]:
            short_score = 25.0 + min(resistance_location[index] * 2.0, 20.0)
            short_score += 10.0 if mature_bull_momentum[index] else 0.0
            short_score += 20.0 if buying_absorbed[index] else 0.0
            short_score += 10.0 if ((highs[index] <= recent_high_5[index]) and (bear_reject[index] or buying_absorbed[index] or closes[index] < opens[index])) else 0.0
            short_score += 10.0 if sqz_bull_decel[index] else 0.0
            short_score += 8.0 if rsi_roc[index] <= -rsi_shock else 0.0
            short_score += 8.0 if recent_bear_div[index] else 0.0
            short_score += 4.0 if bear_div_strong[index] else 0.0
            short_score += 10.0 if micro_bear_break[index] else 0.0
            short_score += 8.0 if bear_zero_cross[index] else 0.0
            short_score -= 15.0 if final_bull_move[index] else 0.0
            short_score += 10.0 if short_risk > 0.0 and short_room >= minimum_room_r else 0.0
        long_ok = long_eligible[index] and long_score >= required_score and long_risk > 0.0 and long_room >= minimum_room_r
        short_ok = short_eligible[index] and short_score >= required_score and short_risk > 0.0 and short_room >= minimum_room_r
        if long_ok and (not short_ok or long_score > short_score):
            long_entries[index] = True
            position = 1
            entry_bar = index
            entry_price = closes[index]
            entry_stop = long_stop[index]
            entry_risk = long_risk
            tp1_done = False
            last_entry_bar = index
        elif short_ok and (not long_ok or short_score > long_score):
            short_entries[index] = True
            position = -1
            entry_bar = index
            entry_price = closes[index]
            entry_stop = short_stop[index]
            entry_risk = short_risk
            tp1_done = False
            last_entry_bar = index
    return (
        np.asarray(long_entries, dtype=np.bool_),
        np.asarray(long_exits, dtype=np.bool_),
        np.asarray(short_entries, dtype=np.bool_),
        np.asarray(short_exits, dtype=np.bool_),
    )


STRATEGY = {
    "strategy_id": "mean_reversion_reversal",
    "hypothesis": "成熟單邊擴張在關鍵位置出現反應、動能輪轉與微型狀態改變後，均值回歸或反轉的勝率提高。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "required_score", "mature_impulse_atr", "location_atr", "stop_buffer_atr",
        "tp1_r", "tp2_r", "track_tp2", "minimum_room_r", "atr_length",
        "rsi_length", "rsi_roc_window", "rsi_shock", "cooldown_bars",
        "require_closed_candle",
    ],
    "signal_parameter_sets": [{
        "required_score": 70.0,
        "mature_impulse_atr": 2.5,
        "location_atr": 0.25,
        "stop_buffer_atr": 0.10,
        "tp1_r": 1.0,
        "tp2_r": 2.0,
        "track_tp2": False,
        "minimum_room_r": 1.0,
        "atr_length": 14,
        "rsi_length": 14,
        "rsi_roc_window": 4,
        "rsi_shock": 4.0,
        "cooldown_bars": 3,
        "require_closed_candle": True,
    }],
}