import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    if size == 0:
        return long_entries, long_exits, short_entries, short_exits

    pivot_strength = 3
    atr_length = 14
    minimum_padding_atr = 0.10
    micro_length = 2
    instant_max_bars = 1
    rejection_wick_body = 1.20
    strong_close_location = 0.65
    displacement_atr = 0.80
    displacement_body_pct = 0.60
    entry_cooldown = 5

    opens = market.opens
    highs = market.highs
    lows = market.lows
    closes = market.closes
    atr = features.atr(atr_length)

    support_top = np.nan
    support_bottom = np.nan
    support_origin = -1
    resistance_top = np.nan
    resistance_bottom = np.nan
    resistance_origin = -1

    forming_direction = 0
    forming_top = np.nan
    forming_bottom = np.nan
    forming_origin = -1
    forming_signal_taken = False

    active_direction = 0
    active_top = np.nan
    active_bottom = np.nan
    active_origin = -1
    active_validated = False

    last_long_entry = -1
    last_short_entry = -1

    for t in range(size):
        new_support = False
        new_resistance = False
        pivot_anchor = t - pivot_strength

        if pivot_anchor >= pivot_strength:
            atr_anchor = atr[pivot_anchor]
            pivot_window_start = t - 2 * pivot_strength
            pivot_window = lows[pivot_window_start : t + 1]
            high_window = highs[pivot_window_start : t + 1]
            ready = (
                np.isfinite(atr_anchor)
                and np.isfinite(opens[pivot_anchor])
                and np.isfinite(highs[pivot_anchor])
                and np.isfinite(lows[pivot_anchor])
                and np.isfinite(closes[pivot_anchor])
                and np.all(np.isfinite(pivot_window))
                and np.all(np.isfinite(high_window))
            )
            if ready and lows[pivot_anchor] <= np.min(pivot_window):
                body_low = min(opens[pivot_anchor], closes[pivot_anchor])
                support_bottom = lows[pivot_anchor]
                support_top = max(
                    body_low, support_bottom + minimum_padding_atr * atr_anchor
                )
                support_origin = pivot_anchor
                new_support = True
            if ready and highs[pivot_anchor] >= np.max(high_window):
                body_high = max(opens[pivot_anchor], closes[pivot_anchor])
                resistance_top = highs[pivot_anchor]
                resistance_bottom = min(
                    body_high, resistance_top - minimum_padding_atr * atr_anchor
                )
                resistance_origin = pivot_anchor
                new_resistance = True

        if not new_support and np.isfinite(support_bottom) and closes[t] < support_bottom:
            support_top = np.nan
            support_bottom = np.nan
            support_origin = -1
        if not new_resistance and np.isfinite(resistance_top) and closes[t] > resistance_top:
            resistance_top = np.nan
            resistance_bottom = np.nan
            resistance_origin = -1

        low_event = False
        high_event = False
        if t >= pivot_strength:
            low_window = lows[t - pivot_strength : t + 1]
            high_window = highs[t - pivot_strength : t + 1]
            ready = (
                np.isfinite(opens[t])
                and np.isfinite(highs[t])
                and np.isfinite(lows[t])
                and np.isfinite(closes[t])
                and np.isfinite(atr[t])
            )
            low_event = ready and np.all(np.isfinite(low_window)) and lows[t] <= np.min(low_window)
            high_event = ready and np.all(np.isfinite(high_window)) and highs[t] >= np.max(high_window)

        if not (low_event and high_event) and not forming_signal_taken:
            if low_event:
                forming_direction = 1
                forming_origin = t
                forming_bottom = lows[t]
                forming_top = max(
                    min(opens[t], closes[t]),
                    lows[t] + minimum_padding_atr * atr[t],
                )
            elif high_event:
                forming_direction = -1
                forming_origin = t
                forming_top = highs[t]
                forming_bottom = min(
                    max(opens[t], closes[t]),
                    highs[t] - minimum_padding_atr * atr[t],
                )

        low_confirmed = (
            forming_direction == 1
            and forming_origin >= 0
            and support_origin == forming_origin
        )
        high_confirmed = (
            forming_direction == -1
            and forming_origin >= 0
            and resistance_origin == forming_origin
        )

        if low_confirmed:
            if active_direction == 1 and not active_validated and active_origin == forming_origin:
                active_top = support_top
                active_bottom = support_bottom
                active_validated = True
            forming_direction = 0
            forming_top = np.nan
            forming_bottom = np.nan
            forming_origin = -1
            forming_signal_taken = False
        if high_confirmed:
            if active_direction == -1 and not active_validated and active_origin == forming_origin:
                active_top = resistance_top
                active_bottom = resistance_bottom
                active_validated = True
            forming_direction = 0
            forming_top = np.nan
            forming_bottom = np.nan
            forming_origin = -1
            forming_signal_taken = False

        if (
            forming_direction != 0
            and not forming_signal_taken
            and forming_origin >= 0
            and t - forming_origin > pivot_strength
        ):
            forming_direction = 0
            forming_top = np.nan
            forming_bottom = np.nan
            forming_origin = -1

        if support_origin >= 0 and (resistance_origin < 0 or support_origin > resistance_origin):
            confirmed_bias = 1
        elif resistance_origin >= 0 and (support_origin < 0 or resistance_origin > support_origin):
            confirmed_bias = -1
        else:
            confirmed_bias = 0

        live_bias = forming_direction if forming_direction != 0 else confirmed_bias
        long_bias_ok = live_bias == 1
        short_bias_ok = live_bias == -1
        long_direction_ok = active_direction != -1
        short_direction_ok = active_direction != 1

        reaction_ready = (
            np.isfinite(opens[t])
            and np.isfinite(highs[t])
            and np.isfinite(lows[t])
            and np.isfinite(closes[t])
            and np.isfinite(atr[t])
            and highs[t] - lows[t] > 0.0
        )
        bull_reaction = False
        bear_reaction = False
        if reaction_ready:
            candle_range = highs[t] - lows[t]
            body = abs(closes[t] - opens[t])
            upper_wick = highs[t] - max(opens[t], closes[t])
            lower_wick = min(opens[t], closes[t]) - lows[t]
            close_location = (closes[t] - lows[t]) / candle_range
            bull_reject = (
                closes[t] > opens[t]
                and lower_wick >= body * rejection_wick_body
                and close_location >= strong_close_location
            )
            bear_reject = (
                closes[t] < opens[t]
                and upper_wick >= body * rejection_wick_body
                and close_location <= 1.0 - strong_close_location
            )
            bull_displacement = (
                closes[t] > opens[t]
                and candle_range >= atr[t] * displacement_atr
                and body / candle_range >= displacement_body_pct
            )
            bear_displacement = (
                closes[t] < opens[t]
                and candle_range >= atr[t] * displacement_atr
                and body / candle_range >= displacement_body_pct
            )
            bull_micro_shift = t >= micro_length and closes[t] > np.max(highs[t - micro_length : t])
            bear_micro_shift = t >= micro_length and closes[t] < np.min(lows[t - micro_length : t])
            bull_reaction = bull_reject or bull_displacement or bull_micro_shift
            bear_reaction = bear_reject or bear_displacement or bear_micro_shift

        long_cooldown_ok = last_long_entry < 0 or t - last_long_entry >= entry_cooldown
        short_cooldown_ok = last_short_entry < 0 or t - last_short_entry >= entry_cooldown
        forming_age = t - forming_origin if forming_direction != 0 and forming_origin >= 0 else -1

        forming_long = (
            forming_direction == 1
            and 0 <= forming_age <= instant_max_bars
            and long_direction_ok
            and long_bias_ok
            and not forming_signal_taken
            and bull_reaction
            and np.isfinite(forming_top)
            and closes[t] > forming_top
            and long_cooldown_ok
        )
        forming_short = (
            forming_direction == -1
            and 0 <= forming_age <= instant_max_bars
            and short_direction_ok
            and short_bias_ok
            and not forming_signal_taken
            and bear_reaction
            and np.isfinite(forming_bottom)
            and closes[t] < forming_bottom
            and short_cooldown_ok
        )

        exact_live_long = active_direction == 1 and active_origin >= 0 and support_origin == active_origin
        exact_live_short = active_direction == -1 and active_origin >= 0 and resistance_origin == active_origin

        confirmed_long = (
            not forming_long
            and new_support
            and long_direction_ok
            and confirmed_bias == 1
            and not exact_live_long
            and np.isfinite(support_top)
            and np.isfinite(support_bottom)
            and closes[t] > support_top
            and long_cooldown_ok
        )
        confirmed_short = (
            not forming_short
            and new_resistance
            and short_direction_ok
            and confirmed_bias == -1
            and not exact_live_short
            and np.isfinite(resistance_top)
            and np.isfinite(resistance_bottom)
            and closes[t] < resistance_bottom
            and short_cooldown_ok
        )

        long_invalid = (
            active_direction == 1
            and (
                np.isfinite(active_bottom) and closes[t] < active_bottom
                or active_validated and active_origin >= 0 and support_origin != active_origin
                or forming_signal_taken and not active_validated and forming_origin >= 0
                and t - forming_origin > pivot_strength + 2
            )
        )
        short_invalid = (
            active_direction == -1
            and (
                np.isfinite(active_top) and closes[t] > active_top
                or active_validated and active_origin >= 0 and resistance_origin != active_origin
                or forming_signal_taken and not active_validated and forming_origin >= 0
                and t - forming_origin > pivot_strength + 2
            )
        )

        if long_invalid:
            long_exits[t] = True
            active_direction = 0
            active_top = np.nan
            active_bottom = np.nan
            active_origin = -1
            active_validated = False
            forming_direction = 0
            forming_top = np.nan
            forming_bottom = np.nan
            forming_origin = -1
            forming_signal_taken = False
        if short_invalid:
            short_exits[t] = True
            active_direction = 0
            active_top = np.nan
            active_bottom = np.nan
            active_origin = -1
            active_validated = False
            forming_direction = 0
            forming_top = np.nan
            forming_bottom = np.nan
            forming_origin = -1
            forming_signal_taken = False

        if forming_long or confirmed_long:
            long_entries[t] = True
            last_long_entry = t
            active_direction = 1
            active_origin = forming_origin if forming_long else support_origin
            active_top = forming_top if forming_long else support_top
            active_bottom = forming_bottom if forming_long else support_bottom
            active_validated = not forming_long
            if forming_long:
                forming_signal_taken = True
        elif forming_short or confirmed_short:
            short_entries[t] = True
            last_short_entry = t
            active_direction = -1
            active_origin = forming_origin if forming_short else resistance_origin
            active_top = forming_top if forming_short else resistance_top
            active_bottom = forming_bottom if forming_short else resistance_bottom
            active_validated = not forming_short
            if forming_short:
                forming_signal_taken = True

        if (
            forming_signal_taken
            and not active_validated
            and forming_origin >= 0
            and t - forming_origin > pivot_strength + 2
        ):
            if active_origin == forming_origin:
                active_direction = 0
                active_top = np.nan
                active_bottom = np.nan
                active_origin = -1
                active_validated = False
            forming_direction = 0
            forming_top = np.nan
            forming_bottom = np.nan
            forming_origin = -1
            forming_signal_taken = False

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "sr_swing_reaction",
    "hypothesis": "Chart-timeframe support or resistance structure combined with a fresh swing reaction produces directional entries, with the originating structure governing invalidation.",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
