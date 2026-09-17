import numpy as np


def _array_value(features, names, size):
    objects = (features, features.market)
    for obj in objects:
        for name in names:
            if not hasattr(obj, name):
                continue
            value = getattr(obj, name)
            if callable(value):
                value = value()
            array = np.asarray(value)
            if array.ndim == 0:
                return np.full(size, array.item())
            array = array.reshape(-1)
            if array.size == size:
                return array
    return None


def _day_keys(features, size):
    for names, is_timestamp in (
        (("session_ids", "session_id"), False),
        (("day_ids", "day_id", "trading_days"), False),
        (("timestamps", "timestamp", "times", "time", "dates", "date"), True),
    ):
        values = _array_value(features, names, size)
        if values is None:
            continue
        if not is_timestamp:
            return np.asarray([str(value) for value in values], dtype=object)
        try:
            if np.issubdtype(values.dtype, np.datetime64):
                return values.astype("datetime64[D]").astype(str)
            if np.issubdtype(values.dtype, np.number):
                finite = values[np.isfinite(values)]
                if finite.size == 0:
                    continue
                magnitude = float(np.nanmedian(np.abs(finite)))
                unit = "ns" if magnitude > 1e14 else "ms" if magnitude > 1e11 else "s"
                return values.astype("datetime64[{}]".format(unit)).astype("datetime64[D]").astype(str)
            return np.asarray([str(value)[:10] for value in values], dtype=object)
        except (TypeError, ValueError, OverflowError):
            continue
    return None


def _derived_context(opens, highs, lows, closes, volumes, keys):
    size = len(closes)
    previous_high = np.full(size, np.nan, dtype=float)
    previous_low = np.full(size, np.nan, dtype=float)
    rvwap = np.full(size, np.nan, dtype=float)
    session_open = np.full(size, np.nan, dtype=float)
    prior_high = np.nan
    prior_low = np.nan
    start = 0
    while start < size:
        end = start + 1
        while end < size and keys[end] == keys[start]:
            end += 1
        previous_high[start:end] = prior_high
        previous_low[start:end] = prior_low
        group_high = highs[start:end]
        group_low = lows[start:end]
        valid_high = group_high[np.isfinite(group_high)]
        valid_low = group_low[np.isfinite(group_low)]
        if valid_high.size:
            prior_high = float(np.max(valid_high))
        if valid_low.size:
            prior_low = float(np.min(valid_low))
        running_volume = 0.0
        running_price_volume = 0.0
        first_open = np.nan
        for index in range(start, end):
            if not np.isfinite(first_open) and np.isfinite(opens[index]):
                first_open = float(opens[index])
            volume = volumes[index]
            price = (highs[index] + lows[index] + closes[index]) / 3.0
            if np.isfinite(volume) and volume > 0.0 and np.isfinite(price):
                running_volume += float(volume)
                running_price_volume += float(price * volume)
            if running_volume > 0.0:
                rvwap[index] = running_price_volume / running_volume
            session_open[index] = first_open
        start = end
    return previous_high, previous_low, rvwap, session_open


def _context(features, opens, highs, lows, closes, volumes, size):
    keys = _day_keys(features, size)
    derived = None
    if keys is not None:
        derived = _derived_context(opens, highs, lows, closes, volumes, keys)

    def resolve(names, index):
        values = _array_value(features, names, size)
        if values is not None:
            return np.asarray(values, dtype=float)
        if derived is None:
            raise AttributeError("missing strategy context: {}".format(names[0]))
        return derived[index]

    previous_high = resolve(
        ("previous_day_high", "prior_day_high", "prev_day_high", "pdh"), 0
    )
    previous_low = resolve(
        ("previous_day_low", "prior_day_low", "prev_day_low", "pdl"), 1
    )
    rvwap = resolve(("rvwap", "rolling_vwap", "daily_vwap", "intraday_rvwap"), 2)
    session_open = resolve(
        ("session_open", "current_session_open", "session_opens"), 3
    )
    return previous_high, previous_low, rvwap, session_open, keys


def _clear_pending():
    return 0, 0.0, 0.0, -1, False


def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    try:
        opens = np.asarray(_array_value(features, ("opens", "open", "o"), size), dtype=float)
        highs = np.asarray(_array_value(features, ("highs", "high", "h"), size), dtype=float)
        lows = np.asarray(_array_value(features, ("lows", "low", "l"), size), dtype=float)
        closes = np.asarray(_array_value(features, ("closes", "close", "c"), size), dtype=float)
        volumes = np.asarray(_array_value(features, ("volumes", "volume", "v"), size), dtype=float)
        previous_high, previous_low, rvwap, session_open, keys = _context(
            features, opens, highs, lows, closes, volumes, size
        )
    except (AttributeError, TypeError, ValueError):
        return long_entries, long_exits, short_entries, short_exits

    try:
        retrace_pct = float(signal_params.get("fvg_retrace_pct", 50.0))
    except (AttributeError, TypeError, ValueError):
        retrace_pct = 50.0
    retrace_pct = min(99.0, max(1.0, retrace_pct))

    state = 0
    direction = 0
    fvg_top = np.nan
    fvg_bottom = np.nan
    fvg_bar = -1
    retracement_tagged = False
    position = 0
    entry_price = np.nan
    stop_price = np.nan
    target_price = np.nan
    previous_key = None

    for t in range(size):
        if keys is not None and previous_key is not None and keys[t] != previous_key:
            if position == 0:
                state, fvg_top, fvg_bottom, fvg_bar, retracement_tagged = _clear_pending()
        previous_key = keys[t] if keys is not None else previous_key

        if position == 1:
            stop_hit = np.isfinite(stop_price) and lows[t] <= stop_price
            target_hit = np.isfinite(target_price) and highs[t] >= target_price
            if target_hit or stop_hit:
                long_exits[t] = True
                position = 0
                state = 0
                continue
        elif position == -1:
            stop_hit = np.isfinite(stop_price) and highs[t] >= stop_price
            target_hit = np.isfinite(target_price) and lows[t] <= target_price
            if target_hit or stop_hit:
                short_exits[t] = True
                position = 0
                state = 0
                continue

        bull_sweep = np.isfinite(closes[t]) and np.isfinite(previous_low[t]) and closes[t] < previous_low[t]
        bear_sweep = np.isfinite(closes[t]) and np.isfinite(previous_high[t]) and closes[t] > previous_high[t]

        if position == 0 and state == 1:
            if not bull_sweep and not bear_sweep:
                state, fvg_top, fvg_bottom, fvg_bar, retracement_tagged = _clear_pending()
            elif t > fvg_bar:
                gap = fvg_top - fvg_bottom
                retracement_level = (
                    fvg_top - gap * retrace_pct / 100.0
                    if direction == 1
                    else fvg_bottom + gap * retrace_pct / 100.0
                )
                if not retracement_tagged:
                    retracement_tagged = (
                        lows[t] <= retracement_level
                        if direction == 1
                        else highs[t] >= retracement_level
                    )
                wick_in = (
                    fvg_bottom <= lows[t] <= fvg_top
                    if direction == 1
                    else fvg_bottom <= highs[t] <= fvg_top
                )
                open_in = fvg_bottom <= opens[t] <= fvg_top
                if retracement_tagged and (wick_in or open_in):
                    entry_price = fvg_top if direction == 1 else fvg_bottom
                    if direction == 1:
                        if np.isfinite(rvwap[t]) and rvwap[t] > entry_price:
                            target_price = rvwap[t]
                        elif (
                            np.isfinite(session_open[t])
                            and session_open[t] > entry_price
                            and session_open[t] < previous_low[t]
                        ):
                            target_price = session_open[t]
                        else:
                            target_price = previous_low[t]
                        stop_price = fvg_bottom
                        long_entries[t] = True
                        position = 1
                    else:
                        if np.isfinite(rvwap[t]) and rvwap[t] < entry_price:
                            target_price = rvwap[t]
                        elif (
                            np.isfinite(session_open[t])
                            and session_open[t] < entry_price
                            and session_open[t] > previous_high[t]
                        ):
                            target_price = session_open[t]
                        else:
                            target_price = previous_high[t]
                        stop_price = fvg_top
                        short_entries[t] = True
                        position = -1
                    state = 2
                    if not np.isfinite(target_price) or (
                        direction == 1 and target_price <= entry_price
                    ) or (direction == -1 and target_price >= entry_price):
                        if position == 1:
                            long_entries[t] = False
                        else:
                            short_entries[t] = False
                        position = 0
                        state = 0

        if position == 0 and state == 0 and t >= 2:
            if bull_sweep and np.isfinite(lows[t]) and np.isfinite(highs[t - 2]) and lows[t] > highs[t - 2]:
                direction = 1
                fvg_top = lows[t]
                fvg_bottom = highs[t - 2]
                fvg_bar = t
                retracement_tagged = False
                state = 1
            elif bear_sweep and np.isfinite(highs[t]) and np.isfinite(lows[t - 2]) and highs[t] < lows[t - 2]:
                direction = -1
                fvg_top = lows[t - 2]
                fvg_bottom = highs[t]
                fvg_bar = t
                retracement_tagged = False
                state = 1

        if position == 1:
            if lows[t] <= stop_price or highs[t] >= target_price:
                long_exits[t] = True
                position = 0
                state = 0
        elif position == -1:
            if highs[t] >= stop_price or lows[t] <= target_price:
                short_exits[t] = True
                position = 0
                state = 0

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "pdh_pdl_fvg_retest_boundary",
    "hypothesis": "前日流動性掃過後的三 K FVG 回撤可形成反轉進場，FVG 邊界控制風險並以日內流動性優先出場。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["fvg_retrace_pct"],
    "signal_parameter_sets": [{"fvg_retrace_pct": 50.0}],
}
