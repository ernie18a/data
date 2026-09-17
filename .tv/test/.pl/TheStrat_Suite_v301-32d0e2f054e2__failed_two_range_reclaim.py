import numpy as np


def _exhaustion_pivot(highs, lows, index):
    if index <= 50:
        return np.nan, np.nan
    max_high = highs[index - 1]
    min_low = lows[index - 1]
    high_pivot = np.nan
    low_pivot = np.nan
    for offset in range(2, 49):
        pivot = index - offset
        if np.isnan(high_pivot) and highs[pivot] > highs[pivot + 1] and highs[pivot] > highs[pivot - 1] and max_high < highs[pivot]:
            high_pivot = highs[pivot]
        if np.isnan(low_pivot) and lows[pivot] < lows[pivot + 1] and lows[pivot] < lows[pivot - 1] and min_low > lows[pivot]:
            low_pivot = lows[pivot]
        max_high = max(max_high, highs[pivot])
        min_low = min(min_low, lows[pivot])
        if not np.isnan(high_pivot) and not np.isnan(low_pivot):
            break
    return high_pivot, low_pivot


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if min(len(opens), len(highs), len(lows), len(closes)) < size:
        return long_entries, long_exits, short_entries, short_exits

    method = str(signal_params.get("failed_2_method", "Reclaim"))
    method = {"Reclaim + Open": "Both", "Reclaim OR Open": "Either"}.get(method, method)
    if method not in {"Open", "Reclaim", "Both", "Either"}:
        method = "Reclaim"

    for t in range(1, size):
        values = (opens[t - 1], highs[t - 1], lows[t - 1], closes[t - 1], opens[t], highs[t], lows[t], closes[t])
        if not np.all(np.isfinite(values)):
            continue
        c1_high = highs[t - 1]
        c1_low = lows[t - 1]
        inside = c1_low <= closes[t] <= c1_high
        bullish = closes[t] > opens[t]
        bearish = closes[t] < opens[t]
        if method == "Open":
            long_confirm, short_confirm = bullish, bearish
        elif method == "Reclaim":
            long_confirm = short_confirm = inside
        elif method == "Both":
            long_confirm, short_confirm = bullish and inside, bearish and inside
        else:
            long_confirm, short_confirm = bullish or inside, bearish or inside
        long_entries[t] = lows[t] < c1_low and highs[t] <= c1_high and long_confirm
        short_entries[t] = highs[t] > c1_high and lows[t] >= c1_low and short_confirm

    position = 0
    stop = np.nan
    target = np.nan
    pending_position = 0
    pending_stop = np.nan
    pending_target = np.nan

    for t in range(size):
        if position == 0 and pending_position:
            position = pending_position
            stop, target = pending_stop, pending_target
            pending_position = 0

        if position == 1:
            if lows[t] < stop or (np.isfinite(target) and highs[t] >= target):
                long_exits[t] = True
                position = 0
        elif position == -1:
            if highs[t] > stop or (np.isfinite(target) and lows[t] <= target):
                short_exits[t] = True
                position = 0

        if position == 0 and t + 1 < size:
            if long_entries[t] and not short_entries[t]:
                exhaustion_high, _ = _exhaustion_pivot(highs, lows, t)
                c2_high = highs[t - 2] if t >= 2 and np.isfinite(highs[t - 2]) else np.nan
                candidates = [v for v in (c2_high, exhaustion_high) if np.isfinite(v)]
                pending_position, pending_stop = 1, lows[t]
                pending_target = min(candidates) if candidates else np.nan
            elif short_entries[t] and not long_entries[t]:
                _, exhaustion_low = _exhaustion_pivot(highs, lows, t)
                c2_low = lows[t - 2] if t >= 2 and np.isfinite(lows[t - 2]) else np.nan
                candidates = [v for v in (c2_low, exhaustion_low) if np.isfinite(v)]
                pending_position, pending_stop = -1, highs[t]
                pending_target = max(candidates) if candidates else np.nan

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "failed_two_range_reclaim",
    "hypothesis": "Failed 2 range reclaims reverse a broken C1 range toward the C2 or exhaustion target.",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["failed_2_method"],
    "signal_parameter_sets": [
        {"failed_2_method": "Open"},
        {"failed_2_method": "Reclaim"},
        {"failed_2_method": "Reclaim + Open"},
        {"failed_2_method": "Reclaim OR Open"},
    ],
}