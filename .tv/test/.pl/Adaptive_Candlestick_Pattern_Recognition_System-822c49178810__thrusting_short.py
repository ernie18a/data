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

def _sma(values, window):
    import numpy as np
    result = np.full(values.size, np.nan, dtype=float)
    if values.size >= window:
        cumulative = np.cumsum(values, dtype=float)
        cumulative[window:] -= cumulative[:-window]
        result[window - 1:] = cumulative[window - 1:] / float(window)
    return result

def generate_signals(features, signal_params):
    import numpy as np
    size = features.market.size
    opens = np.asarray(features.market.opens, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    thrust_tol = float(signal_params.get('i_ThrustTol', 0.5))
    trend_ma = _sma(closes, 20)
    for t in range(1, size):
        previous_open = opens[t - 1]
        previous_close = closes[t - 1]
        current_open = opens[t]
        current_close = closes[t]
        trend_index = t - 3
        if trend_index < 0 or not np.isfinite(trend_ma[trend_index]):
            continue
        if not np.all(np.isfinite((previous_open, previous_close, current_open, current_close, lows[t - 1]))):
            continue
        previous_body = previous_open - previous_close
        midpoint = (previous_open + previous_close) / 2.0
        lower_value = midpoint - thrust_tol * (previous_body / 2.0)
        short_entries[t] = previous_open > previous_close and current_close > current_open and (current_open < lows[t - 1]) and (lower_value < current_close < midpoint) and (closes[trend_index] <= trend_ma[trend_index])
    exit_params = dict(signal_params)
    exit_params['k_base'] = 2.0
    exit_params['gamma'] = 1.0
    exit_params['n_base'] = 2000.0
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'thrusting_short', 'hypothesis': '下行趨勢中的 Thrusting 形態延續下跌，建立空頭部位。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_ThrustTol'], 'signal_parameter_sets': [{'i_ThrustTol': 0.5}]}
