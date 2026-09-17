import numpy as np


def _exhaustion_pivot(values, index, lookback, high_side):
    """Return the nearest intact prior pivot beyond all newer values."""
    if index < 3:
        return None

    start = max(2, 1)
    end = min(int(lookback), index - 1)
    if end < start:
        return None

    if high_side:
        running = float(values[index - 1])
        for offset in range(start, end + 1):
            pivot_index = index - offset
            value = float(values[pivot_index])
            if (
                value > float(values[pivot_index - 1])
                and value > float(values[pivot_index + 1])
                and running < value
            ):
                return value
            running = max(running, value)
    else:
        running = float(values[index - 1])
        for offset in range(start, end + 1):
            pivot_index = index - offset
            value = float(values[pivot_index])
            if (
                value < float(values[pivot_index - 1])
                and value < float(values[pivot_index + 1])
                and running > value
            ):
                return value
            running = min(running, value)

    return None


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    highs = np.asarray(market.highs)
    lows = np.asarray(market.lows)
    closes = np.asarray(market.closes)

    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    stop_reference = str(signal_params.get("stop_reference", "CC")).upper()
    if stop_reference not in ("CC", "C1"):
        stop_reference = "CC"
    break_even_at_exhaustion = bool(
        signal_params.get("break_even_at_exhaustion", False)
    )
    exhaustion_lookback = max(
        2, int(signal_params.get("exhaustion_lookback", 48))
    )

    for t in range(2, size):
        c1_is_three = (
            highs[t - 1] > highs[t - 2] and lows[t - 1] < lows[t - 2]
        )
        cc_is_2u = (
            highs[t] > highs[t - 1]
            and lows[t] >= lows[t - 1]
            and closes[t] > highs[t - 1]
        )
        cc_is_2d = (
            lows[t] < lows[t - 1]
            and highs[t] <= highs[t - 1]
            and closes[t] < lows[t - 1]
        )
        long_entries[t] = c1_is_three and cc_is_2u
        short_entries[t] = c1_is_three and cc_is_2d

    position = 0
    stop = 0.0
    entry_trigger = 0.0
    exhaustion = None
    break_even_armed = False

    for t in range(size):
        if position == 1:
            if lows[t] < stop:
                long_exits[t] = True
                position = 0
            elif (
                exhaustion is not None
                and highs[t] >= exhaustion
                and not break_even_armed
            ):
                if break_even_at_exhaustion:
                    stop = max(stop, entry_trigger)
                    break_even_armed = True
                else:
                    long_exits[t] = True
                    position = 0
        elif position == -1:
            if highs[t] > stop:
                short_exits[t] = True
                position = 0
            elif (
                exhaustion is not None
                and lows[t] <= exhaustion
                and not break_even_armed
            ):
                if break_even_at_exhaustion:
                    stop = min(stop, entry_trigger)
                    break_even_armed = True
                else:
                    short_exits[t] = True
                    position = 0

        if position == 0:
            if long_entries[t] and not short_entries[t]:
                position = 1
                entry_trigger = float(highs[t - 1])
                stop = float(
                    lows[t] if stop_reference == "CC" else lows[t - 1]
                )
                exhaustion = _exhaustion_pivot(
                    highs, t, exhaustion_lookback, high_side=True
                )
                break_even_armed = False
            elif short_entries[t] and not long_entries[t]:
                position = -1
                entry_trigger = float(lows[t - 1])
                stop = float(
                    highs[t] if stop_reference == "CC" else highs[t - 1]
                )
                exhaustion = _exhaustion_pivot(
                    lows, t, exhaustion_lookback, high_side=False
                )
                break_even_armed = False

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "three_two_expansion",
    "hypothesis": "3-2 擴張突破可延續前一根 3-bar 的方向性動能。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "stop_reference",
        "break_even_at_exhaustion",
        "exhaustion_lookback",
    ],
    "signal_parameter_sets": [
        {
            "stop_reference": "CC",
            "break_even_at_exhaustion": False,
            "exhaustion_lookback": 48,
        },
        {
            "stop_reference": "C1",
            "break_even_at_exhaustion": False,
            "exhaustion_lookback": 48,
        },
        {
            "stop_reference": "CC",
            "break_even_at_exhaustion": True,
            "exhaustion_lookback": 48,
        },
        {
            "stop_reference": "C1",
            "break_even_at_exhaustion": True,
            "exhaustion_lookback": 48,
        },
    ],
}
