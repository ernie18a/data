import numpy as np


def _series(market, names, size):
    for name in names:
        if hasattr(market, name):
            value = np.asarray(getattr(market, name), dtype=float).reshape(-1)
            if value.size >= size:
                return value[:size]
    raise AttributeError("missing OHLCV series: " + "/".join(names))


def _atr(high, low, close, period=14):
    n = close.size
    tr = np.full(n, np.nan)
    for i in range(n):
        if np.isfinite(high[i]) and np.isfinite(low[i]):
            tr[i] = high[i] - low[i] if i == 0 or not np.isfinite(close[i - 1]) else max(
                high[i] - low[i], abs(high[i] - close[i - 1]), abs(low[i] - close[i - 1])
            )
    out = np.full(n, np.nan)
    if n >= period and np.all(np.isfinite(tr[:period])):
        out[period - 1] = np.mean(tr[:period])
        for i in range(period, n):
            if np.isfinite(tr[i]):
                out[i] = (out[i - 1] * (period - 1) + tr[i]) / period
    return out


def _wave(high, low, close, volume, atr=None):
    n = close.size
    source = (high + low + close) / 3.0
    good = np.isfinite(source) & np.isfinite(volume)
    vol = np.where(good, np.where(volume > 0.0, volume, 1.0), 0.0)
    pv = np.where(good, source * vol, 0.0)
    p2v = np.where(good, source * source * vol, 0.0)
    count = np.r_[0, np.cumsum(good.astype(np.int64))]
    vp = np.r_[0.0, np.cumsum(vol)]
    pp = np.r_[0.0, np.cumsum(pv)]
    p2p = np.r_[0.0, np.cumsum(p2v)]
    vs = np.full(n, np.nan)
    ps = np.full(n, np.nan)
    p2s = np.full(n, np.nan)
    if n >= 50:
        j = np.arange(49, n)
        ok = count[j + 1] - count[j - 49] == 50
        vs[j[ok]] = vp[j[ok] + 1] - vp[j[ok] - 49]
        ps[j[ok]] = pp[j[ok] + 1] - pp[j[ok] - 49]
        p2s[j[ok]] = p2p[j[ok] + 1] - p2p[j[ok] - 49]
    vwap = ps / vs
    dev = np.sqrt(np.maximum(p2s / vs - vwap * vwap, 0.0))
    upper, lower = vwap + 1.5 * dev, vwap - 1.5 * dev

    def ema(x):
        result = np.full(n, np.nan)
        previous = np.nan
        for i, value in enumerate(x):
            if np.isfinite(value):
                previous = value if not np.isfinite(previous) else (2.0 * value + previous) / 3.0
                result[i] = previous
        return result

    tu, tl = ema(upper), ema(lower)
    if atr is None:
        atr = _atr(high, low, close)
    else:
        atr = np.asarray(atr, dtype=float).reshape(-1)[:n]
        if atr.size != n:
            atr = _atr(high, low, close)
    atr = np.where(np.isfinite(atr) & (atr > 0.0), atr, np.nan)
    ud, ld = (tu - np.roll(tu, 1)) / atr, (tl - np.roll(tl, 1)) / atr
    if n:
        ud[0] = ld[0] = np.nan
    buy = np.zeros(n, dtype=np.bool_)
    sell = np.zeros(n, dtype=np.bool_)
    direction, last_bar, last_price = 0, -10**18, np.nan
    for i in range(1, n):
        if not (np.isfinite(ud[i]) and np.isfinite(ld[i]) and np.isfinite(close[i]) and np.isfinite(atr[i])):
            continue
        raw_buy = ld[i] >= 0.015 and (not np.isfinite(ld[i - 1]) or ld[i - 1] < 0.015)
        raw_sell = ud[i] <= -0.015 and (not np.isfinite(ud[i - 1]) or ud[i - 1] > -0.015)
        separated = i - last_bar >= 4
        moved = not np.isfinite(last_price) or abs(close[i] - last_price) >= 0.25 * atr[i]
        if raw_buy and direction != 1 and separated and moved:
            buy[i], direction, last_bar, last_price = True, 1, i, close[i]
        elif raw_sell and direction != -1 and separated and moved:
            sell[i], direction, last_bar, last_price = True, -1, i, close[i]
    return {"buy": buy, "sell": sell, "upper": upper, "lower": lower, "vwap": vwap, "atr": atr}


def _slope(w, i):
    if i < 3 or not all(np.isfinite(w[k][i]) for k in ("vwap", "atr")) or not np.isfinite(w["vwap"][i - 3]):
        return np.nan
    return (w["vwap"][i] - w["vwap"][i - 3]) / w["atr"][i]


def _rising(w, i):
    return i >= 3 and all(np.isfinite(w[k][i]) and np.isfinite(w[k][i - 3]) for k in ("upper", "lower")) and w["upper"][i] > w["upper"][i - 3] and w["lower"][i] > w["lower"][i - 3]


def _tick(close):
    values = close[np.isfinite(close) & (close > 0)]
    return max(float(values.min()) * 1e-8, 1e-12) if values.size else 1e-12


def _qualified(s):
    if s["n"] < 30:
        return False
    pf = s["win"] / s["loss"] if s["loss"] > 0 else (999.0 if s["win"] > 0 else np.nan)
    return np.isfinite(pf) and pf >= 1.10 and s["r"] / s["n"] > 0


def _add(s, entry, exit_price, risk, qty):
    if not all(np.isfinite(x) for x in (entry, exit_price, risk, qty)) or risk <= 0:
        return
    net = (exit_price - entry) * qty - (entry + exit_price) * qty * 0.0005
    s["n"] += 1
    s["r"] += (exit_price - entry) / risk
    if net > 0:
        s["win"] += net
    elif net < 0:
        s["loss"] -= net


def _profile(opens, highs, lows, closes, w, expiry=None):
    n = closes.size
    qualified = np.zeros(n, dtype=np.bool_)
    s = {"n": 0, "r": 0.0, "win": 0.0, "loss": 0.0}
    state, entry_bar, entry, stop, risk, qty = 0, -1, np.nan, np.nan, np.nan, np.nan
    highest, ride_start, pre_bars = np.nan, -1, 0
    tick = _tick(closes)
    for i in range(n):
        if state and i > entry_bar:
            out = np.nan
            if np.isfinite(lows[i]) and lows[i] <= stop:
                out = opens[i] if np.isfinite(opens[i]) and opens[i] < stop else stop
            elif state == 1:
                ready = np.isfinite(closes[i]) and np.isfinite(w["upper"][i]) and closes[i] > w["upper"][i] and _slope(w, i) >= 0.05 and _rising(w, i)
                if ready:
                    state, highest, ride_start = 2, highs[i], i
                elif (np.isfinite(highs[i]) and highs[i] >= w["upper"][i]) or w["sell"][i]:
                    if expiry is None or pre_bars >= expiry:
                        out = closes[i]
            else:
                if np.isfinite(highs[i]):
                    highest = highs[i] if not np.isfinite(highest) else max(highest, highs[i])
                if np.isfinite(w["atr"][i]) and np.isfinite(highest):
                    stop = max(stop, highest - 2.0 * w["atr"][i])
                if ride_start >= 0 and i - ride_start >= 1 and (w["sell"][i] or closes[i] < w["upper"][i] or _slope(w, i) <= -0.03):
                    out = closes[i]
            if np.isfinite(out):
                _add(s, entry, out, risk, qty)
                state, entry_bar, highest, ride_start, pre_bars = 0, -1, np.nan, -1, 0
        if state == 0 and w["buy"][i]:
            stop_candidate = w["lower"][i] + max(w["vwap"][i] - w["lower"][i], tick) * 0.15 if all(np.isfinite(w[k][i]) for k in ("lower", "vwap", "atr")) else np.nan
            stop_candidate = min(stop_candidate, closes[i] - w["atr"][i] * 0.15) if np.isfinite(stop_candidate) else np.nan
            if np.isfinite(stop_candidate) and stop_candidate < closes[i]:
                state, entry_bar, entry, stop = 1, i, closes[i], stop_candidate
                risk, qty = max(entry - stop, tick), min(100.0 / max(entry - stop, tick), 2500.0 / max(entry, tick))
        qualified[i] = _qualified(s)
    return qualified


def _groups(market, n):
    times = None
    for name in ("timestamps", "times", "time"):
        if hasattr(market, name):
            try:
                x = np.asarray(getattr(market, name), dtype=float).reshape(-1)
                if x.size >= n and np.all(np.isfinite(x[:n])):
                    times = x[:n]
                    break
            except (TypeError, ValueError):
                pass
    if times is None:
        ids = np.arange(n) // 4
    else:
        scale = np.max(np.abs(times))
        times = times / (1e9 if scale > 1e14 else 1e3 if scale > 1e11 else 1.0)
        ids = np.floor(times / 14400.0).astype(np.int64)
        ids -= ids[0]
    starts = np.flatnonzero(np.r_[True, ids[1:] != ids[:-1]])
    return np.searchsorted(starts, np.arange(n), side="right") - 1, starts


def _aggregate(opens, highs, lows, closes, volumes, ordinal, starts):
    m = starts.size
    ends = np.r_[starts[1:], closes.size]
    out = [np.empty(m) for _ in range(5)]
    for g, (a, b) in enumerate(zip(starts, ends)):
        out[0][g], out[1][g], out[2][g], out[3][g] = opens[a], np.nanmax(highs[a:b]), np.nanmin(lows[a:b]), closes[b - 1]
        out[4][g] = np.sum(np.where(np.isfinite(volumes[a:b]) & (volumes[a:b] > 0), volumes[a:b], 1.0))
    return out


def generate_signals(features, signal_params):
    size = int(features.market.size)
    if size <= 0:
        empty = np.zeros(0, dtype=np.bool_)
        return empty, empty.copy(), empty.copy(), empty.copy()
    market = features.market
    opens = _series(market, ("opens", "open"), size)
    highs = _series(market, ("highs", "high"), size)
    lows = _series(market, ("lows", "low"), size)
    closes = _series(market, ("closes", "close"), size)
    volumes = _series(market, ("volumes", "volume"), size)
    try:
        atr = np.asarray(features.atr(14), dtype=float).reshape(-1)
        atr = atr[:size] if atr.size >= size else None
    except (AttributeError, TypeError, ValueError):
        atr = None
    w = _wave(highs, lows, closes, volumes, atr)
    primary = _profile(opens, highs, lows, closes, w)

    ordinal, starts = _groups(market, size)
    fo, fh, fl, fc, fv = _aggregate(opens, highs, lows, closes, volumes, ordinal, starts)
    fw = _wave(fh, fl, fc, fv)
    four_qualified = _profile(fo, fh, fl, fc, fw)
    fallback = np.zeros(size, dtype=np.bool_)
    for i, group in enumerate(ordinal):
        if group > 0:
            fallback[i] = four_qualified[group - 1]

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    state, is_fallback, entry_group = 0, False, -1
    active_stop, highest, ride_start = np.nan, np.nan, -1
    pre_ride = 0
    tick = _tick(closes)

    for i in range(size):
        exited = False
        if state:
            if np.isfinite(lows[i]) and lows[i] <= active_stop:
                long_exits[i], state, exited = True, 0, True
            elif is_fallback:
                group = int(ordinal[i])
                h = group - 1
                if i == starts[group] and h > entry_group:
                    pre_ride += 1
                    close, high, upper = fc[h], fh[h], fw["upper"][h]
                    sell = bool(fw["sell"][h])
                    ready = np.isfinite(close) and np.isfinite(upper) and close > upper and _slope(fw, h) >= 0.05 and _rising(fw, h)
                    if state == 1:
                        if ready:
                            state, highest, ride_start = 2, high, group
                        elif pre_ride >= 4 and ((np.isfinite(high) and high >= upper) or sell):
                            long_exits[i], state, exited = True, 0, True
                    else:
                        if np.isfinite(high):
                            highest = high if not np.isfinite(highest) else max(highest, high)
                        if np.isfinite(fw["atr"][h]) and np.isfinite(highest):
                            active_stop = max(active_stop, highest - 2.0 * fw["atr"][h])
                        if group - ride_start >= 1 and (sell or close < upper or _slope(fw, h) <= -0.03):
                            long_exits[i], state, exited = True, 0, True
            else:
                close, high, upper = closes[i], highs[i], w["upper"][i]
                if state == 1:
                    ready = np.isfinite(close) and np.isfinite(upper) and close > upper and _slope(w, i) >= 0.05 and _rising(w, i)
                    if ready:
                        state, highest, ride_start = 2, high, i
                    elif (np.isfinite(high) and high >= upper) or w["sell"][i]:
                        long_exits[i], state, exited = True, 0, True
                else:
                    if np.isfinite(high):
                        highest = high if not np.isfinite(highest) else max(highest, high)
                    if np.isfinite(w["atr"][i]) and np.isfinite(highest):
                        active_stop = max(active_stop, highest - 2.0 * w["atr"][i])
                    if i - ride_start >= 1 and (w["sell"][i] or close < upper or _slope(w, i) <= -0.03):
                        long_exits[i], state, exited = True, 0, True

        if state == 0 and not exited and w["buy"][i]:
            use_primary = bool(primary[i])
            use_fallback = not use_primary and bool(fallback[i])
            if use_primary or use_fallback:
                stop_candidate = w["lower"][i] + max(w["vwap"][i] - w["lower"][i], tick) * 0.15 if all(np.isfinite(w[k][i]) for k in ("lower", "vwap", "atr")) else np.nan
                stop_candidate = min(stop_candidate, closes[i] - w["atr"][i] * 0.15) if np.isfinite(stop_candidate) else np.nan
                if np.isfinite(stop_candidate) and stop_candidate < closes[i]:
                    long_entries[i], state, is_fallback = True, 1, use_fallback
                    entry_group, active_stop, highest, ride_start, pre_ride = int(ordinal[i]), stop_candidate, np.nan, -1, 0

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "adaptive_vwap_wave_ride",
    "hypothesis": "VWAP 下方波段轉強並突破上包絡時，結合歷史資格篩選與 Balance-to-Ride 管理捕捉多頭延伸。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
