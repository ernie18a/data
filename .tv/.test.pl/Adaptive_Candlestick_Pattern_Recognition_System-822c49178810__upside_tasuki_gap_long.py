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

def _sma(values, length):
    if length < 1:
        raise ValueError('ma_length must be positive')
    result = np.full(values.size, np.nan, dtype=float)
    for index in range(length - 1, values.size):
        window = values[index - length + 1:index + 1]
        if np.all(np.isfinite(window)):
            result[index] = np.mean(window)
    return result

def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    market = features.market
    opens = np.asarray(market.opens, dtype=float).reshape(-1)
    highs = np.asarray(market.highs, dtype=float).reshape(-1)
    lows = np.asarray(market.lows, dtype=float).reshape(-1)
    closes = np.asarray(market.closes, dtype=float).reshape(-1)
    if any((values.size != size for values in (opens, highs, lows, closes))):
        raise ValueError('market OHLC arrays must match market.size')
    ma_length = int(signal_params.get('ma_length', 20))
    moving_average = _sma(closes, ma_length)
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes)
    if size >= 3:
        first_open = opens[:-2]
        first_high = highs[:-2]
        first_close = closes[:-2]
        second_open = opens[1:-1]
        second_low = lows[1:-1]
        second_close = closes[1:-1]
        third_open = opens[2:]
        third_close = closes[2:]
        second_body_low = np.minimum(second_open, second_close)
        second_body_high = np.maximum(second_open, second_close)
        trend_bar = np.zeros(size, dtype=np.bool_)
        if size > 3:
            trend_bar[3:] = finite[:-3] & np.isfinite(moving_average[:-3]) & (closes[:-3] > moving_average[:-3])
        long_entries[2:] = finite[:-2] & finite[1:-1] & finite[2:] & (first_close > first_open) & (second_close > second_open) & (second_low > first_high) & (third_close < third_open) & (third_open > second_body_low) & (third_open < second_body_high) & (third_close > first_high) & (third_close < second_low) & trend_bar[2:]
    exit_params = dict(signal_params)
    exit_params.update(k_base=2.0, gamma=1.0, n_base=2000.0)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, exit_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'upside_tasuki_gap_long', 'hypothesis': '上行動態 SMA 中的 Upside Tasuki Gap 形態可能延續多頭走勢。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'ma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
