from __future__ import annotations
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
    size = features.market.size
    opens = np.asarray(features.market.opens)
    highs = np.asarray(features.market.highs)
    lows = np.asarray(features.market.lows)
    closes = np.asarray(features.market.closes)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    bullish_zones = []
    bearish_zones = []
    for t in range(size):
        if t >= 3:
            if lows[t - 1] > highs[t - 3] and (closes[t - 2] > opens[t - 2] or closes[t - 2] > closes[t - 3]) and (lows[t - 1] < highs[t - 2]) and (lows[t - 2] < highs[t - 3]):
                bullish_zones.append((highs[t - 3], lows[t - 1]))
            if highs[t - 1] < lows[t - 3] and (closes[t - 2] < opens[t - 2] or closes[t - 2] < closes[t - 3]) and (highs[t - 1] > lows[t - 2]) and (highs[t - 2] > lows[t - 3]):
                bearish_zones.append((lows[t - 3], highs[t - 1]))
        bullish_zones = [zone for zone in bullish_zones if not lows[t] < zone[0]]
        bearish_zones = [zone for zone in bearish_zones if not highs[t] > zone[1]]
        if bullish_zones:
            zone_bottom, zone_top = bullish_zones[-1]
            long_entries[t] = lows[t] <= zone_top and highs[t] >= zone_bottom
        if bearish_zones:
            zone_bottom, zone_top = bearish_zones[-1]
            short_entries[t] = lows[t] <= zone_top and highs[t] >= zone_bottom
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    return (np.asarray(long_entries, dtype=np.bool_), np.asarray(long_exits, dtype=np.bool_), np.asarray(short_entries, dtype=np.bool_), np.asarray(short_exits, dtype=np.bool_))
STRATEGY = {'strategy_id': 'fair_value_gap_retest', 'hypothesis': '價格回測最近未失效的 Fair Value Gap 可提供支撐或壓力，並以 ATR 趨勢出場控制持倉。', 'position': 'both', 'generate_signals': generate_signals, 'signal_parameter_names': ['k_base', 'gamma', 'n_base'], 'signal_parameter_sets': [{'k_base': 2.0, 'gamma': 1.0, 'n_base': 2000.0}]}
