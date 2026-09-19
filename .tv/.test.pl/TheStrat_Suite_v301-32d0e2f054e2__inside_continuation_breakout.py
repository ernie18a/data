import numpy as np


def _exhaustion_high(highs, t, magnitude, lookback):
    c2 = t - 2
    if c2 < 2 or not np.isfinite(magnitude):
        return np.nan
    lower = max(1, c2 - lookback + 1)
    running_max = highs[t - 1]
    for j in range(c2, lower - 1, -1):
        value = highs[j]
        if (
            np.isfinite(value)
            and np.isfinite(running_max)
            and value > magnitude
            and value > highs[j - 1]
            and value > highs[j + 1]
            and value > running_max
        ):
            return value
        if np.isfinite(value):
            running_max = max(running_max, value)
    return np.nan


def _exhaustion_low(lows, t, magnitude, lookback):
    c2 = t - 2
    if c2 < 2 or not np.isfinite(magnitude):
        return np.nan
    lower = max(1, c2 - lookback + 1)
    running_min = lows[t - 1]
    for j in range(c2, lower - 1, -1):
        value = lows[j]
        if (
            np.isfinite(value)
            and np.isfinite(running_min)
            and value < magnitude
            and value < lows[j - 1]
            and value < lows[j + 1]
            and value < running_min
        ):
            return value
        if np.isfinite(value):
            running_min = min(running_min, value)
    return np.nan


def generate_signals(features, signal_params):
    size = int(features.market.size)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    if size < 3:
        return long_entries, long_exits, short_entries, short_exits

    c1 = slice(1, None)
    c2 = slice(0, -2)
    cc = slice(2, None)
    c1_inside_c2 = (highs[c1][:-1] <= highs[c2]) & (lows[c1][:-1] >= lows[c2])
    c2_up = closes[c2] > opens[c2]
    c2_down = closes[c2] < opens[c2]
    long_entries[2:] = (
        c1_inside_c2
        & c2_up
        & (lows[cc] >= lows[c1][:-1])
        & (closes[cc] > highs[c1][:-1])
    )
    short_entries[2:] = (
        c1_inside_c2
        & c2_down
        & (highs[cc] <= highs[c1][:-1])
        & (closes[cc] < lows[c1][:-1])
    )

    params = signal_params or {}
    stop_reference = str(params.get("stop_reference", "CC")).upper()
    if stop_reference not in ("CC", "C1"):
        raise ValueError("stop_reference must be 'CC' or 'C1'")
    break_even_at_magnitude = bool(params.get("break_even_at_magnitude", False))
    break_even_at_exhaustion = bool(params.get("break_even_at_exhaustion", False))
    exhaustion_lookback = int(params.get("exhaustion_lookback", 48))
    if exhaustion_lookback < 3:
        raise ValueError("exhaustion_lookback must be at least 3")

    position = 0
    stop = np.nan
    entry_trigger = np.nan
    magnitude = np.nan
    exhaustion = np.nan

    for t in range(size):
        if position == 1:
            magnitude_hit = np.isfinite(magnitude) and highs[t] >= magnitude
            exhaustion_hit = np.isfinite(exhaustion) and highs[t] >= exhaustion
            if break_even_at_magnitude and (magnitude_hit or (not np.isfinite(magnitude) and exhaustion_hit)):
                stop = max(stop, entry_trigger)
            if break_even_at_exhaustion and (exhaustion_hit or (not np.isfinite(exhaustion) and magnitude_hit)):
                stop = max(stop, entry_trigger)
            stop_hit = np.isfinite(stop) and lows[t] < stop
            if stop_hit or magnitude_hit or exhaustion_hit:
                long_exits[t] = True
                position = 0
        elif position == -1:
            magnitude_hit = np.isfinite(magnitude) and lows[t] <= magnitude
            exhaustion_hit = np.isfinite(exhaustion) and lows[t] <= exhaustion
            if break_even_at_magnitude and (magnitude_hit or (not np.isfinite(magnitude) and exhaustion_hit)):
                stop = min(stop, entry_trigger)
            if break_even_at_exhaustion and (exhaustion_hit or (not np.isfinite(exhaustion) and magnitude_hit)):
                stop = min(stop, entry_trigger)
            stop_hit = np.isfinite(stop) and highs[t] > stop
            if stop_hit or magnitude_hit or exhaustion_hit:
                short_exits[t] = True
                position = 0

        if position == 0:
            if long_entries[t] and not short_entries[t]:
                position = 1
                entry_trigger = highs[t - 1]
                magnitude = highs[t - 2]
                exhaustion = _exhaustion_high(highs, t, magnitude, exhaustion_lookback)
                stop = lows[t] if stop_reference == "CC" else lows[t - 1]
            elif short_entries[t] and not long_entries[t]:
                position = -1
                entry_trigger = lows[t - 1]
                magnitude = lows[t - 2]
                exhaustion = _exhaustion_low(lows, t, magnitude, exhaustion_lookback)
                stop = highs[t] if stop_reference == "CC" else highs[t - 1]

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "inside_continuation_breakout",
    "hypothesis": "C2 同向後的 C1 內包蓄勢，CC 突破 C1 範圍時延續原方向。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "stop_reference",
        "break_even_at_magnitude",
        "break_even_at_exhaustion",
        "exhaustion_lookback",
    ],
    "signal_parameter_sets": [
        {
            "stop_reference": "CC",
            "break_even_at_magnitude": False,
            "break_even_at_exhaustion": False,
            "exhaustion_lookback": 48,
        }
    ],
}
