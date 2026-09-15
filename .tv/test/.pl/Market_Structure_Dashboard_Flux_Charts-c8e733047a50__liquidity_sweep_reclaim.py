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

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (long_entries, long_exits, short_entries, short_exits)
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    volumes = features.market.volumes
    atr = features.atr(14)
    k_base = float(signal_params['k_base'])
    phi = float(signal_params['phi'])
    mult = float(signal_params['mult'])
    swing_length = 5
    volume_window = 20
    returns = np.full(size, np.nan, dtype=np.float64)
    for t in range(1, size):
        if np.isfinite(closes[t]) and np.isfinite(closes[t - 1]) and (closes[t - 1] > 0.0):
            returns[t] = closes[t] / closes[t - 1] - 1.0
    raw_long = np.zeros(size, dtype=np.bool_)
    raw_short = np.zeros(size, dtype=np.bool_)
    current_high = None
    current_low = None
    low_broken = False
    high_broken = False
    previous_low_reclaim = False
    previous_high_reclaim = False
    for t in range(size):
        new_swing_high = False
        new_swing_low = False
        center = t - swing_length
        if center >= swing_length and t + 1 >= center + swing_length + 1:
            high_window = highs[center - swing_length:t + 1]
            low_window = lows[center - swing_length:t + 1]
            if np.all(np.isfinite(high_window)) and np.all(np.isfinite(low_window)):
                new_swing_high = highs[center] > np.max(highs[center - swing_length:center]) and highs[center] > np.max(highs[center + 1:t + 1])
                new_swing_low = lows[center] < np.min(lows[center - swing_length:center]) and lows[center] < np.min(lows[center + 1:t + 1])
        if new_swing_high:
            current_high = float(highs[center])
            high_broken = False
            previous_high_reclaim = False
        if new_swing_low:
            current_low = float(lows[center])
            low_broken = False
            previous_low_reclaim = False
        if current_low is not None and np.isfinite(lows[t]) and (lows[t] < current_low):
            low_broken = True
        if current_high is not None and np.isfinite(highs[t]) and (highs[t] > current_high):
            high_broken = True
        low_reclaim = current_low is not None and low_broken and np.isfinite(closes[t]) and (closes[t] > current_low)
        high_reclaim = current_high is not None and high_broken and np.isfinite(closes[t]) and (closes[t] < current_high)
        data_ready = t >= volume_window and np.isfinite(closes[t]) and (closes[t] > 0.0) and np.isfinite(atr[t]) and (atr[t] > 0.0) and np.all(np.isfinite(volumes[t - volume_window:t + 1])) and np.all(volumes[t - volume_window:t + 1] > 0.0)
        if data_ready and low_reclaim and (not previous_low_reclaim):
            raw_long[t] = True
        if data_ready and high_reclaim and (not previous_high_reclaim):
            raw_short[t] = True
        previous_low_reclaim = bool(low_reclaim)
        previous_high_reclaim = bool(high_reclaim)
    position = 0
    entry_index = -1
    best_price = np.nan
    current_stop = np.nan
    cumulative_volume = 0.0
    volume_sum = 0.0
    price_volume_sum = 0.0
    price_square_volume_sum = 0.0
    volume_target = np.nan
    z_entry = None
    previous_z = None
    state_ready = False
    for t in range(size):
        exited_this_bar = False
        if position == 1 and t > 0 and long_exits[t - 1]:
            position = 0
            state_ready = False
            exited_this_bar = True
        elif position == -1 and t > 0 and short_exits[t - 1]:
            position = 0
            state_ready = False
            exited_this_bar = True
        if position == 0 and (not exited_this_bar) and (t > 0):
            if long_entries[t - 1] and (not short_entries[t - 1]):
                position = 1
                entry_index = t
                state_ready = np.isfinite(highs[t]) and np.isfinite(lows[t]) and np.isfinite(closes[t]) and (closes[t] > 0.0) and np.isfinite(volumes[t]) and (volumes[t] > 0.0) and np.isfinite(atr[t]) and (atr[t] > 0.0) and (t >= volume_window) and np.all(np.isfinite(returns[t - volume_window + 1:t + 1])) and np.all(np.isfinite(volumes[t - volume_window:t])) and np.all(volumes[t - volume_window:t] > 0.0)
                if state_ready:
                    best_price = highs[t]
                    window = returns[t - volume_window + 1:t + 1]
                    mean_w = float(np.mean(window))
                    std_w = float(np.std(window))
                    illiq = i5_illiquidity(float(returns[t]), float(closes[t]), float(volumes[t]))
                    k_value = i5_liquidity_k(illiq, mean_w, std_w, k_base, phi) if std_w > 0.0 else np.nan
                    current_stop = i5_stop(1, -np.inf, best_price, k_value, atr[t]) if np.isfinite(k_value) else np.nan
                    cumulative_volume = volumes[t]
                    volume_sum = volumes[t]
                    price_volume_sum = closes[t] * volumes[t]
                    price_square_volume_sum = closes[t] * closes[t] * volumes[t]
                    volume_target = 20.0 * float(np.mean(volumes[t - volume_window:t]))
                    z_entry = None
                    previous_z = None
            elif short_entries[t - 1] and (not long_entries[t - 1]):
                position = -1
                entry_index = t
                state_ready = np.isfinite(highs[t]) and np.isfinite(lows[t]) and np.isfinite(closes[t]) and (closes[t] > 0.0) and np.isfinite(volumes[t]) and (volumes[t] > 0.0) and np.isfinite(atr[t]) and (atr[t] > 0.0) and (t >= volume_window) and np.all(np.isfinite(returns[t - volume_window + 1:t + 1])) and np.all(np.isfinite(volumes[t - volume_window:t])) and np.all(volumes[t - volume_window:t] > 0.0)
                if state_ready:
                    best_price = lows[t]
                    window = returns[t - volume_window + 1:t + 1]
                    mean_w = float(np.mean(window))
                    std_w = float(np.std(window))
                    illiq = i5_illiquidity(float(returns[t]), float(closes[t]), float(volumes[t]))
                    k_value = i5_liquidity_k(illiq, mean_w, std_w, k_base, phi) if std_w > 0.0 else np.nan
                    current_stop = i5_stop(-1, np.inf, best_price, k_value, atr[t]) if np.isfinite(k_value) else np.nan
                    cumulative_volume = volumes[t]
                    volume_sum = volumes[t]
                    price_volume_sum = closes[t] * volumes[t]
                    price_square_volume_sum = closes[t] * closes[t] * volumes[t]
                    volume_target = 20.0 * float(np.mean(volumes[t - volume_window:t]))
                    z_entry = None
                    previous_z = None
        if position == 0:
            if raw_long[t] and (not raw_short[t]):
                long_entries[t] = True
            elif raw_short[t] and (not raw_long[t]):
                short_entries[t] = True
        if position != 0 and state_ready:
            valid_bar = np.isfinite(highs[t]) and np.isfinite(lows[t]) and np.isfinite(closes[t]) and (closes[t] > 0.0) and np.isfinite(volumes[t]) and (volumes[t] > 0.0) and np.isfinite(atr[t]) and (atr[t] > 0.0) and np.isfinite(returns[t]) and (t >= volume_window)
            if valid_bar:
                if position == 1:
                    best_price = max(best_price, highs[t])
                else:
                    best_price = min(best_price, lows[t])
                window = returns[t - volume_window + 1:t + 1]
                if np.all(np.isfinite(window)):
                    mean_w = float(np.mean(window))
                    std_w = float(np.std(window))
                    if std_w > 0.0:
                        illiq = i5_illiquidity(float(returns[t]), float(closes[t]), float(volumes[t]))
                        k_value = i5_liquidity_k(illiq, mean_w, std_w, k_base, phi)
                        if np.isfinite(k_value):
                            current_stop = i5_stop(position, current_stop, best_price, k_value, atr[t])
                stop_touched = np.isfinite(current_stop) and i5_stop_touched(position, float(lows[t]), float(highs[t]), float(current_stop))
                if stop_touched:
                    if position == 1:
                        long_exits[t] = True
                    else:
                        short_exits[t] = True
                else:
                    if t > entry_index:
                        volume_sum += volumes[t]
                        price_volume_sum += closes[t] * volumes[t]
                        price_square_volume_sum += closes[t] * closes[t] * volumes[t]
                        cumulative_volume += volumes[t]
                    if volume_sum > 0.0:
                        vwap = price_volume_sum / volume_sum
                        centered_square_volume_sum = price_square_volume_sum - 2.0 * vwap * price_volume_sum + vwap * vwap * volume_sum
                        if centered_square_volume_sum > 0.0:
                            z_value = i5_vwap_z(float(closes[t]), float(volume_sum), float(price_volume_sum), float(centered_square_volume_sum))
                            if np.isfinite(z_value):
                                if z_entry is None:
                                    z_entry = z_value
                                    previous_z = z_value
                                if previous_z is not None and np.isfinite(volume_target):
                                    if i5_reversion(position, float(previous_z), float(z_value), float(z_entry), mult, float(cumulative_volume), float(volume_target)):
                                        if position == 1:
                                            long_exits[t] = True
                                        else:
                                            short_exits[t] = True
                                previous_z = z_value
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'liquidity_sweep_reclaim', 'hypothesis': '價格掃過已確認 swing level 並收回時，反轉方向的流動性掃掠訊號具有交易優勢。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'phi', 'mult'], 'signal_parameter_sets': [{'k_base': 1.5, 'phi': 0.0, 'mult': 1.5}, {'k_base': 1.5, 'phi': 0.0, 'mult': 2.0}, {'k_base': 1.5, 'phi': 0.5, 'mult': 1.5}, {'k_base': 1.5, 'phi': 0.5, 'mult': 2.0}, {'k_base': 2.5, 'phi': 0.0, 'mult': 1.5}, {'k_base': 2.5, 'phi': 0.0, 'mult': 2.0}, {'k_base': 2.5, 'phi': 0.5, 'mult': 1.5}, {'k_base': 2.5, 'phi': 0.5, 'mult': 2.0}, {'k_base': 3.5, 'phi': 0.0, 'mult': 1.5}, {'k_base': 3.5, 'phi': 0.0, 'mult': 2.0}, {'k_base': 3.5, 'phi': 0.5, 'mult': 1.5}, {'k_base': 3.5, 'phi': 0.5, 'mult': 2.0}]}
