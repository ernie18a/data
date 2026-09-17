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

def _rolling_sma(values, window):
    result = np.full(values.shape, np.nan, dtype=float)
    if window <= 0:
        return result
    cumulative = np.concatenate(([0.0], np.cumsum(values, dtype=float)))
    result[window - 1:] = (cumulative[window:] - cumulative[:-window]) / window
    return result

def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(market.opens, dtype=float)
    highs = np.asarray(market.highs, dtype=float)
    lows = np.asarray(market.lows, dtype=float)
    closes = np.asarray(market.closes, dtype=float)
    ma = _rolling_sma(closes, 20)
    ranges = highs - lows
    for t in range(3, size):
        first = t - 3
        trend_index = first - 1
        if trend_index < 19 or t < 14:
            continue
        first_three_bullish = closes[first] >= opens[first] and closes[first + 1] >= opens[first + 1] and (closes[first + 2] >= opens[first + 2])
        highs_rising = highs[first + 1] > highs[first] and highs[first + 2] > highs[first + 1]
        strike_is_bearish = closes[t] < opens[t]
        strike_gap_and_reversal = opens[t] > closes[t - 1] and closes[t] < opens[first]
        preceding_range_average = float(np.mean(ranges[t - 14:t]))
        strike_is_high_volatility = ranges[t] >= 1.5 * preceding_range_average
        in_ma_uptrend = closes[trend_index] > ma[trend_index]
        long_entries[t] = first_three_bullish and highs_rising and strike_is_bearish and strike_gap_and_reversal and strike_is_high_volatility and in_ma_uptrend
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bullish_three_line_strike_long', 'hypothesis': '上升趨勢中的三線打擊形態可提供多頭進場訊號。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
