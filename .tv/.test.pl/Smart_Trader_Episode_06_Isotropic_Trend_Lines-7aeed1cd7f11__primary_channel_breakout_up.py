import math
import numpy as np

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    volumes = features.market.volumes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    gamma = float(signal_params.get('gamma', 1.0))
    n_base = float(signal_params.get('n_base', 2000.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    cum_vol = 0.0
    entry_atr = 1.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
                cum_vol += volumes[t]
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif cum_vol >= n_base * (entry_atr / max(1e-06, atr[t])) ** gamma:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
                cum_vol += volumes[t]
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
                cum_vol = volumes[t]
                entry_atr = max(1e-06, atr[t])
    return (long_exits, short_exits)

def _yang_zhang_sigma(opens, highs, lows, closes, length):
    size = len(closes)
    result = np.full(size, np.nan, dtype=float)
    length = max(2, int(length))
    weight = 0.34 / (1.34 + (length + 1.0) / max(length - 1.0, 1.0))
    for t in range(length, size):
        start = t - length + 1
        o = opens[start:t + 1]
        h = highs[start:t + 1]
        l = lows[start:t + 1]
        c = closes[start:t + 1]
        previous_c = closes[start - 1:t]
        if not np.all(np.isfinite(np.concatenate((o, h, l, c, previous_c)))):
            continue
        if np.any(o <= 0) or np.any(h <= 0) or np.any(l <= 0) or np.any(c <= 0) or np.any(previous_c <= 0):
            continue
        overnight = np.log(o / previous_c)
        close_open = np.log(c / o)
        high_open = np.log(h / o)
        high_close = np.log(h / c)
        low_open = np.log(l / o)
        low_close = np.log(l / c)
        rs = high_open * high_close + low_open * low_close
        variance = np.var(overnight) + weight * np.var(close_open) + (1.0 - weight) * np.mean(rs)
        if np.isfinite(variance):
            result[t] = math.sqrt(max(variance, 0.0))
    return result

def _ics_line(price_1, x_1, price_2, x_2, target_x):
    if x_1 == x_2:
        return price_1
    return math.exp(math.log(price_1) + (math.log(price_2) - math.log(price_1)) * (target_x - x_1) / (x_2 - x_1))

def _primary_channel(t, highs, lows, sigma, period, groups, threshold):
    if t < groups * period or not np.isfinite(sigma) or sigma <= 0.0:
        return None
    blocks = []
    for block in range(groups):
        end = t - block * period
        start = end - period + 1
        if start < 0:
            return None
        block_high = float(np.max(highs[start:end + 1]))
        block_low = float(np.min(lows[start:end + 1]))
        if not np.isfinite(block_high) or not np.isfinite(block_low) or block_high <= 0.0 or (block_low <= 0.0):
            return None
        geometric_mean = math.sqrt(block_high * block_low)
        center = t - block * period - period // 2
        blocks.append((geometric_mean, block_high, block_low, center))
    if blocks[0][0] == blocks[1][0]:
        return None
    primary_direction = 1 if blocks[0][0] > blocks[1][0] else -1
    segment_end = 1
    for block in range(1, groups - 1):
        comparison = 1 if blocks[block][0] > blocks[block + 1][0] else -1 if blocks[block][0] < blocks[block + 1][0] else 0
        if comparison == primary_direction:
            segment_end = block + 1
        else:
            break
    old_block = blocks[segment_end]
    new_block = blocks[0]
    angle = math.degrees(math.atan((math.log(new_block[0]) - math.log(old_block[0])) / sigma / (new_block[3] - old_block[3])))
    direction = 0 if abs(angle) <= threshold else primary_direction
    highest_high = -math.inf
    lowest_high = math.inf
    highest_low = -math.inf
    lowest_low = math.inf
    highest_high_x = lowest_high_x = highest_low_x = lowest_low_x = None
    for _, block_high, block_low, center in blocks[:segment_end + 1]:
        if block_high > highest_high:
            highest_high = block_high
            highest_high_x = center
        if block_high < lowest_high:
            lowest_high = block_high
            lowest_high_x = center
        if block_low > highest_low:
            highest_low = block_low
            highest_low_x = center
        if block_low < lowest_low:
            lowest_low = block_low
            lowest_low_x = center
    if direction == 1:
        channel_upper = _ics_line(lowest_high, lowest_high_x, highest_high, highest_high_x, t)
        channel_lower = _ics_line(lowest_low, lowest_low_x, highest_low, highest_low_x, t)
    elif direction == -1:
        channel_upper = _ics_line(highest_high, highest_high_x, lowest_high, lowest_high_x, t)
        channel_lower = _ics_line(highest_low, highest_low_x, lowest_low, lowest_low_x, t)
    else:
        channel_upper = highest_high
        channel_lower = lowest_low
    return (direction, channel_upper, channel_lower)

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    period = max(5, int(signal_params.get('period', 13)))
    groups = min(5, max(3, int(signal_params.get('groups', 5))))
    threshold = float(signal_params.get('range_threshold', 0.5))
    sigma_length = max(5, int(signal_params.get('sigma_length', 20)))
    sigma = _yang_zhang_sigma(opens, highs, lows, closes, sigma_length)
    state = 0
    previous_direction = 0
    for t in range(size):
        channel = _primary_channel(t, highs, lows, sigma[t], period, groups, threshold)
        if channel is None:
            continue
        direction, channel_upper, channel_lower = channel
        if not np.isfinite(closes[t]) or closes[t] <= 0.0 or channel_upper <= channel_lower or (channel_lower <= 0.0):
            continue
        direction_changed = previous_direction != 0 and direction != previous_direction
        previous_direction = direction
        if direction_changed:
            state = 0
            continue
        denominator = math.log(channel_upper) - math.log(channel_lower)
        if denominator <= 0.0:
            continue
        ext_pos = (math.log(closes[t]) - math.log(channel_lower)) / denominator
        if state == 0:
            if ext_pos > 1.0:
                long_entries[t] = True
                state = 1
            elif ext_pos < 0.0:
                state = -1
        elif state == 1:
            if ext_pos < 0.0:
                state = -1
            elif ext_pos <= 1.0:
                state = 0
        elif state == -1:
            if ext_pos > 1.0:
                state = 1
            elif ext_pos >= 0.0:
                state = 0
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'primary_channel_breakout_up', 'hypothesis': '主通道上破代表結構性上行延續，搭配 ATR 移動停損與累積成交量趨勢出場。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['period', 'groups', 'range_threshold', 'sigma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'period': 13, 'groups': 5, 'range_threshold': 0.5, 'sigma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
