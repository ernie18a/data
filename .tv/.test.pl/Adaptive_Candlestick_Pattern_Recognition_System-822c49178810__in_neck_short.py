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

def _rolling_prior_mean(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window, values.size):
        sample = values[index - window:index]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def _rolling_sma(values, window):
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(window - 1, values.size):
        sample = values[index - window + 1:index + 1]
        if np.all(np.isfinite(sample)):
            result[index] = np.mean(sample)
    return result

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    params = dict(signal_params or {})
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if any((values.size != size for values in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match market.size')
    in_neck_tol = float(params.get('i_InNeckTol', 0.15))
    tall_sample = int(params.get('i_TCSample', 14))
    tall_setting = str(params.get('i_TCSetting', 'RANGE')).upper()
    tall_multiplier = float(params.get('i_TCTol', 1.5))
    ma_length = int(params.get('ma_length', 20))
    if not np.isfinite(in_neck_tol) or in_neck_tol < 0.0 or tall_sample < 1 or (tall_setting not in ('RANGE', 'BODY')) or (not np.isfinite(tall_multiplier)) or (tall_multiplier <= 0.0) or (ma_length < 1):
        raise ValueError('invalid signal parameters')
    candle_range = highs - lows
    body = np.abs(closes - opens)
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & (candle_range > 0.0)
    tall_value = candle_range if tall_setting == 'RANGE' else body
    prior_tall_mean = _rolling_prior_mean(tall_value, tall_sample)
    is_tall = finite & np.isfinite(prior_tall_mean) & (tall_value >= tall_multiplier * prior_tall_mean)
    moving_average = _rolling_sma(closes, ma_length)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    for index in range(1, size):
        previous = index - 1
        trend_index = index - 2
        if trend_index < 0:
            continue
        if not (finite[previous] and finite[index] and is_tall[previous] and (not is_tall[index]) and np.isfinite(moving_average[trend_index])):
            continue
        previous_body = closes[previous] - opens[previous]
        upper_close = closes[previous] + abs(previous_body) * in_neck_tol
        short_entries[index] = bool(closes[previous] < opens[previous] and closes[index] >= opens[index] and (opens[index] < lows[previous]) and (closes[index] > closes[previous]) and (closes[index] < upper_close) and (closes[trend_index] <= moving_average[trend_index]))
    exit_params = dict(params)
    exit_params.update(k_base=2.0, gamma=1.0, n_base=2000.0)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'in_neck_short', 'hypothesis': '下行動態 MA 中的 In Neck 形態可能延續空方動能。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['i_InNeckTol', 'i_TCSample', 'i_TCSetting', 'i_TCTol', 'ma_length'], 'signal_parameter_sets': [{'i_InNeckTol': 0.15, 'i_TCSample': 14, 'i_TCSetting': 'RANGE', 'i_TCTol': 1.5, 'ma_length': 20}]}
