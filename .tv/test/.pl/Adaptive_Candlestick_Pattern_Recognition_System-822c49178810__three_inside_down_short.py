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

def _sma(values, period):
    result = np.full(values.size, np.nan, dtype=float)
    if values.size >= period:
        result[period - 1:] = np.convolve(values, np.ones(period, dtype=float), mode='valid') / period
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    opens = np.asarray(features.market.opens, dtype=float).reshape(-1)
    closes = np.asarray(features.market.closes, dtype=float).reshape(-1)
    if opens.size != size or closes.size != size:
        raise ValueError('market opens and closes must match market.size')
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    ma = _sma(closes, 20)
    for t in range(3, size):
        first = t - 2
        second = t - 1
        trend_bar = t - 3
        first_bullish = closes[first] > opens[first]
        second_bearish = closes[second] < opens[second]
        third_bearish = closes[t] < opens[t]
        second_inside_first = opens[first] <= opens[second] <= closes[first] and opens[first] <= closes[second] <= closes[first]
        not_completely_equal = not (closes[second] == opens[first] and opens[second] == closes[first])
        uptrend = np.isfinite(ma[trend_bar]) and closes[trend_bar] > ma[trend_bar]
        short_entries[t] = bool(first_bullish and second_bearish and third_bearish and second_inside_first and not_completely_equal and uptrend)
    params = {'k_base': float(signal_params.get('k_base', 2.0)), 'gamma': float(signal_params.get('gamma', 1.0)), 'n_base': float(signal_params.get('n_base', 2000.0))}
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'three_inside_down_short', 'hypothesis': '上行趨勢中的三根 K 線反轉型態可能帶來空頭延續，並以 ATR 趨勢出場管理風險。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
