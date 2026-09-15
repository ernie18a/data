import numpy as np


def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    highs = features.market.highs
    lows = features.market.lows
    length = 10
    use_500 = True
    use_559 = True
    use_618 = True
    use_667 = True
    num_tps = 4
    sequences = []
    pivots = []

    for t in range(size):
        new_pivot = False
        if t >= 2 * length:
            center = t - length
            start = t - 2 * length
            high_window = highs[start : t + 1]
            low_window = lows[start : t + 1]
            if np.isfinite(high_window).all() and np.isfinite(low_window).all():
                if highs[center] >= np.max(high_window):
                    pivots.append((highs[center], center, 1))
                    new_pivot = True
                if lows[center] <= np.min(low_window):
                    pivots.append((lows[center], center, -1))
                    new_pivot = True
                if len(pivots) > 10:
                    del pivots[0]

        if new_pivot and len(pivots) >= 3:
            p0, b0, t0 = pivots[-3]
            p_a, b_a, t_a = pivots[-2]
            p_b, b_b, t_b = pivots[-1]
            wave = p_a - p0
            if wave != 0.0:
                direction = 0
                if t0 == -1 and t_a == 1 and t_b == -1 and p_b > p0:
                    direction = 1
                elif t0 == 1 and t_a == -1 and t_b == 1 and p_b < p0:
                    direction = -1
                ratio = (p_a - p_b) / wave
                ratio_valid = (
                    (use_500 and 0.500 <= ratio < 0.559)
                    or (use_559 and 0.559 <= ratio < 0.618)
                    or (use_618 and 0.618 <= ratio < 0.667)
                    or (use_667 and 0.667 <= ratio <= 1.000)
                )
                if direction != 0 and ratio_valid:
                    t1 = p_b + wave * 1.38
                    t2 = p_b + wave * 1.618
                    t3 = p_b + wave * 1.809
                    t4 = p_b + wave * 2.0
                    sequences.append(
                        {
                            "direction": direction,
                            "p0": p0,
                            "p_a": p_a,
                            "p_b": p_b,
                            "t1": t1,
                            "t2": t2,
                            "t3": t3,
                            "t4": t4,
                            "stop": p0,
                            "active": True,
                            "tp1": False,
                            "tp2": False,
                            "tp3": False,
                            "tp4": False,
                        }
                    )
                    if direction == 1:
                        long_entries[t] = True
                    else:
                        short_entries[t] = True

        for sequence in sequences:
            if not sequence["active"]:
                continue

            direction = sequence["direction"]
            if (
                direction == 1 and lows[t] < sequence["p0"]
            ) or (direction == -1 and highs[t] > sequence["p0"]):
                if direction == 1:
                    long_exits[t] = True
                else:
                    short_exits[t] = True
                sequence["active"] = False
                continue

            if direction == 1:
                hit_sl = lows[t] <= sequence["stop"]
                hit_tp1 = highs[t] >= sequence["t1"]
                hit_tp2 = highs[t] >= sequence["t2"]
                hit_tp3 = highs[t] >= sequence["t3"]
                hit_tp4 = highs[t] >= sequence["t4"]
            else:
                hit_sl = highs[t] >= sequence["stop"]
                hit_tp1 = lows[t] <= sequence["t1"]
                hit_tp2 = lows[t] <= sequence["t2"]
                hit_tp3 = lows[t] <= sequence["t3"]
                hit_tp4 = lows[t] <= sequence["t4"]

            if hit_tp1:
                sequence["tp1"] = True
            if hit_tp2:
                sequence["tp2"] = True
            if hit_tp3:
                sequence["tp3"] = True
            if hit_tp4:
                sequence["tp4"] = True

            final_target_hit = (
                (num_tps == 1 and sequence["tp1"])
                or (num_tps == 2 and sequence["tp2"])
                or (num_tps == 3 and sequence["tp3"])
                or (num_tps == 4 and sequence["tp4"])
            )
            if hit_sl or final_target_hit:
                if direction == 1:
                    long_exits[t] = True
                else:
                    short_exits[t] = True
                sequence["active"] = False
            else:
                if direction == 1:
                    if sequence["tp1"]:
                        sequence["stop"] = max(sequence["stop"], sequence["p_b"])
                    if sequence["tp2"]:
                        sequence["stop"] = max(sequence["stop"], sequence["t1"])
                    if sequence["tp3"]:
                        sequence["stop"] = max(sequence["stop"], sequence["t2"])
                else:
                    if sequence["tp1"]:
                        sequence["stop"] = min(sequence["stop"], sequence["p_b"])
                    if sequence["tp2"]:
                        sequence["stop"] = min(sequence["stop"], sequence["t1"])
                    if sequence["tp3"]:
                        sequence["stop"] = min(sequence["stop"], sequence["t2"])

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "PivotSequenceAtB",
    "hypothesis": "確認後的 0-A-B 樞紐序列在指定回撤區間於 B 點進場，並以來源 Fibonacci 目標與逐級移動止損管理部位。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
