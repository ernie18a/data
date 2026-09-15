import numpy as np

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    if size == 0:
        return long_entries, long_exits, short_entries, short_exits

    lookback = 50
    turn_length = 2
    atr_length = 14
    slope_threshold = 0.015
    minimum_bars = 4
    minimum_move_atr = 0.25
    deviation_multiplier = 1.5
    stop_inside_fraction = 0.15
    stop_atr_fraction = 0.15

    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volumes = np.asarray(features.market.volumes, dtype=np.float64)
    atr = np.asarray(features.atr(atr_length), dtype=np.float64)

    if (
        highs.size != size
        or lows.size != size
        or closes.size != size
        or volumes.size != size
        or atr.size != size
    ):
        return long_entries, long_exits, short_entries, short_exits

    typical = (highs + lows + closes) / 3.0
    valid_bar = (
        np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & np.isfinite(volumes)
        & np.isfinite(typical)
    )
    effective_volume = np.where(
        valid_bar, np.maximum(volumes, 1.0), 0.0
    )
    safe_typical = np.where(valid_bar, typical, 0.0)
    weighted_price = safe_typical * effective_volume
    weighted_square = safe_typical * safe_typical * effective_volume

    cumulative_volume = np.concatenate(
        (np.array([0.0]), np.cumsum(effective_volume))
    )
    cumulative_price = np.concatenate(
        (np.array([0.0]), np.cumsum(weighted_price))
    )
    cumulative_square = np.concatenate(
        (np.array([0.0]), np.cumsum(weighted_square))
    )
    cumulative_valid = np.concatenate(
        (np.array([0], dtype=np.int64), np.cumsum(valid_bar.astype(np.int64)))
    )

    rolling_vwap = np.full(size, np.nan, dtype=np.float64)
    rolling_deviation = np.full(size, np.nan, dtype=np.float64)
    lower = np.full(size, np.nan, dtype=np.float64)
    upper = np.full(size, np.nan, dtype=np.float64)

    for t in range(lookback - 1, size):
        left = t + 1 - lookback
        right = t + 1
        if cumulative_valid[right] - cumulative_valid[left] != lookback:
            continue
        volume_sum = cumulative_volume[right] - cumulative_volume[left]
        if not np.isfinite(volume_sum) or volume_sum <= 0.0:
            continue
        price_sum = cumulative_price[right] - cumulative_price[left]
        square_sum = cumulative_square[right] - cumulative_square[left]
        vwap = price_sum / volume_sum
        variance = max(square_sum / volume_sum - vwap * vwap, 0.0)
        deviation = np.sqrt(variance)
        if np.isfinite(vwap) and np.isfinite(deviation):
            rolling_vwap[t] = vwap
            rolling_deviation[t] = deviation
            upper[t] = vwap + deviation_multiplier * deviation
            lower[t] = vwap - deviation_multiplier * deviation

    turn_lower = np.full(size, np.nan, dtype=np.float64)
    turn_upper = np.full(size, np.nan, dtype=np.float64)
    alpha = 2.0 / (turn_length + 1.0)
    for t in range(size):
        if np.isfinite(lower[t]):
            if t > 0 and np.isfinite(turn_lower[t - 1]):
                turn_lower[t] = (
                    alpha * lower[t] + (1.0 - alpha) * turn_lower[t - 1]
                )
            else:
                turn_lower[t] = lower[t]
        if np.isfinite(upper[t]):
            if t > 0 and np.isfinite(turn_upper[t - 1]):
                turn_upper[t] = (
                    alpha * upper[t] + (1.0 - alpha) * turn_upper[t - 1]
                )
            else:
                turn_upper[t] = upper[t]

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

    last_signal_direction = 0
    last_signal_bar = -1
    last_signal_price = np.nan
    position = 0
    entry_signal_bar = -1
    initial_stop = np.nan
    minimum_ready_bar = lookback + atr_length

    for t in range(size):
        if t < minimum_ready_bar:
            continue
        if not (
            np.isfinite(closes[t])
            and np.isfinite(lows[t])
            and np.isfinite(atr[t])
            and atr[t] > 0.0
            and np.isfinite(lower_delta[t])
            and np.isfinite(upper_delta[t])
            and np.isfinite(lower_delta[t - 1])
            and np.isfinite(upper_delta[t - 1])
            and np.isfinite(rolling_vwap[t])
            and np.isfinite(lower[t])
        ):
            continue

        raw_buy = (
            lower_delta[t] >= slope_threshold
            and lower_delta[t - 1] < slope_threshold
        )
        raw_sell = (
            upper_delta[t] <= -slope_threshold
            and upper_delta[t - 1] > -slope_threshold
        )
        bars_separated = (
            last_signal_bar < 0
            or t - last_signal_bar >= minimum_bars
        )
        move_separated = (
            not np.isfinite(last_signal_price)
            or abs(closes[t] - last_signal_price)
            >= minimum_move_atr * atr[t]
        )
        buy_signal = (
            raw_buy
            and last_signal_direction != 1
            and bars_separated
            and move_separated
        )
        sell_signal = (
            raw_sell
            and last_signal_direction != -1
            and bars_separated
            and move_separated
        )

        if buy_signal:
            last_signal_direction = 1
            last_signal_bar = t
            last_signal_price = closes[t]
        elif sell_signal:
            last_signal_direction = -1
            last_signal_bar = t
            last_signal_price = closes[t]

        exit_event = False
        if position == 1 and t > entry_signal_bar:
            stop_hit = lows[t] <= initial_stop
            if stop_hit or sell_signal:
                long_exits[t] = True
                exit_event = True
                position = 0
                entry_signal_bar = -1
                initial_stop = np.nan

        if position == 0 and not exit_event and buy_signal:
            candidate_stop = min(
                lower[t] + (rolling_vwap[t] - lower[t]) * stop_inside_fraction,
                closes[t] - stop_atr_fraction * atr[t],
            )
            if np.isfinite(candidate_stop) and candidate_stop < closes[t]:
                long_entries[t] = True
                position = 1
                entry_signal_bar = t
                initial_stop = candidate_stop

    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    "strategy_id": "AdaptiveLowerEnvelopeTurnSignalExit",
    "hypothesis": "Lower VWAP envelope turning upward after a non-rising phase marks selective long entries, managed by the source fixed protective stop or opposing upper-envelope turn.",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
