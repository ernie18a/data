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
            return np.full(n, float(array[0]), dtype=float)
        if array.size == n:
            return array
    if np.isscalar(default):
        return np.full(n, float(default), dtype=float)
    return np.asarray(default, dtype=float).reshape(-1).copy()


def _optional(features, market, names, n, fallback):
    result = _series(features, names, n)
    if np.isfinite(result).any():
        return result
    result = _series(market, names, n)
    return result if np.isfinite(result).any() else np.asarray(fallback, dtype=float).copy()


def _sma(values, length):
    result = np.full(values.size, np.nan)
    if length <= 0:
        return result
    for i in range(length - 1, values.size):
        window = values[i - length + 1:i + 1]
        if np.isfinite(window).all():
            result[i] = np.mean(window)
    return result


def _ema(values, length):
    result = np.full(values.size, np.nan)
    if length <= 0 or values.size < length:
        return result
    first = values[:length]
    if not np.isfinite(first).all():
        return result
    result[length - 1] = np.mean(first)
    alpha = 2.0 / (length + 1.0)
    for i in range(length, values.size):
        if np.isfinite(values[i]) and np.isfinite(result[i - 1]):
            result[i] = alpha * values[i] + (1.0 - alpha) * result[i - 1]
    return result


def _atr(highs, lows, closes, length):
    previous = np.r_[closes[0], closes[:-1]]
    true_range = np.maximum(highs - lows, np.maximum(abs(highs - previous), abs(lows - previous)))
    result = np.full(closes.size, np.nan)
    if length <= 0 or closes.size < length:
        return result
    for i in range(length - 1, closes.size):
        window = true_range[i - length + 1:i + 1]
        if np.isfinite(window).all():
            result[i] = np.mean(window)
    return result


def _rsi(closes, length):
    result = np.full(closes.size, np.nan)
    if length <= 0 or closes.size <= length:
        return result
    delta = np.diff(closes, prepend=closes[0])
    gains = np.maximum(delta, 0.0)
    losses = np.maximum(-delta, 0.0)
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
                result[i] = np.min(window) if kind == "min" else np.max(window)
    return result


def _bars_since(condition):
    result = np.full(condition.size, condition.size + 1, dtype=float)
    last = -10**9
    for i, value in enumerate(condition):
        if value:
            last = i
        if last >= 0:
            result[i] = i - last
    return result


def _cci(highs, lows, closes, length):
    typical = (highs + lows + closes) / 3.0
    mean = _sma(typical, length)
    result = np.full(closes.size, np.nan)
    for i in range(length - 1, closes.size):
        window = typical[i - length + 1:i + 1]
        if np.isfinite(window).all() and np.isfinite(mean[i]):
            deviation = np.mean(np.abs(window - mean[i]))
            result[i] = 0.0 if deviation == 0.0 else (typical[i] - mean[i]) / (0.015 * deviation)
    return result


def _clamp(values, low, high):
    return np.minimum(np.maximum(values, low), high)


def _bool_series(values):
    return np.isfinite(values) & (values >= 0.5)


def _latest_pivots(highs, lows, strength):
    n = highs.size
    pivot_high = np.zeros(n, dtype=bool)
    pivot_low = np.zeros(n, dtype=bool)
    for bar in range(2 * strength, n):
        center = bar - strength
        window_high = highs[center - strength:center + strength + 1]
        window_low = lows[center - strength:center + strength + 1]
        if np.isfinite(window_high).all() and highs[center] == np.max(window_high):
            pivot_high[bar] = True
        if np.isfinite(window_low).all() and lows[center] == np.min(window_low):
            pivot_low[bar] = True
    ready = np.zeros(n, dtype=bool)
    seeking_high = np.zeros(n, dtype=bool)
    pivot_price = np.full(n, np.nan)
    pivot_index = np.full(n, -1, dtype=int)
    last_kind = 0
    last_price = np.nan
    last_index = -1
    for bar in range(n):
        if pivot_high[bar] and not pivot_low[bar]:
            last_kind, last_price, last_index = 1, highs[bar - strength], bar - strength
        elif pivot_low[bar]:
            last_kind, last_price, last_index = -1, lows[bar - strength], bar - strength
        ready[bar] = last_kind != 0
        seeking_high[bar] = last_kind == -1
        pivot_price[bar] = last_price
        pivot_index[bar] = last_index
    return ready, seeking_high, pivot_price, pivot_index


def _leg_metrics(highs, lows, closes, atr, ready, seeking_high, pivot_price, pivot_index, fallback_atr):
    n = closes.size
    strength = np.full(n, np.nan)
    risk = np.full(n, np.nan)
    retracement = np.full(n, np.nan)
    extreme = np.full(n, np.nan)
    extreme_bar = np.full(n, -1, dtype=int)
    trend = _ema(closes, 20)
    for i in range(n):
        p = pivot_index[i]
        if not ready[i] or p < 0 or p > i or not np.isfinite(pivot_price[i]):
            continue
        if seeking_high[i]:
            segment = highs[p:i + 1]
            if not np.isfinite(segment).all():
                continue
            ebar = p + int(np.argmax(segment))
            eprice = highs[ebar]
            counter = lows[ebar:i + 1]
            reversal = eprice - np.min(counter) if np.isfinite(counter).all() else np.nan
        else:
            segment = lows[p:i + 1]
            if not np.isfinite(segment).all():
                continue
            ebar = p + int(np.argmin(segment))
            eprice = lows[ebar]
            counter = highs[ebar:i + 1]
            reversal = np.max(counter) - eprice if np.isfinite(counter).all() else np.nan
        leg = abs(eprice - pivot_price[i])
        a = max(float(atr[i]) if np.isfinite(atr[i]) else 0.0, 1e-12)
        leg_atr = leg / a
        bars_to_extreme = max(1, ebar - p)
        bars_since = max(0, i - ebar)
        baseline = a * fallback_atr
        relative = leg / max(baseline, 1e-12)
        velocity = leg_atr / np.sqrt(float(bars_to_extreme))
        slope = trend[i] - trend[max(0, i - 3)] if np.isfinite(trend[i]) and np.isfinite(trend[max(0, i - 3)]) else 0.0
        aligned = (seeking_high[i] and slope >= 0.0) or (not seeking_high[i] and slope <= 0.0)
        ratio = reversal / max(leg, 1e-12) if np.isfinite(reversal) else np.nan
        size_score = min(max(leg_atr / fallback_atr * 24.0, 0.0), 24.0)
        relative_score = min(max(relative * 24.0, 0.0), 24.0)
        velocity_score = min(max(velocity / 0.65 * 20.0, 0.0), 20.0)
        freshness = min(max(16.0 - bars_since / max(2.0, 3.5) * 16.0, 0.0), 16.0)
        structure = 8.0 if aligned else 0.0
        retrace_penalty = min(max(ratio / 0.50 * 28.0, 0.0), 28.0) if np.isfinite(ratio) else 0.0
        stale_penalty = min(max(bars_since / 5.0 * 12.0, 0.0), 12.0)
        strength[i] = _clamp(np.asarray(size_score + relative_score + velocity_score + freshness + structure - retrace_penalty - stale_penalty), 0.0, 100.0)
        one_shift = (closes[i] < lows[i - 1]) if seeking_high[i] and i > 0 else (closes[i] > highs[i - 1] if i > 0 else False)
        two_shift = (closes[i] < np.min(lows[max(0, i - 2):i])) if seeking_high[i] and i > 1 else (closes[i] > np.max(highs[max(0, i - 2):i]) if i > 1 else False)
        overextended = relative >= 1.20 or leg_atr >= fallback_atr * 1.35
        risk[i] = _clamp(np.asarray((ratio / 0.382 * 40.0 if np.isfinite(ratio) else 0.0) + min(max(bars_since / 3.5 * 20.0, 0.0), 20.0) + (20.0 if two_shift else 12.0 if one_shift else 0.0) + (6.0 if overextended else 0.0)), 0.0, 100.0)
        retracement[i] = ratio
        extreme[i] = eprice
        extreme_bar[i] = ebar
    return strength, risk, retracement, extreme, extreme_bar


def _valid_feature_array(features, market, names, n, fallback, boolean=False):
    result = _optional(features, market, names, n, fallback)
    return _bool_series(result) if boolean else result


def generate_signals(features, signal_params):
    params = signal_params or {}
    market = features.market
    size = int(market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return empty.copy(), empty.copy(), empty.copy(), empty.copy()
    try:
        opens = np.asarray(market.opens, dtype=float).reshape(-1)
    except AttributeError:
        opens = np.asarray(getattr(market, "open"), dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    volumes = np.asarray(market.volumes, dtype=float).reshape(-1)
    if any(array.size != size for array in (opens, highs, lows, closes, volumes)):
        return empty.copy(), empty.copy(), empty.copy(), empty.copy()

    strictness = params.get("signal_strictness", "Cân bằng")
    profile = params.get("trading_profile", "Cân bằng")
    micro_mode = params.get("micro_trigger_mode", "Break + Retest")
    management_mode = params.get("trade_management_mode", "Cân bằng")
    location_block = float(params.get("location_block_atr", 0.50))
    candle_threshold = 58.0 if strictness == "Nhạy" else 78.0 if strictness == "Chặt" else 68.0
    pivot_watch = 56.0 if strictness == "Nhạy" else 65.0 if strictness == "Chặt" else 60.0
    min_pullback = 0.08 if strictness == "Nhạy" else 0.18 if strictness == "Chặt" else 0.12
    max_pullback = 0.62 if strictness == "Nhạy" else 0.42 if strictness == "Chặt" else 0.52
    volume_limit = 30.0 if strictness == "Nhạy" else 40.0 if strictness == "Chặt" else 35.0
    regime_block = 55.0 if strictness == "Nhạy" else 68.0 if strictness == "Chặt" else 62.0
    micro_strength = 1 if profile == "Lướt nhanh" else 4 if profile == "Giữ xu hướng" else 2
    micro_expiry = 12 if profile == "Lướt nhanh" else 30 if profile == "Giữ xu hướng" else 20
    max_bars = 80 if profile == "Lướt nhanh" else 260 if profile == "Giữ xu hướng" else 160
    base_mult = 1.55 if management_mode == "Chặt" else 2.85 if management_mode == "Rộng" else 2.15
    breakeven_r = 0.70 if management_mode == "Chặt" else 1.20 if management_mode == "Rộng" else 0.95
    tighten_r = 1.20 if management_mode == "Chặt" else 2.40 if management_mode == "Rộng" else 1.75
    minimum_risk = 0.28 if management_mode == "Chặt" else 0.35
    maximum_risk = 1.80 if management_mode == "Chặt" else 3.20 if management_mode == "Rộng" else 2.50

    atr = _atr(highs, lows, closes, 14)
    try:
        candidate_atr = np.asarray(features.atr(14), dtype=float).reshape(-1)
        if candidate_atr.size == size:
            atr = candidate_atr
    except (AttributeError, TypeError, ValueError):
        pass
    atr = np.where(np.isfinite(atr) & (atr > 0.0), atr, np.nan)
    previous_close = np.r_[closes[0], closes[:-1]]
    candle_range = np.maximum(highs - lows, np.maximum(abs(highs - previous_close), abs(lows - previous_close)))
    safe_range = np.maximum(highs - lows, np.finfo(float).eps)
    body = np.maximum(abs(closes - opens), np.finfo(float).eps)
    previous_body = np.maximum(abs(np.r_[closes[0], closes[:-1]] - np.r_[opens[0], opens[:-1]]), np.finfo(float).eps)
    upper_wick = highs - np.maximum(opens, closes)
    lower_wick = np.minimum(opens, closes) - lows

    prev_close = np.r_[closes[0], closes[:-1]]
    prev_open = np.r_[opens[0], opens[:-1]]
    bear_engulfing = (closes < opens) & (prev_close > prev_open) & (opens >= prev_close) & (closes <= prev_open) & (body >= previous_body * 0.90)
    bear_shooting = (upper_wick >= body * 2.0) & (lower_wick <= safe_range * 0.25) & (closes <= lows + safe_range * 0.40)
    c2_close = np.r_[closes[0], closes[0], closes[:-2]]
    c2_open = np.r_[opens[0], opens[0], opens[:-2]]
    c1_close = prev_close
    c1_open = prev_open
    evening_star = (c2_close > c2_open) & (abs(c1_close - c1_open) <= abs(c2_close - c2_open) * 0.55) & (closes < opens) & (closes <= (c2_open + c2_close) * 0.50)
    dark_cloud = (c1_close > c1_open) & (closes < opens) & (opens >= c1_close) & (closes <= (c1_open + c1_close) * 0.50) & (closes > c1_open)
    bear_pattern = bear_engulfing | evening_star | bear_shooting | dark_cloud
    bear_pattern_quality = np.where(bear_engulfing | evening_star, 35.0, np.where(bear_shooting | dark_cloud, 28.0, 0.0))
    bull_engulfing = (closes > opens) & (prev_close < prev_open) & (opens <= prev_close) & (closes >= prev_open) & (body >= previous_body * 0.90)
    bull_hammer = (lower_wick >= body * 2.0) & (upper_wick <= safe_range * 0.25) & (closes >= lows + safe_range * 0.60)
    morning_star = (c2_close < c2_open) & (abs(c1_close - c1_open) <= abs(c2_close - c2_open) * 0.55) & (closes > opens) & (closes >= (c2_open + c2_close) * 0.50)
    piercing = (c1_close < c1_open) & (closes > opens) & (opens <= c1_close) & (closes >= (c1_open + c1_close) * 0.50) & (closes < c1_open)
    bull_pattern = bull_engulfing | morning_star | bull_hammer | piercing
    bull_pattern_quality = np.where(bull_engulfing | morning_star, 35.0, np.where(bull_hammer | piercing, 28.0, 0.0))

    high_before = _rolling(highs, 20, "max", previous=True)
    low_before = _rolling(lows, 20, "min", previous=True)
    bear_sweep = (highs > high_before) & (closes < high_before) & (closes < opens)
    bull_sweep = (lows < low_before) & (closes > low_before) & (closes > opens)

    swing_ready0, swing_seek0, swing_price0, swing_index0 = _latest_pivots(highs, lows, 7)
    major_ready0, major_seek0, major_price0, major_index0 = _latest_pivots(highs, lows, 18)
    swing_strength0, swing_risk0, swing_retrace0, swing_extreme0, swing_extreme_bar0 = _leg_metrics(highs, lows, closes, atr, swing_ready0, swing_seek0, swing_price0, swing_index0, 1.5)
    major_strength0, major_risk0, major_retrace0, major_extreme0, major_extreme_bar0 = _leg_metrics(highs, lows, closes, atr, major_ready0, major_seek0, major_price0, major_index0, 3.0)
    swing_ready = _valid_feature_array(features, market, ("swing_ready", "swingReady"), size, swing_ready0, True)
    swing_seeking_high = _valid_feature_array(features, market, ("swing_seeking_high", "swingSeekingHigh"), size, swing_seek0, True)
    swing_strength = _optional(features, market, ("swing_strength", "swingStrength"), size, swing_strength0)
    swing_risk = _optional(features, market, ("swing_pivot_risk", "swingPivotRisk"), size, swing_risk0)
    swing_retrace = _optional(features, market, ("swing_retracement", "swingRetracement"), size, swing_retrace0)
    major_ready = _valid_feature_array(features, market, ("major_ready", "majorReady"), size, major_ready0, True)
    major_seeking_high = _valid_feature_array(features, market, ("major_seeking_high", "majorSeekingHigh"), size, major_seek0, True)
    major_strength = _optional(features, market, ("major_strength", "majorStrength"), size, major_strength0)
    major_risk = _optional(features, market, ("major_pivot_risk", "majorPivotRisk"), size, major_risk0)
    major_extreme = _optional(features, market, ("major_realtime_price", "majorRealtimePrice"), size, major_extreme0)
    swing_extreme = _optional(features, market, ("swing_realtime_price", "swingRealtimePrice"), size, swing_extreme0)

    rsi = _optional(features, market, ("rsi", "RSI"), size, _rsi(closes, 14))
    rsi_signal = _ema(rsi, 5)
    cci = _optional(features, market, ("cci", "CCI"), size, _cci(highs, lows, closes, 20))
    cci_signal = _ema(cci, 13)
    qqe_fallback = np.where(rsi >= rsi_signal, 1.0, -1.0)
    qqe_direction = _optional(features, market, ("qqe_direction", "qqeDirection"), size, qqe_fallback)
    bear_votes = (qqe_direction < 0).astype(float) + (rsi < rsi_signal).astype(float) + (cci < cci_signal).astype(float)
    bull_votes = (qqe_direction > 0).astype(float) + (rsi > rsi_signal).astype(float) + (cci > cci_signal).astype(float)
    momentum_direction0 = np.where((bear_votes >= 2) & (bear_votes > bull_votes), -1.0, np.where((bull_votes >= 2) & (bull_votes > bear_votes), 1.0, 0.0))
    momentum_direction = _optional(features, market, ("momentum_direction", "momentumDirection"), size, momentum_direction0)
    momentum_bear_ok = momentum_direction == -1
    momentum_bull_ok = momentum_direction == 1

    volume_positive = np.maximum(volumes, 0.0)
    volume_mean = _sma(volume_positive, 50)
    volume_delta = volume_positive * _clamp((closes - opens) / safe_range * 0.65 + (2.0 * closes - highs - lows) / safe_range * 0.35, -1.0, 1.0)
    delta_ema = _ema(volume_delta, 14)
    volume_ema = _ema(volume_positive, 14)
    delta_ratio = np.divide(delta_ema, volume_ema, out=np.zeros(size), where=np.isfinite(volume_ema) & (volume_ema > 0.0))
    cmf_num = _sma(volume_positive * _clamp((2.0 * closes - highs - lows) / safe_range, -1.0, 1.0), 20)
    cmf_den = _sma(volume_positive, 20)
    cmf = np.divide(cmf_num, cmf_den, out=np.zeros(size), where=np.isfinite(cmf_den) & (cmf_den > 0.0))
    signed_flow = _clamp((delta_ratio * 0.65 + cmf * 0.35) * 100.0, -100.0, 100.0)
    bear_bias = _clamp(50.0 - signed_flow * 0.50, 0.0, 100.0)
    bear_bias = _optional(features, market, ("volume_bear_bias_score", "volumeBearBiasScore"), size, bear_bias)
    volume_ready = np.isfinite(volume_mean) & (volume_mean > 0.0) & (volume_positive > 0.0)
    bear_volume_ok = (~volume_ready) | (bear_bias >= volume_limit)

    ema20 = _ema(closes, 20)
    ema50 = _ema(closes, 50)
    ema100 = _ema(closes, 100)
    basis = _sma(closes, 20)
    deviation = _sma((closes - basis) ** 2, 20) ** 0.5
    width = np.divide(2.0 * deviation, np.maximum(abs(basis), 1e-12))
    atr_mean = _sma(atr, 50)
    squeeze_on0 = np.isfinite(width) & np.isfinite(atr_mean) & (width <= 0.015) & (atr <= atr_mean * 0.70)
    squeeze_down0 = squeeze_on0 & ~np.r_[False, squeeze_on0[:-1]] & (closes < opens)
    squeeze_up0 = squeeze_on0 & ~np.r_[False, squeeze_on0[:-1]] & (closes > opens)
    squeeze_down = _valid_feature_array(features, market, ("recent_squeeze_release_down", "recentSqueezeReleaseDown"), size, squeeze_down0, True)
    squeeze_up = _valid_feature_array(features, market, ("recent_squeeze_release_up", "recentSqueezeReleaseUp"), size, squeeze_up0, True)
    squeeze_cooling_down = _valid_feature_array(features, market, ("squeeze_cooling_down", "squeezeCoolingDown"), size, (closes < opens), True)
    squeeze_cooling_up = _valid_feature_array(features, market, ("squeeze_cooling_up", "squeezeCoolingUp"), size, (closes > opens), True)

    efficiency_num = abs(closes - np.r_[np.full(20, np.nan), closes[:-20]])
    travel = np.full(size, np.nan)
    for i in range(20, size):
        travel[i] = np.sum(abs(np.diff(closes[i - 20:i + 1])))
    efficiency = np.divide(efficiency_num, travel, out=np.full(size, np.nan), where=np.isfinite(travel) & (travel > 0.0))
    trend_gap = np.divide(ema20 - ema50, np.maximum(atr, 1e-12))
    regime_direction0 = np.where(trend_gap > 0.15, 1.0, np.where(trend_gap < -0.15, -1.0, 0.0))
    regime_confidence0 = _clamp(abs(trend_gap) * 25.0 + np.nan_to_num(efficiency, nan=0.0) * 40.0, 0.0, 100.0)
    regime_ready0 = np.isfinite(regime_confidence0) & np.isfinite(ema100)
    regime_compression0 = regime_ready0 & squeeze_on0
    regime_range0 = regime_ready0 & (np.nan_to_num(efficiency, nan=0.0) < 0.20) & (abs(trend_gap) < 0.80)
    regime_trend0 = regime_ready0 & (regime_confidence0 >= regime_block) & (np.nan_to_num(efficiency, nan=0.0) >= 0.20)
    regime_exhaustion0 = regime_ready0 & (abs(trend_gap) > 2.0) & (np.nan_to_num(efficiency, nan=0.0) < 0.20)
    regime_direction = _optional(features, market, ("regime_direction", "regimeDirection"), size, regime_direction0)
    regime_confidence = _optional(features, market, ("regime_confidence", "regimeConfidence"), size, regime_confidence0)
    regime_ready = _valid_feature_array(features, market, ("regime_ready", "regimeReady"), size, regime_ready0, True)
    regime_compression = _valid_feature_array(features, market, ("regime_compression", "regimeCompression"), size, regime_compression0, True)
    regime_range = _valid_feature_array(features, market, ("regime_range", "regimeRange"), size, regime_range0, True)
    regime_trend = _valid_feature_array(features, market, ("regime_trend_candidate", "regimeTrendCandidate"), size, regime_trend0, True)
    regime_exhaustion = _valid_feature_array(features, market, ("regime_exhaustion", "regimeExhaustion"), size, regime_exhaustion0, True)
    bear_regime_ok = (~regime_ready) | ~(regime_compression | (regime_range & (regime_confidence >= regime_block)) | ((regime_direction == 1) & regime_trend & (regime_confidence >= regime_block)) | (regime_exhaustion & (regime_direction == -1)))

    htf_bull0 = np.where((ema50 > ema100) & np.isfinite(ema100), 75.0, np.where(np.isfinite(ema100), 25.0, np.nan))
    htf_bear0 = 100.0 - htf_bull0
    htf_bull = _optional(features, market, ("htf_bull_score", "htfBullScore"), size, htf_bull0)
    htf_bear = _optional(features, market, ("htf_bear_score", "htfBearScore"), size, htf_bear0)
    htf_direction0 = np.where(htf_bull > htf_bear, 1.0, np.where(htf_bear > htf_bull, -1.0, 0.0))
    htf_direction = _optional(features, market, ("htf_consensus_direction", "htfConsensusDirection"), size, htf_direction0)
    htf_both = _valid_feature_array(features, market, ("htf_both_ready", "htfBothReady"), size, np.isfinite(htf_bull) & np.isfinite(htf_bear), True)
    htf_strong = _valid_feature_array(features, market, ("htf_strong_consensus", "htfStrongConsensus"), size, htf_both & (abs(htf_bull - htf_bear) >= 30.0), True)
    htf_conflict = _valid_feature_array(features, market, ("htf_conflict", "htfConflict"), size, np.zeros(size), True)
    htf_bear_ok = (~htf_both) | ~(htf_strong & (htf_direction == 1) & (htf_bear < 35.0))

    micro_low = _rolling(lows, micro_strength + 2, "min", previous=True)
    micro_high = _rolling(highs, micro_strength + 2, "max", previous=True)
    micro_break_down = closes < micro_low
    micro_break_up = closes > micro_high
    recent_down = _bars_since(micro_break_down) <= micro_expiry
    recent_up = _bars_since(micro_break_up) <= micro_expiry
    micro_retest_down0 = recent_down & (highs >= micro_low) & (closes < micro_low) & (closes < opens)
    micro_retest_up0 = recent_up & (lows <= micro_high) & (closes > micro_high) & (closes > opens)
    micro_direction0 = np.zeros(size)
    for i in range(size):
        if micro_break_down[i]:
            micro_direction0[i] = -1.0
        elif micro_break_up[i]:
            micro_direction0[i] = 1.0
        elif i > 0:
            micro_direction0[i] = micro_direction0[i - 1]
    micro_ready = _valid_feature_array(features, market, ("micro_ready", "microReady"), size, np.arange(size) >= (micro_strength + 2) * 2, True)
    micro_direction = _optional(features, market, ("micro_direction", "microDirection"), size, micro_direction0)
    recent_down = _valid_feature_array(features, market, ("recent_micro_structure_down", "recentMicroStructureDown"), size, recent_down, True)
    recent_up = _valid_feature_array(features, market, ("recent_micro_structure_up", "recentMicroStructureUp"), size, recent_up, True)
    micro_retest_down = _valid_feature_array(features, market, ("micro_retest_bear_confirmed", "microRetestBearConfirmed", "recent_micro_retest_down", "recentMicroRetestDown"), size, micro_retest_down0, True)
    micro_retest_up = _valid_feature_array(features, market, ("micro_retest_bull_confirmed", "microRetestBullConfirmed", "recent_micro_retest_up", "recentMicroRetestUp"), size, micro_retest_up0, True)
    micro_choch_down = _valid_feature_array(features, market, ("recent_micro_choch_down", "recentMicroChochDown", "micro_choch_retest_bear_confirmed", "microChochRetestBearConfirmed"), size, micro_break_down, True)
    micro_choch_up = _valid_feature_array(features, market, ("recent_micro_choch_up", "recentMicroChochUp", "micro_choch_retest_bull_confirmed", "microChochRetestBullConfirmed"), size, micro_break_up, True)
    if micro_mode == "Đồng thuận":
        micro_bear_cont0 = (~micro_ready) | (micro_direction == -1)
        micro_bull_cont0 = (~micro_ready) | (micro_direction == 1)
    elif micro_mode == "Phá cấu trúc":
        micro_bear_cont0 = (~micro_ready) | recent_down
        micro_bull_cont0 = (~micro_ready) | recent_up
    else:
        micro_bear_cont0 = (~micro_ready) | micro_retest_down
        micro_bull_cont0 = (~micro_ready) | micro_retest_up
    micro_bear_cont = _valid_feature_array(features, market, ("micro_bear_continuation_signal", "microBearContinuationSignal"), size, micro_bear_cont0, True)
    micro_bull_cont = _valid_feature_array(features, market, ("micro_bull_continuation_signal", "microBullContinuationSignal"), size, micro_bull_cont0, True)

    support = _rolling(lows, 20, "min", previous=True)
    resistance = _rolling(highs, 20, "max", previous=True)
    volume_sum = np.cumsum(volume_positive)
    price_volume_sum = np.cumsum((highs + lows + closes) / 3.0 * volume_positive)
    vwap = np.divide(price_volume_sum, volume_sum, out=np.full(size, np.nan), where=volume_sum > 0.0)
    sell_room = np.divide(np.maximum(closes - support, 0.0), atr, out=np.full(size, np.nan), where=np.isfinite(atr) & (atr > 0.0))
    sell_room_score = np.where(~np.isfinite(sell_room), 50.0, _clamp((sell_room - location_block) / max(1.80 - location_block, 1e-12) * 100.0, 0.0, 100.0))
    sell_vwap_score = _clamp(50.0 + np.divide(vwap - closes, np.maximum(atr, 1e-12), out=np.zeros(size), where=np.isfinite(atr)) * 20.0, 0.0, 100.0)
    sell_location_score0 = _clamp(sell_room_score * 0.65 + sell_vwap_score * 0.35, 0.0, 100.0)
    sell_location_score = _optional(features, market, ("sell_location_score", "sellLocationScore"), size, sell_location_score0)
    location_ready = _valid_feature_array(features, market, ("location_ready", "locationReady"), size, np.isfinite(support) & np.isfinite(atr), True)
    bear_location_ok = (~location_ready) | ~np.isfinite(sell_room) | (sell_room >= location_block)

    bear_reversal_context0 = ((major_ready & major_seeking_high & (major_risk >= pivot_watch) & (highs >= major_extreme - np.nan_to_num(atr, nan=0.0) * 0.45)) | (swing_ready & swing_seeking_high & (swing_risk >= pivot_watch) & (highs >= swing_extreme - np.nan_to_num(atr, nan=0.0) * 0.45)))
    bear_cont_context0 = swing_ready & ~swing_seeking_high & (swing_strength >= 50.0) & (swing_risk < pivot_watch) & (swing_retrace >= min_pullback) & (swing_retrace <= max_pullback)
    bear_reversal_context = _valid_feature_array(features, market, ("bear_reversal_context", "bearReversalContext"), size, bear_reversal_context0, True)
    bear_cont_context = _valid_feature_array(features, market, ("bear_continuation_context", "bearContinuationContext"), size, bear_cont_context0, True)
    bear_reversal_evidence = bear_pattern | bear_sweep | micro_choch_down
    bear_cont_evidence = bear_pattern | micro_retest_down
    bear_score0 = _clamp(np.maximum(bear_pattern_quality, np.where(micro_retest_down, 30.0, 0.0)) + bear_sweep.astype(float) * 20.0 + bear_votes / 3.0 * 20.0 + np.where(bear_reversal_context, 25.0, np.where(bear_cont_context, 20.0, 0.0)) + np.where(major_ready & (~major_seeking_high | bear_reversal_context), 10.0, 0.0) + np.where(swing_ready & (~swing_seeking_high | bear_reversal_context), 10.0, 0.0) + np.where(sell_location_score >= 70.0, 8.0, np.where(sell_location_score < 35.0, -8.0, 0.0)) + np.where(~micro_ready, 0.0, np.where(micro_retest_down, 14.0, np.where(recent_down, 9.0, np.where(micro_direction == -1, 4.0, -10.0)))), 0.0, 100.0)
    bear_score = _optional(features, market, ("bear_entry_score", "bearEntryScore"), size, bear_score0)
    bear_reversal0 = bear_reversal_evidence & bear_reversal_context & momentum_bear_ok & bear_volume_ok & ((~regime_ready) | regime_exhaustion | ~((regime_direction == 1) & regime_trend & (regime_confidence >= regime_block))) & ((~htf_both) | htf_conflict | ~((htf_strong) & (htf_direction == 1))) & ((~location_ready) | ((np.isnan(sell_room) | (sell_room >= location_block * 0.70)) & (sell_location_score >= 30.0))) & ((~micro_ready) | micro_choch_down) & (bear_score >= candle_threshold)
    bear_reversal = _valid_feature_array(features, market, ("bear_reversal_trigger", "bearReversalTrigger"), size, bear_reversal0, True)
    bear_cont0 = bear_cont_evidence & bear_cont_context & momentum_bear_ok & bear_volume_ok & bear_regime_ok & htf_bear_ok & bear_location_ok & ((~micro_ready) | micro_bear_cont) & (bear_score >= candle_threshold) & ~bear_reversal
    bear_cont = _valid_feature_array(features, market, ("bear_continuation_trigger", "bearContinuationTrigger"), size, bear_cont0, True)
    short_entries = np.asarray(bear_cont & ~bear_reversal, dtype=np.bool_)

    bull_cont_context = swing_ready & swing_seeking_high & (swing_strength >= 50.0) & (swing_risk < pivot_watch) & (swing_retrace >= min_pullback) & (swing_retrace <= max_pullback)
    bull_reversal_context = ((major_ready & ~major_seeking_high & (major_risk >= pivot_watch)) | (swing_ready & ~swing_seeking_high & (swing_risk >= pivot_watch)))
    bull_score = _clamp(np.maximum(bull_pattern_quality, np.where(micro_retest_up, 30.0, 0.0)) + bull_sweep.astype(float) * 20.0 + bull_votes / 3.0 * 20.0 + np.where(bull_reversal_context, 25.0, np.where(bull_cont_context, 20.0, 0.0)) + np.where(sell_location_score <= 30.0, 8.0, 0.0), 0.0, 100.0)
    bull_cont0 = (bull_pattern | micro_retest_up) & bull_cont_context & momentum_bull_ok & ((~volume_ready) | (_clamp(50.0 + signed_flow * 0.50, 0.0, 100.0) >= volume_limit)) & ~regime_compression & htf_bear_ok & ((~micro_ready) | micro_bull_cont) & (bull_score >= candle_threshold)
    bull_reversal0 = (bull_pattern | bull_sweep | micro_choch_up) & bull_reversal_context & momentum_bull_ok & (bull_score >= candle_threshold)
    bull_reversal = _valid_feature_array(features, market, ("bull_reversal_trigger", "bullReversalTrigger"), size, bull_reversal0, True)
    bull_cont = _valid_feature_array(features, market, ("bull_continuation_trigger", "bullContinuationTrigger"), size, bull_cont0 & ~bull_reversal, True)
    opposite_trigger = bull_reversal | bull_cont

    micro_protected_high = _optional(features, market, ("micro_protected_high", "microProtectedHigh"), size, np.full(size, np.nan))
    resistance_bottom = _optional(features, market, ("nearest_resistance_bottom", "nearestResistanceBottom"), size, resistance)
    bear_ob_top = _optional(features, market, ("bear_ob_top", "bearObTop"), size, np.full(size, np.nan))
    bear_fvg_top = _optional(features, market, ("bear_fvg_top", "bearFvgTop"), size, np.full(size, np.nan))
    range_top = _optional(features, market, ("institutional_range_top", "institutionalRangeTop"), size, np.full(size, np.nan))
    session_high = _optional(features, market, ("active_session_high", "activeSessionHigh", "last_completed_session_high"), size, np.full(size, np.nan))
    htf_last_high = _optional(features, market, ("htf_primary_last_high", "htfPrimaryLastHigh"), size, np.full(size, np.nan))
    micro_opp = micro_ready & (micro_direction == 1)
    htf_opp = htf_both & (htf_conflict | (htf_direction == 1))
    htf_aligned = htf_both & (htf_direction == -1)
    htf_expanding = _valid_feature_array(features, market, ("htf_momentum_expanding", "managementHtfMomentumExpanding"), size, np.r_[False, abs(np.diff(np.nan_to_num(ema50 - ema100, nan=0.0))) > 0.0], True)
    htf_cooling = _valid_feature_array(features, market, ("htf_momentum_cooling", "managementHtfMomentumCooling"), size, ~htf_expanding, True)
    endpoint_high = _valid_feature_array(features, market, ("major_endpoint_exhaustion_high", "majorEndpointExhaustionHigh"), size, major_ready & (major_risk >= 74.0) & major_seeking_high, True)
    zone_close = np.isfinite(sell_room) & (sell_room < location_block)
    risk_off = htf_opp | (htf_aligned & htf_cooling) | squeeze_up | squeeze_cooling_down | endpoint_high | zone_close | micro_opp
    trend_hold = (htf_aligned & htf_expanding) | squeeze_down | (regime_ready & regime_trend & (regime_direction == -1) & ~regime_exhaustion)

    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    active = False
    entry_bar = -1
    entry_price = np.nan
    trail = np.nan
    risk_price = np.nan
    best_price = np.nan
    stage = 0
    tick = _optional(features, market, ("mintick", "min_tick", "tick_size"), size, np.maximum(abs(closes) * 1e-8, 1e-12))
    for i in range(size):
        if active and i > entry_bar:
            best_price = min(best_price, lows[i])
            mfe_r = (entry_price - best_price) / max(risk_price, 1e-12)
            expired = i - entry_bar > max_bars
            hit = highs[i] >= trail
            if hit or opposite_trigger[i] or expired:
                short_exits[i] = True
                active = False
                stage = 0
            else:
                stage = 3 if risk_off[i] or mfe_r >= tighten_r else 2 if mfe_r >= breakeven_r else 1
                multiplier = base_mult + (0.25 if trend_hold[i] else 0.0) - (0.30 if regime_ready[i] and (regime_range[i] or regime_compression[i]) else 0.0) - (0.35 if risk_off[i] else 0.0) - (0.30 if mfe_r >= tighten_r else 0.0)
                multiplier = min(max(multiplier, 1.15), 3.40)
                candidate = (highs[i] + lows[i]) * 0.5 + atr[i] * multiplier if np.isfinite(atr[i]) else trail
                structural = []
                for value in (micro_protected_high[i], resistance_bottom[i], bear_ob_top[i], bear_fvg_top[i], range_top[i], session_high[i], htf_last_high[i]):
                    if np.isfinite(value) and value > closes[i]:
                        structural.append(value + max(tick[i] * 2.0, atr[i] * 0.08 if np.isfinite(atr[i]) else 0.0))
                if structural:
                    candidate = min(candidate, min(structural))
                if mfe_r >= breakeven_r:
                    candidate = min(candidate, entry_price - risk_price * 0.03)
                if stage == 3 and mfe_r >= 1.0:
                    locked_r = min(max(mfe_r * (0.42 if risk_off[i] else 0.30), 0.30 if risk_off[i] else 0.20), 1.50 if risk_off[i] else 1.00)
                    candidate = min(candidate, entry_price - risk_price * locked_r)
                safety_gap = atr[i] * 0.08 if np.isfinite(atr[i]) else 0.0
                candidate = max(candidate, closes[i] + safety_gap)
                trail = min(trail, candidate)
        if not active and short_entries[i]:
            entry_price = closes[i]
            candidates = [highs[i]]
            for value in (micro_protected_high[i], resistance_bottom[i], bear_ob_top[i], bear_fvg_top[i], range_top[i], session_high[i], htf_last_high[i]):
                if np.isfinite(value) and value > entry_price:
                    candidates.append(value)
            structural_level = min(candidates) if candidates else np.nan
            buffer = max(tick[i] * 2.0, atr[i] * 0.08 if np.isfinite(atr[i]) else 0.0)
            fallback_risk = atr[i] * (0.85 if management_mode == "Chặt" else 1.35 if management_mode == "Rộng" else 1.05) if np.isfinite(atr[i]) else max(abs(entry_price) * 1e-4, 1e-12)
            raw_risk = structural_level + buffer - entry_price if np.isfinite(structural_level) else fallback_risk
            risk_price = min(max(raw_risk, (atr[i] if np.isfinite(atr[i]) else 0.0) * minimum_risk), (atr[i] if np.isfinite(atr[i]) else 0.0) * maximum_risk)
            risk_price = max(risk_price, max(tick[i] * 2.0, 1e-12))
            trail = entry_price + risk_price
            best_price = entry_price
            entry_bar = i
            active = True
            stage = 1
    return empty, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "zz_continuation_short",
    "hypothesis": "在 Swing ZigZag 尋找低點且回撤健康時，空方延續型態與動能、量能及多層結構一致，可能捕捉下一段下跌延續。",
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "signal_strictness",
        "trading_profile",
        "micro_trigger_mode",
        "trade_management_mode",
        "location_block_atr",
    ],
    "signal_parameter_sets": [{
        "signal_strictness": "Cân bằng",
        "trading_profile": "Cân bằng",
        "micro_trigger_mode": "Break + Retest",
        "trade_management_mode": "Cân bằng",
        "location_block_atr": 0.50,
    }],
}
