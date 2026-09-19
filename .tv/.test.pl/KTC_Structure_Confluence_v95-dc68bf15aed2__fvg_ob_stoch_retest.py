import numpy as np


def _parameter(params, name, default, converter):
    try:
        value = converter(params.get(name, default))
        if not np.isfinite(value):
            return default
        return value
    except (TypeError, ValueError, OverflowError):
        return default


def _sma(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = float(np.mean(window))
    return result


def _stochastic(closes, highs, lows, k_length, smooth_k, d_length):
    raw_k = np.full(closes.size, np.nan, dtype=float)
    for index in range(k_length - 1, closes.size):
        close = closes[index]
        high_window = highs[index - k_length + 1:index + 1]
        low_window = lows[index - k_length + 1:index + 1]
        if (
            np.isfinite(close)
            and np.all(np.isfinite(high_window))
            and np.all(np.isfinite(low_window))
        ):
            highest = float(np.max(high_window))
            lowest = float(np.min(low_window))
            if highest > lowest:
                raw_k[index] = 100.0 * (close - lowest) / (highest - lowest)
    k = _sma(raw_k, smooth_k)
    d = _sma(k, d_length)
    return k, d


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    if size == 0:
        return long_entries, long_exits, short_entries, short_exits

    params = signal_params or {}
    ob_atr_multiple = _parameter(params, "ob_atr_multiple", 2.0, float)
    fvg_window = max(1, int(_parameter(params, "fvg_window", 3, float)))
    be_offset = _parameter(params, "be_offset", 0.50, float)

    opens = np.asarray(market.opens, dtype=float)
    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    atr = np.asarray(features.atr(14), dtype=float)
    k, d = _stochastic(closes, highs, lows, 9, 3, 3)

    bullish_fvgs = []
    bearish_fvgs = []
    bullish_obs = []
    bearish_obs = []
    last_bullish_fvg_touch = None
    last_bearish_fvg_touch = None

    position = 0
    entry_bar = -1
    entry_price = 0.0
    initial_stop = 0.0
    tp1 = 0.0
    tp2 = 0.0
    tp3 = 0.0
    breakeven_active = False

    for index in range(size):
        finite_bar = (
            np.isfinite(opens[index])
            and np.isfinite(highs[index])
            and np.isfinite(lows[index])
            and np.isfinite(closes[index])
            and np.isfinite(atr[index])
        )

        if index >= 2 and finite_bar and np.isfinite(highs[index - 2]):
            bull_gap = lows[index] - highs[index - 2]
            bear_gap = lows[index - 2] - highs[index]
            if bull_gap > 0.0:
                bullish_fvgs.append({
                    "top": float(lows[index]),
                    "bottom": float(highs[index - 2]),
                })
            if bear_gap > 0.0:
                bearish_fvgs.append({
                    "top": float(lows[index - 2]),
                    "bottom": float(highs[index]),
                })

        for fvg_index in range(len(bullish_fvgs) - 1, -1, -1):
            fvg = bullish_fvgs[fvg_index]
            if lows[index] <= fvg["top"] and highs[index] >= fvg["bottom"]:
                last_bullish_fvg_touch = index
            if fvg["bottom"] < lows[index] < fvg["top"]:
                fvg["top"] = float(lows[index])
            if lows[index] <= fvg["bottom"]:
                bullish_fvgs.pop(fvg_index)

        for fvg_index in range(len(bearish_fvgs) - 1, -1, -1):
            fvg = bearish_fvgs[fvg_index]
            if lows[index] <= fvg["top"] and highs[index] >= fvg["bottom"]:
                last_bearish_fvg_touch = index
            if fvg["bottom"] < highs[index] < fvg["top"]:
                fvg["bottom"] = float(highs[index])
            if highs[index] >= fvg["top"]:
                bearish_fvgs.pop(fvg_index)

        if index >= 2 and finite_bar and np.isfinite(atr[index]):
            bullish_ob = (
                closes[index - 2] < opens[index - 2]
                and closes[index - 1] > opens[index - 1]
                and lows[index] > highs[index - 2]
                and (highs[index - 2] - lows[index - 2])
                < atr[index] * ob_atr_multiple
            )
            bearish_ob = (
                closes[index - 2] > opens[index - 2]
                and closes[index - 1] < opens[index - 1]
                and highs[index] < lows[index - 2]
                and (highs[index - 2] - lows[index - 2])
                < atr[index] * ob_atr_multiple
            )
            if bullish_ob and highs[index - 2] > lows[index - 2]:
                bullish_obs.append({
                    "top": float(highs[index - 2]),
                    "bottom": float(lows[index - 2]),
                    "created": index,
                })
            if bearish_ob and highs[index - 2] > lows[index - 2]:
                bearish_obs.append({
                    "top": float(highs[index - 2]),
                    "bottom": float(lows[index - 2]),
                    "created": index,
                })

        for ob_index in range(len(bullish_obs) - 1, -1, -1):
            ob = bullish_obs[ob_index]
            if index > ob["created"] and closes[index] < ob["bottom"]:
                bullish_obs.pop(ob_index)

        for ob_index in range(len(bearish_obs) - 1, -1, -1):
            ob = bearish_obs[ob_index]
            if index > ob["created"] and closes[index] > ob["top"]:
                bearish_obs.pop(ob_index)

        best_bullish_ob = None
        for ob in bullish_obs:
            if (
                index > ob["created"]
                and highs[index] >= ob["bottom"]
                and lows[index] <= ob["top"]
                and (
                    best_bullish_ob is None
                    or ob["bottom"] > best_bullish_ob["bottom"]
                )
            ):
                best_bullish_ob = ob

        best_bearish_ob = None
        for ob in bearish_obs:
            if (
                index > ob["created"]
                and highs[index] >= ob["bottom"]
                and lows[index] <= ob["top"]
                and (
                    best_bearish_ob is None
                    or ob["top"] < best_bearish_ob["top"]
                )
            ):
                best_bearish_ob = ob

        bullish_stoch = False
        bearish_stoch = False
        if index > 0 and np.isfinite(k[index]) and np.isfinite(d[index]):
            previous_k = k[index - 1]
            previous_d = d[index - 1]
            memory_start = max(0, index - 4)
            recent_k = k[memory_start:index + 1]
            memory_ready = np.all(np.isfinite(recent_k))
            bullish_stoch = (
                memory_ready
                and k[index] > d[index]
                and np.isfinite(previous_k)
                and np.isfinite(previous_d)
                and previous_k <= previous_d
                and np.min(recent_k) <= 20.0
            )
            bearish_stoch = (
                memory_ready
                and k[index] < d[index]
                and np.isfinite(previous_k)
                and np.isfinite(previous_d)
                and previous_k >= previous_d
                and np.max(recent_k) >= 80.0
            )

        bullish_fvg_ready = (
            last_bullish_fvg_touch is not None
            and 1 <= index - last_bullish_fvg_touch <= fvg_window
        )
        bearish_fvg_ready = (
            last_bearish_fvg_touch is not None
            and 1 <= index - last_bearish_fvg_touch <= fvg_window
        )
        bullish_core = best_bullish_ob is not None and bullish_fvg_ready and bullish_stoch
        bearish_core = best_bearish_ob is not None and bearish_fvg_ready and bearish_stoch

        if bullish_core and not bearish_core:
            long_entries[index] = True
        elif bearish_core and not bullish_core:
            short_entries[index] = True

        if position != 0 and index > entry_bar:
            reached_tp1 = (
                highs[index] >= tp1 if position == 1 else lows[index] <= tp1
            )
            if reached_tp1:
                breakeven_active = True
            stop = (
                entry_price + position * be_offset
                if breakeven_active
                else initial_stop
            )
            hit_stop = lows[index] <= stop if position == 1 else highs[index] >= stop
            hit_tp3 = highs[index] >= tp3 if position == 1 else lows[index] <= tp3
            if hit_stop or hit_tp3:
                if position == 1:
                    long_exits[index] = True
                else:
                    short_exits[index] = True
                position = 0

        if position == 0:
            if long_entries[index] and best_bullish_ob is not None:
                position = 1
                entry_bar = index
                entry_price = float(best_bullish_ob["top"])
                initial_stop = float(best_bullish_ob["bottom"])
                risk = abs(entry_price - initial_stop)
                tp1 = entry_price + risk
                tp2 = entry_price + 2.0 * risk
                tp3 = entry_price + 3.0 * risk
                breakeven_active = False
            elif short_entries[index] and best_bearish_ob is not None:
                position = -1
                entry_bar = index
                entry_price = float(best_bearish_ob["bottom"])
                initial_stop = float(best_bearish_ob["top"])
                risk = abs(entry_price - initial_stop)
                tp1 = entry_price - risk
                tp2 = entry_price - 2.0 * risk
                tp3 = entry_price - 3.0 * risk
                breakeven_active = False

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "fvg_ob_stoch_retest",
    "hypothesis": "FVG 回補至 Order Block 時，Stochastic 反轉可改善雙向進場的風險報酬。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["ob_atr_multiple", "fvg_window", "be_offset"],
    "signal_parameter_sets": [
        {"ob_atr_multiple": 2.0, "fvg_window": 3, "be_offset": 0.50}
    ],
}
