from __future__ import annotations
from collections import deque
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
SCALES = (3, 7, 13, 19, 29, 47)
GROUPS = 5
RANGE_THRESHOLD = 0.5
SIGMA_LENGTH = 20
MIN_SIGMA = 1e-10

def _rolling_extreme(values, period, maximum):
    result = np.full(values.size, np.nan, dtype=float)
    queue = deque()
    for index in range(values.size):
        value = float(values[index])
        if not np.isfinite(value):
            queue.clear()
            continue
        while queue and queue[0] <= index - period:
            queue.popleft()
        while queue:
            tail_value = float(values[queue[-1]])
            if maximum and tail_value <= value:
                queue.pop()
            elif not maximum and tail_value >= value:
                queue.pop()
            else:
                break
        queue.append(index)
        if index >= period - 1:
            result[index] = float(values[queue[0]])
    return result

def _yang_zhang_sigma(opens, highs, lows, closes):
    size = closes.size
    sigma = np.full(size, MIN_SIGMA, dtype=float)
    previous_closes = np.empty(size, dtype=float)
    previous_closes[0] = opens[0]
    if size > 1:
        previous_closes[1:] = closes[:-1]
    with np.errstate(divide='ignore', invalid='ignore'):
        overnight = np.log(opens / previous_closes)
        close_open = np.log(closes / opens)
        high_open = np.log(highs / opens)
        high_close = np.log(highs / closes)
        low_open = np.log(lows / opens)
        low_close = np.log(lows / closes)
        rogers_satchell = high_open * high_close + low_open * low_close
    weight = 0.34 / (1.34 + (SIGMA_LENGTH + 1.0) / max(SIGMA_LENGTH - 1.0, 1.0))
    for index in range(SIGMA_LENGTH - 1, size):
        start = index - SIGMA_LENGTH + 1
        window = slice(start, index + 1)
        components = (overnight[window], close_open[window], rogers_satchell[window])
        if not all((np.all(np.isfinite(component)) for component in components)):
            continue
        variance = float(np.var(components[0])) + weight * float(np.var(components[1])) + (1.0 - weight) * float(np.mean(components[2]))
        sigma[index] = max(float(np.sqrt(max(variance, 0.0))), MIN_SIGMA)
    return sigma

def _direction_series(highs, lows, sigmas, period):
    size = highs.size
    directions = np.zeros(size, dtype=np.int8)
    rolling_highs = _rolling_extreme(highs, period, True)
    rolling_lows = _rolling_extreme(lows, period, False)
    for index in range(GROUPS * period, size):
        geometric_means = []
        valid = True
        for block in range(GROUPS):
            endpoint = index - block * period
            block_high = rolling_highs[endpoint]
            block_low = rolling_lows[endpoint]
            if not np.isfinite(block_high) or not np.isfinite(block_low) or block_high <= 0.0 or (block_low <= 0.0):
                valid = False
                break
            geometric_means.append(float(np.sqrt(block_high * block_low)))
        if not valid or geometric_means[0] == geometric_means[1]:
            continue
        primary_direction = 1 if geometric_means[0] > geometric_means[1] else -1
        segment = 1
        for block in range(1, GROUPS - 1):
            pair_direction = 0
            if geometric_means[block] > geometric_means[block + 1]:
                pair_direction = 1
            elif geometric_means[block] < geometric_means[block + 1]:
                pair_direction = -1
            if pair_direction == primary_direction:
                segment = block + 1
            else:
                break
        current_sigma = float(sigmas[index])
        if not np.isfinite(current_sigma) or current_sigma <= 0.0:
            current_sigma = MIN_SIGMA
        slope = (np.log(geometric_means[0]) - np.log(geometric_means[segment])) / (segment * period * current_sigma)
        angle = float(np.degrees(np.arctan(slope)))
        if abs(angle) > RANGE_THRESHOLD:
            directions[index] = primary_direction
    return directions

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    sigmas = _yang_zhang_sigma(opens, highs, lows, closes)
    directions = np.zeros((len(SCALES), size), dtype=np.int8)
    for scale_index, period in enumerate(SCALES):
        directions[scale_index] = _direction_series(highs, lows, sigmas, period)
    bullish_consensus = np.sum(directions == 1, axis=0)
    if size > 1:
        long_entries[1:] = (bullish_consensus[1:] == 5) & (bullish_consensus[:-1] != 5)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (np.asarray(long_entries, dtype=np.bool_).reshape(-1), np.asarray(long_exits, dtype=np.bool_).reshape(-1), np.asarray(short_entries, dtype=np.bool_).reshape(-1), np.asarray(short_exits, dtype=np.bool_).reshape(-1))
STRATEGY = {'strategy_id': 'strong_bullish_scale_consensus', 'hypothesis': '六個 OHLC 結構尺度中五個呈現上行共識時，捕捉強勢多頭結構。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
