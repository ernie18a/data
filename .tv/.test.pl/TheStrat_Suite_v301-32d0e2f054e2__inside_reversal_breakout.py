import numpy as np


def _find_exhaustion(highs, lows, magnitude_index, magnitude, side, lookback):
    if not np.isfinite(magnitude) or lookback < 1:
        return np.nan
    first = max(1, magnitude_index - lookback)
    for index in range(magnitude_index - 1, first - 1, -1):
        if side == 1:
            candidate = highs[index]
            if (
                np.isfinite(candidate)
                and candidate > magnitude
                and candidate > highs[index - 1]
                and candidate > highs[index + 1]
            ):
                return float(candidate)
        else:
            candidate = lows[index]
            if (
                np.isfinite(candidate)
                and candidate < magnitude
                and candidate < lows[index - 1]
                and candidate < lows[index + 1]
            ):
                return float(candidate)
    return np.nan


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    opens = np.asarray(market.opens).reshape(-1)
    highs = np.asarray(market.highs).reshape(-1)
    lows = np.asarray(market.lows).reshape(-1)
    closes = np.asarray(market.closes).reshape(-1)
    if any(array.size != size for array in (opens, highs, lows, closes)):
        raise ValueError("market OHLC arrays must match market.size")

    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    for t in range(2, size):
        c1_inside = highs[t - 1] <= highs[t - 2] and lows[t - 1] >= lows[t - 2]
        c2_down = closes[t - 2] <= opens[t - 2]
        c2_up = closes[t - 2] >= opens[t - 2]
        long_entries[t] = (
            c1_inside
            and c2_down
            and lows[t] >= lows[t - 1]
            and closes[t] > highs[t - 1]
        )
        short_entries[t] = (
            c1_inside
            and c2_up
            and highs[t] <= highs[t - 1]
            and closes[t] < lows[t - 1]
        )

    stop_reference = str(signal_params.get("stop_reference", "CC")).lower()
    if stop_reference not in {"cc", "c1"}:
        stop_reference = "cc"
    target_mode = str(signal_params.get("target_mode", "magnitude")).lower()
    if target_mode not in {"magnitude", "exhaustion", "both"}:
        target_mode = "magnitude"
    break_even = bool(signal_params.get("break_even", False))
    try:
        lookback = max(1, int(signal_params.get("exhaustion_lookback", 48)))
    except (TypeError, ValueError):
        lookback = 48

    position = 0
    active_target_mode = target_mode
    stop = np.nan
    entry_trigger = np.nan
    magnitude_target = np.nan
    exhaustion_target = np.nan

    for t in range(size):
        if position == 1:
            if lows[t] < stop:
                long_exits[t] = True
                position = 0
            else:
                magnitude_hit = np.isfinite(magnitude_target) and highs[t] >= magnitude_target
                exhaustion_hit = np.isfinite(exhaustion_target) and highs[t] >= exhaustion_target
                if break_even and magnitude_hit:
                    stop = max(stop, entry_trigger)
                take_profit = (
                    magnitude_hit
                    if active_target_mode == "magnitude"
                    else exhaustion_hit
                    if active_target_mode == "exhaustion"
                    else magnitude_hit or exhaustion_hit
                )
                if take_profit:
                    long_exits[t] = True
                    position = 0

        elif position == -1:
            if highs[t] > stop:
                short_exits[t] = True
                position = 0
            else:
                magnitude_hit = np.isfinite(magnitude_target) and lows[t] <= magnitude_target
                exhaustion_hit = np.isfinite(exhaustion_target) and lows[t] <= exhaustion_target
                if break_even and magnitude_hit:
                    stop = min(stop, entry_trigger)
                take_profit = (
                    magnitude_hit
                    if active_target_mode == "magnitude"
                    else exhaustion_hit
                    if active_target_mode == "exhaustion"
                    else magnitude_hit or exhaustion_hit
                )
                if take_profit:
                    short_exits[t] = True
                    position = 0

        if position == 0:
            if long_entries[t] and not short_entries[t]:
                position = 1
                active_target_mode = target_mode
                entry_trigger = highs[t - 1]
                magnitude_target = highs[t - 2]
                exhaustion_target = _find_exhaustion(
                    highs, lows, t - 2, magnitude_target, 1, lookback
                )
                if active_target_mode == "exhaustion" and not np.isfinite(exhaustion_target):
                    active_target_mode = "magnitude"
                stop = lows[t] if stop_reference == "cc" else lows[t - 1]
            elif short_entries[t] and not long_entries[t]:
                position = -1
                active_target_mode = target_mode
                entry_trigger = lows[t - 1]
                magnitude_target = lows[t - 2]
                exhaustion_target = _find_exhaustion(
                    highs, lows, t - 2, magnitude_target, -1, lookback
                )
                if active_target_mode == "exhaustion" and not np.isfinite(exhaustion_target):
                    active_target_mode = "magnitude"
                stop = highs[t] if stop_reference == "cc" else highs[t - 1]

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "inside_reversal_breakout",
    "hypothesis": "Inside-bar consolidation followed by an opposite-direction breakout creates a tradable reversal.",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "stop_reference",
        "target_mode",
        "break_even",
        "exhaustion_lookback",
    ],
    "signal_parameter_sets": [
        {
            "stop_reference": "CC",
            "target_mode": "magnitude",
            "break_even": False,
            "exhaustion_lookback": 48,
        }
    ],
}
