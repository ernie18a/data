import numpy as np


def _array(obj, name, fallback=None):
    value = getattr(obj, name, fallback)
    if value is None:
        raise AttributeError(f"missing market field: {name}")
    return np.asarray(value, dtype=float).reshape(-1)


def _ema(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    alpha = 2.0 / (float(length) + 1.0)
    previous = np.nan
    for i, value in enumerate(values):
        if np.isfinite(value):
            previous = value if not np.isfinite(previous) else alpha * value + (1.0 - alpha) * previous
            result[i] = previous
    return result


def _rolling_vwap_deviation(source, volume, window):
    usable = np.isfinite(source)
    effective_volume = np.where(np.isfinite(volume) & (volume > 0.0), volume, 1.0)
    weighted = np.where(usable, effective_volume, 0.0)
    prefix_w = np.concatenate(([0.0], np.cumsum(weighted)))
    prefix_p = np.concatenate(([0.0], np.cumsum(np.where(usable, source * weighted, 0.0))))
    prefix_p2 = np.concatenate(([0.0], np.cumsum(np.where(usable, source * source * weighted, 0.0))))
    prefix_n = np.concatenate(([0], np.cumsum(usable.astype(np.int64))))
    w = prefix_w[window:] - prefix_w[:-window]
    p = prefix_p[window:] - prefix_p[:-window]
    p2 = prefix_p2[window:] - prefix_p2[:-window]
    n = prefix_n[window:] - prefix_n[:-window]
    vwap = np.full(source.size, np.nan, dtype=float)
    deviation = np.full(source.size, np.nan, dtype=float)
    good = (n == window) & (w > 0.0)
    values = p[good] / w[good]
    variance = np.maximum(p2[good] / w[good] - values * values, 0.0)
    vwap[window - 1:][good] = values
    deviation[window - 1:][good] = np.sqrt(variance)
    return vwap, deviation


def _signal_events(vwap, deviation, closes, atr, params):
    n = closes.size
    smoothing = int(params["turn_smoothing"])
    width = float(params["deviation_multiplier"])
    slope_limit = float(params["minimum_slope"])
    min_bars = int(params["minimum_bars_between_signals"])
    min_move = float(params["minimum_move_atr"])

    upper = vwap + width * deviation
    lower = vwap - width * deviation
    turn_upper = _ema(upper, smoothing) if smoothing > 1 else upper
    turn_lower = _ema(lower, smoothing) if smoothing > 1 else lower
    upper_delta = np.full(n, np.nan, dtype=float)
    lower_delta = np.full(n, np.nan, dtype=float)
    if n > 1:
        valid_atr = np.isfinite(atr) & (atr > 0.0)
        valid_upper = valid_atr[1:] & np.isfinite(turn_upper[1:]) & np.isfinite(turn_upper[:-1])
        valid_lower = valid_atr[1:] & np.isfinite(turn_lower[1:]) & np.isfinite(turn_lower[:-1])
        upper_delta[1:][valid_upper] = (turn_upper[1:][valid_upper] - turn_upper[:-1][valid_upper]) / atr[1:][valid_upper]
        lower_delta[1:][valid_lower] = (turn_lower[1:][valid_lower] - turn_lower[:-1][valid_lower]) / atr[1:][valid_lower]

    raw_buy = np.zeros(n, dtype=np.bool_)
    raw_sell = np.zeros(n, dtype=np.bool_)
    for t in range(1, n):
        if not (np.isfinite(lower_delta[t]) and np.isfinite(lower_delta[t - 1])):
            continue
        if lower_delta[t] >= slope_limit and lower_delta[t - 1] < slope_limit:
            raw_buy[t] = True
        if np.isfinite(upper_delta[t]) and np.isfinite(upper_delta[t - 1]):
            if upper_delta[t] <= -slope_limit and upper_delta[t - 1] > -slope_limit:
                raw_sell[t] = True

    buys = np.zeros(n, dtype=np.bool_)
    sells = np.zeros(n, dtype=np.bool_)
    last_direction = 0
    last_bar = -10**18
    last_price = np.nan
    for t in range(n):
        if not (np.isfinite(closes[t]) and np.isfinite(atr[t]) and atr[t] > 0.0):
            continue
        separated = t - last_bar >= min_bars
        moved = not np.isfinite(last_price) or abs(closes[t] - last_price) >= min_move * atr[t]
        if raw_buy[t] and last_direction != 1 and separated and moved:
            buys[t] = True
            last_direction, last_bar, last_price = 1, t, closes[t]
        elif raw_sell[t] and last_direction != -1 and separated and moved:
            sells[t] = True
            last_direction, last_bar, last_price = -1, t, closes[t]
    return buys, sells, lower, vwap


def _initial_stop(close, vwap, lower, atr):
    return np.minimum(lower + 0.15 * (vwap - lower), close - 0.15 * atr)


def _qualified_history(buys, sells, opens, lows, closes, stops, params):
    n = closes.size
    qualified = np.zeros(n, dtype=np.bool_)
    position = False
    entry_bar = -1
    entry_price = np.nan
    entry_stop = np.nan
    entry_risk = np.nan
    quantity = np.nan
    trades = 0
    gross_wins = 0.0
    gross_losses = 0.0
    total_r = 0.0
    commission = float(params["commission_rate"])
    equity = float(params["virtual_equity"])
    risk_pct = float(params["risk_percent"])
    max_position_pct = float(params["maximum_position_percent"])
    min_tick = 1e-12

    for t in range(n):
        if not position and buys[t] and np.isfinite(stops[t]) and stops[t] < closes[t]:
            position = True
            entry_bar = t
            entry_price = closes[t]
            entry_stop = stops[t]
            entry_risk = max(entry_price - entry_stop, min_tick)
            quantity = min((equity * risk_pct / 100.0) / entry_risk,
                           (equity * max_position_pct / 100.0) / max(entry_price, min_tick))

        if position and t > entry_bar:
            stop_hit = np.isfinite(lows[t]) and lows[t] <= entry_stop
            signal_hit = sells[t]
            if stop_hit or signal_hit:
                stop_fill = np.isfinite(opens[t]) and opens[t] < entry_stop
                exit_price = opens[t] if stop_hit and stop_fill else entry_stop if stop_hit else closes[t]
                net = (exit_price - entry_price) * quantity - (entry_price * quantity + exit_price * quantity) * commission
                total_r += (exit_price - entry_price) / entry_risk
                trades += 1
                if net > 0.0:
                    gross_wins += net
                elif net < 0.0:
                    gross_losses += -net
                position = False

        if trades >= int(params["minimum_trades"]):
            profit_factor = gross_wins / gross_losses if gross_losses > 0.0 else 999.0 if gross_wins > 0.0 else np.nan
            average_r = total_r / trades
            qualified[t] = np.isfinite(profit_factor) and profit_factor >= float(params["minimum_pf"]) and average_r > float(params["minimum_average_r"])
    return qualified


def generate_signals(features, signal_params):
    params = {
        "lookback": 50,
        "deviation_multiplier": 1.5,
        "turn_smoothing": 2,
        "atr_length": 14,
        "minimum_slope": 0.015,
        "minimum_bars_between_signals": 4,
        "minimum_move_atr": 0.25,
        "minimum_trades": 30,
        "minimum_pf": 1.10,
        "minimum_average_r": 0.0,
        "commission_rate": 0.0005,
        "virtual_equity": 10000.0,
        "risk_percent": 1.0,
        "maximum_position_percent": 25.0,
    }
    if signal_params:
        params.update(signal_params)

    market = features.market
    size = int(market.size)
    closes = _array(market, "closes")
    highs = _array(market, "highs")
    lows = _array(market, "lows")
    opens = _array(market, "opens", closes)
    volumes = _array(market, "volumes")
    if any(values.size != size for values in (closes, highs, lows, opens, volumes)):
        raise ValueError("market arrays must all have features.market.size elements")

    atr = np.asarray(features.atr(int(params["atr_length"])), dtype=float).reshape(-1)
    if atr.size != size:
        raise ValueError("features.atr() must return one value per market bar")
    source = (highs + lows + closes) / 3.0
    vwap, deviation = _rolling_vwap_deviation(source, volumes, int(params["lookback"]))
    buys, sells, lower, vwap = _signal_events(vwap, deviation, closes, atr, params)
    stops = _initial_stop(closes, vwap, lower, atr)
    valid = np.isfinite(closes) & np.isfinite(stops) & (stops < closes)
    qualified = _qualified_history(buys & valid, sells, opens, lows, closes, stops, params)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    position = False
    entry_bar = -1
    active_stop = np.nan

    for t in range(size):
        was_open = position
        if was_open and t > entry_bar:
            stop_hit = np.isfinite(lows[t]) and lows[t] <= active_stop
            signal_hit = sells[t]
            if stop_hit or signal_hit:
                long_exits[t] = True
                position = False
        if not was_open and buys[t] and valid[t] and qualified[t]:
            long_entries[t] = True
            position = True
            entry_bar = t
            active_stop = stops[t]

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "adaptive_vwap_wave_s2s",
    "hypothesis": "下方 VWAP 外包絡由非上升轉為上升，代表長側結構支撐恢復；以 SELL 訊號或進場時保護停損退出。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "lookback",
        "deviation_multiplier",
        "turn_smoothing",
        "atr_length",
        "minimum_slope",
        "minimum_bars_between_signals",
        "minimum_move_atr",
        "minimum_trades",
        "minimum_pf",
        "minimum_average_r",
        "commission_rate",
        "virtual_equity",
        "risk_percent",
        "maximum_position_percent",
    ],
    "signal_parameter_sets": [{
        "lookback": 50,
        "deviation_multiplier": 1.5,
        "turn_smoothing": 2,
        "atr_length": 14,
        "minimum_slope": 0.015,
        "minimum_bars_between_signals": 4,
        "minimum_move_atr": 0.25,
        "minimum_trades": 30,
        "minimum_pf": 1.10,
        "minimum_average_r": 0.0,
        "commission_rate": 0.0005,
        "virtual_equity": 10000.0,
        "risk_percent": 1.0,
        "maximum_position_percent": 25.0,
    }],
}