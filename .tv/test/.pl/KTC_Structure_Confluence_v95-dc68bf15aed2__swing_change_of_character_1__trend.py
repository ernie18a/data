import numpy as np
from numba import njit

from numba import njit
import numpy as np

@njit
def _update_entries(closes, atr, pivot_high, pivot_low, atr_buf_mult, min_body_atr):
    n = closes.size
    long_entries = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    last_high = np.nan
    last_low = np.nan
    trend = 0
    high_broken = False
    low_broken = False
    for t in range(n):
        ph = pivot_high[t]
        pl = pivot_low[t]
        if not np.isnan(ph):
            last_high = ph
            high_broken = False
        if not np.isnan(pl):
            last_low = pl
            low_broken = False
        close = closes[t]
        previous_close = closes[t - 1] if t > 0 else np.nan
        body = abs(close - opens[t])
        break_buffer = atr[t] * atr_buf_mult
        body_ok = body >= atr[t] * min_body_atr
        up_raw = not np.isnan(last_high) and (not high_broken) and (close > last_high + break_buffer) and (previous_close <= last_high) and body_ok
        dn_raw = not np.isnan(last_low) and (not low_broken) and (close < last_low - break_buffer) and (previous_close >= last_low) and body_ok
        long_entries[t] = up_raw and trend != 1
        short_entries[t] = dn_raw and trend != -1
        if up_raw:
            trend = 1
            high_broken = True
            low_broken = False
        if dn_raw:
            trend = -1
            low_broken = True
            high_broken = False
    return (long_entries, short_entries)

def generate_entries(features, signal_params):
    pivot_len = signal_params['pivotLen']
    atr_buf_mult = signal_params['atrBufMult']
    min_body_atr = signal_params['minBodyATR']
    opens = features.market.opens
    closes = features.market.closes
    atr = features.atr(14)
    pivot_high = features.pivot_high(pivot_len, pivot_len)
    pivot_low = features.pivot_low(pivot_len, pivot_len)
    return _update_entries(closes, atr, pivot_high, pivot_low, atr_buf_mult, min_body_atr)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'swing_change_of_character_1__trend', 'hypothesis': '價格以足夠的實體幅度突破最新樞紐高低點並超過 ATR 緩衝時，僅在方向與既有趨勢不同時進場，且每個樞紐價位只觸發一次突破。', 'position': 'both', 'signal_parameter_names': ['pivotLen', 'atrBufMult', 'minBodyATR'], 'signal_parameter_specs': [{'name': 'pivotLen', 'family': 'lookback', 'anchor': 5}, {'name': 'atrBufMult', 'family': 'multiplier', 'anchor': 0.1}, {'name': 'minBodyATR', 'family': 'multiplier', 'anchor': 0.15}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'pivotLen': [5, 2, 10], 'atrBufMult': [0.1, 0.06999999999999999, 0.13999999999999999], 'minBodyATR': [0.15, 0.105, 0.21]}}, 'generate_signals': generate_signals}
