import numpy as np
from numba import njit

@njit
def _ts_changed(bar_terms, short_lookback, long_lookback, sensitivity_multiplier):
    n = bar_terms.size
    changed = np.zeros(n, dtype=np.bool_)
    recent = np.empty(30, dtype=np.float64)
    count = 0
    prev_state = 0
    prev_defined = False
    for i in range(n):
        term = bar_terms[i]
        if not np.isnan(term):
            if count < 30:
                recent[count] = term
                count += 1
            else:
                for j in range(29):
                    recent[j] = recent[j + 1]
                recent[29] = term
        if i < short_lookback or i < long_lookback:
            continue
        if count < short_lookback or count < long_lookback:
            continue
        short_sum = 0.0
        for j in range(count - short_lookback, count):
            short_sum += recent[j]
        long_sum = 0.0
        for j in range(count - long_lookback, count):
            long_sum += recent[j]
        rv_short = np.sqrt(short_sum / short_lookback)
        rv_long = np.sqrt(long_sum / long_lookback)
        if rv_long <= 0.0:
            continue
        if rv_short < sensitivity_multiplier * rv_long:
            state = 1
        elif rv_long < sensitivity_multiplier * rv_short:
            state = -1
        else:
            state = 0
        if prev_defined and state != prev_state:
            changed[i] = True
        prev_state = state
        prev_defined = True
    return changed

def generate_entries(features, signal_params):
    short_lookback = signal_params['short_lookback']
    long_lookback = signal_params['long_lookback']
    sensitivity_multiplier = signal_params['sensitivity_multiplier']
    n = features.market.size
    highs = features.market.highs
    lows = features.market.lows
    bar_terms = np.full(n, np.nan, dtype=np.float64)
    valid = (highs > 0.0) & (lows > 0.0) & (highs >= lows)
    log_range = np.log(highs[valid] / lows[valid])
    bar_terms[valid] = log_range * log_range / (4.0 * np.log(2.0))
    short_entries = _ts_changed(bar_terms, short_lookback, long_lookback, sensitivity_multiplier)
    long_entries = np.zeros(n, dtype=np.bool_)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Short_Volatility_Term_Structure_Change_2__trend__follow', 'hypothesis': '當短期實現波動率相對長期基準的狀態改變時，觸發做空進場。', 'position': 'short', 'signal_parameter_names': ['short_lookback', 'long_lookback', 'sensitivity_multiplier'], 'signal_parameter_specs': [{'name': 'short_lookback', 'family': 'lookback', 'anchor': 5}, {'name': 'long_lookback', 'family': 'lookback', 'anchor': 30}, {'name': 'sensitivity_multiplier', 'family': 'multiplier', 'anchor': 0.9}], 'signal_parameter_relations': [['short_lookback', 'lt', 'long_lookback']], 'signal_parameter_candidates': {'short_lookback': [5, 2, 10], 'long_lookback': [30, 15, 60], 'sensitivity_multiplier': [0.9, 0.63, 1.26]}}, 'generate_signals': generate_signals}
