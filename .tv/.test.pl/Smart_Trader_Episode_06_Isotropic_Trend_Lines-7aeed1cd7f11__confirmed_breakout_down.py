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
import numpy as np

def _rolling_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        chunk = values[index - window + 1:index + 1]
        if np.all(np.isfinite(chunk)):
            result[index] = float(np.mean(chunk))
    return result

def _rolling_variance(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        chunk = values[index - window + 1:index + 1]
        if np.all(np.isfinite(chunk)):
            result[index] = float(np.var(chunk))
    return result

def _yang_zhang_sigma(opens, highs, lows, closes, window):
    previous_closes = np.empty_like(closes, dtype=float)
    if closes.size:
        previous_closes[0] = opens[0]
        previous_closes[1:] = closes[:-1]
    with np.errstate(divide='ignore', invalid='ignore', over='ignore'):
        overnight = np.log(opens / previous_closes)
        close_open = np.log(closes / opens)
        high_open = np.log(highs / opens)
        high_close = np.log(highs / closes)
        low_open = np.log(lows / opens)
        low_close = np.log(lows / closes)
        rogers_satchell = high_open * high_close + low_open * low_close
    variance_overnight = _rolling_variance(overnight, window)
    variance_close_open = _rolling_variance(close_open, window)
    mean_rogers_satchell = _rolling_mean(rogers_satchell, window)
    weight = 0.34 / (1.34 + (window + 1.0) / max(window - 1.0, 1.0))
    variance = np.nan_to_num(variance_overnight, nan=0.0) + weight * np.nan_to_num(variance_close_open, nan=0.0) + (1.0 - weight) * np.nan_to_num(mean_rogers_satchell, nan=0.0)
    return np.maximum(np.sqrt(np.maximum(variance, 0.0)), 1e-12)

def _ics_line(price_one, x_one, price_two, x_two, target_x):
    if x_one == x_two or price_one <= 0.0 or price_two <= 0.0:
        return price_one
    return float(np.exp(np.log(price_one) + (np.log(price_two) - np.log(price_one)) * (target_x - x_one) / (x_two - x_one)))

def _primary_channel(t, highs, lows, sigma, period, groups, threshold):
    if t < groups * period or not np.isfinite(sigma[t]):
        return (0, np.nan, np.nan)
    block_gm = []
    block_high = []
    block_low = []
    block_x = []
    for block in range(groups):
        end = t - block * period
        start = end - period + 1
        if start < 0:
            return (0, np.nan, np.nan)
        high = float(np.max(highs[start:end + 1]))
        low = float(np.min(lows[start:end + 1]))
        if high <= 0.0 or low <= 0.0:
            return (0, np.nan, np.nan)
        block_high.append(high)
        block_low.append(low)
        block_gm.append(float(np.sqrt(high * low)))
        block_x.append(end - period // 2)
    if block_gm[0] == block_gm[1]:
        return (0, np.nan, np.nan)
    primary_direction = 1 if block_gm[0] > block_gm[1] else -1
    segment = 1
    for block in range(1, groups - 1):
        pair_direction = 1 if block_gm[block] > block_gm[block + 1] else -1 if block_gm[block] < block_gm[block + 1] else 0
        if pair_direction == primary_direction:
            segment = block + 1
        else:
            break
    angle = float(np.degrees(np.arctan((np.log(block_gm[0]) - np.log(block_gm[segment])) / (sigma[t] * (block_x[0] - block_x[segment])))))
    direction = 0 if abs(angle) <= threshold else primary_direction
    highest_high = lowest_high = highest_low = lowest_low = None
    x_highest_high = x_lowest_high = x_highest_low = x_lowest_low = 0
    for block in range(segment + 1):
        high = block_high[block]
        low = block_low[block]
        x = block_x[block]
        if highest_high is None or high > highest_high:
            highest_high, x_highest_high = (high, x)
        if lowest_high is None or high < lowest_high:
            lowest_high, x_lowest_high = (high, x)
        if highest_low is None or low > highest_low:
            highest_low, x_highest_low = (low, x)
        if lowest_low is None or low < lowest_low:
            lowest_low, x_lowest_low = (low, x)
    if direction == 1:
        upper = _ics_line(lowest_high, x_lowest_high, highest_high, x_highest_high, t)
        lower = _ics_line(lowest_low, x_lowest_low, highest_low, x_highest_low, t)
    elif direction == -1:
        upper = _ics_line(highest_high, x_highest_high, lowest_high, x_lowest_high, t)
        lower = _ics_line(highest_low, x_highest_low, lowest_low, x_lowest_low, t)
    else:
        upper, lower = (highest_high, lowest_low)
    return (direction, float(upper), float(lower))

def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    params = signal_params or {}
    period = int(params.get('period', 13))
    groups = int(params.get('groups', 5))
    threshold = float(params.get('threshold', 0.5))
    sigma_length = int(params.get('sigma_length', 20))
    if period < 5 or groups < 3 or sigma_length < 5:
        raise ValueError('period、groups、sigma_length 必須符合策略的最小窗口')
    opens = np.asarray(market.opens, dtype=float)
    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    sigma = _yang_zhang_sigma(opens, highs, lows, closes, sigma_length)
    state = 0
    confirmed = False
    distanced = False
    previous_direction = 0
    for t in range(size):
        direction, channel_upper, channel_lower = _primary_channel(t, highs, lows, sigma, period, groups, threshold)
        if not np.isfinite(channel_upper) or not np.isfinite(channel_lower):
            continue
        close = closes[t]
        current_sigma = sigma[t]
        if not np.isfinite(close) or close <= 0.0 or channel_upper <= 0.0 or (channel_lower <= 0.0) or (channel_upper <= channel_lower) or (not np.isfinite(current_sigma)) or (current_sigma <= 0.0):
            continue
        extension_position = (np.log(close) - np.log(channel_lower)) / (np.log(channel_upper) - np.log(channel_lower))
        distance_upper = abs(np.log(close) - np.log(channel_upper)) / current_sigma
        distance_lower = abs(np.log(close) - np.log(channel_lower)) / current_sigma
        was_confirmed = confirmed
        direction_changed = direction != previous_direction and previous_direction != 0
        previous_direction = direction
        if direction_changed:
            state = 0
            confirmed = False
            distanced = False
        elif state == 0:
            if extension_position > 1.0:
                state = 1
                confirmed = False
                distanced = False
            elif extension_position < 0.0:
                state = -1
                confirmed = False
                distanced = False
        elif state == 1:
            if distance_upper >= 1.0:
                distanced = True
            if extension_position < 0.0:
                state = -1
                confirmed = False
                distanced = False
            elif extension_position <= 1.0:
                state = 0
                confirmed = False
                distanced = False
            elif distanced and distance_upper < 1.0:
                state = 2
        elif state == 2:
            if extension_position < 0.0:
                state = -1
                confirmed = False
                distanced = False
            elif extension_position <= 1.0:
                state = 0
                confirmed = False
                distanced = False
            elif distance_upper >= 1.0:
                state = 1
                confirmed = True
                distanced = True
        elif state == -1:
            if distance_lower >= 1.0:
                distanced = True
            if extension_position > 1.0:
                state = 1
                confirmed = False
                distanced = False
            elif extension_position >= 0.0:
                state = 0
                confirmed = False
                distanced = False
            elif distanced and distance_lower < 1.0:
                state = -2
        elif state == -2:
            if extension_position > 1.0:
                state = 1
                confirmed = False
                distanced = False
            elif extension_position >= 0.0:
                state = 0
                confirmed = False
                distanced = False
            elif distance_lower >= 1.0:
                state = -1
                confirmed = True
                distanced = True
        if state == -1 and confirmed and (not was_confirmed):
            short_entries[t] = True
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'confirmed_breakout_down', 'hypothesis': '下破主通道後完成一個 Yang-Zhang σ 距離、回測並再次下行確認時，順勢做空。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['period', 'groups', 'threshold', 'sigma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'period': 13, 'groups': 5, 'threshold': 0.5, 'sigma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
