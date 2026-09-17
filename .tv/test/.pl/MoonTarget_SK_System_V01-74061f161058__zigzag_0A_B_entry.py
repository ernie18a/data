from __future__ import annotations

import numpy as np


def _enabled_retracement(ratio: float, params: dict) -> bool:
    ranges = (
        (0.382, 0.500, "use_382"),
        (0.500, 0.559, "use_500"),
        (0.559, 0.618, "use_559"),
        (0.618, 0.667, "use_618"),
        (0.667, 1.000, "use_667"),
    )
    for lower, upper, name in ranges:
        if bool(params.get(name, name == "use_500")) and lower <= ratio < upper:
            return True
    return bool(params.get("use_667", True)) and 0.667 <= ratio <= 1.0


def _pivot_at(highs: np.ndarray, lows: np.ndarray, center: int, length: int) -> tuple[bool, bool]:
    left = center - length
    right = center + length + 1
    if left < 0 or right > highs.size:
        return False, False
    high_window = highs[left:right]
    low_window = lows[left:right]
    if not (np.isfinite(high_window).all() and np.isfinite(low_window).all()):
        return False, False
    return bool(highs[center] == np.max(high_window)), bool(lows[center] == np.min(low_window))


def _targets(entry: float, p0: float, wave_0a: float, side: int, params: dict) -> tuple[float, float, float, float]:
    mode = str(params.get("rr_mode", "automatic")).lower()
    if mode in {"custom", "custom rr"}:
        custom_rr = max(0.0, float(params.get("custom_rr", 3.0)))
        reward = abs(entry - p0) * custom_rr
        return tuple(entry + reward * fraction * side for fraction in (0.25, 0.50, 0.75, 1.0))
    return tuple(entry + wave_0a * multiple for multiple in (1.38, 1.618, 1.809, 2.0))


def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    if highs.size != size or lows.size != size or closes.size != size:
        raise ValueError("market OHLC arrays must match features.market.size")

    length = max(1, int(signal_params.get("length", 10)))
    num_tps = min(4, max(1, int(signal_params.get("num_tps", 4))))
    pivots: list[tuple[float, int, int]] = []
    last_b_index = -1
    position = 0
    entry = 0.0
    stop = 0.0
    targets = (0.0, 0.0, 0.0, 0.0)
    hit_tp = [False, False, False, False]

    for t in range(size):
        if position:
            if (position == 1 and lows[t] <= stop) or (position == -1 and highs[t] >= stop):
                if position == 1:
                    long_exits[t] = True
                else:
                    short_exits[t] = True
                position = 0
            else:
                if position == 1:
                    hit_now = [highs[t] >= target for target in targets]
                else:
                    hit_now = [lows[t] <= target for target in targets]
                hit_tp = [old or now for old, now in zip(hit_tp, hit_now)]
                if hit_tp[num_tps - 1]:
                    if position == 1:
                        long_exits[t] = True
                    else:
                        short_exits[t] = True
                    position = 0
                else:
                    if hit_tp[0]:
                        stop = max(stop, entry) if position == 1 else min(stop, entry)
                    if hit_tp[1]:
                        stop = max(stop, targets[0]) if position == 1 else min(stop, targets[0])
                    if hit_tp[2]:
                        stop = max(stop, targets[1]) if position == 1 else min(stop, targets[1])

        center = t - length
        if center >= length:
            is_ph, is_pl = _pivot_at(highs, lows, center, length)
            if is_ph:
                pivots.insert(0, (float(highs[center]), 1, center))
            if is_pl:
                pivots.insert(0, (float(lows[center]), -1, center))
            del pivots[10:]

        if len(pivots) < 3 or pivots[0][2] == last_b_index or position:
            continue

        p_b, type_b, b_index = pivots[0]
        p_a, type_a, _ = pivots[1]
        p_0, type_0, _ = pivots[2]
        if type_0 == -1 and type_a == 1 and type_b == -1:
            side = 1
        elif type_0 == 1 and type_a == -1 and type_b == 1:
            side = -1
        else:
            continue

        wave_0a = p_a - p_0
        if wave_0a == 0.0 or (side == 1 and p_b <= p_0) or (side == -1 and p_b >= p_0):
            continue
        ratio = (p_a - p_b) / wave_0a
        if not (np.isfinite(ratio) and _enabled_retracement(ratio, signal_params)):
            continue

        last_b_index = b_index
        entry = p_b
        stop = p_0
        targets = _targets(entry, p_0, wave_0a, side, signal_params)
        hit_tp = [False, False, False, False]
        position = side
        if side == 1:
            long_entries[t] = True
        else:
            short_entries[t] = True

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "zigzag_0A_B_entry",
    "hypothesis": "確認 0-A-B 結構且 B 回撤落入啟用 Fibonacci 區間後，沿 0-A 方向進場並以分段目標與點 0 風險管理出場。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "length", "use_382", "use_500", "use_559", "use_618", "use_667",
        "num_tps", "rr_mode", "custom_rr",
    ],
    "signal_parameter_sets": [{
        "length": 10,
        "use_382": False,
        "use_500": True,
        "use_559": True,
        "use_618": True,
        "use_667": True,
        "num_tps": 4,
        "rr_mode": "automatic",
        "custom_rr": 3.0,
    }],
}
