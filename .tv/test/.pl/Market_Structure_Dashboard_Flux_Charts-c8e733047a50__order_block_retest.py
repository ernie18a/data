import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    highs = market.highs
    lows = market.lows
    closes = market.closes

    swing_length = 5
    max_zones = 6
    max_search = 50

    zone_dir = np.zeros(max_zones, dtype=np.int8)
    zone_top = np.full(max_zones, np.nan, dtype=np.float64)
    zone_bottom = np.full(max_zones, np.nan, dtype=np.float64)
    zone_created = np.full(max_zones, -1, dtype=np.int64)
    zone_id = np.zeros(max_zones, dtype=np.int64)
    zone_used = np.zeros(max_zones, dtype=np.bool_)
    zone_count = 0
    next_zone_id = 1

    last_ph = np.nan
    last_ph_bar = -1
    last_pl = np.nan
    last_pl_bar = -1

    position = 0
    position_zone_id = 0
    position_bottom = np.nan
    position_top = np.nan

    for t in range(size):
        if not (
            np.isfinite(highs[t])
            and np.isfinite(lows[t])
            and np.isfinite(closes[t])
        ):
            continue

        exited_this_signal = False

        if t >= 2 * swing_length:
            pivot_bar = t - swing_length
            ph = highs[pivot_bar]
            pl = lows[pivot_bar]
            pivot_high_ok = np.isfinite(ph)
            pivot_low_ok = np.isfinite(pl)
            if pivot_high_ok and pivot_low_ok:
                for offset in range(1, swing_length + 1):
                    if (
                        not np.isfinite(highs[pivot_bar - offset])
                        or not np.isfinite(highs[pivot_bar + offset])
                        or ph <= highs[pivot_bar - offset]
                        or ph <= highs[pivot_bar + offset]
                    ):
                        pivot_high_ok = False
                    if (
                        not np.isfinite(lows[pivot_bar - offset])
                        or not np.isfinite(lows[pivot_bar + offset])
                        or pl >= lows[pivot_bar - offset]
                        or pl >= lows[pivot_bar + offset]
                    ):
                        pivot_low_ok = False
                if pivot_high_ok:
                    last_ph = ph
                    last_ph_bar = pivot_bar
                if pivot_low_ok:
                    last_pl = pl
                    last_pl_bar = pivot_bar

        bull_break = False
        bear_break = False
        bull_pivot_bar = -1
        bear_pivot_bar = -1
        if t > 0 and np.isfinite(closes[t - 1]):
            if np.isfinite(last_ph) and closes[t] > last_ph and closes[t - 1] <= last_ph:
                bull_break = True
                bull_pivot_bar = last_ph_bar
                last_ph = np.nan
                last_ph_bar = -1
            if np.isfinite(last_pl) and closes[t] < last_pl and closes[t - 1] >= last_pl:
                bear_break = True
                bear_pivot_bar = last_pl_bar
                last_pl = np.nan
                last_pl_bar = -1

        for direction, pivot_bar in (
            (1, bull_pivot_bar) if bull_break else (0, -1),
            (-1, bear_pivot_bar) if bear_break else (0, -1),
        ):
            if direction == 0:
                continue
            search_start = max(pivot_bar + 1, t - max_search)
            selected_bar = -1
            if direction == 1:
                selected_price = np.inf
                for bar in range(t, search_start - 1, -1):
                    if np.isfinite(lows[bar]) and lows[bar] < selected_price:
                        selected_price = lows[bar]
                        selected_bar = bar
                if selected_bar < 0 or not np.isfinite(highs[selected_bar]):
                    continue
                new_bottom = lows[selected_bar]
                new_top = highs[selected_bar]
            else:
                selected_price = -np.inf
                for bar in range(t, search_start - 1, -1):
                    if np.isfinite(highs[bar]) and highs[bar] > selected_price:
                        selected_price = highs[bar]
                        selected_bar = bar
                if selected_bar < 0 or not np.isfinite(lows[selected_bar]):
                    continue
                new_top = highs[selected_bar]
                new_bottom = lows[selected_bar]

            if not np.isfinite(new_bottom) or not np.isfinite(new_top):
                continue
            if new_bottom > new_top:
                continue

            overlaps = False
            for zone in range(zone_count):
                if (
                    zone_dir[zone] == direction
                    and new_top >= zone_bottom[zone]
                    and new_bottom <= zone_top[zone]
                ):
                    overlaps = True
                    break
            if overlaps:
                continue

            if zone_count == max_zones:
                for zone in range(max_zones - 1, 0, -1):
                    zone_dir[zone] = zone_dir[zone - 1]
                    zone_top[zone] = zone_top[zone - 1]
                    zone_bottom[zone] = zone_bottom[zone - 1]
                    zone_created[zone] = zone_created[zone - 1]
                    zone_id[zone] = zone_id[zone - 1]
                    zone_used[zone] = zone_used[zone - 1]
            else:
                for zone in range(zone_count, 0, -1):
                    zone_dir[zone] = zone_dir[zone - 1]
                    zone_top[zone] = zone_top[zone - 1]
                    zone_bottom[zone] = zone_bottom[zone - 1]
                    zone_created[zone] = zone_created[zone - 1]
                    zone_id[zone] = zone_id[zone - 1]
                    zone_used[zone] = zone_used[zone - 1]
                zone_count += 1

            zone_dir[0] = direction
            zone_top[0] = new_top
            zone_bottom[0] = new_bottom
            zone_created[0] = t
            zone_id[0] = next_zone_id
            zone_used[0] = False
            next_zone_id += 1

        if position == 1 and closes[t] < position_bottom:
            long_exits[t] = True
            position = 0
            position_zone_id = 0
            position_bottom = np.nan
            position_top = np.nan
            exited_this_signal = True
        elif position == -1 and closes[t] > position_top:
            short_exits[t] = True
            position = 0
            position_zone_id = 0
            position_bottom = np.nan
            position_top = np.nan
            exited_this_signal = True

        zone = 0
        while zone < zone_count:
            mitigated = (
                (zone_dir[zone] == 1 and closes[t] < zone_bottom[zone])
                or (zone_dir[zone] == -1 and closes[t] > zone_top[zone])
            )
            if mitigated:
                for shift in range(zone, zone_count - 1):
                    zone_dir[shift] = zone_dir[shift + 1]
                    zone_top[shift] = zone_top[shift + 1]
                    zone_bottom[shift] = zone_bottom[shift + 1]
                    zone_created[shift] = zone_created[shift + 1]
                    zone_id[shift] = zone_id[shift + 1]
                    zone_used[shift] = zone_used[shift + 1]
                zone_count -= 1
            else:
                zone += 1

        if position == 0 and not exited_this_signal:
            long_candidate = -1
            short_candidate = -1
            for zone in range(zone_count):
                touched = highs[t] >= zone_bottom[zone] and lows[t] <= zone_top[zone]
                if not touched or zone_created[zone] >= t or zone_used[zone]:
                    continue
                if zone_dir[zone] == 1 and long_candidate < 0:
                    long_candidate = zone
                elif zone_dir[zone] == -1 and short_candidate < 0:
                    short_candidate = zone

            if (long_candidate >= 0) != (short_candidate >= 0):
                if long_candidate >= 0:
                    zone = long_candidate
                    long_entries[t] = True
                    zone_used[zone] = True
                    position = 1
                    position_zone_id = int(zone_id[zone])
                    position_bottom = zone_bottom[zone]
                    position_top = zone_top[zone]
                else:
                    zone = short_candidate
                    short_entries[t] = True
                    zone_used[zone] = True
                    position = -1
                    position_zone_id = int(zone_id[zone])
                    position_bottom = zone_bottom[zone]
                    position_top = zone_top[zone]

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "order_block_retest",
    "hypothesis": "價格突破已確認的市場結構後，回測突破所形成的 Order Block 區間可能延續突破方向。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
