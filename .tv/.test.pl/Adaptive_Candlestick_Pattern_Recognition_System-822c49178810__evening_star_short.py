from __future__ import annotations
import numpy as np

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    import numpy as np
    size = features.market.size
    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    highs = features.market.highs
    lows = features.market.lows
    closes = features.market.closes
    atr = features.atr(14)
    k_base = float(signal_params.get('k_base', 2.0))
    mult = float(signal_params.get('mult', 2.0))
    position = 0
    best_price = 0.0
    current_stop = 0.0
    entry_price = 0.0
    for t in range(size):
        if position == 1:
            if lows[t] < current_stop:
                long_exits[t] = True
                position = 0
            elif closes[t] >= entry_price + mult * atr[t]:
                long_exits[t] = True
                position = 0
            elif closes[t] < entry_price - mult * atr[t]:
                long_exits[t] = True
                position = 0
            else:
                best_price = max(best_price, highs[t])
                current_stop = max(current_stop, best_price - k_base * atr[t])
        elif position == -1:
            if highs[t] > current_stop:
                short_exits[t] = True
                position = 0
            elif closes[t] <= entry_price - mult * atr[t]:
                short_exits[t] = True
                position = 0
            elif closes[t] > entry_price + mult * atr[t]:
                short_exits[t] = True
                position = 0
            else:
                best_price = min(best_price, lows[t])
                current_stop = min(current_stop, best_price + k_base * atr[t])
        if position == 0:
            if long_entries[t] and (not short_entries[t]):
                position = 1
                entry_price = closes[t]
                best_price = highs[t]
                current_stop = best_price - k_base * atr[t]
            elif short_entries[t] and (not long_entries[t]):
                position = -1
                entry_price = closes[t]
                best_price = lows[t]
                current_stop = best_price + k_base * atr[t]
    return (long_exits, short_exits)

def _moving_average(values, length, ma_type):
    values = np.asarray(values, dtype=float)
    if length < 1:
        raise ValueError('ma_length must be positive')
    if ma_type == 'SMA':
        result = np.full(values.shape, np.nan, dtype=float)
        if values.size >= length:
            csum = np.concatenate(([0.0], np.cumsum(values)))
            result[length - 1:] = (csum[length:] - csum[:-length]) / length
        return result
    if ma_type == 'EMA':
        result = np.full(values.shape, np.nan, dtype=float)
        if values.size >= length:
            result[length - 1] = np.mean(values[:length])
            alpha = 2.0 / (length + 1.0)
            for index in range(length, values.size):
                result[index] = alpha * values[index] + (1.0 - alpha) * result[index - 1]
        return result
    raise ValueError('ma_type must be SMA or EMA')

def _tall_candles(opens, highs, lows, closes, sample, multiplier, measure):
    if sample < 1 or multiplier <= 0.0:
        raise ValueError('invalid Tall Candle parameters')
    sizes = highs - lows if measure == 'range' else np.abs(closes - opens)
    result = np.zeros(sizes.size, dtype=np.bool_)
    if sizes.size >= sample + 1:
        csum = np.concatenate(([0.0], np.cumsum(sizes)))
        averages = (csum[sample:-1] - csum[:-sample - 1]) / sample
        result[sample:] = sizes[sample:] >= multiplier * averages
    return result

def generate_signals(features, signal_params):
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    ma_length = int(signal_params.get('ma_length', 20))
    ma_type = str(signal_params.get('ma_type', 'SMA'))
    tall_sample = int(signal_params.get('tall_sample', 14))
    tall_measure = str(signal_params.get('tall_measure', 'range')).lower()
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    moving_average = _moving_average(closes, ma_length, ma_type)
    tall = _tall_candles(opens, highs, lows, closes, tall_sample, tall_multiplier, tall_measure)
    for index in range(3, size):
        first = index - 2
        middle = index - 1
        uptrend = closes[index - 3] > moving_average[index - 3]
        middle_body_low = min(opens[middle], closes[middle])
        first_body_midpoint = (opens[first] + closes[first]) / 2.0
        short_entries[index] = bool(np.isfinite(moving_average[index - 3]) and tall[first] and tall[index] and (closes[first] > opens[first]) and (closes[index] < opens[index]) and (middle_body_low > closes[first]) and (middle_body_low > opens[index]) and (closes[index] < first_body_midpoint) and uptrend)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'evening_star_short', 'hypothesis': '上升趨勢中的 Evening Star 反轉形態可能預示短線下跌。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'ma_type', 'tall_sample', 'tall_measure', 'tall_multiplier', 'k_base', 'mult'], 'signal_parameter_sets': [{'ma_length': 20, 'ma_type': 'SMA', 'tall_sample': 14, 'tall_measure': 'range', 'tall_multiplier': 1.5, 'k_base': 2.0, 'mult': 2.0}]}
