import numpy as np


def generate_signals(features, signal_params):
    size = int(features.market.size)
    if size == 0:
        return (
            np.zeros(0, dtype=np.bool_),
            np.zeros(0, dtype=np.bool_),
            np.zeros(0, dtype=np.bool_),
            np.zeros(0, dtype=np.bool_),
        )

    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volumes = np.asarray(features.market.volumes, dtype=np.float64)
    atr = np.asarray(features.atr(14), dtype=np.float64)

    lookback = 50
    valid_bar = (
        np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & np.isfinite(volumes)
    )
    typical = (highs + lows + closes) / 3.0
    effective_volume = np.where(valid_bar, np.maximum(volumes, 1.0), 0.0)
    typical = np.where(valid_bar, typical, 0.0)

    prefix_volume = np.concatenate(
        (np.array([0.0], dtype=np.float64), np.cumsum(effective_volume))
    )
    prefix_price_volume = np.concatenate(
        (np.array([0.0], dtype=np.float64), np.cumsum(typical * effective_volume))
    )
    prefix_squared_volume = np.concatenate(
        (
            np.array([0.0], dtype=np.float64),
            np.cumsum(typical * typical * effective_volume),
        )
    )
    prefix_valid = np.concatenate(
        (np.array([0], dtype=np.int64), np.cumsum(valid_bar.astype(np.int64)))
    )

    vwap = np.full(size, np.nan, dtype=np.float64)
    deviation = np.full(size, np.nan, dtype=np.float64)
    if size >= lookback:
        window_volume = prefix_volume[lookback:] - prefix_volume[:-lookback]
        window_price_volume = (
            prefix_price_volume[lookback:] - prefix_price_volume[:-lookback]
        )
        window_squared_volume = (
            prefix_squared_volume[lookback:] - prefix_squared_volume[:-lookback]
        )
        window_valid = prefix_valid[lookback:] - prefix_valid[:-lookback]
        safe_volume = np.where(window_volume > 0.0, window_volume, 1.0)
        window_vwap = window_price_volume / safe_volume
        window_variance = np.maximum(
            window_squared_volume / safe_volume - window_vwap * window_vwap,
            0.0,
        )
        complete = window_valid == lookback
        vwap[lookback - 1 :] = np.where(complete, window_vwap, np.nan)
        deviation[lookback - 1 :] = np.where(
            complete, np.sqrt(window_variance), np.nan
        )

    upper = vwap + 1.5 * deviation
    lower = vwap - 1.5 * deviation

    turn_lower = np.full(size, np.nan, dtype=np.float64)
    turn_upper = np.full(size, np.nan, dtype=np.float64)
    alpha = 2.0 / 3.0
    for t in range(size):
        if np.isfinite(lower[t]):
            if t == 0 or not np.isfinite(turn_lower[t - 1]):
                turn_lower[t] = lower[t]
            else:
                turn_lower[t] = alpha * lower[t] + (1.0 - alpha) * turn_lower[t - 1]
        if np.isfinite(upper[t]):
            if t == 0 or not np.isfinite(turn_upper[t - 1]):
                turn_upper[t] = upper[t]
            else:
                turn_upper[t] = alpha * upper[t] + (1.0 - alpha) * turn_upper[t - 1]

    lower_delta = np.full(size, np.nan, dtype=np.float64)
    upper_delta = np.full(size, np.nan, dtype=np.float64)
    for t in range(1, size):
        if (
            np.isfinite(turn_lower[t])
            and np.isfinite(turn_lower[t - 1])
            and np.isfinite(atr[t])
            and atr[t] > 0.0
        ):
            lower_delta[t] = (turn_lower[t] - turn_lower[t - 1]) / atr[t]
        if (
            np.isfinite(turn_upper[t])
            and np.isfinite(turn_upper[t - 1])
            and np.isfinite(atr[t])
            and atr[t] > 0.0
        ):
            upper_delta[t] = (turn_upper[t] - turn_upper[t - 1]) / atr[t]

    raw_buy = np.zeros(size, dtype=np.bool_)
    raw_sell = np.zeros(size, dtype=np.bool_)
    for t in range(1, size):
        if np.isfinite(lower_delta[t]) and np.isfinite(lower_delta[t - 1]):
            raw_buy[t] = lower_delta[t] >= 0.015 and lower_delta[t - 1] < 0.015
        if np.isfinite(upper_delta[t]) and np.isfinite(upper_delta[t - 1]):
            raw_sell[t] = upper_delta[t] <= -0.015 and upper_delta[t - 1] > -0.015

    buy_signals = np.zeros(size, dtype=np.bool_)
    sell_signals = np.zeros(size, dtype=np.bool_)
    last_signal_direction = 0
    last_signal_bar = -1
    last_signal_price = np.nan

    for t in range(size):
        bars_separated = (
            last_signal_bar < 0 or t - last_signal_bar >= 4
        )
        move_separated = (
            not np.isfinite(last_signal_price)
            or (
                np.isfinite(closes[t])
                and np.isfinite(atr[t])
                and atr[t] > 0.0
                and abs(closes[t] - last_signal_price) >= 0.25 * atr[t]
            )
        )
        buy_ok = bool(
            raw_buy[t]
            and last_signal_direction != 1
            and bars_separated
            and move_separated
        )
        sell_ok = bool(
            raw_sell[t]
            and last_signal_direction != -1
            and bars_separated
            and move_separated
        )
        buy_signals[t] = buy_ok
        sell_signals[t] = sell_ok
        if buy_ok:
            last_signal_direction = 1
            last_signal_bar = t
            last_signal_price = closes[t]
        elif sell_ok:
            last_signal_direction = -1
            last_signal_bar = t
            last_signal_price = closes[t]

    long_entries = buy_signals.copy()
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    position = 0
    initial_stop = np.nan
    entry_target = np.nan

    for t in range(size):
        exited_this_bar = False

        if position == 1:
            stop_hit = bool(
                np.isfinite(lows[t])
                and np.isfinite(initial_stop)
                and lows[t] <= initial_stop
            )
            target_hit = bool(
                np.isfinite(highs[t])
                and np.isfinite(upper[t])
                and highs[t] >= upper[t]
            )
            sell_exit = bool(sell_signals[t])

            if stop_hit or target_hit or sell_exit:
                long_exits[t] = True
                position = 0
                initial_stop = np.nan
                entry_target = np.nan
                exited_this_bar = True

        if position == 0 and not exited_this_bar and buy_signals[t]:
            if (
                np.isfinite(closes[t])
                and np.isfinite(lower[t])
                and np.isfinite(vwap[t])
                and np.isfinite(upper[t])
                and np.isfinite(atr[t])
                and atr[t] > 0.0
            ):
                candidate_stop = min(
                    lower[t] + (vwap[t] - lower[t]) * 0.15,
                    closes[t] - 0.15 * atr[t],
                )
                if np.isfinite(candidate_stop) and candidate_stop < closes[t]:
                    position = 1
                    initial_stop = candidate_stop
                    entry_target = upper[t]

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'AdaptiveLowerEnvelopeTurnBalanceExit',
    'hypothesis': '下緣包絡由非上升轉為有效上升時建立多頭，以上緣包絡或 SELL 訊號退出，並以固定結構停損保護。',
    'position': 'long',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}