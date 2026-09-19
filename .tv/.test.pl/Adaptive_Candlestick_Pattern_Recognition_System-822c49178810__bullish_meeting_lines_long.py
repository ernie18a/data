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

def _prior_mean(values: np.ndarray, window: int) -> np.ndarray:
    result = np.full(values.shape, np.nan, dtype=float)
    for index in range(window, values.size):
        result[index] = np.mean(values[index - window:index])
    return result

def _sma(values: np.ndarray, window: int) -> np.ndarray:
    result = np.full(values.shape, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        result[index] = np.mean(values[index - window + 1:index + 1])
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    volatility_window = max(1, int(signal_params.get('volatility_window', 14)))
    volatility_multiplier = float(signal_params.get('volatility_multiplier', 1.5))
    close_tolerance = float(signal_params.get('close_tolerance', 0.05))
    ma_window = max(1, int(signal_params.get('ma_window', 20)))
    ranges = highs - lows
    prior_range_mean = _prior_mean(ranges, volatility_window)
    trend_ma = _sma(closes, ma_window)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for index in range(2, size):
        previous = index - 1
        trend_index = index - 2
        previous_is_bearish = closes[previous] < opens[previous]
        latest_is_bullish = closes[index] >= opens[index]
        previous_is_tall = np.isfinite(prior_range_mean[previous]) and ranges[previous] >= volatility_multiplier * prior_range_mean[previous] and (prior_range_mean[previous] > 0.0)
        latest_is_tall = np.isfinite(prior_range_mean[index]) and ranges[index] >= volatility_multiplier * prior_range_mean[index] and (prior_range_mean[index] > 0.0)
        closes_meet = np.isfinite(ranges[previous]) and abs(closes[index] - closes[previous]) <= close_tolerance * ranges[previous]
        in_downtrend = np.isfinite(trend_ma[trend_index]) and closes[trend_index] <= trend_ma[trend_index]
        long_entries[index] = previous_is_bearish and latest_is_bullish and previous_is_tall and latest_is_tall and closes_meet and in_downtrend
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, {'k_base': float(signal_params.get('k_base', 2.0)), 'mult': float(signal_params.get('mult', 2.0))})
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_meeting_lines_long', 'hypothesis': '下行趨勢中的高波動多空交會線反轉形態，可能預示多方反彈。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['volatility_window', 'volatility_multiplier', 'close_tolerance', 'ma_window', 'k_base', 'mult'], 'signal_parameter_sets': [{'volatility_window': 14, 'volatility_multiplier': 1.5, 'close_tolerance': 0.05, 'ma_window': 20, 'k_base': 2.0, 'mult': 2.0}]}
