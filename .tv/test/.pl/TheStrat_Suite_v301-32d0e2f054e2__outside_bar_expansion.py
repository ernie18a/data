import numpy as np


def _find_exhaustion(highs, lows, entry_index, magnitude, side, lookback):
    if entry_index < 3 or lookback < 3:
        return None
    first = entry_index - 2
    last = max(1, entry_index - int(lookback))
    if side == 1:
        running_extreme = float(highs[entry_index - 1])
        for i in range(first, last - 1, -1):
            if highs[i] > highs[i - 1] and highs[i] > highs[i + 1] and highs[i] > running_extreme and highs[i] > magnitude:
                return float(highs[i])
            running_extreme = max(running_extreme, float(highs[i]))
    else:
        running_extreme = float(lows[entry_index - 1])
        for i in range(first, last - 1, -1):
            if lows[i] < lows[i - 1] and lows[i] < lows[i + 1] and lows[i] < running_extreme and lows[i] < magnitude:
                return float(lows[i])
            running_extreme = min(running_extreme, float(lows[i]))
    return None


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    opens = np.asarray(market.opens)
    highs = np.asarray(market.highs)
    lows = np.asarray(market.lows)
    closes = np.asarray(market.closes)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    if size >= 2:
        outside = (highs[1:] > highs[:-1]) & (lows[1:] < lows[:-1])
        long_entries[1:] = outside & (closes[1:] > opens[1:])
        short_entries[1:] = outside & (closes[1:] <= opens[1:])

    stop_reference = str(signal_params.get("stop_reference", "CC")).upper()
    use_magnitude = bool(signal_params.get("use_magnitude", True))
    use_exhaustion = bool(signal_params.get("use_exhaustion", False))
    exhaustion_lookback = int(signal_params.get("exhaustion_lookback", 48))

    position = 0
    stop = None
    magnitude = None
    exhaustion = None

    for t in range(size):
        if position == 1:
            hit_stop = lows[t] < stop
            hit_target = ((use_magnitude and magnitude is not None and highs[t] >= magnitude) or (use_exhaustion and exhaustion is not None and highs[t] >= exhaustion))
            if hit_stop or hit_target:
                long_exits[t] = True
                position = 0
                stop = magnitude = exhaustion = None
        elif position == -1:
            hit_stop = highs[t] > stop
            hit_target = ((use_magnitude and magnitude is not None and lows[t] <= magnitude) or (use_exhaustion and exhaustion is not None and lows[t] <= exhaustion))
            if hit_stop or hit_target:
                short_exits[t] = True
                position = 0
                stop = magnitude = exhaustion = None

        if position == 0:
            if long_entries[t] and not short_entries[t]:
                position = 1
                stop = lows[t] if stop_reference == "CC" else lows[t - 1]
                magnitude = float(highs[t - 2]) if t >= 2 else None
                exhaustion = _find_exhaustion(highs, lows, t, magnitude, 1, exhaustion_lookback) if use_exhaustion and magnitude is not None else None
            elif short_entries[t] and not long_entries[t]:
                position = -1
                stop = highs[t] if stop_reference == "CC" else highs[t - 1]
                magnitude = float(lows[t - 2]) if t >= 2 else None
                exhaustion = _find_exhaustion(highs, lows, t, magnitude, -1, exhaustion_lookback) if use_exhaustion and magnitude is not None else None

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "outside_bar_expansion",
    "hypothesis": "Outside bar range expansion with directional close can continue toward the C2 magnitude or an intact exhaustion pivot.",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["stop_reference", "use_magnitude", "use_exhaustion", "exhaustion_lookback"],
    "signal_parameter_sets": [
        {"stop_reference": "CC", "use_magnitude": True, "use_exhaustion": False, "exhaustion_lookback": 48},
        {"stop_reference": "C1", "use_magnitude": True, "use_exhaustion": False, "exhaustion_lookback": 48},
        {"stop_reference": "CC", "use_magnitude": True, "use_exhaustion": True, "exhaustion_lookback": 48},
        {"stop_reference": "C1", "use_magnitude": True, "use_exhaustion": True, "exhaustion_lookback": 48},
    ],
}