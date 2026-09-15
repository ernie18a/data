import numpy as np


def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    if size == 0:
        return long_entries, long_exits, short_entries, short_exits

    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volumes = np.asarray(features.market.volumes, dtype=np.float64)
    atr = np.asarray(features.atr(14), dtype=np.float64)

    lookback = 50
    deviation_multiplier = 1.5
    smoothing_length = 2
    minimum_slope = 0.015
    minimum_bars_between_signals = 4
    minimum_move_atr = 0.25

    market_valid = (
        np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & np.isfinite(volumes)
    )
    typical_price = (highs + lows + closes) / 3.0
    safe_price = np.where(market_valid, typical_price, 0.0)
    safe_volume = np.where(market_valid, np.maximum(volumes, 1.0), 0.0)
    safe_price_volume = safe_price * safe_volume
    safe_price_squared_volume = safe_price * safe_price * safe_volume

    rolling_vwap = np.full(size, np.nan, dtype=np.float64)
    rolling_deviation = np.full(size, np.nan, dtype=np.float64)
    volume_sum = 0.0
    price_volume_sum = 0.0
    price_squared_volume_sum = 0.0
    valid_count = 0

    for t in range(size):
        volume_sum += safe_volume[t]
        price_volume_sum += safe_price_volume[t]
        price_squared_volume_sum += safe_price_squared_volume[t]
        valid_count += int(market_valid[t])

        if t >= lookback:
            volume_sum -= safe_volume[t - lookback]
            price_volume_sum -= safe_price_volume[t - lookback]
            price_squared_volume_sum -= safe_price_squared_volume[t - lookback]
            valid_count -= int(market_valid[t - lookback])

        if t >= lookback - 1 and valid_count == lookback and volume_sum > 0.0:
            vwap = price_volume_sum / volume_sum
            variance = price_squared_volume_sum / volume_sum - vwap * vwap
            rolling_vwap[t] = vwap
            rolling_deviation[t] = np.sqrt(max(variance, 0.0))

    upper = rolling_vwap + deviation_multiplier * rolling_deviation
    lower = rolling_vwap - deviation_multiplier * rolling_deviation

    turn_upper = np.full(size, np.nan, dtype=np.float64)
    turn_lower = np.full(size, np.nan, dtype=np.float64)
    alpha = 2.0 / (smoothing_length + 1.0)
    for t in range(size):
        if np.isfinite(upper[t]):
            if t == 0 or not np.isfinite(turn_upper[t - 1]):
                turn_upper[t] = upper[t]
            else:
                turn_upper[t] = alpha * upper[t] + (1.0 - alpha) * turn_upper[t - 1]
        if np.isfinite(lower[t]):
            if t == 0 or not np.isfinite(turn_lower[t - 1]):
                turn_lower[t] = lower[t]
            else:
                turn_lower[t] = alpha * lower[t] + (1.0 - alpha) * turn_lower[t - 1]

    upper_delta = np.full(size, np.nan, dtype=np.float64)
    lower_delta = np.full(size, np.nan, dtype=np.float64)
    for t in range(1, size):
        if (
            np.isfinite(turn_upper[t])
            and np.isfinite(turn_upper[t - 1])
            and np.isfinite(atr[t])
            and atr[t] > 0.0
        ):
            upper_delta[t] = (turn_upper[t] - turn_upper[t - 1]) / atr[t]
        if (
            np.isfinite(turn_lower[t])
            and np.isfinite(turn_lower[t - 1])
            and np.isfinite(atr[t])
            and atr[t] > 0.0
        ):
            lower_delta[t] = (turn_lower[t] - turn_lower[t - 1]) / atr[t]

    raw_buy = np.zeros(size, dtype=np.bool_)
    raw_sell = np.zeros(size, dtype=np.bool_)
    for t in range(1, size):
        if (
            np.isfinite(lower_delta[t])
            and np.isfinite(lower_delta[t - 1])
            and lower_delta[t] >= minimum_slope
            and lower_delta[t - 1] < minimum_slope
        ):
            raw_buy[t] = True
        if (
            np.isfinite(upper_delta[t])
            and np.isfinite(upper_delta[t - 1])
            and upper_delta[t] <= -minimum_slope
            and upper_delta[t - 1] > -minimum_slope
        ):
            raw_sell[t] = True

    buy_signals = np.zeros(size, dtype=np.bool_)
    sell_signals = np.zeros(size, dtype=np.bool_)
    last_signal_direction = 0
    last_signal_bar = None
    last_signal_price = None

    position_state = 0
    entry_bar = None
    initial_stop = np.nan
    ride_start_bar = None

    for t in range(size):
        atr_ready = np.isfinite(atr[t]) and atr[t] > 0.0
        price_ready = np.isfinite(closes[t]) and atr_ready
        bars_separated = (
            last_signal_bar is None
            or t - last_signal_bar >= minimum_bars_between_signals
        )
        move_separated = (
            last_signal_price is None
            or (
                price_ready
                and abs(closes[t] - last_signal_price) >= minimum_move_atr * atr[t]
            )
        )

        buy_signal = bool(
            raw_buy[t]
            and price_ready
            and last_signal_direction != 1
            and bars_separated
            and move_separated
        )
        sell_signal = bool(
            raw_sell[t]
            and price_ready
            and last_signal_direction != -1
            and bars_separated
            and move_separated
        )
        buy_signals[t] = buy_signal
        sell_signals[t] = sell_signal

        if buy_signal:
            last_signal_direction = 1
            last_signal_bar = t
            last_signal_price = closes[t]
        elif sell_signal:
            last_signal_direction = -1
            last_signal_bar = t
            last_signal_price = closes[t]

        exited_this_bar = False
        if position_state != 0 and entry_bar is not None and t > entry_bar:
            stop_hit = (
                np.isfinite(lows[t])
                and np.isfinite(initial_stop)
                and lows[t] <= initial_stop
            )
            if stop_hit:
                long_exits[t] = True
                position_state = 0
                entry_bar = None
                initial_stop = np.nan
                ride_start_bar = None
                exited_this_bar = True
            elif position_state == 1:
                ride_ready = False
                if t >= 3 and np.isfinite(atr[t]) and atr[t] > 0.0:
                    ride_ready = bool(
                        np.isfinite(closes[t])
                        and np.isfinite(upper[t])
                        and np.isfinite(rolling_vwap[t])
                        and np.isfinite(rolling_vwap[t - 3])
                        and np.isfinite(upper[t - 3])
                        and np.isfinite(lower[t])
                        and np.isfinite(lower[t - 3])
                        and closes[t] > upper[t]
                        and (rolling_vwap[t] - rolling_vwap[t - 3]) / atr[t] >= 0.05
                        and upper[t] > upper[t - 3]
                        and lower[t] > lower[t - 3]
                    )

                if ride_ready:
                    position_state = 2
                    ride_start_bar = t
                else:
                    balance_target_hit = (
                        np.isfinite(highs[t])
                        and np.isfinite(upper[t])
                        and highs[t] >= upper[t]
                    )
                    if balance_target_hit or sell_signals[t]:
                        long_exits[t] = True
                        position_state = 0
                        entry_bar = None
                        initial_stop = np.nan
                        ride_start_bar = None
                        exited_this_bar = True
            else:
                can_exit_ride = (
                    ride_start_bar is not None
                    and t - ride_start_bar >= 1
                )
                back_inside = (
                    np.isfinite(closes[t])
                    and np.isfinite(upper[t])
                    and closes[t] < upper[t]
                )
                wave_reversal = False
                if t >= 3 and np.isfinite(atr[t]) and atr[t] > 0.0:
                    wave_reversal = bool(
                        np.isfinite(rolling_vwap[t])
                        and np.isfinite(rolling_vwap[t - 3])
                        and (rolling_vwap[t] - rolling_vwap[t - 3]) / atr[t] <= -0.03
                    )
                if can_exit_ride and (
                    sell_signals[t] or back_inside or wave_reversal
                ):
                    long_exits[t] = True
                    position_state = 0
                    entry_bar = None
                    initial_stop = np.nan
                    ride_start_bar = None
                    exited_this_bar = True

        if (
            position_state == 0
            and not exited_this_bar
            and buy_signals[t]
            and np.isfinite(lower[t])
            and np.isfinite(rolling_vwap[t])
            and np.isfinite(closes[t])
            and np.isfinite(atr[t])
            and atr[t] > 0.0
        ):
            candidate_stop = min(
                lower[t] + (rolling_vwap[t] - lower[t]) * 0.15,
                closes[t] - 0.15 * atr[t],
            )
            if np.isfinite(candidate_stop) and candidate_stop < closes[t]:
                long_entries[t] = True
                position_state = 1
                entry_bar = t
                initial_stop = candidate_stop
                ride_start_bar = None

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "AdaptiveLowerEnvelopeTurnRideReversal",
    "hypothesis": "下緣包絡帶轉升確認平衡結束，持有至來源定義的趨勢轉換後反轉或回落事件。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
