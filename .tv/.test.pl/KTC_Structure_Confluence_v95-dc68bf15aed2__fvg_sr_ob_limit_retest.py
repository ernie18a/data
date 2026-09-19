import numpy as np


def _array(market, name, size):
    return np.asarray(getattr(market, name), dtype=np.float64).reshape(size)


def _atr(features, highs, lows, closes, length):
    try:
        result = np.asarray(features.atr(length), dtype=np.float64).reshape(highs.size)
        if np.isfinite(result).any():
            return result
    except (AttributeError, TypeError, ValueError):
        pass
    result = np.full(highs.size, np.nan, dtype=np.float64)
    if highs.size == 0:
        return result
    true_range = highs - lows
    if highs.size > 1:
        true_range[1:] = np.maximum(
            true_range[1:], np.abs(highs[1:] - closes[:-1])
        )
        true_range[1:] = np.maximum(
            true_range[1:], np.abs(lows[1:] - closes[:-1])
        )
    for index in range(length - 1, highs.size):
        if index == length - 1:
            result[index] = np.mean(true_range[:length])
        else:
            result[index] = (
                result[index - 1] * (length - 1) + true_range[index]
            ) / length
    return result


def _fvg_on_path(z_top, z_bottom, is_bull, close, fvgs):
    if is_bull:
        band_low, band_high = z_top, close
    else:
        band_low, band_high = close, z_bottom
    if not np.isfinite(band_low) or not np.isfinite(band_high) or band_high <= band_low:
        return False
    for fvg_top, fvg_bottom, fvg_bull, _ in fvgs:
        if min(fvg_top, band_high) > max(fvg_bottom, band_low):
            return True
    return False


def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return long_entries, long_exits, short_entries, short_exits

    market = features.market
    opens = _array(market, "opens", size)
    highs = _array(market, "highs", size)
    lows = _array(market, "lows", size)
    closes = _array(market, "closes", size)
    atr_length = int(signal_params.get("atr_length", 14))
    ob_atr_max = float(signal_params.get("ob_atr_max", 2.0))
    fvg_atr_min = float(signal_params.get("fvg_atr_min", 0.2))
    sr_pivot_length = int(signal_params.get("sr_pivot_length", 7))
    if atr_length < 1 or ob_atr_max <= 0.0 or fvg_atr_min < 0.0 or sr_pivot_length < 1:
        return long_entries, long_exits, short_entries, short_exits
    atr = _atr(features, highs, lows, closes, atr_length)

    fvgs = []
    sr_levels = []
    zones = []
    entry_prices = np.full(size, np.nan, dtype=np.float64)
    stop_prices = np.full(size, np.nan, dtype=np.float64)

    for t in range(size):
        current_atr = atr[t]
        if not np.isfinite(current_atr) or current_atr <= 0.0:
            continue

        pivot = t - sr_pivot_length
        if pivot >= sr_pivot_length:
            window = slice(pivot - sr_pivot_length, pivot + sr_pivot_length + 1)
            if highs[pivot] >= np.max(highs[window]):
                sr_levels.append([float(highs[pivot]), -1])
            if lows[pivot] <= np.min(lows[window]):
                sr_levels.append([float(lows[pivot]), 1])

        for level in sr_levels:
            if level[1] == -1 and closes[t] > level[0]:
                level[1] = 0
            elif level[1] == 1 and closes[t] < level[0]:
                level[1] = 0
        sr_levels = [level for level in sr_levels if level[1] != 0]

        new_fvgs = []
        if t >= 2:
            bull_width = lows[t] - highs[t - 2]
            bear_width = lows[t - 2] - highs[t]
            if bull_width > 0.0 and bull_width >= current_atr * fvg_atr_min:
                new_fvgs.append([float(lows[t]), float(highs[t - 2]), True, t])
            if bear_width > 0.0 and bear_width >= current_atr * fvg_atr_min:
                new_fvgs.append([float(lows[t - 2]), float(highs[t]), False, t])
        fvgs.extend(new_fvgs)

        live_fvgs = []
        for fvg_top, fvg_bottom, is_bull, born in fvgs:
            if is_bull:
                if lows[t] <= fvg_bottom:
                    continue
                if lows[t] < fvg_top:
                    fvg_top = float(lows[t])
            else:
                if highs[t] >= fvg_top:
                    continue
                if highs[t] > fvg_bottom:
                    fvg_bottom = float(highs[t])
            if fvg_top > fvg_bottom:
                live_fvgs.append([fvg_top, fvg_bottom, is_bull, born])
        fvgs = live_fvgs

        candidates = []
        if t >= 2:
            ob_width = highs[t - 2] - lows[t - 2]
            bull_ob = (
                opens[t - 2] > closes[t - 2]
                and closes[t - 1] > opens[t - 1]
                and lows[t] > highs[t - 2]
            )
            bear_ob = (
                opens[t - 2] < closes[t - 2]
                and closes[t - 1] < opens[t - 1]
                and highs[t] < lows[t - 2]
            )
            if bull_ob and 0.0 < ob_width < current_atr * ob_atr_max:
                candidates.append((float(highs[t - 2]), float(lows[t - 2]), True, t))
            if bear_ob and 0.0 < ob_width < current_atr * ob_atr_max:
                candidates.append((float(highs[t - 2]), float(lows[t - 2]), False, t))
            candidates.extend(
                (top, bottom, is_bull, born)
                for top, bottom, is_bull, born in new_fvgs
            )

        for z_top, z_bottom, is_bull, born in candidates:
            if z_top <= z_bottom or not _fvg_on_path(
                z_top, z_bottom, is_bull, closes[t], fvgs
            ):
                continue
            if not any(
                level[1] != 0 and z_bottom <= level[0] <= z_top
                for level in sr_levels
            ):
                continue
            entry = z_top if is_bull else z_bottom
            if (is_bull and entry >= closes[t]) or (not is_bull and entry <= closes[t]):
                continue
            zones.append({"top": z_top, "bottom": z_bottom, "bull": is_bull, "born": born})

        filled = []
        remaining = []
        for zone in zones:
            entry = zone["top"] if zone["bull"] else zone["bottom"]
            invalid = (zone["bull"] and lows[t] < zone["bottom"]) or (
                not zone["bull"] and highs[t] > zone["top"]
            )
            hit = zone["born"] < t and lows[t] <= entry <= highs[t]
            if hit and not invalid:
                filled.append(zone)
            elif not invalid:
                remaining.append(zone)
        zones = remaining
        if filled:
            directions = {zone["bull"] for zone in filled}
            if len(directions) == 1:
                chosen = max(filled, key=lambda zone: zone["born"])
                entry = chosen["top"] if chosen["bull"] else chosen["bottom"]
                stop = chosen["bottom"] if chosen["bull"] else chosen["top"]
                entry_prices[t] = entry
                stop_prices[t] = stop
                if chosen["bull"]:
                    long_entries[t] = True
                else:
                    short_entries[t] = True

    position = 0
    entry_bar = -1
    entry = stop = tp1 = tp2 = tp3 = 0.0
    breakeven_on = False
    for t in range(size):
        if position == 1 and t > entry_bar:
            if highs[t] >= tp1:
                breakeven_on = True
            active_stop = entry if breakeven_on else stop
            if lows[t] <= active_stop or highs[t] >= tp3:
                long_exits[t] = True
                position = 0
        elif position == -1 and t > entry_bar:
            if lows[t] <= tp1:
                breakeven_on = True
            active_stop = entry if breakeven_on else stop
            if highs[t] >= active_stop or lows[t] <= tp3:
                short_exits[t] = True
                position = 0

        if position == 0:
            if long_entries[t] and not short_entries[t]:
                position = 1
                entry_bar = t
                entry = entry_prices[t]
                stop = stop_prices[t]
                risk = abs(entry - stop)
                tp1, tp2, tp3 = entry + risk, entry + risk * 2.0, entry + risk * 3.0
                breakeven_on = False
            elif short_entries[t] and not long_entries[t]:
                position = -1
                entry_bar = t
                entry = entry_prices[t]
                stop = stop_prices[t]
                risk = abs(entry - stop)
                tp1, tp2, tp3 = entry - risk, entry - risk * 2.0, entry - risk * 3.0
                breakeven_on = False

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "fvg_sr_ob_limit_retest",
    "hypothesis": "FVG 路徑與 S/R 共振的 OB/FVG 回測近端邊界可提供具風險回報優勢的雙向進場。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["atr_length", "ob_atr_max", "fvg_atr_min", "sr_pivot_length"],
    "signal_parameter_sets": [{"atr_length": 14, "ob_atr_max": 2.0, "fvg_atr_min": 0.2, "sr_pivot_length": 7}],
}
