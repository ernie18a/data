import numpy as np

def i5_illiquidity(return_t: float, close: float, volume: float) -> float:
    return abs(return_t) / (close * volume)

def i5_liquidity_k(illiq: float, mean: float, std: float, k_base: float, phi: float) -> float:
    return k_base * (1.0 + phi * max(0.0, (illiq - mean) / std))

def i5_reversion(side: int, previous_z: float, z: float, z_entry: float, mult: float, cumulative_volume: float, volume_target: float) -> bool:
    return side * previous_z <= 0.0 < side * z or abs(z) > mult * abs(z_entry) or cumulative_volume >= volume_target

def i5_stop(side: int, previous_stop: float, best: float, k: float, atr: float) -> float:
    return side * max(side * previous_stop, side * (best - side * k * atr))

def i5_vwap_z(close: float, volume_sum: float, price_volume_sum: float, centered_square_volume_sum: float) -> float:
    from math import sqrt
    return (close - price_volume_sum / volume_sum) / sqrt(centered_square_volume_sum / volume_sum)

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, long_exits, short_entries, short_exits)
    try:
        k_base = float(signal_params['k_base'])
        phi = float(signal_params['phi'])
        mult = float(signal_params['mult'])
    except (KeyError, TypeError, ValueError):
        return (long_entries, long_exits, short_entries, short_exits)
    if not np.isfinite(k_base) or k_base <= 0.0 or (not np.isfinite(phi)) or (phi < 0.0) or (not np.isfinite(mult)) or (mult <= 0.0):
        return (long_entries, long_exits, short_entries, short_exits)
    raw_volume_target = signal_params.get('volume_target', np.nan)
    try:
        volume_target = float(raw_volume_target)
    except (TypeError, ValueError):
        volume_target = np.nan
    has_volume_target = np.isfinite(volume_target) and volume_target > 0.0
    opens = market.opens
    highs = market.highs
    lows = market.lows
    closes = market.closes
    volumes = market.volumes
    atr = features.atr(14)
    q_long = np.zeros(size, dtype=np.bool_)
    q_short = np.zeros(size, dtype=np.bool_)
    for t in range(1, size):
        if np.isfinite(lows[t]) and np.isfinite(lows[t - 1]) and np.isfinite(closes[t]) and np.isfinite(opens[t - 1]) and (lows[t] < lows[t - 1]) and (closes[t] > opens[t - 1]):
            q_long[t] = True
        if np.isfinite(highs[t]) and np.isfinite(highs[t - 1]) and np.isfinite(closes[t]) and np.isfinite(opens[t - 1]) and (highs[t] > highs[t - 1]) and (closes[t] < opens[t - 1]):
            q_short[t] = True
    for t in range(1, size):
        long_entries[t] = q_long[t] and (not q_long[t - 1])
        short_entries[t] = q_short[t] and (not q_short[t - 1])
    liquidity_k = np.full(size, np.nan, dtype=np.float64)
    count = 0
    mean_illiq = 0.0
    centered_sum = 0.0
    for t in range(size):
        if t < 1 or not np.isfinite(closes[t]) or (not np.isfinite(closes[t - 1])) or (not np.isfinite(volumes[t])) or (closes[t] <= 0.0) or (closes[t - 1] == 0.0) or (volumes[t] <= 0.0):
            continue
        return_t = closes[t] / closes[t - 1] - 1.0
        illiq = i5_illiquidity(return_t, closes[t], volumes[t])
        if not np.isfinite(illiq):
            continue
        count += 1
        delta = illiq - mean_illiq
        mean_illiq += delta / count
        centered_sum += delta * (illiq - mean_illiq)
        if count > 1:
            std_illiq = np.sqrt(centered_sum / count)
            if np.isfinite(std_illiq) and std_illiq > 0.0:
                liquidity_k[t] = i5_liquidity_k(illiq, mean_illiq, std_illiq, k_base, phi)
    position = 0
    pending_exit = False
    best_price = np.nan
    current_stop = np.nan
    cumulative_volume = np.nan
    sum_volume = np.nan
    sum_price_volume = np.nan
    sum_price_square_volume = np.nan
    z_entry = np.nan
    previous_z = np.nan
    for t in range(size):
        block_entry = False
        if pending_exit:
            position = 0
            pending_exit = False
            block_entry = True
            best_price = np.nan
            current_stop = np.nan
            cumulative_volume = np.nan
            sum_volume = np.nan
            sum_price_volume = np.nan
            sum_price_square_volume = np.nan
            z_entry = np.nan
            previous_z = np.nan
        entered_now = False
        if position == 0 and (not block_entry) and (t > 0):
            if long_entries[t - 1] and (not short_entries[t - 1]):
                position = 1
                entered_now = True
            elif short_entries[t - 1] and (not long_entries[t - 1]):
                position = -1
                entered_now = True
            if entered_now:
                best_price = highs[t] if np.isfinite(highs[t]) else np.nan
                if np.isfinite(volumes[t]) and volumes[t] > 0.0:
                    cumulative_volume = volumes[t]
                else:
                    cumulative_volume = np.nan
                if np.isfinite(closes[t]) and np.isfinite(volumes[t]) and (volumes[t] > 0.0):
                    sum_volume = volumes[t]
                    sum_price_volume = closes[t] * volumes[t]
                    sum_price_square_volume = closes[t] * closes[t] * volumes[t]
                else:
                    sum_volume = np.nan
                    sum_price_volume = np.nan
                    sum_price_square_volume = np.nan
                if np.isfinite(best_price) and np.isfinite(liquidity_k[t]) and np.isfinite(atr[t]) and (atr[t] > 0.0):
                    initial_stop = best_price - position * liquidity_k[t] * atr[t]
                    current_stop = i5_stop(position, initial_stop, best_price, liquidity_k[t], atr[t])
                else:
                    current_stop = np.nan
                z_entry = np.nan
                previous_z = np.nan
        if position == 0:
            continue
        if not entered_now:
            if position == 1 and np.isfinite(highs[t]):
                best_price = max(best_price, highs[t])
            elif position == -1 and np.isfinite(lows[t]):
                best_price = min(best_price, lows[t])
            if np.isfinite(closes[t]) and np.isfinite(volumes[t]) and (volumes[t] > 0.0):
                if np.isfinite(sum_volume):
                    sum_volume += volumes[t]
                    sum_price_volume += closes[t] * volumes[t]
                    sum_price_square_volume += closes[t] * closes[t] * volumes[t]
                if np.isfinite(cumulative_volume):
                    cumulative_volume += volumes[t]
            if np.isfinite(current_stop) and np.isfinite(best_price) and np.isfinite(liquidity_k[t]) and np.isfinite(atr[t]) and (atr[t] > 0.0):
                current_stop = i5_stop(position, current_stop, best_price, liquidity_k[t], atr[t])
        stop_touched = False
        if np.isfinite(current_stop):
            if position == 1 and np.isfinite(lows[t]):
                stop_touched = lows[t] < current_stop
            elif position == -1 and np.isfinite(highs[t]):
                stop_touched = highs[t] > current_stop
        reversion_touched = False
        if np.isfinite(sum_volume) and sum_volume > 0.0 and np.isfinite(sum_price_volume) and np.isfinite(sum_price_square_volume) and np.isfinite(closes[t]):
            vwap = sum_price_volume / sum_volume
            centered_square_volume_sum = sum_price_square_volume - sum_price_volume * sum_price_volume / sum_volume
            if np.isfinite(vwap) and np.isfinite(centered_square_volume_sum) and (centered_square_volume_sum > 0.0):
                z = i5_vwap_z(closes[t], sum_volume, sum_price_volume, centered_square_volume_sum)
                if np.isfinite(z):
                    if not np.isfinite(z_entry):
                        z_entry = z
                    elif np.isfinite(previous_z):
                        if has_volume_target and np.isfinite(cumulative_volume):
                            reversion_touched = i5_reversion(position, previous_z, z, z_entry, mult, cumulative_volume, volume_target)
                        else:
                            reversion_touched = position * previous_z <= 0.0 < position * z or abs(z) > mult * abs(z_entry)
                    previous_z = z
        if stop_touched or reversion_touched:
            if position == 1:
                long_exits[t] = True
            else:
                short_exits[t] = True
            pending_exit = True
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'prior_candle_sweep_reversal', 'hypothesis': '前一根K棒高低點被掃掠後收回前一根開盤價，形成反轉訊號；以ATR流動性停損與進場錨定VWAP偏離出場。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'phi', 'mult'], 'signal_parameter_sets': [{'k_base': 1.5, 'phi': 0.0, 'mult': 1.5}, {'k_base': 1.5, 'phi': 0.0, 'mult': 2.0}, {'k_base': 1.5, 'phi': 0.5, 'mult': 1.5}, {'k_base': 1.5, 'phi': 0.5, 'mult': 2.0}, {'k_base': 2.5, 'phi': 0.0, 'mult': 1.5}, {'k_base': 2.5, 'phi': 0.0, 'mult': 2.0}, {'k_base': 2.5, 'phi': 0.5, 'mult': 1.5}, {'k_base': 2.5, 'phi': 0.5, 'mult': 2.0}, {'k_base': 3.5, 'phi': 0.0, 'mult': 1.5}, {'k_base': 3.5, 'phi': 0.0, 'mult': 2.0}, {'k_base': 3.5, 'phi': 0.5, 'mult': 1.5}, {'k_base': 3.5, 'phi': 0.5, 'mult': 2.0}]}
