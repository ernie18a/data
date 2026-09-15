import numpy as np

def i5_illiquidity(return_t: float, close: float, volume: float) -> float:
    return abs(return_t) / (close * volume)

def i5_liquidity_k(illiq: float, mean: float, std: float, k_base: float, phi: float) -> float:
    return k_base * (1.0 + phi * max(0.0, (illiq - mean) / std))

def i5_reversion(side: int, previous_z: float, z: float, z_entry: float, mult: float, cumulative_volume: float, volume_target: float) -> bool:
    return side * previous_z <= 0.0 < side * z or abs(z) > mult * abs(z_entry) or cumulative_volume >= volume_target

def i5_stop(side: int, previous_stop: float, best: float, k: float, atr: float) -> float:
    return side * max(side * previous_stop, side * (best - side * k * atr))

def i5_stop_touched(side: int, low: float, high: float, stop: float) -> bool:
    return side == 1 and low < stop or (side == -1 and high > stop)

def i5_vwap_z(close: float, volume_sum: float, price_volume_sum: float, centered_square_volume_sum: float) -> float:
    from math import sqrt
    return (close - price_volume_sum / volume_sum) / sqrt(centered_square_volume_sum / volume_sum)

def iter_signal_parameter_sets():
    for k_base in (1.5, 2.5, 3.5):
        for phi in (0.0, 0.5):
            for mult in (1.5, 2.0):
                for volume_target in (1000.0, 5000.0, 10000.0):
                    yield {'k_base': k_base, 'phi': phi, 'mult': mult, 'volume_target': volume_target}

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, long_exits, short_entries, short_exits)
    opens = features.market.opens
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    volumes = features.market.volumes
    lookback = 20
    pivot_low = np.nan
    pivot_high = np.nan
    for t in range(size):
        if t >= 2 * lookback:
            pivot_bar = t - lookback
            pivot_window = lows[t - 2 * lookback:t + 1]
            if np.all(np.isfinite(pivot_window)):
                candidate = lows[pivot_bar]
                if candidate == np.min(pivot_window):
                    pivot_low = candidate
            pivot_window = highs[t - 2 * lookback:t + 1]
            if np.all(np.isfinite(pivot_window)):
                candidate = highs[pivot_bar]
                if candidate == np.max(pivot_window):
                    pivot_high = candidate
        if t < lookback or not np.isfinite(opens[t]):
            continue
        recent_lows = lows[t - lookback + 1:t + 1]
        recent_highs = highs[t - lookback + 1:t + 1]
        recent_closes = closes[t - lookback + 1:t + 1]
        if np.isfinite(pivot_low) and np.isfinite(lows[t]) and np.isfinite(closes[t]) and np.all(np.isfinite(recent_lows)) and np.all(np.isfinite(recent_closes)):
            long_entries[t] = bool(lows[t] < pivot_low and closes[t] > pivot_low and (opens[t] > pivot_low) and (lows[t] == np.min(recent_lows)) and (np.min(recent_closes) >= pivot_low))
        if np.isfinite(pivot_high) and np.isfinite(highs[t]) and np.isfinite(closes[t]) and np.all(np.isfinite(recent_highs)) and np.all(np.isfinite(recent_closes)):
            short_entries[t] = bool(highs[t] > pivot_high and closes[t] < pivot_high and (opens[t] < pivot_high) and (highs[t] == np.max(recent_highs)) and (np.max(recent_closes) <= pivot_high))
    atr = features.atr(14)
    illiquidity = np.full(size, np.nan, dtype=np.float64)
    for t in range(1, size):
        if np.isfinite(closes[t]) and np.isfinite(closes[t - 1]) and np.isfinite(volumes[t]) and (closes[t] > 0.0) and (closes[t - 1] > 0.0) and (volumes[t] > 0.0):
            return_t = closes[t] / closes[t - 1] - 1.0
            if np.isfinite(return_t):
                illiquidity[t] = i5_illiquidity(return_t, closes[t], volumes[t])
    k_base = float(signal_params['k_base'])
    phi = float(signal_params['phi'])
    mult = float(signal_params['mult'])
    volume_target = float(signal_params['volume_target'])
    window = 20
    position = 0
    best = np.nan
    current_stop = np.nan
    stop_ready = False
    cumulative_volume = 0.0
    price_volume_sum = 0.0
    price_square_volume_sum = 0.0
    z_entry = np.nan
    previous_z = np.nan
    previous_z_ready = False
    for t in range(size):
        if position == 0 and t > 0:
            previous_signal_was_exit = bool(long_exits[t - 1] or short_exits[t - 1])
            if not previous_signal_was_exit:
                if long_entries[t - 1] and (not short_entries[t - 1]):
                    position = 1
                    best = highs[t]
                    current_stop = np.nan
                    stop_ready = False
                    cumulative_volume = 0.0
                    price_volume_sum = 0.0
                    price_square_volume_sum = 0.0
                    z_entry = np.nan
                    previous_z = np.nan
                    previous_z_ready = False
                elif short_entries[t - 1] and (not long_entries[t - 1]):
                    position = -1
                    best = lows[t]
                    current_stop = np.nan
                    stop_ready = False
                    cumulative_volume = 0.0
                    price_volume_sum = 0.0
                    price_square_volume_sum = 0.0
                    z_entry = np.nan
                    previous_z = np.nan
                    previous_z_ready = False
        if position == 0:
            continue
        base_inputs_ready = bool(np.isfinite(highs[t]) and np.isfinite(lows[t]) and np.isfinite(closes[t]) and np.isfinite(volumes[t]) and (volumes[t] > 0.0))
        if base_inputs_ready:
            if position == 1:
                best = max(best, highs[t])
            else:
                best = min(best, lows[t])
            cumulative_volume += volumes[t]
            price_volume_sum += closes[t] * volumes[t]
            price_square_volume_sum += closes[t] * closes[t] * volumes[t]
        liquidity_ready = False
        k_t = np.nan
        if t >= window - 1:
            illiq_window = illiquidity[t - window + 1:t + 1]
            if np.all(np.isfinite(illiq_window)):
                mean_w = float(np.mean(illiq_window))
                std_w = float(np.std(illiq_window))
                if np.isfinite(mean_w) and np.isfinite(std_w) and (std_w > 0.0) and np.isfinite(atr[t]) and (atr[t] > 0.0):
                    k_t = i5_liquidity_k(illiquidity[t], mean_w, std_w, k_base, phi)
                    liquidity_ready = bool(np.isfinite(k_t) and k_t > 0.0)
        if liquidity_ready and base_inputs_ready:
            if not stop_ready:
                if position == 1:
                    current_stop = i5_stop(1, -np.inf, best, k_t, atr[t])
                else:
                    current_stop = i5_stop(-1, np.inf, best, k_t, atr[t])
                stop_ready = True
            else:
                current_stop = i5_stop(position, current_stop, best, k_t, atr[t])
            stop_hit = i5_stop_touched(position, lows[t], highs[t], current_stop)
            if stop_hit:
                if position == 1:
                    long_exits[t] = True
                else:
                    short_exits[t] = True
                position = 0
                best = np.nan
                current_stop = np.nan
                stop_ready = False
                cumulative_volume = 0.0
                price_volume_sum = 0.0
                price_square_volume_sum = 0.0
                z_entry = np.nan
                previous_z = np.nan
                previous_z_ready = False
                continue
            if cumulative_volume > 0.0:
                vwap = price_volume_sum / cumulative_volume
                centered_square_volume_sum = price_square_volume_sum - 2.0 * vwap * price_volume_sum + vwap * vwap * cumulative_volume
                if np.isfinite(vwap) and np.isfinite(centered_square_volume_sum) and (centered_square_volume_sum > 0.0):
                    z = i5_vwap_z(closes[t], cumulative_volume, price_volume_sum, centered_square_volume_sum)
                    if np.isfinite(z):
                        if np.isfinite(z_entry):
                            previous_for_formula = previous_z if previous_z_ready else z
                            if i5_reversion(position, previous_for_formula, z, z_entry, mult, cumulative_volume, volume_target):
                                if position == 1:
                                    long_exits[t] = True
                                else:
                                    short_exits[t] = True
                                position = 0
                                best = np.nan
                                current_stop = np.nan
                                stop_ready = False
                                cumulative_volume = 0.0
                                price_volume_sum = 0.0
                                price_square_volume_sum = 0.0
                                z_entry = np.nan
                                previous_z = np.nan
                                previous_z_ready = False
                                continue
                            previous_z = z
                            previous_z_ready = True
                        else:
                            z_entry = z
                            previous_z = z
                            previous_z_ready = True
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'confirmed_pivot_sweep_reversal', 'hypothesis': 'Confirmed pivot liquidity sweeps that reclaim the pivot level may reverse toward anchored mean value.', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'phi', 'mult', 'volume_target'], 'signal_parameter_sets': iter_signal_parameter_sets}
