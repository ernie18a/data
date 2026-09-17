import numpy as np


def _read_series(features, names, size):
    for owner in (features, getattr(features, "market", None)):
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
            try:
                array = np.asarray(value, dtype=float)
            except (TypeError, ValueError):
                continue
            if array.ndim == 1 and array.size == size:
                return array
    return np.full(size, np.nan, dtype=float)


def _rolling_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        part = values[index - window + 1:index + 1]
        if np.all(np.isfinite(part)):
            result[index] = np.mean(part)
    return result


def _atr(features, highs, lows, closes, window):
    method = getattr(features, "atr", None)
    if callable(method):
        try:
            result = np.asarray(method(window), dtype=float)
            if result.ndim == 1 and result.size == closes.size:
                return result
        except (AttributeError, TypeError, ValueError):
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


def _ema(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    if values.size < window:
        return result
    seed = values[:window]
    if not np.all(np.isfinite(seed)):
        return result
    result[window - 1] = np.mean(seed)
    alpha = 2.0 / (window + 1.0)
    for index in range(window, values.size):
        if np.isfinite(values[index]) and np.isfinite(result[index - 1]):
            result[index] = alpha * values[index] + (1.0 - alpha) * result[index - 1]
    return result


def _confirmed_pivots(highs, lows, lookback):
    size = highs.size
    pivot_high = np.full(size, np.nan, dtype=float)
    pivot_low = np.full(size, np.nan, dtype=float)
    for confirmation in range(lookback * 2, size):
        pivot = confirmation - lookback
        high_part = highs[pivot - lookback:pivot + lookback + 1]
        low_part = lows[pivot - lookback:pivot + lookback + 1]
        if np.all(np.isfinite(high_part)) and highs[pivot] >= np.max(high_part):
            pivot_high[confirmation] = highs[pivot]
        if np.all(np.isfinite(low_part)) and lows[pivot] <= np.min(low_part):
            pivot_low[confirmation] = lows[pivot]
    return pivot_high, pivot_low


def _htf_fvg_events(highs, lows, period):
    size = highs.size
    bull_event = np.zeros(size, dtype=np.bool_)
    bear_event = np.zeros(size, dtype=np.bool_)
    bull_top = np.full(size, np.nan, dtype=float)
    bull_bottom = np.full(size, np.nan, dtype=float)
    bear_top = np.full(size, np.nan, dtype=float)
    bear_bottom = np.full(size, np.nan, dtype=float)
    previous_bull = False
    previous_bear = False
    group_count = size // period
    group_high = np.full(group_count, np.nan, dtype=float)
    group_low = np.full(group_count, np.nan, dtype=float)
    for group in range(group_count):
        start = group * period
        end = min(size, start + period)
        if end > start and np.all(np.isfinite(highs[start:end])) and np.all(np.isfinite(lows[start:end])):
            group_high[group] = np.max(highs[start:end])
            group_low[group] = np.min(lows[start:end])
    for group in range(3, group_count):
        boundary = min(size, (group + 1) * period) - 1
        if boundary < 0 or boundary >= size:
            continue
        bull_raw = np.isfinite(group_low[group - 3]) and np.isfinite(group_high[group - 1]) and group_low[group - 3] > group_high[group - 1]
        bear_raw = np.isfinite(group_high[group - 3]) and np.isfinite(group_low[group - 1]) and group_high[group - 3] < group_low[group - 1]
        if bull_raw and not previous_bull:
            bull_event[boundary] = True
            bull_top[boundary] = group_low[group - 3]
            bull_bottom[boundary] = group_high[group - 1]
        if bear_raw and not previous_bear:
            bear_event[boundary] = True
            bear_top[boundary] = group_low[group - 1]
            bear_bottom[boundary] = group_high[group - 3]
        previous_bull = bool(bull_raw)
        previous_bear = bool(bear_raw)
    return bull_event, bull_top, bull_bottom, bear_event, bear_top, bear_bottom


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return empty, empty.copy(), empty.copy(), empty.copy()

    params = signal_params or {}
    liq_lookback = max(3, int(params.get("liq_lookback", 20)))
    htf_period = max(1, int(params.get("htf_period", 15)))
    sweep_to_htf_max = max(1, int(params.get("sweep_to_htf_max", 50)))
    htf_to_ifvg_max = max(1, int(params.get("htf_to_ifvg_max", 80)))
    ifvg_to_cisd_max = max(1, int(params.get("ifvg_to_cisd_max", 20)))
    min_rr = float(params.get("min_rr", 1.5))
    max_sl_atr = float(params.get("max_sl_atr", 2.0))
    sl_atr_len = max(1, int(params.get("sl_atr_len", 14)))
    trend_ema_len = max(1, int(params.get("trend_ema_len", 50)))
    trend_period = max(1, int(params.get("trend_period", htf_period)))
    tp1_pct = float(params.get("tp1_pct", 30.0)) / 100.0
    tp2_pct = float(params.get("tp2_pct", 50.0)) / 100.0
    tp1_pct = min(0.99, max(0.01, tp1_pct))
    tp2_pct = min(0.99, max(tp1_pct, tp2_pct))

    opens = _read_series(features, ("opens", "open"), size)
    highs = _read_series(features, ("highs", "high"), size)
    lows = _read_series(features, ("lows", "low"), size)
    closes = _read_series(features, ("closes", "close"), size)
    volumes = _read_series(features, ("volumes", "volume"), size)
    if any(array.ndim != 1 or array.size != size for array in (opens, highs, lows, closes, volumes)):
        raise ValueError("market OHLCV 必須是與 market.size 等長的一維陣列")
    atr = _atr(features, highs, lows, closes, sl_atr_len)

    pivot_high, pivot_low = _confirmed_pivots(highs, lows, liq_lookback)
    swing_high = np.full(size, np.nan, dtype=float)
    swing_low = np.full(size, np.nan, dtype=float)
    current_high = np.nan
    current_low = np.nan
    for index in range(size):
        if np.isfinite(pivot_high[index]):
            current_high = pivot_high[index]
        if np.isfinite(pivot_low[index]):
            current_low = pivot_low[index]
        swing_high[index] = current_high
        swing_low[index] = current_low

    bull_sweep = np.isfinite(swing_low) & (lows < swing_low) & (closes > swing_low)
    bear_sweep = np.isfinite(swing_high) & (highs > swing_high) & (closes < swing_high)
    bull_sweep_wick = np.where(bull_sweep, lows, np.nan)
    bear_sweep_wick = np.where(bear_sweep, highs, np.nan)
    bull_sweep_tp = np.where(bull_sweep, swing_high, np.nan)
    bear_sweep_tp = np.where(bear_sweep, swing_low, np.nan)

    htf = _htf_fvg_events(highs, lows, htf_period)
    bull_htf_event, bull_htf_top, bull_htf_bottom, bear_htf_event, bear_htf_top, bear_htf_bottom = htf
    long_candidates = np.zeros(size, dtype=np.bool_)
    short_candidates = np.zeros(size, dtype=np.bool_)
    candidate_sl = np.full(size, np.nan, dtype=float)
    candidate_tp = np.full(size, np.nan, dtype=float)

    bull_zones = []
    bear_zones = []
    ltf_bull_zones = []
    ltf_bear_zones = []
    last_bull_sweep = None
    last_bear_sweep = None
    last_bull_delivery = None
    last_bear_delivery = None
    long_chain = None
    short_chain = None
    last_bull_ifvg = None
    last_bear_ifvg = None
    bull_delivery_sweep = None
    bear_delivery_sweep = None
    trend_group_count = size // trend_period
    trend_group_closes = np.full(trend_group_count, np.nan, dtype=float)
    for group in range(trend_group_count):
        start = group * trend_period
        end = start + trend_period
        if np.all(np.isfinite(closes[start:end])):
            trend_group_closes[group] = closes[end - 1]
    for index in range(size):
        if bull_sweep[index]:
            last_bull_sweep = index
        if bear_sweep[index]:
            last_bear_sweep = index

        if long_chain is not None and index - long_chain[2] > ifvg_to_cisd_max:
            long_chain = None
        if short_chain is not None and index - short_chain[2] > ifvg_to_cisd_max:
            short_chain = None

        if bull_htf_event[index]:
            bull_zones.append([bull_htf_top[index], bull_htf_bottom[index], False])
            if len(bull_zones) > 5:
                bull_zones.pop(0)
        if bear_htf_event[index]:
            bear_zones.append([bear_htf_top[index], bear_htf_bottom[index], False])
            if len(bear_zones) > 5:
                bear_zones.pop(0)

        remaining = []
        for top, bottom, delivered in bull_zones:
            if closes[index] < bottom:
                continue
            if not delivered and lows[index] <= top and closes[index] >= bottom:
                delivered = True
                last_bull_delivery = index
                bull_delivery_sweep = last_bull_sweep
            remaining.append([top, bottom, delivered])
        bull_zones = remaining
        remaining = []
        for top, bottom, delivered in bear_zones:
            if closes[index] > top:
                continue
            if not delivered and highs[index] >= bottom and closes[index] <= top:
                delivered = True
                last_bear_delivery = index
                bear_delivery_sweep = last_bear_sweep
            remaining.append([top, bottom, delivered])
        bear_zones = remaining

        if index >= 2 and lows[index] > highs[index - 2]:
            ltf_bull_zones.append([lows[index], highs[index - 2]])
            if len(ltf_bull_zones) > 10:
                ltf_bull_zones.pop(0)
        if index >= 2 and highs[index] < lows[index - 2]:
            ltf_bear_zones.append([lows[index - 2], highs[index]])
            if len(ltf_bear_zones) > 10:
                ltf_bear_zones.pop(0)

        new_bear_ifvg = False
        remaining = []
        for top, bottom in ltf_bull_zones:
            if closes[index] < bottom:
                if last_bear_sweep is not None and index - last_bear_sweep <= sweep_to_htf_max + htf_to_ifvg_max:
                    new_bear_ifvg = True
                    last_bear_ifvg = index
                continue
            remaining.append([top, bottom])
        ltf_bull_zones = remaining

        new_bull_ifvg = False
        remaining = []
        for top, bottom in ltf_bear_zones:
            if closes[index] > top:
                if last_bull_sweep is not None and index - last_bull_sweep <= sweep_to_htf_max + htf_to_ifvg_max:
                    new_bull_ifvg = True
                    last_bull_ifvg = index
                continue
            remaining.append([top, bottom])
        ltf_bear_zones = remaining

        if new_bear_ifvg:
            first_open = np.nan
            for distance in range(1, 11):
                previous = index - distance
                if previous < 0 or not (closes[previous] > opens[previous]):
                    break
                first_open = opens[previous]
            if np.isfinite(first_open):
                short_chain = (bear_delivery_sweep, last_bear_delivery, index, first_open)

        if new_bull_ifvg:
            first_open = np.nan
            for distance in range(1, 11):
                previous = index - distance
                if previous < 0 or not (closes[previous] < opens[previous]):
                    break
                first_open = opens[previous]
            if np.isfinite(first_open):
                long_chain = (bull_delivery_sweep, last_bull_delivery, index, first_open)

        completed_group = index // trend_period - 1
        finite_trend = trend_group_closes[:completed_group + 1]
        finite_trend = finite_trend[np.isfinite(finite_trend)]
        trend_value = np.nan
        if finite_trend.size >= trend_ema_len:
            compact = np.full(finite_trend.size, np.nan, dtype=float)
            compact[:] = finite_trend
            trend_value = _ema(compact, trend_ema_len)[-1]
        trend_long_ok = np.isfinite(trend_value) and closes[index] > trend_value
        trend_short_ok = np.isfinite(trend_value) and closes[index] < trend_value

        if long_chain is not None and closes[index] > long_chain[3]:
            sweep_index, delivery_index, ifvg_index, _ = long_chain
            sequence_ok = (
                sweep_index is not None
                and delivery_index is not None
                and index - sweep_index >= 0
                and delivery_index - sweep_index <= sweep_to_htf_max
                and ifvg_index - delivery_index >= 0
                and ifvg_index - delivery_index <= htf_to_ifvg_max
                and index - ifvg_index >= 0
                and index - ifvg_index <= ifvg_to_cisd_max
            )
            if sequence_ok and bull_zones and trend_long_ok:
                entry = closes[index]
                stop = bull_sweep_wick[sweep_index]
                target = bull_sweep_tp[sweep_index]
                risk = entry - stop if np.isfinite(stop) else np.nan
                if np.isfinite(risk) and risk > 0.0:
                    if not np.isfinite(target) or target <= entry:
                        target = entry + 3.0 * risk
                    reward = target - entry
                    rr = reward / risk if reward > 0.0 else np.nan
                    if np.isfinite(atr[index]) and rr >= min_rr and (max_sl_atr == 0.0 or risk <= atr[index] * max_sl_atr):
                        long_candidates[index] = True
                        candidate_sl[index] = stop
                        candidate_tp[index] = target
            long_chain = None

        if short_chain is not None and closes[index] < short_chain[3]:
            sweep_index, delivery_index, ifvg_index, _ = short_chain
            sequence_ok = (
                sweep_index is not None
                and delivery_index is not None
                and delivery_index - sweep_index >= 0
                and delivery_index - sweep_index <= sweep_to_htf_max
                and ifvg_index - delivery_index >= 0
                and ifvg_index - delivery_index <= htf_to_ifvg_max
                and index - ifvg_index >= 0
                and index - ifvg_index <= ifvg_to_cisd_max
            )
            if sequence_ok and bear_zones and trend_short_ok:
                entry = closes[index]
                stop = bear_sweep_wick[sweep_index]
                target = bear_sweep_tp[sweep_index]
                risk = stop - entry if np.isfinite(stop) else np.nan
                if np.isfinite(risk) and risk > 0.0:
                    if not np.isfinite(target) or target >= entry:
                        target = entry - 3.0 * risk
                    reward = entry - target
                    rr = reward / risk if reward > 0.0 else np.nan
                    if np.isfinite(atr[index]) and rr >= min_rr and (max_sl_atr == 0.0 or risk <= atr[index] * max_sl_atr):
                        short_candidates[index] = True
                        candidate_sl[index] = stop
                        candidate_tp[index] = target
            short_chain = None

    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    position = 0
    entry_bar = -1
    entry_price = np.nan
    initial_stop = np.nan
    target = np.nan
    tp1 = np.nan
    tp2 = np.nan
    tp1_done = False
    tp2_done = False
    tp1_bar = -1
    for index in range(size):
        if position == 1 and index > entry_bar:
            active_stop = entry_price if tp1_done and index > tp1_bar else initial_stop
            stop_hit = np.isfinite(active_stop) and lows[index] < active_stop
            tp1_hit = np.isfinite(tp1) and highs[index] >= tp1
            tp2_hit = np.isfinite(tp2) and highs[index] >= tp2
            tp3_hit = np.isfinite(target) and highs[index] >= target
            if stop_hit:
                long_exits[index] = True
                position = 0
            elif tp3_hit:
                long_exits[index] = True
                position = 0
            else:
                if tp1_hit and not tp1_done:
                    tp1_done = True
                    tp1_bar = index
                if tp2_hit:
                    tp2_done = True
        elif position == -1 and index > entry_bar:
            active_stop = entry_price if tp1_done and index > tp1_bar else initial_stop
            stop_hit = np.isfinite(active_stop) and highs[index] > active_stop
            tp1_hit = np.isfinite(tp1) and lows[index] <= tp1
            tp2_hit = np.isfinite(tp2) and lows[index] <= tp2
            tp3_hit = np.isfinite(target) and lows[index] <= target
            if stop_hit:
                short_exits[index] = True
                position = 0
            elif tp3_hit:
                short_exits[index] = True
                position = 0
            else:
                if tp1_hit and not tp1_done:
                    tp1_done = True
                    tp1_bar = index
                if tp2_hit:
                    tp2_done = True

        if position != 0:
            continue
        if long_candidates[index] and not short_candidates[index]:
            long_entries[index] = True
            position = 1
            entry_bar = index
            entry_price = closes[index]
            initial_stop = candidate_sl[index]
            target = candidate_tp[index]
            distance = target - entry_price
            tp1 = entry_price + distance * tp1_pct
            tp2 = entry_price + distance * tp2_pct
            tp1_done = False
            tp2_done = False
            tp1_bar = -1
        elif short_candidates[index] and not long_candidates[index]:
            short_entries[index] = True
            position = -1
            entry_bar = index
            entry_price = closes[index]
            initial_stop = candidate_sl[index]
            target = candidate_tp[index]
            distance = entry_price - target
            tp1 = entry_price - distance * tp1_pct
            tp2 = entry_price - distance * tp2_pct
            tp1_done = False
            tp2_done = False
            tp1_bar = -1

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "sm4c_sweep_htf_ifvg_cisd",
    "hypothesis": "流動性掃掠後依序完成 HTF FVG delivery、反向 iFVG 與 CISD，可在趨勢一致且風險報酬足夠時捕捉結構反轉。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "liq_lookback", "htf_period", "sweep_to_htf_max", "htf_to_ifvg_max",
        "ifvg_to_cisd_max", "min_rr", "max_sl_atr", "sl_atr_len",
        "trend_ema_len", "trend_period", "tp1_pct", "tp2_pct",
    ],
    "signal_parameter_sets": [{
        "liq_lookback": 20,
        "htf_period": 15,
        "sweep_to_htf_max": 50,
        "htf_to_ifvg_max": 80,
        "ifvg_to_cisd_max": 20,
        "min_rr": 1.5,
        "max_sl_atr": 2.0,
        "sl_atr_len": 14,
        "trend_ema_len": 50,
        "trend_period": 15,
        "tp1_pct": 30.0,
        "tp2_pct": 50.0,
    }],
}
