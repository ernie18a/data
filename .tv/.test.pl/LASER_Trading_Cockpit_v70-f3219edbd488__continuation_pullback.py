import numpy as np


def _series(obj, names, n, default=np.nan):
    for name in names:
        try:
            value = getattr(obj, name)
        except AttributeError:
            continue
        if callable(value):
            try:
                value = value()
            except TypeError:
                continue
        try:
            array = np.asarray(value, dtype=float).reshape(-1)
        except (TypeError, ValueError):
            continue
        if array.size == 1:
            return np.full(n, float(array[0]))
        if array.size == n:
            return array
    return np.full(n, default, dtype=float)


def _optional(features, market, names, n, fallback):
    result = _series(features, names, n)
    if not np.isfinite(result).any():
        result = _series(market, names, n)
    return result if np.isfinite(result).any() else np.asarray(fallback, dtype=float).copy()


def _sma(values, length):
    result = np.full(values.size, np.nan)
    for i in range(length - 1, values.size):
        window = values[i - length + 1:i + 1]
        if np.isfinite(window).all():
            result[i] = np.mean(window)
    return result


def _ema(values, length):
    result = np.full(values.size, np.nan)
    if values.size < length or not np.isfinite(values[:length]).all():
        return result
    result[length - 1] = np.mean(values[:length])
    alpha = 2.0 / (length + 1.0)
    for i in range(length, values.size):
        result[i] = alpha * values[i] + (1.0 - alpha) * result[i - 1]
    return result


def _atr(highs, lows, closes, length):
    previous = np.r_[closes[0], closes[:-1]]
    true_range = np.maximum(highs - lows, np.maximum(abs(highs - previous), abs(lows - previous)))
    result = np.full(closes.size, np.nan)
    if closes.size < length:
        return result
    result[length - 1] = np.mean(true_range[:length])
    for i in range(length, closes.size):
        result[i] = ((length - 1.0) * result[i - 1] + true_range[i]) / length
    return result


def _rsi(closes, length):
    delta = np.diff(closes, prepend=closes[0])
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
    result = np.full(closes.size, np.nan)
    if closes.size <= length:
        return result
    gain = np.mean(gains[1:length + 1])
    loss = np.mean(losses[1:length + 1])
    for i in range(length, closes.size):
        if i > length:
            gain = ((length - 1.0) * gain + gains[i]) / length
            loss = ((length - 1.0) * loss + losses[i]) / length
        result[i] = 100.0 if loss == 0.0 else 100.0 - 100.0 / (1.0 + gain / loss)
    return result


def _rolling(values, length, kind, previous=False):
    result = np.full(values.size, np.nan)
    for i in range(values.size):
        end = i if previous else i + 1
        start = end - length
        if start >= 0:
            window = values[start:end]
            if np.isfinite(window).all():
                result[i] = np.min(window) if kind == 'min' else np.max(window)
    return result


def _bars_since(condition):
    result = np.full(condition.size, condition.size + 1, dtype=int)
    last = -10**9
    for i, value in enumerate(condition):
        if value:
            last = i
        if last >= 0:
            result[i] = i - last
    return result


def _linreg(values, length):
    result = np.full(values.size, np.nan)
    x = np.arange(length, dtype=float)
    sx = np.sum(x)
    sxx = np.sum(x * x)
    denominator = length * sxx - sx * sx
    for i in range(length - 1, values.size):
        window = values[i - length + 1:i + 1]
        if np.isfinite(window).all():
            sy = np.sum(window)
            slope = (length * np.sum(x * window) - sx * sy) / denominator
            result[i] = (sy - slope * sx) / length + slope * (length - 1.0)
    return result


def _near(level, price, atr, distance):
    return np.isfinite(level) & np.isfinite(atr) & (abs(price - level) <= atr * distance)


def generate_signals(features, signal_params):
    params = signal_params or {}
    market = features.market
    size = int(market.size)
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    volumes = np.asarray(market.volumes, dtype=float).reshape(-1)

    atr_length = int(params.get('atr_length', 14))
    micro_length = int(params.get('micro_lookback', 4))
    structure_length = int(params.get('structure_lookback', 12))
    stop_buffer = float(params.get('stop_buffer_atr', 0.10))
    location_atr = float(params.get('location_atr', 0.25))
    minimum_room = float(params.get('minimum_room_r', 1.0))
    cooldown = int(params.get('cooldown', 3))
    preset = params.get('preset', 'Neutral')
    required_score = 60.0 if preset == 'Aggressive' else 80.0 if preset == 'Conservative' else 70.0
    require_closed = bool(params.get('require_closed_bar', True))
    track_tp2 = bool(params.get('track_tp2', False))
    tp1_r = float(params.get('tp1_r', 1.0))
    tp2_r = float(params.get('tp2_r', 2.0))

    atr = _optional(features, market, ('atr_values', 'atr_series'), size, _atr(highs, lows, closes, atr_length))
    try:
        candidate_atr = np.asarray(features.atr(atr_length), dtype=float).reshape(-1)
        if candidate_atr.size == size:
            atr = candidate_atr
    except (AttributeError, TypeError, ValueError):
        pass

    fast = _optional(features, market, ('fast_ema', 'ema_fast', 'laserFastEma'), size, _ema(closes, 5))
    trend = _optional(features, market, ('trend_ema', 'ema_trend', 'laserTrendEma'), size, _ema(closes, 50))
    volume_sum = np.cumsum(np.maximum(volumes, 0.0))
    vwap_fallback = np.cumsum((highs + lows + closes) * volumes / 3.0) / np.maximum(volume_sum, 1e-12)
    vwap = _optional(features, market, ('session_vwap', 'futures_session_vwap', 'vwap'), size, vwap_fallback)
    vah = _optional(features, market, ('active_vah', 'activeVAH', 'vah'), size, np.full(size, np.nan))
    val = _optional(features, market, ('active_val', 'activeVAL', 'val'), size, np.full(size, np.nan))
    poc = _optional(features, market, ('active_poc', 'activePOC', 'poc'), size, np.full(size, np.nan))
    closed = _optional(features, market, ('closed', 'is_closed', 'bar_closed', 'is_confirmed'), size, np.ones(size)) >= 0.5

    rsi = _optional(features, market, ('rsi', 'RSI'), size, _rsi(closes, 14))
    rsi_roc = _optional(features, market, ('rsi_roc', 'rsiROC', 'rsi_rate_of_change'), size, rsi - np.r_[np.full(4, np.nan), rsi[:-4]])

    basis = _sma(closes, 20)
    deviation = 2.0 * _sma((closes - basis) ** 2, 20) ** 0.5
    kc_range = _sma(np.maximum(highs - lows, np.maximum(abs(highs - np.r_[closes[0], closes[:-1]]), abs(lows - np.r_[closes[0], closes[:-1]]))), 20)
    squeeze_on = (basis - deviation > basis - 1.5 * kc_range) & (basis + deviation < basis + 1.5 * kc_range)
    range_middle = (_rolling(highs, 20, 'max') + _rolling(lows, 20, 'min')) / 2.0
    momentum_fallback = _linreg(closes - (range_middle + basis) / 2.0, 20)
    momentum = _optional(features, market, ('squeeze_momentum', 'sqz_momentum', 'sqzMomentum'), size, momentum_fallback)
    momentum_roc = momentum - np.r_[np.nan, momentum[:-1]]
    momentum_accel = momentum_roc - np.r_[np.nan, momentum_roc[:-1]]
    bull_accel = (momentum > 0) & (momentum_roc > 0)
    bear_accel = (momentum < 0) & (momentum_roc < 0)
    bull_decel = (momentum > 0) & (momentum_roc < 0)
    bear_decel = (momentum < 0) & (momentum_roc > 0)
    bull_reaccel = bull_accel & (momentum_accel > 0)
    bear_reaccel = bear_accel & (momentum_accel < 0)

    prior_support = _rolling(lows, structure_length, 'min', previous=True)
    prior_resistance = _rolling(highs, structure_length, 'max', previous=True)
    micro_support = _rolling(lows, micro_length, 'min', previous=True)
    micro_resistance = _rolling(highs, micro_length, 'max', previous=True)
    trend_slope = trend - np.r_[np.full(3, np.nan), trend[:-3]]
    close15 = _optional(features, market, ('close15', 'close_15'), size, closes)
    ema15 = _optional(features, market, ('ema15', 'ema_15'), size, _ema(closes, 50))
    close60 = _optional(features, market, ('close60', 'close_60'), size, closes)
    ema60 = _optional(features, market, ('ema60', 'ema_60'), size, _ema(closes, 200))
    bull_score = (closes > vwap) + (fast > trend) + (trend_slope > 0) + (close15 > ema15) + (close60 > ema60)
    bear_score = (closes < vwap) + (fast < trend) + (trend_slope < 0) + (close15 < ema15) + (close60 < ema60)
    bull_trend = bull_score >= 3
    bear_trend = bear_score >= 3

    support_location = np.zeros(size)
    resistance_location = np.zeros(size)
    for level, weight in ((vah, 5.0), (val, 5.0), (poc, 4.0), (prior_support, 4.0), (prior_resistance, 4.0), (vwap, 3.5)):
        near = _near(level, closes, atr, location_atr)
        support_location += np.where(near & (closes >= level), weight, 0.0)
        resistance_location += np.where(near & (closes <= level), weight, 0.0)
    support_location = np.minimum(support_location, 10.0)
    resistance_location = np.minimum(resistance_location, 10.0)
    long_touch = (lows <= fast + atr * location_atr) | (lows <= prior_support + atr * location_atr) | _near(vwap, closes, atr, location_atr)
    short_touch = (highs >= fast - atr * location_atr) | (highs >= prior_resistance - atr * location_atr) | _near(vwap, closes, atr, location_atr)
    recent_long_touch = _bars_since(long_touch & (bull_trend | (np.isfinite(vah) & (closes > vah)))) <= 3
    recent_short_touch = _bars_since(short_touch & (bear_trend | (np.isfinite(val) & (closes < val)))) <= 3

    bull_impulse = (closes > opens) & (closes > np.r_[closes[0], closes[:-1]])
    bear_impulse = (closes < opens) & (closes < np.r_[closes[0], closes[:-1]])
    long_reaccel = (rsi_roc > 0) & (((momentum > 0) & (momentum_roc > 0)) | bull_reaccel | bull_impulse)
    short_reaccel = (rsi_roc < 0) & (((momentum < 0) & (momentum_roc < 0)) | bear_reaccel | bear_impulse)

    average_volume = _sma(volumes, 20)
    rvol = volumes / np.maximum(average_volume, 1e-12)
    candle_range = highs - lows
    body_pct = 100.0 * abs(closes - opens) / np.maximum(candle_range, 1e-12)
    lower_wick = np.minimum(opens, closes) - lows
    upper_wick = highs - np.maximum(opens, closes)
    selling_absorbed = (rvol >= 1.5) & (body_pct <= 40.0) & (lower_wick >= candle_range * 0.35) & (lower_wick >= upper_wick * 1.5) & (closes >= (highs + lows) / 2.0)
    buying_absorbed = (rvol >= 1.5) & (body_pct <= 40.0) & (upper_wick >= candle_range * 0.35) & (upper_wick >= lower_wick * 1.5) & (closes <= (highs + lows) / 2.0)

    bull_break = closes > micro_resistance
    bear_break = closes < micro_support
    bull_shift = bull_break & (selling_absorbed | bull_impulse)
    bear_shift = bear_break & (buying_absorbed | bear_impulse)
    bull_level = np.full(size, np.nan)
    bear_level = np.full(size, np.nan)
    last_bull = np.nan
    last_bear = np.nan
    for i in range(size):
        if bull_shift[i]:
            last_bull = micro_resistance[i]
        if bear_shift[i]:
            last_bear = micro_support[i]
        bull_level[i] = last_bull
        bear_level[i] = last_bear
    structure_long = (_bars_since(bull_shift) <= 8) & (((lows <= fast + atr * location_atr) & (closes > fast)) | ((lows <= bull_level + atr * location_atr) & (closes > bull_level))) & (rsi_roc > 0) & (bear_decel | bull_accel | bull_impulse)
    structure_short = (_bars_since(bear_shift) <= 8) & (((highs >= fast - atr * location_atr) & (closes < fast)) | ((highs >= bear_level - atr * location_atr) & (closes < bear_level))) & (rsi_roc < 0) & (bull_decel | bear_accel | bear_impulse)

    travel = np.zeros(size)
    net = np.full(size, np.nan)
    for i in range(11, size):
        travel[i] = np.sum(abs(np.diff(closes[i - 11:i + 1])))
        net[i] = abs(closes[i] - closes[i - 11])
    efficiency = net / np.maximum(travel, 1e-12)
    compressed = (np.maximum(vwap, np.maximum(fast, trend)) - np.minimum(vwap, np.minimum(fast, trend))) <= atr * 0.75
    cross = np.sign(closes - fast) != np.sign(np.r_[np.nan, closes[:-1] - fast[:-1]])
    cross_count = np.convolve(cross.astype(int), np.ones(12, dtype=int), mode='same')
    balance_score = np.where(efficiency <= 0.30, 25.0, 0.0) + np.where(compressed, 20.0, 0.0) + np.where(cross_count >= 5, 20.0, np.where(cross_count >= 3, 10.0, 0.0))
    hard_balance = (balance_score >= 65.0) & (bull_score < 4) & (bear_score < 4)

    long_stop = _rolling(lows, micro_length, 'min') - atr * stop_buffer
    short_stop = _rolling(highs, micro_length, 'max') + atr * stop_buffer
    long_risk = closes - long_stop
    short_risk = short_stop - closes
    levels = (prior_support, prior_resistance, vah, val, poc)
    nearest_above = np.full(size, np.inf)
    nearest_below = np.full(size, -np.inf)
    for level in levels:
        nearest_above = np.where(np.isfinite(level) & (level > closes) & (level < nearest_above), level, nearest_above)
        nearest_below = np.where(np.isfinite(level) & (level < closes) & (level > nearest_below), level, nearest_below)
    long_room = np.where(np.isfinite(nearest_above), nearest_above - closes, long_risk * 10.0) / np.maximum(long_risk, 1e-12)
    short_room = np.where(np.isfinite(nearest_below), closes - nearest_below, short_risk * 10.0) / np.maximum(short_risk, 1e-12)

    continuation_long = bull_trend & recent_long_touch & long_reaccel & (closes > fast)
    continuation_short = bear_trend & recent_short_touch & short_reaccel & (closes < fast)
    eligible_long = (continuation_long | structure_long) & ~hard_balance
    eligible_short = (continuation_short | structure_short) & ~hard_balance
    long_score = np.where(continuation_long, np.minimum(np.maximum(support_location, 2.5) * 2.0, 20.0) + bull_score * 5.0, 0.0)
    short_score = np.where(continuation_short, np.minimum(np.maximum(resistance_location, 2.5) * 2.0, 20.0) + bear_score * 5.0, 0.0)
    long_score += np.where(continuation_long & bull_reaccel, 10.0, 0.0) + np.where(continuation_long & selling_absorbed, 12.0, 0.0) + np.where(continuation_long & long_risk > 0, 15.0, 0.0)
    short_score += np.where(continuation_short & bear_reaccel, 10.0, 0.0) + np.where(continuation_short & buying_absorbed, 12.0, 0.0) + np.where(continuation_short & short_risk > 0, 15.0, 0.0)
    long_score = np.maximum(long_score, np.where(structure_long, 55.0 + np.where(selling_absorbed, 12.0, 0.0) + np.where(bull_accel, 10.0, 0.0), 0.0))
    short_score = np.maximum(short_score, np.where(structure_short, 55.0 + np.where(buying_absorbed, 12.0, 0.0) + np.where(bear_accel, 10.0, 0.0), 0.0))
    valid = np.arange(size) >= max(60, atr_length + 5)
    long_candidate = valid & eligible_long & (long_score >= required_score) & (long_risk > 0) & (long_room >= minimum_room)
    short_candidate = valid & eligible_short & (short_score >= required_score) & (short_risk > 0) & (short_room >= minimum_room)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    position = 0
    stop = entry = risk = tp1 = tp2 = np.nan
    tp1_done = False
    last_signal = -10**9
    for i in range(size):
        if position == 1:
            if lows[i] < stop:
                long_exits[i] = True
                position = 0
            elif track_tp2 and not tp1_done and highs[i] >= tp1:
                tp1_done = True
            elif not track_tp2 and highs[i] >= tp1:
                long_exits[i] = True
                position = 0
            elif track_tp2 and tp1_done and highs[i] >= tp2:
                long_exits[i] = True
                position = 0
        elif position == -1:
            if highs[i] > stop:
                short_exits[i] = True
                position = 0
            elif track_tp2 and not tp1_done and lows[i] <= tp1:
                tp1_done = True
            elif not track_tp2 and lows[i] <= tp1:
                short_exits[i] = True
                position = 0
            elif track_tp2 and tp1_done and lows[i] <= tp2:
                short_exits[i] = True
                position = 0
        if position == 0 and i - last_signal > cooldown and (not require_closed or closed[i]):
            take_long = long_candidate[i] and (not short_candidate[i] or long_score[i] > short_score[i])
            take_short = short_candidate[i] and (not long_candidate[i] or short_score[i] > long_score[i])
            if take_long:
                long_entries[i] = True
                position = 1
                stop = long_stop[i]
                entry = closes[i]
                risk = long_risk[i]
                tp1 = entry + risk * tp1_r
                tp2 = entry + risk * tp2_r
                tp1_done = False
                last_signal = i
            elif take_short:
                short_entries[i] = True
                position = -1
                stop = short_stop[i]
                entry = closes[i]
                risk = short_risk[i]
                tp1 = entry - risk * tp1_r
                tp2 = entry - risk * tp2_r
                tp1_done = False
                last_signal = i
    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'continuation_pullback',
    'hypothesis': '既有方向趨勢中的支撐或阻力回測，在動能重新轉強與風險空間足夠時延續走勢。',
    'position': 'both',
    'generate_signals': generate_signals,
    'signal_parameter_names': ['preset', 'atr_length', 'micro_lookback', 'structure_lookback', 'stop_buffer_atr', 'location_atr', 'minimum_room_r', 'cooldown', 'require_closed_bar', 'track_tp2', 'tp1_r', 'tp2_r'],
    'signal_parameter_sets': [{'preset': 'Neutral', 'atr_length': 14, 'micro_lookback': 4, 'structure_lookback': 12, 'stop_buffer_atr': 0.1, 'location_atr': 0.25, 'minimum_room_r': 1.0, 'cooldown': 3, 'require_closed_bar': True, 'track_tp2': False, 'tp1_r': 1.0, 'tp2_r': 2.0}],
}