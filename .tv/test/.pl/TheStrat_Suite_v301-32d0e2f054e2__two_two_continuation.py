import numpy as np


def _finite_at(*values):
    return bool(np.isfinite(np.asarray(values, dtype=float)).all())


def _exhaustion_high(highs, entry_index, lookback):
    c1_index = entry_index - 1
    if c1_index < 2 or not np.isfinite(highs[c1_index]):
        return np.nan
    running_max = float(highs[c1_index])
    limit = min(max(2, int(lookback)), entry_index - 1)
    for offset in range(2, limit + 1):
        index = entry_index - offset
        if not _finite_at(highs[index - 1], highs[index], highs[index + 1]):
            continue
        if highs[index] > highs[index - 1] and highs[index] > highs[index + 1] and running_max < highs[index]:
            return float(highs[index])
        running_max = max(running_max, float(highs[index]))
    return np.nan


def _exhaustion_low(lows, entry_index, lookback):
    c1_index = entry_index - 1
    if c1_index < 2 or not np.isfinite(lows[c1_index]):
        return np.nan
    running_min = float(lows[c1_index])
    limit = min(max(2, int(lookback)), entry_index - 1)
    for offset in range(2, limit + 1):
        index = entry_index - offset
        if not _finite_at(lows[index - 1], lows[index], lows[index + 1]):
            continue
        if lows[index] < lows[index - 1] and lows[index] < lows[index + 1] and running_min > lows[index]:
            return float(lows[index])
        running_min = min(running_min, float(lows[index]))
    return np.nan


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    params = {} if signal_params is None else signal_params
    stop_reference = str(params.get("stop_reference", "CC")).upper()
    break_even_at_magnitude = bool(params.get("break_even_at_magnitude", False))
    break_even_at_exhaustion = bool(params.get("break_even_at_exhaustion", False))
    exhaustion_lookback = int(params.get("exhaustion_lookback", 48))

    position = 0
    stop = np.nan
    entry_price = np.nan
    magnitude = np.nan
    exhaustion = np.nan
    break_even_armed = False

    for t in range(size):
        if position == 1:
            stop_hit = np.isfinite(stop) and lows[t] < stop
            exhaustion_hit = np.isfinite(exhaustion) and highs[t] >= exhaustion
            if stop_hit or exhaustion_hit:
                long_exits[t] = True
                position = 0
                continue
            if break_even_at_magnitude and not break_even_armed and np.isfinite(magnitude) and highs[t] >= magnitude:
                stop = max(stop, entry_price)
                break_even_armed = True
            if break_even_at_exhaustion and not break_even_armed and np.isfinite(exhaustion) and highs[t] >= exhaustion:
                stop = max(stop, entry_price)
                break_even_armed = True
        elif position == -1:
            stop_hit = np.isfinite(stop) and highs[t] > stop
            exhaustion_hit = np.isfinite(exhaustion) and lows[t] <= exhaustion
            if stop_hit or exhaustion_hit:
                short_exits[t] = True
                position = 0
                continue
            if break_even_at_magnitude and not break_even_armed and np.isfinite(magnitude) and lows[t] <= magnitude:
                stop = min(stop, entry_price)
                break_even_armed = True
            if break_even_at_exhaustion and not break_even_armed and np.isfinite(exhaustion) and lows[t] <= exhaustion:
                stop = min(stop, entry_price)
                break_even_armed = True

        if position != 0 or t < 3:
            continue
        if not _finite_at(highs[t - 3], lows[t - 3], highs[t - 2], lows[t - 2], highs[t - 1], lows[t - 1], highs[t], lows[t], closes[t]):
            continue

        c2_up = highs[t - 2] > highs[t - 3] and lows[t - 2] >= lows[t - 3]
        c1_up = highs[t - 1] > highs[t - 2] and lows[t - 1] >= lows[t - 2]
        cc_up = highs[t] > highs[t - 1] and lows[t] >= lows[t - 1]
        c2_down = lows[t - 2] < lows[t - 3] and highs[t - 2] <= highs[t - 3]
        c1_down = lows[t - 1] < lows[t - 2] and highs[t - 1] <= highs[t - 2]
        cc_down = lows[t] < lows[t - 1] and highs[t] <= highs[t - 1]

        is_long = c2_up and c1_up and cc_up and closes[t] > highs[t - 1]
        is_short = c2_down and c1_down and cc_down and closes[t] < lows[t - 1]
        long_entries[t] = is_long
        short_entries[t] = is_short

        if is_long:
            position = 1
            entry_price = float(highs[t - 1])
            stop = float(lows[t] if stop_reference == "CC" else lows[t - 1])
            magnitude = float(highs[t - 2])
            exhaustion = _exhaustion_high(highs, t, exhaustion_lookback)
            break_even_armed = False
            if break_even_at_magnitude and highs[t] >= magnitude:
                stop = max(stop, entry_price)
                break_even_armed = True
        elif is_short:
            position = -1
            entry_price = float(lows[t - 1])
            stop = float(highs[t] if stop_reference == "CC" else highs[t - 1])
            magnitude = float(lows[t - 2])
            exhaustion = _exhaustion_low(lows, t, exhaustion_lookback)
            break_even_armed = False
            if break_even_at_magnitude and lows[t] <= magnitude:
                stop = min(stop, entry_price)
                break_even_armed = True

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "two_two_continuation",
    "hypothesis": "連續兩根同向 2 棒後的第三根突破延續原方向，並以結構停損與 exhaustion pivot 管理退出。",
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
