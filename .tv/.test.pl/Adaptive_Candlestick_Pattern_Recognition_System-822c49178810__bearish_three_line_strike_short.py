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

def generate_signals(features, signal_params):
    size = int(features.market.size)
    short_entries = np.zeros(size, dtype=np.bool_)
    long_entries = np.zeros(size, dtype=np.bool_)
    opens = np.asarray(features.market.opens, dtype=float)
    highs = np.asarray(features.market.highs, dtype=float)
    lows = np.asarray(features.market.lows, dtype=float)
    closes = np.asarray(features.market.closes, dtype=float)
    ma_period = max(1, int(signal_params.get('ma_period', 20)))
    volatility_window = max(3, int(signal_params.get('volatility_window', 3)))
    volatility_multiplier = float(signal_params.get('volatility_multiplier', 1.0))
    ranges = highs - lows
    moving_average = np.full(size, np.nan, dtype=float)
    for t in range(ma_period - 1, size):
        moving_average[t] = np.mean(closes[t - ma_period + 1:t + 1])
    for t in range(3, size):
        if t < volatility_window or not np.isfinite(moving_average[t - 1:t + 1]).all():
            continue
        first_three_bearish = closes[t - 3] < opens[t - 3] and closes[t - 2] < opens[t - 2] and (closes[t - 1] < opens[t - 1])
        descending_lows = lows[t - 3] > lows[t - 2] > lows[t - 1]
        bullish_strike = opens[t] < closes[t - 1] and closes[t] > opens[t - 3]
        high_volatility = ranges[t] > volatility_multiplier * np.mean(ranges[t - volatility_window:t])
        ma_downtrend = moving_average[t] < moving_average[t - 1] and closes[t] < moving_average[t]
        short_entries[t] = first_three_bearish and descending_lows and (closes[t] > opens[t]) and bullish_strike and high_volatility and ma_downtrend
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (long_entries, long_exits, short_entries, short_exits)
STRATEGY = {'strategy_id': 'bearish_three_line_strike_short', 'hypothesis': '熊市下行趨勢中的看跌三線打擊型態可能延續下跌。', 'position': 'short', 'generate_signals': generate_signals, 'signal_parameter_names': ['ma_period', 'volatility_window', 'volatility_multiplier', 'k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'ma_period': 20, 'volatility_window': 3, 'volatility_multiplier': 1.0, 'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
