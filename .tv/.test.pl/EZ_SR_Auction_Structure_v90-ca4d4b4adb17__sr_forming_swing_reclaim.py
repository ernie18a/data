import numpy as np


def _finite_array(values, size):
    array = np.asarray(values, dtype=float).reshape(-1)
    if array.size != size:
        raise ValueError("market series must have features.market.size elements")
    return array


def _atr_from_ohlc(highs, lows, closes, length):
    size = closes.size
    true_range = np.full(size, np.nan, dtype=float)
    if size:
        true_range[0] = highs[0] - lows[0]
    if size > 1:
        true_range[1:] = np.maximum(
            highs[1:] - lows[1:],
            np.maximum(
                np.abs(highs[1:] - closes[:-1]),
                np.abs(lows[1:] - closes[:-1]),
            ),
        )
    result = np.full(size, np.nan, dtype=float)
    for index in range(length - 1, size):
        window = true_range[index + 1 - length:index + 1]
        if np.all(np.isfinite(window)):
            if index == length - 1:
                result[index] = np.mean(window)
            elif np.isfinite(result[index - 1]):
                result[index] = (result[index - 1] * (length - 1) + true_range[index]) / length
    return result


def _atr(features, highs, lows, closes, length):
    try:
        values = np.asarray(features.atr(length), dtype=float).reshape(-1)
        if values.size == 1:
            return np.full(closes.size, values[0], dtype=float)
        if values.size == closes.size:
            return values
    except (AttributeError, TypeError, ValueError):
        pass
    return _atr_from_ohlc(highs, lows, closes, length)


def _number(params, name, default, lower=0.0):
    try:
        value = float(params.get(name, default))
    except (AttributeError, TypeError, ValueError):
        value = float(default)
    if not np.isfinite(value):
        value = float(default)
    return max(lower, value)


def _integer(params, name, default, lower=1):
    return max(lower, int(round(_number(params, name, default, lower))))


def _fresh_origins(values, strength):
    size = values.size
    origins = np.full(size, -1, dtype=np.int64)
    latest = -1
    for index in range(size):
        start = max(0, index - strength)
        if np.isfinite(values[index]) and values[index] <= np.nanmin(values[start:index + 1]):
            latest = index
        origins[index] = latest
    return origins


def _confirmed_pivots(values, strength):
    confirmed = np.full(values.size, -1, dtype=np.int64)
    for current in range(2 * strength, values.size):
        origin = current - strength
        window = values[origin - strength:origin + strength + 1]
        if np.all(np.isfinite(window)) and values[origin] == np.min(window):
            confirmed[current] = origin
    return confirmed


def _zone(origin, opens, closes, values, atr, padding):
    if origin < 0 or not np.isfinite(values[origin]) or not np.isfinite(atr[origin]):
        return np.nan, np.nan
    edge = values[origin]
    body_edge = min(opens[origin], closes[origin])
    return max(body_edge, edge + atr[origin] * padding), edge


def _rolling_mean(values, length):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index + 1 - length:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    opens = _finite_array(market.opens, size)
    highs = _finite_array(market.highs, size)
    lows = _finite_array(market.lows, size)
    closes = _finite_array(market.closes, size)
    volumes = _finite_array(market.volumes, size)

    atr_length = _integer(signal_params, "atr_length", 14)
    pivot_strength = _integer(signal_params, "sr_pivot_strength", 3)
    zone_atr_length = _integer(signal_params, "sr_atr_length", 14)
    padding = _number(signal_params, "sr_minimum_padding_atr", 0.10)
    micro_length = _integer(signal_params, "micro_length", 2)
    rejection_ratio = _number(signal_params, "rejection_wick_body", 1.20)
    close_threshold = _number(signal_params, "strong_close_location", 0.65)
    displacement_atr = _number(signal_params, "displacement_atr", 0.80)
    displacement_body_pct = _number(signal_params, "displacement_body_pct", 0.60)
    use_relative_volume = bool(signal_params.get("use_relative_volume", False))
    relative_volume_length = _integer(signal_params, "relative_volume_length", 20)
    relative_volume_multiple = _number(signal_params, "relative_volume_multiple", 1.20)
    instant_max_bars = _integer(signal_params, "instant_swing_max_bars", 1, 0)
    cooldown = _integer(signal_params, "entry_cooldown_bars", 5, 0)
    use_bias = bool(signal_params.get("use_chart_tf_bias", True))

    reaction_atr = _atr(features, highs, lows, closes, atr_length)
    zone_atr = _atr(features, highs, lows, closes, zone_atr_length)
    low_origins = _fresh_origins(lows, pivot_strength)
    high_origins = _fresh_origins(highs, pivot_strength)
    low_confirmations = _confirmed_pivots(lows, pivot_strength)
    high_confirmations = _confirmed_pivots(highs, pivot_strength)

    support_origin = np.full(size, -1, dtype=np.int64)
    support_top = np.full(size, np.nan)
    support_bottom = np.full(size, np.nan)
    resistance_origin = np.full(size, -1, dtype=np.int64)
    resistance_top = np.full(size, np.nan)
    resistance_bottom = np.full(size, np.nan)

    active_support = -1
    active_support_top = np.nan
    active_support_bottom = np.nan
    active_resistance = -1
    active_resistance_top = np.nan
    active_resistance_bottom = np.nan

    for index in range(size):
        if low_confirmations[index] >= 0:
            active_support = int(low_confirmations[index])
            active_support_top, active_support_bottom = _zone(
                active_support, opens, closes, lows, zone_atr, padding
            )
        if high_confirmations[index] >= 0:
            active_resistance = int(high_confirmations[index])
            active_resistance_top, active_resistance_bottom = _zone(
                active_resistance, opens, closes, highs, zone_atr, padding
            )
        if active_support >= 0 and closes[index] < active_support_bottom:
            active_support = -1
            active_support_top = np.nan
            active_support_bottom = np.nan
        if active_resistance >= 0 and closes[index] > active_resistance_top:
            active_resistance = -1
            active_resistance_top = np.nan
            active_resistance_bottom = np.nan
        support_origin[index] = active_support
        support_top[index] = active_support_top
        support_bottom[index] = active_support_bottom
        resistance_origin[index] = active_resistance
        resistance_top[index] = active_resistance_top
        resistance_bottom[index] = active_resistance_bottom

    ranges = np.maximum(highs - lows, np.finfo(float).eps)
    bodies = np.abs(closes - opens)
    upper_wicks = highs - np.maximum(opens, closes)
    lower_wicks = np.minimum(opens, closes) - lows
    close_location = (closes - lows) / ranges
    body_pct = bodies / ranges
    prior_high = np.full(size, np.nan)
    prior_low = np.full(size, np.nan)
    for index in range(micro_length, size):
        high_window = highs[index - micro_length:index]
        low_window = lows[index - micro_length:index]
        if np.all(np.isfinite(high_window)):
            prior_high[index] = np.max(high_window)
        if np.all(np.isfinite(low_window)):
            prior_low[index] = np.min(low_window)

    bullish_rejection = (
        (closes > opens)
        & (lower_wicks >= bodies * rejection_ratio)
        & (close_location >= close_threshold)
    )
    bearish_rejection = (
        (closes < opens)
        & (upper_wicks >= bodies * rejection_ratio)
        & (close_location <= 1.0 - close_threshold)
    )
    bullish_displacement = (
        (closes > opens)
        & (ranges >= reaction_atr * displacement_atr)
        & (body_pct >= displacement_body_pct)
    )
    bearish_displacement = (
        (closes < opens)
        & (ranges >= reaction_atr * displacement_atr)
        & (body_pct >= displacement_body_pct)
    )
    bullish_micro = np.isfinite(prior_high) & (closes > prior_high)
    bearish_micro = np.isfinite(prior_low) & (closes < prior_low)
    volume_average = _rolling_mean(volumes, relative_volume_length)
    high_relative_volume = (
        use_relative_volume
        & np.isfinite(volume_average)
        & (volumes >= volume_average * relative_volume_multiple)
    )
    bullish_volume = high_relative_volume & (closes > opens) & (close_location >= close_threshold)
    bearish_volume = high_relative_volume & (closes < opens) & (close_location <= 1.0 - close_threshold)
    bullish_reaction = bullish_rejection | bullish_displacement | bullish_micro | bullish_volume
    bearish_reaction = bearish_rejection | bearish_displacement | bearish_micro | bearish_volume

    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    entry_long_origin = np.full(size, -1, dtype=np.int64)
    entry_short_origin = np.full(size, -1, dtype=np.int64)
    last_long_entry = -10**9
    last_short_entry = -10**9

    for index in range(size):
        low_origin = (
            int(low_origins[index])
            if low_origins[index] >= 0 and index - low_origins[index] <= pivot_strength
            else -1
        )
        high_origin = (
            int(high_origins[index])
            if high_origins[index] >= 0 and index - high_origins[index] <= pivot_strength
            else -1
        )
        low_age = index - low_origin if low_origin >= 0 else 10**9
        high_age = index - high_origin if high_origin >= 0 else 10**9
        low_top, low_bottom = _zone(low_origin, opens, closes, lows, zone_atr, padding)
        high_top, high_bottom = _zone(high_origin, opens, closes, highs, zone_atr, padding)

        forming_long = (
            low_origin >= 0
            and low_age <= instant_max_bars
            and np.isfinite(low_top)
            and closes[index] > low_top
            and bullish_reaction[index]
        )
        forming_short = (
            high_origin >= 0
            and high_age <= instant_max_bars
            and np.isfinite(high_bottom)
            and closes[index] < high_bottom
            and bearish_reaction[index]
        )

        latest_low = max(low_origin, int(support_origin[index]))
        latest_high = max(high_origin, int(resistance_origin[index]))
        bias_long_ok = not use_bias or latest_low > latest_high
        bias_short_ok = not use_bias or latest_high > latest_low
        same_origin = low_origin >= 0 and high_origin >= 0 and low_origin == high_origin
        if same_origin:
            forming_long = False
            forming_short = False

        instant_long = forming_long and bias_long_ok and index - last_long_entry >= cooldown
        instant_short = forming_short and bias_short_ok and index - last_short_entry >= cooldown
        confirmed_long = (
            low_confirmations[index] >= 0
            and np.isfinite(support_top[index])
            and closes[index] > support_top[index]
            and bias_long_ok
            and index - last_long_entry >= cooldown
        )
        confirmed_short = (
            high_confirmations[index] >= 0
            and np.isfinite(resistance_bottom[index])
            and closes[index] < resistance_bottom[index]
            and bias_short_ok
            and index - last_short_entry >= cooldown
        )

        if instant_long or confirmed_long:
            long_entries[index] = True
            entry_long_origin[index] = low_origin if instant_long else low_confirmations[index]
            last_long_entry = index
        if instant_short or confirmed_short:
            short_entries[index] = True
            entry_short_origin[index] = high_origin if instant_short else high_confirmations[index]
            last_short_entry = index
        if long_entries[index] and short_entries[index]:
            long_entries[index] = False
            short_entries[index] = False
            entry_long_origin[index] = -1
            entry_short_origin[index] = -1

    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    position = 0
    trade_origin = -1
    trade_bottom = np.nan
    trade_top = np.nan
    trade_validated = False

    for index in range(size):
        if position == 1 and trade_origin >= 0:
            confirmation_bar = trade_origin + pivot_strength
            if not trade_validated and confirmation_bar < size and index >= confirmation_bar:
                if support_origin[index] == trade_origin:
                    trade_validated = True
                    trade_bottom = support_bottom[index]
                    trade_top = support_top[index]
                elif index > trade_origin + pivot_strength + 2:
                    long_exits[index] = True
                    position = 0
            if position == 1 and support_origin[index] > trade_origin:
                long_exits[index] = True
                position = 0
            if position == 1 and trade_validated and support_origin[index] != trade_origin:
                long_exits[index] = True
                position = 0
            if position == 1 and np.isfinite(trade_bottom) and closes[index] < trade_bottom:
                long_exits[index] = True
                position = 0

        elif position == -1 and trade_origin >= 0:
            confirmation_bar = trade_origin + pivot_strength
            if not trade_validated and confirmation_bar < size and index >= confirmation_bar:
                if resistance_origin[index] == trade_origin:
                    trade_validated = True
                    trade_top = resistance_top[index]
                    trade_bottom = resistance_bottom[index]
                elif index > trade_origin + pivot_strength + 2:
                    short_exits[index] = True
                    position = 0
            if position == -1 and resistance_origin[index] > trade_origin:
                short_exits[index] = True
                position = 0
            if position == -1 and trade_validated and resistance_origin[index] != trade_origin:
                short_exits[index] = True
                position = 0
            if position == -1 and np.isfinite(trade_top) and closes[index] > trade_top:
                short_exits[index] = True
                position = 0

        if position == 0:
            if long_entries[index] and not short_entries[index]:
                position = 1
                trade_origin = int(entry_long_origin[index])
                trade_top, trade_bottom = _zone(trade_origin, opens, closes, lows, zone_atr, padding)
                confirmation_bar = trade_origin + pivot_strength
                trade_validated = (
                    trade_origin >= 0
                    and confirmation_bar < size
                    and support_origin[confirmation_bar] == trade_origin
                )
                if trade_validated:
                    trade_top = support_top[confirmation_bar]
                    trade_bottom = support_bottom[confirmation_bar]
            elif short_entries[index] and not long_entries[index]:
                position = -1
                trade_origin = int(entry_short_origin[index])
                trade_top, trade_bottom = _zone(trade_origin, opens, closes, highs, zone_atr, padding)
                confirmation_bar = trade_origin + pivot_strength
                trade_validated = (
                    trade_origin >= 0
                    and confirmation_bar < size
                    and resistance_origin[confirmation_bar] == trade_origin
                )
                if trade_validated:
                    trade_top = resistance_top[confirmation_bar]
                    trade_bottom = resistance_bottom[confirmation_bar]

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "sr_forming_swing_reclaim",
    "hypothesis": "圖表週期的支撐/阻力局部極值在反應與結構偏向一致時，突破區域邊緣可形成短期延續。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "atr_length",
        "sr_pivot_strength",
        "sr_atr_length",
        "sr_minimum_padding_atr",
        "micro_length",
        "rejection_wick_body",
        "strong_close_location",
        "displacement_atr",
        "displacement_body_pct",
        "use_relative_volume",
        "relative_volume_length",
        "relative_volume_multiple",
        "instant_swing_max_bars",
        "entry_cooldown_bars",
        "use_chart_tf_bias",
    ],
    "signal_parameter_sets": [{
        "atr_length": 14,
        "sr_pivot_strength": 3,
        "sr_atr_length": 14,
        "sr_minimum_padding_atr": 0.10,
        "micro_length": 2,
        "rejection_wick_body": 1.20,
        "strong_close_location": 0.65,
        "displacement_atr": 0.80,
        "displacement_body_pct": 0.60,
        "use_relative_volume": False,
        "relative_volume_length": 20,
        "relative_volume_multiple": 1.20,
        "instant_swing_max_bars": 1,
        "entry_cooldown_bars": 5,
        "use_chart_tf_bias": True,
    }],
}