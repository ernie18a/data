import numpy as np


def _series(value, size, name):
    array = np.asarray(value, dtype=float)
    if array.ndim != 1 or array.size != size:
        raise ValueError(f"{name} must be a one-dimensional array of market.size")
    return array


def _exhaustion_high(highs, index, magnitude):
    if index < 3 or not np.isfinite(magnitude) or not np.isfinite(highs[index - 1]):
        return np.nan
    running_max = max(float(highs[index - 1]), float(magnitude))
    first = index - 2
    last = max(-1, index - 49)
    for pivot in range(first, last, -1):
        if pivot - 1 < 0:
            break
        value = highs[pivot]
        newer = highs[pivot + 1]
        older = highs[pivot - 1]
        if (
            np.isfinite(value)
            and np.isfinite(newer)
            and np.isfinite(older)
            and value > newer
            and value > older
            and value > running_max
        ):
            return float(value)
        if np.isfinite(value):
            running_max = max(running_max, float(value))
    return np.nan


def _exhaustion_low(lows, index, magnitude):
    if index < 3 or not np.isfinite(magnitude) or not np.isfinite(lows[index - 1]):
        return np.nan
    running_min = min(float(lows[index - 1]), float(magnitude))
    first = index - 2
    last = max(-1, index - 49)
    for pivot in range(first, last, -1):
        if pivot - 1 < 0:
            break
        value = lows[pivot]
        newer = lows[pivot + 1]
        older = lows[pivot - 1]
        if (
            np.isfinite(value)
            and np.isfinite(newer)
            and np.isfinite(older)
            and value < newer
            and value < older
            and value < running_min
        ):
            return float(value)
        if np.isfinite(value):
            running_min = min(running_min, float(value))
    return np.nan


def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return long_entries, long_exits, short_entries, short_exits

    market = features.market
    highs = _series(market.highs, size, "highs")
    lows = _series(market.lows, size, "lows")
    closes = _series(market.closes, size, "closes")
    if size >= 3:
        c1_high = highs[1:-1]
        c1_low = lows[1:-1]
        c2_high = highs[:-2]
        c2_low = lows[:-2]
        cc_high = highs[2:]
        cc_low = lows[2:]
        cc_close = closes[2:]
        finite = (
            np.isfinite(c1_high)
            & np.isfinite(c1_low)
            & np.isfinite(c2_high)
            & np.isfinite(c2_low)
            & np.isfinite(cc_high)
            & np.isfinite(cc_low)
            & np.isfinite(cc_close)
        )
        long_entries[2:] = finite & (
            (c1_low < c2_low)
            & (c1_high <= c2_high)
            & (cc_high > c1_high)
            & (cc_low >= c1_low)
            & (cc_close > c1_high)
        )
        short_entries[2:] = finite & (
            (c1_high > c2_high)
            & (c1_low >= c2_low)
            & (cc_low < c1_low)
            & (cc_high <= c1_high)
            & (cc_close < c1_low)
        )

    stop_reference = str(signal_params.get("stop_reference", "CC")).strip().upper()
    if stop_reference not in {"CC", "C1"}:
        raise ValueError("stop_reference must be 'CC' or 'C1'")

    position = 0
    stop = np.nan
    target = np.nan
    exhaustion = np.nan
    for index in range(size):
        if position == 1:
            if np.isfinite(lows[index]) and lows[index] < stop:
                long_exits[index] = True
                position = 0
            elif (
                np.isfinite(highs[index])
                and np.isfinite(target)
                and highs[index] >= target
            ) or (
                np.isfinite(highs[index])
                and np.isfinite(exhaustion)
                and highs[index] >= exhaustion
            ):
                long_exits[index] = True
                position = 0
        elif position == -1:
            if np.isfinite(highs[index]) and highs[index] > stop:
                short_exits[index] = True
                position = 0
            elif (
                np.isfinite(lows[index])
                and np.isfinite(target)
                and lows[index] <= target
            ) or (
                np.isfinite(lows[index])
                and np.isfinite(exhaustion)
                and lows[index] <= exhaustion
            ):
                short_exits[index] = True
                position = 0

        if position == 0:
            if long_entries[index] and not short_entries[index]:
                c1 = index - 1
                c2 = index - 2
                stop = lows[c1] if stop_reference == "C1" else lows[index]
                target = highs[c2]
                exhaustion = _exhaustion_high(highs, index, target)
                if np.isfinite(stop) and np.isfinite(target):
                    position = 1
                else:
                    stop = target = exhaustion = np.nan
            elif short_entries[index] and not long_entries[index]:
                c1 = index - 1
                c2 = index - 2
                stop = highs[c1] if stop_reference == "C1" else highs[index]
                target = lows[c2]
                exhaustion = _exhaustion_low(lows, index, target)
                if np.isfinite(stop) and np.isfinite(target):
                    position = -1
                else:
                    stop = target = exhaustion = np.nan

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "two_two_reversal",
    "hypothesis": "2d 後的 2u 反轉突破 C1 高點可向上回補至 C2 高點；反向條件同理。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["stop_reference"],
    "signal_parameter_sets": [
        {"stop_reference": "CC"},
        {"stop_reference": "C1"},
    ],
}
