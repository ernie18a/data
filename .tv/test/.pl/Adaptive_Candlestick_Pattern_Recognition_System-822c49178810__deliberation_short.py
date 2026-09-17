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

def _rolling_mean(values, length):
    if length < 1:
        raise ValueError('rolling window must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def _previous_mean(values, length):
    if length < 1:
        raise ValueError('rolling window must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length, values.size):
        window = values[index - length:index]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    empty = np.zeros(size, dtype=np.bool_)
    if size == 0:
        return (empty, empty.copy(), empty.copy(), empty.copy())
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)[:size]
    highs = np.asarray(market.highs, dtype=float).reshape(-1)[:size]
    lows = np.asarray(market.lows, dtype=float).reshape(-1)[:size]
    closes = np.asarray(market.closes, dtype=float).reshape(-1)[:size]
    ma_length = int(signal_params.get('ma_length', 20))
    tall_window = int(signal_params.get('tall_window', 14))
    tall_setting = str(signal_params.get('tall_setting', 'RANGE')).upper()
    tall_multiplier = float(signal_params.get('tall_multiplier', 1.5))
    gap_tolerance = float(signal_params.get('gap_tolerance', 0.1))
    force_gap = bool(signal_params.get('force_gap', True))
    third_size_multiplier = float(signal_params.get('third_size_multiplier', 0.33))
    if tall_setting not in ('RANGE', 'BODY'):
        raise ValueError("tall_setting must be 'RANGE' or 'BODY'")
    if ma_length < 1 or tall_window < 1:
        raise ValueError('ma_length and tall_window must be positive')
    if tall_multiplier < 0.0 or gap_tolerance < 0.0 or third_size_multiplier < 0.0:
        raise ValueError('thresholds must be non-negative')
    body = np.abs(closes - opens)
    candle_range = highs - lows
    tall_value = candle_range if tall_setting == 'RANGE' else body
    previous_tall_mean = _previous_mean(tall_value, tall_window)
    moving_average = _rolling_mean(closes, ma_length)
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & np.isfinite(previous_tall_mean) & np.isfinite(moving_average)
    bullish = closes > opens
    tall = finite & (tall_value >= previous_tall_mean * tall_multiplier)
    short_entries = np.zeros(size, dtype=np.bool_)
    if size >= 3:
        candle_one = np.arange(size - 2)
        candle_two = candle_one + 1
        candle_three = candle_one + 2
        trend_index = candle_one
        gap_body = body[candle_two]
        lower_open = closes[candle_two] - gap_body * gap_tolerance
        upper_open = closes[candle_two] + gap_body * gap_tolerance
        lower_bound = closes[candle_two] if force_gap else lower_open
        pattern = finite[candle_one] & finite[candle_two] & finite[candle_three] & (closes[trend_index] > moving_average[trend_index]) & bullish[candle_one] & tall[candle_one] & bullish[candle_two] & tall[candle_two] & (closes[candle_two] > closes[candle_one]) & bullish[candle_three] & (opens[candle_three] > lower_bound) & (opens[candle_three] < upper_open) & (body[candle_three] <= (body[candle_one] + body[candle_two]) / 2.0 * third_size_multiplier)
        short_entries[2:] = pattern
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, {'k_base': float(signal_params.get('k_base', 2.0)), 'gamma': float(signal_params.get('gamma', 1.0)), 'n_base': float(signal_params.get('n_base', 2000.0))})
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'deliberation_short', 'hypothesis': '上行動態 MA 中的 Deliberation 形態可能預示看跌反轉，採空頭。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'tall_window', 'tall_setting', 'tall_multiplier', 'gap_tolerance', 'force_gap', 'third_size_multiplier', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'ma_length': 20, 'tall_window': 14, 'tall_setting': 'RANGE', 'tall_multiplier': 1.5, 'gap_tolerance': 0.1, 'force_gap': True, 'third_size_multiplier': 0.33, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
