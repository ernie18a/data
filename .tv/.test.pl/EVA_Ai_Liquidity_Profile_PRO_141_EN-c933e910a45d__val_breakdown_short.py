import numpy as np


def _series(source, names, size):
    for name in names:
        try:
            value = getattr(source, name)
        except AttributeError:
            continue
        try:
            array = np.asarray(value, dtype=float).reshape(-1)
        except (TypeError, ValueError):
            continue
        if array.size == size:
            return array
    return None


def _confirmed_series(features, market, size):
    for source in (features, market):
        for name in ("confirmed", "is_confirmed", "bar_confirmed", "closed"):
            try:
                value = getattr(source, name)
            except AttributeError:
                continue
            try:
                array = np.asarray(value, dtype=np.bool_).reshape(-1)
            except (TypeError, ValueError):
                continue
            if array.size == size:
                return array
    return np.ones(size, dtype=np.bool_)


def _profile_levels(features, signal_params, size):
    market = features.market
    poc = _series(features, ("currentPoc", "current_poc", "poc", "pocs"), size)
    vah = _series(features, ("currentVah", "current_vah", "vah", "value_area_high"), size)
    val = _series(features, ("currentVal", "current_val", "val", "value_area_low"), size)
    if poc is None:
        poc = _series(market, ("currentPoc", "current_poc", "poc", "pocs"), size)
    if vah is None:
        vah = _series(market, ("currentVah", "current_vah", "vah", "value_area_high"), size)
    if val is None:
        val = _series(market, ("currentVal", "current_val", "val", "value_area_low"), size)
    if poc is not None and vah is not None and val is not None:
        return poc, vah, val

    opens = _series(market, ("opens", "open"), size)
    highs = _series(market, ("highs", "high"), size)
    lows = _series(market, ("lows", "low"), size)
    closes = _series(market, ("closes", "close"), size)
    volumes = _series(market, ("volumes", "volume"), size)
    if any(item is None for item in (opens, highs, lows, closes, volumes)):
        return (
            np.full(size, np.nan, dtype=float),
            np.full(size, np.nan, dtype=float),
            np.full(size, np.nan, dtype=float),
        )

    window = max(1, int(signal_params.get("profile_window", 300)))
    rows = max(1, int(signal_params.get("profile_rows", 48)))
    value_area_pct = float(signal_params.get("value_area_pct", 70.0))
    value_area_pct = min(95.0, max(50.0, value_area_pct))
    calculated_poc = np.full(size, np.nan, dtype=float)
    calculated_vah = np.full(size, np.nan, dtype=float)
    calculated_val = np.full(size, np.nan, dtype=float)

    for t in range(size):
        start = max(0, t - window + 1)
        valid = (
            np.isfinite(opens[start:t + 1])
            & np.isfinite(highs[start:t + 1])
            & np.isfinite(lows[start:t + 1])
            & np.isfinite(closes[start:t + 1])
            & np.isfinite(volumes[start:t + 1])
            & (volumes[start:t + 1] > 0.0)
        )
        if not np.any(valid):
            continue
        sample_open = opens[start:t + 1][valid]
        sample_high = highs[start:t + 1][valid]
        sample_low = lows[start:t + 1][valid]
        sample_close = closes[start:t + 1][valid]
        sample_volume = volumes[start:t + 1][valid]
        raw_low = float(np.min(np.minimum(sample_low, sample_high)))
        raw_high = float(np.max(np.maximum(sample_low, sample_high)))
        raw_range = raw_high - raw_low

        if raw_range <= 0.0:
            row_volumes = np.array([float(np.sum(sample_volume))], dtype=float)
            profile_low = raw_low - 0.5
            row_step = 1.0
        else:
            row_count = rows
            row_step = raw_range / row_count
            profile_low = raw_low
            row_volumes = np.zeros(row_count, dtype=float)
            for candle_low, candle_high, candle_close, volume in zip(
                np.minimum(sample_low, sample_high),
                np.maximum(sample_low, sample_high),
                sample_close,
                sample_volume,
            ):
                candle_range = candle_high - candle_low
                if candle_range <= 0.0:
                    row = int(np.floor((candle_close - profile_low) / row_step))
                    row = min(row_count - 1, max(0, row))
                    row_volumes[row] += volume
                    continue
                first = min(row_count - 1, max(0, int(np.floor((candle_low - profile_low) / row_step))))
                last = min(row_count - 1, max(0, int(np.floor((candle_high - profile_low) / row_step))))
                if first == last:
                    overlap = max(0.0, min(candle_high, profile_low + (first + 1) * row_step) - max(candle_low, profile_low + first * row_step))
                    row_volumes[first] += volume * overlap / candle_range
                    continue
                first_overlap = max(0.0, min(candle_high, profile_low + (first + 1) * row_step) - max(candle_low, profile_low + first * row_step))
                last_overlap = max(0.0, min(candle_high, profile_low + (last + 1) * row_step) - max(candle_low, profile_low + last * row_step))
                row_volumes[first] += volume * first_overlap / candle_range
                row_volumes[last] += volume * last_overlap / candle_range
                if last > first + 1:
                    row_volumes[first + 1:last] += volume * row_step / candle_range

        total_volume = float(np.sum(row_volumes))
        if total_volume <= 0.0:
            continue
        max_volume = float(np.max(row_volumes))
        midpoint = (row_volumes.size - 1) * 0.5
        poc_index = min(
            range(row_volumes.size),
            key=lambda index: (
                -row_volumes[index],
                abs(index - midpoint),
                index,
            ),
        )
        target = total_volume * value_area_pct * 0.01
        low_index = high_index = poc_index
        accumulated = float(row_volumes[poc_index])
        while accumulated < target and (low_index > 0 or high_index < row_volumes.size - 1):
            has_lower = low_index > 0
            has_upper = high_index < row_volumes.size - 1
            lower_volume = row_volumes[low_index - 1] if has_lower else -1.0
            upper_volume = row_volumes[high_index + 1] if has_upper else -1.0
            if not has_lower:
                choose_upper = True
            elif not has_upper:
                choose_upper = False
            elif upper_volume > lower_volume:
                choose_upper = True
            elif lower_volume > upper_volume:
                choose_upper = False
            else:
                choose_upper = (high_index + 1 - poc_index) <= (poc_index - (low_index - 1))
            chosen = max(0.0, upper_volume if choose_upper else lower_volume)
            if accumulated + chosen > target + max(1e-10, total_volume * 1e-10):
                break
            if choose_upper:
                high_index += 1
            else:
                low_index -= 1
            accumulated += chosen

        calculated_poc[t] = profile_low + (poc_index + 0.5) * row_step
        calculated_vah[t] = profile_low + (high_index + 1.0) * row_step
        calculated_val[t] = profile_low + low_index * row_step

    return calculated_poc, calculated_vah, calculated_val


def generate_signals(features, signal_params):
    size = features.market.size
    market = features.market
    closes = _series(market, ("closes", "close"), size)
    if closes is None:
        false = np.zeros(size, dtype=np.bool_)
        return false, false.copy(), false.copy(), false.copy()

    poc, vah, val = _profile_levels(features, signal_params, size)
    confirmed = _confirmed_series(features, market, size)
    valid = np.isfinite(poc) & np.isfinite(vah) & np.isfinite(val)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    if size > 1:
        previous_valid = valid[:-1]
        current_valid = valid[1:]
        short_entries[1:] = (
            confirmed[1:]
            & previous_valid
            & current_valid
            & np.isfinite(closes[:-1])
            & np.isfinite(closes[1:])
            & (closes[:-1] >= val[:-1])
            & (closes[1:] < val[1:])
        )
        short_exits[1:] = (
            confirmed[1:]
            & previous_valid
            & current_valid
            & np.isfinite(closes[:-1])
            & np.isfinite(closes[1:])
            & (closes[1:] <= vah[1:])
            & (closes[1:] >= val[1:])
            & (closes[:-1] < val[:-1])
        )
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "val_breakdown_short",
    "hypothesis": "Short when a confirmed close crosses below VAL; exit when price returns into the Value Area.",
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["profile_window", "profile_rows", "value_area_pct"],
    "signal_parameter_sets": [
        {"profile_window": 300, "profile_rows": 48, "value_area_pct": 70.0},
    ],
}
