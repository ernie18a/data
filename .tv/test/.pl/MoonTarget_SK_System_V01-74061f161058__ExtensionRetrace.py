import numpy as np


def _pivot_high(highs: np.ndarray, center: int, length: int) -> bool:
    left = center - length
    right = center + length + 1
    if left < 0 or right > highs.size:
        return False
    value = highs[center]
    return bool(np.isfinite(value) and value == np.max(highs[left:right]))


def _pivot_low(lows: np.ndarray, center: int, length: int) -> bool:
    left = center - length
    right = center + length + 1
    if left < 0 or right > lows.size:
        return False
    value = lows[center]
    return bool(np.isfinite(value) and value == np.min(lows[left:right]))


def _valid_setup(p0: float, p_a: float, p_b: float, side: int) -> bool:
    wave_0a = p_a - p0
    if not (np.isfinite(p0) and np.isfinite(p_a) and np.isfinite(p_b)):
        return False
    if wave_0a == 0.0:
        return False
    ratio = (p_a - p_b) / wave_0a
    if side == 1 and p_b <= p0:
        return False
    if side == -1 and p_b >= p0:
        return False
    return 0.500 <= ratio <= 1.000


def _make_sequence(p0: float, p_a: float, p_b: float, side: int, created_at: int) -> dict:
    fib138 = p_b + 1.38 * (p_a - p0)
    return {
        "side": side,
        "p0": p0,
        "pA": p_a,
        "pB": p_b,
        "created_at": created_at,
        "fib138": fib138,
        "a_broken": False,
        "c_reached": False,
        "wcl_top": np.nan,
        "wcl_bottom": np.nan,
        "wcl_touched": False,
        "wcl_trade_active": False,
        "wcl_trade_closed": False,
        "wcl_failed": False,
        "wcl_entry": np.nan,
        "wcl_sl": p0,
        "targets": [np.nan, np.nan, np.nan, np.nan],
        "target_hits": [False, False, False, False],
        "invalidated": False,
    }


def _set_wcl(seq: dict) -> None:
    fib138 = seq["fib138"]
    p0 = seq["p0"]
    if seq["side"] == 1:
        full_range = fib138 - p0
        seq["wcl_top"] = fib138 - full_range * 0.500
        seq["wcl_bottom"] = fib138 - full_range * 0.667
    else:
        full_range = p0 - fib138
        seq["wcl_top"] = fib138 + full_range * 0.667
        seq["wcl_bottom"] = fib138 + full_range * 0.500


def _set_targets(seq: dict, rr_mode: str, custom_rr: float) -> None:
    side = seq["side"]
    if rr_mode == "Automatic (Fibonacci)":
        p0 = seq["p0"]
        p_a = seq["pA"]
        p_b = seq["pB"]
        seq["targets"] = [
            p_b + (p_a - p0) * 1.38,
            p_b + (p_a - p0) * 1.618,
            p_b + (p_a - p0) * 1.809,
            p_b + (p_a - p0) * 2.0,
        ]
        return
    risk = abs(seq["wcl_entry"] - seq["p0"])
    reward = risk * custom_rr
    seq["targets"] = [
        seq["wcl_entry"] + reward * 0.25 * side,
        seq["wcl_entry"] + reward * 0.50 * side,
        seq["wcl_entry"] + reward * 0.75 * side,
        seq["wcl_entry"] + reward * side,
    ]


def _target_touched(seq: dict, high: float, low: float, index: int) -> bool:
    target = seq["targets"][index]
    if not np.isfinite(target):
        return False
    if seq["side"] == 1:
        return high >= target
    return low <= target


def _stop_touched(seq: dict, high: float, low: float) -> bool:
    if seq["side"] == 1:
        return low <= seq["wcl_sl"]
    return high >= seq["wcl_sl"]


def _zero_invalidated(seq: dict, high: float, low: float) -> bool:
    if seq["side"] == 1:
        return low < seq["p0"]
    return high > seq["p0"]


def generate_signals(features, signal_params):
    market = features.market
    highs = market.highs
    lows = market.lows
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    rr_mode = signal_params["rr_mode"]
    custom_rr = float(signal_params["custom_rr"])
    num_tps = int(signal_params["num_tps"])
    if rr_mode not in ("Automatic (Fibonacci)", "Custom RR"):
        return long_entries, long_exits, short_entries, short_exits
    if not np.isfinite(custom_rr) or custom_rr <= 0.0 or num_tps not in (1, 2, 3, 4):
        return long_entries, long_exits, short_entries, short_exits

    pivot_length = 10
    pivot_events: list[tuple[int, float, int]] = []
    sequences: list[dict] = []
    last_setup_b_index = -1

    for t in range(size):
        if not (
            np.isfinite(highs[t])
            and np.isfinite(lows[t])
        ):
            continue

        center = t - pivot_length
        if center >= pivot_length:
            new_pivot = False
            if _pivot_high(highs, center, pivot_length):
                pivot_events.append((center, float(highs[center]), 1))
                new_pivot = True
            if _pivot_low(lows, center, pivot_length):
                pivot_events.append((center, float(lows[center]), -1))
                new_pivot = True
            if len(pivot_events) > 10:
                del pivot_events[:-10]

            if new_pivot and len(pivot_events) >= 3:
                b_index, p_b, b_type = pivot_events[-1]
                a_index, p_a, a_type = pivot_events[-2]
                zero_index, p0, zero_type = pivot_events[-3]
                side = (
                    1
                    if zero_type == -1 and a_type == 1 and b_type == -1
                    else -1
                    if zero_type == 1 and a_type == -1 and b_type == 1
                    else 0
                )
                if (
                    side != 0
                    and b_index != last_setup_b_index
                    and _valid_setup(p0, p_a, p_b, side)
                ):
                    sequences.append(_make_sequence(p0, p_a, p_b, side, t))
                    last_setup_b_index = b_index

        for seq in sequences:
            if seq["invalidated"]:
                continue

            if _zero_invalidated(seq, highs[t], lows[t]):
                if seq["wcl_trade_active"]:
                    long_exits[t] |= seq["side"] == 1
                    short_exits[t] |= seq["side"] == -1
                    seq["wcl_trade_active"] = False
                    seq["wcl_trade_closed"] = True
                    seq["wcl_failed"] = True
                seq["invalidated"] = True
                continue

            if seq["wcl_trade_active"]:
                for target_index in range(4):
                    if _target_touched(seq, highs[t], lows[t], target_index):
                        seq["target_hits"][target_index] = True

            if not seq["a_broken"]:
                if seq["side"] == 1 and highs[t] > seq["pA"]:
                    seq["a_broken"] = True
                elif seq["side"] == -1 and lows[t] < seq["pA"]:
                    seq["a_broken"] = True

            if not seq["c_reached"]:
                if (
                    seq["side"] == 1
                    and highs[t] >= seq["fib138"]
                ) or (
                    seq["side"] == -1
                    and lows[t] <= seq["fib138"]
                ):
                    seq["c_reached"] = True
                    _set_wcl(seq)
            else:
                if not seq["wcl_touched"]:
                    if (
                        seq["side"] == 1
                        and lows[t] <= seq["wcl_top"]
                        and highs[t] >= seq["wcl_bottom"]
                    ) or (
                        seq["side"] == -1
                        and highs[t] >= seq["wcl_bottom"]
                        and lows[t] <= seq["wcl_top"]
                    ):
                        seq["wcl_touched"] = True

                if (
                    seq["wcl_touched"]
                    and not seq["wcl_trade_active"]
                    and not seq["wcl_trade_closed"]
                ):
                    seq["wcl_trade_active"] = True
                    seq["wcl_entry"] = (seq["wcl_top"] + seq["wcl_bottom"]) * 0.5
                    seq["wcl_sl"] = seq["p0"]
                    _set_targets(seq, rr_mode, custom_rr)
                    if seq["side"] == 1:
                        long_entries[t] = True
                    else:
                        short_entries[t] = True

            if seq["wcl_trade_active"]:
                if _stop_touched(seq, highs[t], lows[t]):
                    if seq["side"] == 1:
                        long_exits[t] = True
                    else:
                        short_exits[t] = True
                    seq["wcl_trade_active"] = False
                    seq["wcl_trade_closed"] = True
                    if seq["wcl_sl"] == seq["p0"]:
                        seq["wcl_failed"] = True
                elif any(seq["target_hits"][:num_tps]):
                    if seq["target_hits"][num_tps - 1]:
                        if seq["side"] == 1:
                            long_exits[t] = True
                        else:
                            short_exits[t] = True
                        seq["wcl_trade_active"] = False
                        seq["wcl_trade_closed"] = True
                    else:
                        if seq["target_hits"][0]:
                            if seq["side"] == 1:
                                seq["wcl_sl"] = max(seq["wcl_sl"], seq["wcl_entry"])
                            else:
                                seq["wcl_sl"] = min(seq["wcl_sl"], seq["wcl_entry"])
                        if seq["target_hits"][1]:
                            if seq["side"] == 1:
                                seq["wcl_sl"] = max(seq["wcl_sl"], seq["targets"][0])
                            else:
                                seq["wcl_sl"] = min(seq["wcl_sl"], seq["targets"][0])
                        if seq["target_hits"][2]:
                            if seq["side"] == 1:
                                seq["wcl_sl"] = max(seq["wcl_sl"], seq["targets"][1])
                            else:
                                seq["wcl_sl"] = min(seq["wcl_sl"], seq["targets"][1])
            if (
                not seq["wcl_trade_active"]
                and not seq["invalidated"]
                and not seq["wcl_failed"]
            ):
                if (
                    seq["side"] == 1
                    and lows[t] <= seq["p0"]
                ) or (
                    seq["side"] == -1
                    and highs[t] >= seq["p0"]
                ):
                    seq["invalidated"] = True

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "ExtensionRetrace",
    "hypothesis": "0-A-B 結構完成 1.38 波段延伸 C 後，價格回撤至 0.500-0.667 WCL 區間時，依方向進場並以 p0 止損及來源目標管理。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["rr_mode", "custom_rr", "num_tps"],
    "signal_parameter_sets": [
        {"rr_mode": "Automatic (Fibonacci)", "custom_rr": 3.0, "num_tps": 1},
        {"rr_mode": "Automatic (Fibonacci)", "custom_rr": 3.0, "num_tps": 2},
        {"rr_mode": "Automatic (Fibonacci)", "custom_rr": 3.0, "num_tps": 3},
        {"rr_mode": "Automatic (Fibonacci)", "custom_rr": 3.0, "num_tps": 4},
        {"rr_mode": "Custom RR", "custom_rr": 2.0, "num_tps": 1},
        {"rr_mode": "Custom RR", "custom_rr": 2.0, "num_tps": 2},
        {"rr_mode": "Custom RR", "custom_rr": 2.0, "num_tps": 3},
        {"rr_mode": "Custom RR", "custom_rr": 2.0, "num_tps": 4},
        {"rr_mode": "Custom RR", "custom_rr": 3.0, "num_tps": 1},
        {"rr_mode": "Custom RR", "custom_rr": 3.0, "num_tps": 2},
        {"rr_mode": "Custom RR", "custom_rr": 3.0, "num_tps": 3},
        {"rr_mode": "Custom RR", "custom_rr": 3.0, "num_tps": 4},
        {"rr_mode": "Custom RR", "custom_rr": 4.0, "num_tps": 1},
        {"rr_mode": "Custom RR", "custom_rr": 4.0, "num_tps": 2},
        {"rr_mode": "Custom RR", "custom_rr": 4.0, "num_tps": 3},
        {"rr_mode": "Custom RR", "custom_rr": 4.0, "num_tps": 4},
    ],
}
