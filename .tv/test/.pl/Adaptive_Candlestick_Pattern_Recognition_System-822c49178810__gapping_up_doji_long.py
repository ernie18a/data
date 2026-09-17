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

def _rolling_sma(values, length):
    size = values.size
    result = np.full(size, np.nan, dtype=float)
    if size >= length:
        cumulative = np.cumsum(values, dtype=float)
        previous = np.concatenate(([0.0], cumulative[:-length]))
        result[length - 1:] = (cumulative[length - 1:] - previous) / length
    return result

def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    opens = np.asarray(market.opens, dtype=float)
    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    doji_tolerance = float(signal_params.get('doji_tolerance', 0.04))
    ma_length = max(1, int(signal_params.get('ma_length', 20)))
    moving_average = _rolling_sma(closes, ma_length)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    candle_range = highs - lows
    finite = np.isfinite(opens) & np.isfinite(highs) & np.isfinite(lows) & np.isfinite(closes) & np.isfinite(moving_average)
    is_doji = finite & (candle_range > 0.0) & (np.abs(closes - opens) / candle_range <= doji_tolerance)
    long_entries[1:] = is_doji[1:] & (lows[1:] > highs[:-1]) & (closes[1:] > moving_average[1:])
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, np.asarray(long_exits, dtype=np.bool_), short_entries, np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'gapping_up_doji_long', 'hypothesis': '上行動態 SMA 趨勢中的向上跳空十字線具有多頭延續訊號。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['doji_tolerance', 'ma_length', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'doji_tolerance': 0.04, 'ma_length': 20, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
