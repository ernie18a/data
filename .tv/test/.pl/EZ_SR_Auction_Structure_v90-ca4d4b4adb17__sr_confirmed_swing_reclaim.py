import numpy as np


def _market_array(market, name, size):
    value = getattr(market, name, None)
    if value is None and name == "opens":
        value = getattr(market, "open", None)
    if value is None:
        return None
    array = np.asarray(value, dtype=float)
    if array.ndim != 1 or array.size != size:
        return None
    return array


def _confirmed_pivot(values, bar, strength, is_low):
    center = bar - strength
    left = center - strength
    if left < 0:
        return False
    window = values[left:bar + 1]
    if window.size != 2 * strength + 1 or not np.all(np.isfinite(window)):
        return False
    return values[center] == (np.min(window) if is_low else np.max(window))


def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    params = signal_params or {}
    pivot_strength = max(1, int(params.get("pivot_strength", 3)))
    atr_length = max(1, int(params.get("atr_length", 14)))
    minimum_padding_atr = float(params.get("minimum_padding_atr", 0.10))
    cooldown_bars = max(0, int(params.get("cooldown_bars", 5)))

    market = features.market
    opens = _market_array(market, "opens", size)
    highs = _market_array(market, "highs", size)
    lows = _market_array(market, "lows", size)
    closes = _market_array(market, "closes", size)
    if any(array is None for array in (opens, highs, lows, closes)):
        return long_entries, long_exits, short_entries, short_exits

    atr = np.asarray(features.atr(atr_length), dtype=float)
    if atr.ndim != 1 or atr.size != size:
        return long_entries, long_exits, short_entries, short_exits

    support_top = None
    support_bottom = None
    support_source = None
    resistance_top = None
    resistance_bottom = None
    resistance_source = None

    long_open = False
    long_bound_source = None
    long_bound_bottom = None
    short_open = False
    short_bound_source = None
    short_bound_top = None

    last_long_entry_bar = None
    last_short_entry_bar = None
    last_long_entry_source = None
    last_short_entry_source = None

    for bar in range(size):
        previous_support_source = support_source
        previous_support_bottom = support_bottom
        previous_resistance_source = resistance_source
        previous_resistance_top = resistance_top

        new_support = False
        new_resistance = False

        if _confirmed_pivot(lows, bar, pivot_strength, True):
            source = bar - pivot_strength
            if np.all(np.isfinite((opens[source], closes[source], lows[source], atr[source]))):
                support_bottom = float(lows[source])
                support_top = float(
                    max(
                        min(opens[source], closes[source]),
                        support_bottom + atr[source] * minimum_padding_atr,
                    )
                )
                support_source = source
                new_support = True

        if _confirmed_pivot(highs, bar, pivot_strength, False):
            source = bar - pivot_strength
            if np.all(np.isfinite((opens[source], closes[source], highs[source], atr[source]))):
                resistance_top = float(highs[source])
                resistance_bottom = float(
                    min(
                        max(opens[source], closes[source]),
                        resistance_top - atr[source] * minimum_padding_atr,
                    )
                )
                resistance_source = source
                new_resistance = True

        support_replaced = (
            new_support
            and previous_support_source is not None
            and support_source != previous_support_source
        )
        resistance_replaced = (
            new_resistance
            and previous_resistance_source is not None
            and resistance_source != previous_resistance_source
        )
        support_removed = (
            not new_support
            and previous_support_source is not None
            and np.isfinite(closes[bar])
            and closes[bar] < previous_support_bottom
        )
        resistance_removed = (
            not new_resistance
            and previous_resistance_source is not None
            and np.isfinite(closes[bar])
            and closes[bar] > previous_resistance_top
        )

        if support_removed:
            support_top = None
            support_bottom = None
            support_source = None
        if resistance_removed:
            resistance_top = None
            resistance_bottom = None
            resistance_source = None

        if long_open:
            if (
                support_replaced
                and long_bound_source == previous_support_source
            ) or (
                support_removed
                and long_bound_source == previous_support_source
            ):
                long_exits[bar] = True
                long_open = False
                long_bound_source = None
                long_bound_bottom = None

        if short_open:
            if (
                resistance_replaced
                and short_bound_source == previous_resistance_source
            ) or (
                resistance_removed
                and short_bound_source == previous_resistance_source
            ):
                short_exits[bar] = True
                short_open = False
                short_bound_source = None
                short_bound_top = None

        valid_close = np.isfinite(closes[bar])
        long_candidate = (
            new_support
            and support_source is not None
            and support_top is not None
            and valid_close
            and closes[bar] > support_top
            and (resistance_source is None or support_source > resistance_source)
            and last_long_entry_source != support_source
            and (
                last_long_entry_bar is None
                or bar - last_long_entry_bar >= cooldown_bars
            )
        )
        short_candidate = (
            new_resistance
            and resistance_source is not None
            and resistance_bottom is not None
            and valid_close
            and closes[bar] < resistance_bottom
            and (support_source is None or resistance_source > support_source)
            and last_short_entry_source != resistance_source
            and (
                last_short_entry_bar is None
                or bar - last_short_entry_bar >= cooldown_bars
            )
        )

        if long_candidate:
            long_entries[bar] = True
            long_open = True
            long_bound_source = support_source
            long_bound_bottom = support_bottom
            last_long_entry_bar = bar
            last_long_entry_source = support_source

        if short_candidate:
            short_entries[bar] = True
            short_open = True
            short_bound_source = resistance_source
            short_bound_top = resistance_top
            last_short_entry_bar = bar
            last_short_entry_source = resistance_source

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "sr_confirmed_swing_reclaim",
    "hypothesis": "確認後的當前週期支撐阻力結構在價格 reclaim 時，提供具方向性的雙向交易訊號。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "pivot_strength",
        "atr_length",
        "minimum_padding_atr",
        "cooldown_bars",
    ],
    "signal_parameter_sets": [
        {
            "pivot_strength": 3,
            "atr_length": 14,
            "minimum_padding_atr": 0.10,
            "cooldown_bars": 5,
        }
    ],
}
