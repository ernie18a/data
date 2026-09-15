import numpy as np


def _path_has_fvg(fvgs, bull, zone_top, zone_bottom, close):
    if bull:
        band_low, band_high = zone_top, close
    else:
        band_low, band_high = close, zone_bottom
    if band_high <= band_low:
        return False
    for fvg in fvgs:
        if fvg["bull"] != bull:
            continue
        if fvg["top"] >= fvg["bottom"] and fvg["bottom"] <= band_high and fvg["top"] >= band_low:
            return True
    return False


def _sr_in_zone(levels, top, bottom, tolerance):
    for level in levels:
        if level["state"] == 0 and bottom - tolerance <= level["price"] <= top + tolerance:
            return True
    return False


def _add_sr(levels, level_type, wick, body, atr):
    merge_distance = 0.20 * atr
    for level in levels:
        if level["type"] != level_type or level["state"] != 0:
            continue
        if abs(level["price"] - wick) > merge_distance:
            continue
        if level_type == 1:
            candidate = min(level["price"], wick)
            level["price"] = max(candidate, level["origin"] - atr)
            level["body"] = min(level["body"], body)
        else:
            candidate = max(level["price"], wick)
            level["price"] = min(candidate, level["origin"] + atr)
            level["body"] = max(level["body"], body)
        return
    levels.append(
        {
            "type": level_type,
            "price": wick,
            "body": body,
            "origin": wick,
            "state": 0,
            "break_t": -1,
            "flipped": False,
        }
    )


def _update_sr(levels, t, opens, highs, lows, closes, atr):
    if t >= 7 and np.isfinite(atr[t]) and atr[t] > 0.0:
        pivot = t - 7
        left_high = np.max(highs[pivot - 7:pivot]) if pivot >= 7 else np.nan
        right_high = np.max(highs[pivot + 1:t + 1])
        if pivot >= 7 and highs[pivot] > left_high and highs[pivot] > right_high:
            body = max(opens[pivot], closes[pivot])
            wick = body if highs[pivot] - body > 2.0 * atr[t] else highs[pivot]
            _add_sr(levels, -1, wick, body, atr[t])
        left_low = np.min(lows[pivot - 7:pivot]) if pivot >= 7 else np.nan
        right_low = np.min(lows[pivot + 1:t + 1])
        if pivot >= 7 and lows[pivot] < left_low and lows[pivot] < right_low:
            body = min(opens[pivot], closes[pivot])
            wick = body if body - lows[pivot] > 2.0 * atr[t] else lows[pivot]
            _add_sr(levels, 1, wick, body, atr[t])

    kept = []
    for level in levels:
        if level["state"] == 0:
            break_price = (level["price"] + level["body"]) / 2.0
            body_ok = abs(closes[t] - opens[t]) >= 0.20 * atr[t]
            resistance_broken = level["type"] == -1 and closes[t] > break_price + 0.10 * atr[t] and body_ok
            support_broken = level["type"] == 1 and closes[t] < break_price - 0.10 * atr[t] and body_ok
            if resistance_broken or support_broken:
                if level["flipped"]:
                    continue
                level["state"] = 1
                level["break_t"] = t
            
        if level["state"] == 1:
            if t - level["break_t"] > 25:
                continue
            if t > level["break_t"]:
                tolerance = 0.15 * atr[t]
                touched = lows[t] <= level["body"] + tolerance and highs[t] >= level["body"] - tolerance
                if touched and level["type"] == -1 and closes[t] > level["price"]:
                    level["type"] = 1
                    level["state"] = 0
                    level["flipped"] = True
                    level["break_t"] = -1
                elif touched and level["type"] == 1 and closes[t] < level["price"]:
                    level["type"] = -1
                    level["state"] = 0
                    level["flipped"] = True
                    level["break_t"] = -1
        kept.append(level)
    levels[:] = kept


def _update_fvgs(fvgs, t, highs, lows, atr):
    if t >= 2 and np.isfinite(atr[t]) and atr[t] > 0.0:
        bull_size = lows[t] - highs[t - 2]
        bear_size = lows[t - 2] - highs[t]
        if lows[t] > highs[t - 2] and bull_size >= 0.20 * atr[t]:
            fvgs.append({"bull": True, "top": lows[t], "bottom": highs[t - 2]})
        if highs[t] < lows[t - 2] and bear_size >= 0.20 * atr[t]:
            fvgs.append({"bull": False, "top": lows[t - 2], "bottom": highs[t]})

    kept = []
    for fvg in fvgs:
        if fvg["bull"]:
            if lows[t] < fvg["top"] and lows[t] > fvg["bottom"]:
                fvg["top"] = lows[t]
            if lows[t] <= fvg["bottom"]:
                continue
        else:
            if highs[t] > fvg["bottom"] and highs[t] < fvg["top"]:
                fvg["bottom"] = highs[t]
            if highs[t] >= fvg["top"]:
                continue
        kept.append(fvg)
    fvgs[:] = kept


def _update_trade(trade, t, highs, lows):
    if trade is None or t <= trade["entry_t"]:
        return False
    if trade["bull"]:
        if highs[t] >= trade["tp1"]:
            trade["be_moved"] = True
        stop = trade["be"] if trade["be_moved"] else trade["stop"]
        stop_hit = lows[t] <= stop
        tp3_hit = highs[t] >= trade["tp3"]
    else:
        if lows[t] <= trade["tp1"]:
            trade["be_moved"] = True
        stop = trade["be"] if trade["be_moved"] else trade["stop"]
        stop_hit = highs[t] >= stop
        tp3_hit = lows[t] <= trade["tp3"]
    return stop_hit or tp3_hit


def _make_trade(zone, t):
    entry = zone["entry"]
    stop = zone["stop"]
    direction = 1 if zone["bull"] else -1
    risk = abs(entry - stop)
    return {
        "bull": zone["bull"],
        "entry_t": t,
        "stop": stop,
        "be": entry + direction * 0.50,
        "tp1": entry + direction * risk,
        "tp3": entry + direction * risk * 3.0,
        "be_moved": False,
    }


def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    opens = market.opens
    highs = market.highs
    lows = market.lows
    closes = market.closes
    atr = features.atr(14)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    fvgs = []
    levels = []
    zones = []
    trade = None

    for t in range(size):
        if _update_trade(trade, t, highs, lows):
            if trade["bull"]:
                long_exits[t] = True
            else:
                short_exits[t] = True
            trade = None

        if not np.isfinite(atr[t]) or atr[t] <= 0.0:
            continue

        _update_sr(levels, t, opens, highs, lows, closes, atr)
        _update_fvgs(fvgs, t, highs, lows, atr)

        triggered = []
        for zone in zones:
            if zone["born"] < t and lows[t] <= zone["entry"] <= highs[t]:
                triggered.append(zone)
        if triggered:
            long_hit = any(zone["bull"] for zone in triggered)
            short_hit = any(not zone["bull"] for zone in triggered)
            zones[:] = [zone for zone in zones if zone not in triggered]
            if long_hit != short_hit:
                selected = triggered[0]
                if selected["bull"]:
                    long_entries[t] = True
                else:
                    short_entries[t] = True
                trade = _make_trade(selected, t)

        if t < 2:
            continue
        bull_ob = closes[t - 2] < opens[t - 2] and closes[t - 1] > opens[t - 1] and lows[t] > highs[t - 2]
        bear_ob = closes[t - 2] > opens[t - 2] and closes[t - 1] < opens[t - 1] and highs[t] < lows[t - 2]
        narrow = highs[t - 2] - lows[t - 2] < 2.0 * atr[t]
        if narrow and bull_ob:
            top = highs[t - 2]
            bottom = lows[t - 2]
            if _path_has_fvg(fvgs, True, top, bottom, closes[t]) and _sr_in_zone(levels, top, bottom, 250.0 * 0.01):
                zones.append(
                    {
                        "bull": True,
                        "top": top,
                        "bottom": bottom,
                        "entry": top,
                        "stop": bottom - 60.0 * 0.01,
                        "born": t,
                    }
                )
        if narrow and bear_ob:
            top = highs[t - 2]
            bottom = lows[t - 2]
            if _path_has_fvg(fvgs, False, top, bottom, closes[t]) and _sr_in_zone(levels, top, bottom, 250.0 * 0.01):
                zones.append(
                    {
                        "bull": False,
                        "top": top,
                        "bottom": bottom,
                        "entry": bottom,
                        "stop": top + 60.0 * 0.01,
                        "born": t,
                    }
                )
        if len(zones) > 8:
            zones.pop(0)

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "fvg_ob_sr_limit_retest",
    "hypothesis": "以 FVG、OB 與動態 S/R 匯合形成固定限價回測區，觸發後依來源停損與 TP3 規則出場。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}

