import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    opens = market.opens
    highs = market.highs
    lows = market.lows
    closes = market.closes

    max_fvgs = 6
    zones = []
    position = 0
    held_zones = []
    pending_side = 0
    pending_zones = []

    for t in range(size):
        exited_now = False

        if pending_side != 0:
            if position == 0:
                position = pending_side
                held_zones = pending_zones
            pending_side = 0
            pending_zones = []

        if position == 1:
            if np.isfinite(lows[t]):
                for zone in held_zones:
                    if lows[t] < zone[1]:
                        long_exits[t] = True
                        position = 0
                        held_zones = []
                        exited_now = True
                        break
        elif position == -1:
            if np.isfinite(highs[t]):
                for zone in held_zones:
                    if highs[t] > zone[2]:
                        short_exits[t] = True
                        position = 0
                        held_zones = []
                        exited_now = True
                        break

        new_zone = None
        if t >= 3:
            values_ready = (
                np.isfinite(opens[t - 2])
                and np.isfinite(closes[t - 3])
                and np.isfinite(closes[t - 2])
                and np.isfinite(highs[t - 3])
                and np.isfinite(highs[t - 2])
                and np.isfinite(lows[t - 3])
                and np.isfinite(lows[t - 2])
                and np.isfinite(lows[t - 1])
                and np.isfinite(highs[t - 1])
            )
            if values_ready:
                green = (
                    closes[t - 2] > opens[t - 2]
                    or closes[t - 2] > closes[t - 3]
                )
                red = (
                    closes[t - 2] < opens[t - 2]
                    or closes[t - 2] < closes[t - 3]
                )

                if (
                    lows[t - 1] > highs[t - 3]
                    and green
                    and lows[t - 1] < highs[t - 2]
                    and lows[t - 2] < highs[t - 3]
                ):
                    new_zone = (1, highs[t - 3], lows[t - 1], t)
                elif (
                    highs[t - 1] < lows[t - 3]
                    and red
                    and highs[t - 1] > lows[t - 2]
                    and highs[t - 2] > lows[t - 3]
                ):
                    new_zone = (-1, highs[t - 1], lows[t - 3], t)

        if new_zone is not None:
            zones.append(new_zone)
            if len(zones) > max_fvgs:
                zones.pop(0)

        if np.isfinite(lows[t]) or np.isfinite(highs[t]):
            remaining_zones = []
            for zone in zones:
                mitigated = (
                    zone[0] == 1
                    and np.isfinite(lows[t])
                    and lows[t] < zone[1]
                ) or (
                    zone[0] == -1
                    and np.isfinite(highs[t])
                    and highs[t] > zone[2]
                )
                if not mitigated:
                    remaining_zones.append(zone)
            zones = remaining_zones

        bullish_triggers = []
        bearish_triggers = []
        if not exited_now and position == 0:
            if np.isfinite(lows[t]) and np.isfinite(highs[t]):
                for zone in zones:
                    if zone[3] == t:
                        continue
                    if (
                        zone[0] == 1
                        and lows[t] >= zone[1]
                        and lows[t] <= zone[2]
                        and highs[t] >= zone[1]
                    ):
                        bullish_triggers.append(zone)
                    elif (
                        zone[0] == -1
                        and highs[t] <= zone[2]
                        and lows[t] <= zone[2]
                        and highs[t] >= zone[1]
                    ):
                        bearish_triggers.append(zone)

        if bullish_triggers and not bearish_triggers:
            long_entries[t] = True
            pending_side = 1
            pending_zones = list(bullish_triggers)
            zones = [zone for zone in zones if zone not in bullish_triggers]
        elif bearish_triggers and not bullish_triggers:
            short_entries[t] = True
            pending_side = -1
            pending_zones = list(bearish_triggers)
            zones = [zone for zone in zones if zone not in bearish_triggers]

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "fair_value_gap_retest",
    "hypothesis": "三 K 棒位移形成的公平價值缺口，價格首次回測缺口時順勢進場，缺口 wick mitigation 出場。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}