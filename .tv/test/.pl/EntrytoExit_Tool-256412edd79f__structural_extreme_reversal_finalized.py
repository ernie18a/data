import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    highs = market.highs
    lows = market.lows
    closes = market.closes

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    structural_length = 10
    group_dir = 0
    group_extreme_price = np.nan
    group_extreme_bar = -1
    last_committed_dir = 0

    active_dir = 0
    entry_price = np.nan
    entry_terminal = np.nan

    for t in range(size):
        finalized_dir = 0
        finalized_terminal = np.nan
        current_close = closes[t]

        if t >= structural_length:
            start = t - structural_length + 1
            high_window = highs[start : t + 1]
            low_window = lows[start : t + 1]
            data_ready = (
                np.isfinite(high_window).all()
                and np.isfinite(low_window).all()
                and np.isfinite(current_close)
                and np.isfinite(closes[t - 1])
            )
            if data_ready:
                structural_high = highs[t] == np.max(high_window)
                structural_low = lows[t] == np.min(low_window)
                candidate_dir = 0
                candidate_price = np.nan

                if structural_high and structural_low:
                    up_distance = abs(highs[t] - closes[t - 1])
                    down_distance = abs(closes[t - 1] - lows[t])
                    if up_distance >= down_distance:
                        candidate_dir = -1
                        candidate_price = highs[t]
                    else:
                        candidate_dir = 1
                        candidate_price = lows[t]
                elif structural_high:
                    candidate_dir = -1
                    candidate_price = highs[t]
                elif structural_low:
                    candidate_dir = 1
                    candidate_price = lows[t]

                if candidate_dir != 0:
                    if group_dir == 0:
                        group_dir = candidate_dir
                        group_extreme_price = candidate_price
                        group_extreme_bar = t
                    elif candidate_dir == group_dir:
                        more_extreme = (
                            candidate_price < group_extreme_price
                            if group_dir > 0
                            else candidate_price > group_extreme_price
                        )
                        if more_extreme:
                            group_extreme_price = candidate_price
                            group_extreme_bar = t
                    else:
                        alternation_pass = (
                            last_committed_dir == 0
                            or group_dir != last_committed_dir
                        )
                        if alternation_pass and group_extreme_bar >= 0:
                            finalized_dir = group_dir
                            finalized_terminal = group_extreme_price
                            last_committed_dir = group_dir

                        group_dir = candidate_dir
                        group_extreme_price = candidate_price
                        group_extreme_bar = t

        event_on_bar = (
            finalized_dir != 0
            and np.isfinite(current_close)
            and np.isfinite(finalized_terminal)
        )

        if active_dir != 0 and np.isfinite(current_close):
            opposite_event = event_on_bar and finalized_dir == -active_dir
            if opposite_event:
                denominator = max(
                    abs(entry_price), np.finfo(np.float64).tiny
                )
                event_return_pct = (
                    (current_close - entry_price) * 100.0 / denominator
                    if active_dir > 0
                    else (entry_price - current_close) * 100.0 / denominator
                )
                if np.isfinite(event_return_pct) and event_return_pct >= 0.0:
                    if active_dir > 0:
                        long_exits[t] = True
                    else:
                        short_exits[t] = True
                    active_dir = 0
                    entry_price = np.nan
                    entry_terminal = np.nan
            elif not event_on_bar:
                terminal_break = (
                    (active_dir > 0 and current_close < entry_terminal)
                    or (active_dir < 0 and current_close > entry_terminal)
                )
                if terminal_break:
                    if active_dir > 0:
                        long_exits[t] = True
                    else:
                        short_exits[t] = True
                    active_dir = 0
                    entry_price = np.nan
                    entry_terminal = np.nan

        if event_on_bar and active_dir == 0:
            if finalized_dir > 0:
                long_entries[t] = True
            else:
                short_entries[t] = True
            active_dir = finalized_dir
            entry_price = current_close
            entry_terminal = finalized_terminal

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "structural_extreme_reversal_finalized",
    "hypothesis": "同向結構極值群在反向結構確認後形成 Finalized 方向事件，沿用來源的 terminal 失效或獲利反向訊號出場。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}