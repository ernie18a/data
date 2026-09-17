import numpy as np


def _parameter(signal_params, name, default):
    try:
        value = float(signal_params.get(name, default))
    except (AttributeError, TypeError, ValueError):
        value = float(default)
    return value if np.isfinite(value) else float(default)


def _ema(values, length):
    values = np.asarray(values, dtype=float)
    result = np.full(values.shape, np.nan, dtype=float)
    alpha = 2.0 / (float(length) + 1.0)
    previous = np.nan
    for index, value in enumerate(values):
        if not np.isfinite(value):
            continue
        previous = value if not np.isfinite(previous) else alpha * value + (1.0 - alpha) * previous
        result[index] = previous
    return result


def _rolling_wave(highs, lows, closes, volumes, lookback, deviation_multiplier):
    source = (highs + lows + closes) / 3.0
    effective_volume = np.where(np.isfinite(volumes) & (volumes > 0.0), volumes, 1.0)
    valid = np.isfinite(source) & np.isfinite(effective_volume)
    safe_source = np.where(valid, source, 0.0)
    safe_volume = np.where(valid, effective_volume, 0.0)

    def rolling(values):
        cumulative = np.concatenate(([0.0], np.cumsum(values, dtype=float)))
        return cumulative[lookback:] - cumulative[:-lookback]

    volume_sum = rolling(safe_volume)
    price_volume_sum = rolling(safe_source * safe_volume)
    squared_volume_sum = rolling(safe_source * safe_source * safe_volume)
    valid_count = rolling(valid.astype(float))

    vwap = np.full(source.shape, np.nan, dtype=float)
    deviation = np.full(source.shape, np.nan, dtype=float)
    denominator = volume_sum > 0.0
    complete = (valid_count >= float(lookback)) & denominator
    positions = np.arange(lookback - 1, source.size)
    vwap[positions[complete]] = price_volume_sum[complete] / volume_sum[complete]
    variance = squared_volume_sum[complete] / volume_sum[complete] - vwap[positions[complete]] ** 2
    deviation[positions[complete]] = np.sqrt(np.maximum(variance, 0.0))
    upper = vwap + deviation_multiplier * deviation
    lower = vwap - deviation_multiplier * deviation
    return vwap, upper, lower


def _atr_from_arrays(highs, lows, closes, period):
    true_range = np.full(closes.shape, np.nan, dtype=float)
    true_range[0] = highs[0] - lows[0]
    if closes.size > 1:
        true_range[1:] = np.maximum(
            highs[1:] - lows[1:],
            np.maximum(np.abs(highs[1:] - closes[:-1]), np.abs(lows[1:] - closes[:-1])),
        )
    result = np.full(closes.shape, np.nan, dtype=float)
    if closes.size < period:
        return result
    for index in range(period - 1, closes.size):
        window = true_range[index - period + 1 : index + 1]
        if not np.all(np.isfinite(window)):
            continue
        if index == period - 1:
            result[index] = float(np.mean(window))
        elif np.isfinite(result[index - 1]):
            result[index] = (result[index - 1] * (period - 1.0) + true_range[index]) / period
    return result


def _signals_from_wave(upper, lower, atr, closes, slope, min_bars, min_move_atr):
    turn_upper = _ema(upper, 2)
    turn_lower = _ema(lower, 2)
    upper_delta = np.full(closes.shape, np.nan, dtype=float)
    lower_delta = np.full(closes.shape, np.nan, dtype=float)
    valid_atr = np.isfinite(atr) & (atr > 0.0)
    upper_delta[1:] = np.divide(
        turn_upper[1:] - turn_upper[:-1], atr[1:],
        out=np.full(closes.size - 1, np.nan), where=valid_atr[1:],
    )
    lower_delta[1:] = np.divide(
        turn_lower[1:] - turn_lower[:-1], atr[1:],
        out=np.full(closes.size - 1, np.nan), where=valid_atr[1:],
    )
    raw_buy = (
        np.isfinite(lower_delta) & (lower_delta >= slope)
        & np.concatenate(([False], np.isfinite(lower_delta[:-1]) & (lower_delta[:-1] < slope)))
    )
    raw_sell = (
        np.isfinite(upper_delta) & (upper_delta <= -slope)
        & np.concatenate(([False], np.isfinite(upper_delta[:-1]) & (upper_delta[:-1] > -slope)))
    )

    buys = np.zeros(closes.size, dtype=np.bool_)
    sells = np.zeros(closes.size, dtype=np.bool_)
    last_direction = 0
    last_bar = -10**12
    last_price = np.nan
    for index in range(closes.size):
        if not np.isfinite(closes[index]) or not valid_atr[index]:
            continue
        separated = index - last_bar >= min_bars
        moved = not np.isfinite(last_price) or abs(closes[index] - last_price) >= min_move_atr * atr[index]
        if raw_buy[index] and last_direction != 1 and separated and moved:
            buys[index] = True
            last_direction = 1
            last_bar = index
            last_price = closes[index]
        elif raw_sell[index] and last_direction != -1 and separated and moved:
            sells[index] = True
            last_direction = -1
            last_bar = index
            last_price = closes[index]
    return buys, sells


def _entry_risk(closes, vwap, lower, atr):
    stop = np.minimum(lower + 0.15 * (vwap - lower), closes - 0.15 * atr)
    risk = closes - stop
    valid = np.isfinite(stop) & np.isfinite(risk) & (risk > 0.0)
    return stop, risk, valid


def _quantity(closes, risk, signal_params):
    equity = _parameter(signal_params, "virtual_equity", 10000.0)
    risk_percent = _parameter(signal_params, "risk_percent", 1.0)
    max_position_percent = _parameter(signal_params, "max_position_percent", 25.0)
    risk_cash = max(equity * risk_percent / 100.0, 0.0)
    value_cap = max(equity * max_position_percent / 100.0, 0.0)
    return np.minimum(risk_cash / np.maximum(risk, 1e-12), value_cap / np.maximum(closes, 1e-12))


def _qualified_balance_timeline(data, signal_params, minimum_sample, minimum_pf, minimum_expectancy):
    opens, highs, lows, closes, upper, lower, vwap, atr, buys, sells, stops, risks, valid = data
    quantities = _quantity(closes, risks, signal_params)
    states = {"s2s": None, "balance": None, "ride": None}
    stats = {name: {"trades": 0, "win": 0.0, "loss": 0.0, "net_r": 0.0} for name in states}
    qualified = np.zeros(closes.size, dtype=np.bool_)
    commission = _parameter(signal_params, "commission_rate", 0.0005)

    def close_trade(name, state, exit_price):
        risk = state["risk"]
        if not np.isfinite(exit_price) or not np.isfinite(risk) or risk <= 0.0:
            return
        trade_r = (exit_price - state["entry"]) / risk
        net_dollars = (exit_price - state["entry"]) * state["quantity"]
        net_dollars -= (state["entry"] + exit_price) * state["quantity"] * commission
        record = stats[name]
        record["trades"] += 1
        record["net_r"] += trade_r
        if net_dollars > 0.0:
            record["win"] += net_dollars
        elif net_dollars < 0.0:
            record["loss"] += -net_dollars

    def profile_is_qualified(name):
        record = stats[name]
        if record["trades"] < minimum_sample:
            return False, np.nan, np.nan
        profit_factor = record["win"] / record["loss"] if record["loss"] > 0.0 else (999.0 if record["win"] > 0.0 else np.nan)
        expectancy = record["net_r"] / record["trades"]
        return profit_factor >= minimum_pf and expectancy > minimum_expectancy, profit_factor, expectancy

    for index in range(closes.size):
        for name, state in tuple(states.items()):
            if state is None or index <= state["entry_bar"]:
                continue
            stop_hit = np.isfinite(lows[index]) and lows[index] <= state["stop"]
            if stop_hit:
                exit_price = opens[index] if np.isfinite(opens[index]) and opens[index] < state["stop"] else state["stop"]
                close_trade(name, state, exit_price)
                states[name] = None
                continue
            if name == "s2s":
                should_exit = bool(sells[index])
            elif name == "balance":
                should_exit = bool(sells[index]) or (np.isfinite(highs[index]) and np.isfinite(upper[index]) and highs[index] >= upper[index])
            else:
                if state["phase"] == 1:
                    ride_ready = (
                        np.isfinite(upper[index]) and closes[index] > upper[index]
                        and index >= 3 and np.isfinite(atr[index]) and atr[index] > 0.0
                        and np.isfinite(vwap[index - 3])
                        and (vwap[index] - vwap[index - 3]) / atr[index] >= 0.05
                        and upper[index] > upper[index - 3] and lower[index] > lower[index - 3]
                    )
                    if ride_ready:
                        state["phase"] = 2
                        state["highest"] = highs[index]
                        continue
                    should_exit = bool(sells[index]) or (np.isfinite(highs[index]) and np.isfinite(upper[index]) and highs[index] >= upper[index])
                else:
                    state["highest"] = max(state["highest"], highs[index])
                    if np.isfinite(atr[index]):
                        state["stop"] = max(state["stop"], state["highest"] - 2.0 * atr[index])
                    should_exit = bool(sells[index]) or closes[index] < upper[index]
            if should_exit:
                close_trade(name, state, closes[index])
                states[name] = None

        candidates = []
        for name in states:
            is_qualified, profit_factor, expectancy = profile_is_qualified(name)
            if is_qualified:
                candidates.append((expectancy, profit_factor, name))
        if candidates:
            selected = max(candidates, key=lambda item: (item[0], item[1]))[2]
            qualified[index] = selected == "balance"

        if buys[index] and valid[index] and np.isfinite(closes[index]):
            for name in states:
                if states[name] is None:
                    state = {"entry": closes[index], "stop": stops[index], "risk": risks[index], "quantity": quantities[index], "entry_bar": index}
                    if name == "ride":
                        state.update({"phase": 1, "highest": highs[index]})
                    states[name] = state
    return qualified


def _aggregate_four_hour(opens, highs, lows, closes, volumes):
    count = closes.size // 4
    if count == 0:
        return tuple(np.empty(0, dtype=float) for _ in range(5))
    htf_opens = np.empty(count, dtype=float)
    htf_highs = np.empty(count, dtype=float)
    htf_lows = np.empty(count, dtype=float)
    htf_closes = np.empty(count, dtype=float)
    htf_volumes = np.empty(count, dtype=float)
    for index in range(count):
        start = index * 4
        end = start + 4
        htf_opens[index] = opens[start]
        htf_highs[index] = np.nanmax(highs[start:end])
        htf_lows[index] = np.nanmin(lows[start:end])
        htf_closes[index] = closes[end - 1]
        block = volumes[start:end]
        htf_volumes[index] = np.nansum(np.where(np.isfinite(block) & (block > 0.0), block, 1.0))
    return htf_opens, htf_highs, htf_lows, htf_closes, htf_volumes


def _prepare_data(opens, highs, lows, closes, volumes, atr, signal_params):
    lookback = max(1, int(round(_parameter(signal_params, "lookback", 50.0))))
    deviation_multiplier = _parameter(signal_params, "deviation_multiplier", 1.5)
    slope = _parameter(signal_params, "minimum_slope", 0.015)
    min_bars = max(1, int(round(_parameter(signal_params, "minimum_bars_between_signals", 4.0))))
    min_move_atr = _parameter(signal_params, "minimum_move_atr", 0.25)
    vwap, upper, lower = _rolling_wave(highs, lows, closes, volumes, lookback, deviation_multiplier)
    buys, sells = _signals_from_wave(upper, lower, atr, closes, slope, min_bars, min_move_atr)
    stops, risks, valid = _entry_risk(closes, vwap, lower, atr)
    return opens, highs, lows, closes, upper, lower, vwap, atr, buys, sells, stops, risks, valid


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    import numpy as np

    if size == 0:
        empty = np.zeros(0, dtype=np.bool_)
        return empty.copy(), empty.copy(), empty.copy(), empty.copy()

    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    volumes = np.asarray(market.volumes, dtype=float)
    opens = np.asarray(getattr(market, "opens", closes), dtype=float)
    atr = np.asarray(features.atr(14), dtype=float)
    if atr.ndim == 0:
        atr = np.full(size, float(atr), dtype=float)
    else:
        atr = np.broadcast_to(atr, (size,)).astype(float, copy=False)

    data = _prepare_data(opens, highs, lows, closes, volumes, atr, signal_params)
    minimum_sample = max(1, int(round(_parameter(signal_params, "minimum_sample", 30.0))))
    minimum_pf = _parameter(signal_params, "minimum_pf", 1.10)
    minimum_expectancy = _parameter(signal_params, "minimum_expectancy", 0.0)
    primary_qualified = _qualified_balance_timeline(data, signal_params, minimum_sample, minimum_pf, minimum_expectancy)

    htf_opens, htf_highs, htf_lows, htf_closes, htf_volumes = _aggregate_four_hour(opens, highs, lows, closes, volumes)
    fallback_qualified = np.zeros(size, dtype=np.bool_)
    if htf_closes.size:
        htf_atr = _atr_from_arrays(htf_highs, htf_lows, htf_closes, 14)
        htf_data = _prepare_data(htf_opens, htf_highs, htf_lows, htf_closes, htf_volumes, htf_atr, signal_params)
        htf_qualified = _qualified_balance_timeline(htf_data, signal_params, minimum_sample, minimum_pf, minimum_expectancy)
        for index in range(size):
            group = index // 4
            if group > 0 and group - 1 < htf_qualified.size:
                fallback_qualified[index] = htf_qualified[group - 1]

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    buys, sells, stops, upper = data[8], data[9], data[10], data[4]
    position = False
    current_stop = np.nan
    for index in range(size):
        if position:
            stop_hit = np.isfinite(lows[index]) and np.isfinite(current_stop) and lows[index] <= current_stop
            target_hit = np.isfinite(highs[index]) and np.isfinite(upper[index]) and highs[index] >= upper[index]
            if stop_hit or target_hit or sells[index]:
                long_exits[index] = True
                position = False
                current_stop = np.nan
                continue
        route_qualified = bool(primary_qualified[index]) or (not bool(primary_qualified[index]) and bool(fallback_qualified[index]))
        if not position and buys[index] and route_qualified and np.isfinite(stops[index]) and stops[index] < closes[index]:
            long_entries[index] = True
            position = True
            current_stop = stops[index]
    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "adaptive_vwap_wave_balance",
    "hypothesis": "平衡市場中，下包絡轉強的確認買進可在上包絡或反轉訊號處獲利了結。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "lookback", "deviation_multiplier", "minimum_slope", "minimum_bars_between_signals", "minimum_move_atr", "minimum_sample", "minimum_pf", "minimum_expectancy", "virtual_equity", "risk_percent", "max_position_percent", "commission_rate",
    ],
    "signal_parameter_sets": [{
        "lookback": 50, "deviation_multiplier": 1.5, "minimum_slope": 0.015, "minimum_bars_between_signals": 4, "minimum_move_atr": 0.25, "minimum_sample": 30, "minimum_pf": 1.10, "minimum_expectancy": 0.0, "virtual_equity": 10000.0, "risk_percent": 1.0, "max_position_percent": 25.0, "commission_rate": 0.0005,
    }],
}