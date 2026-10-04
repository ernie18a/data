import numpy as np
from numba import njit

@njit
def _ts_changed_entries(bar_term, short_len, long_len, tolerance):
    n = bar_term.size
    entries = np.zeros(n, dtype=np.bool_)
    prev_state = 0
    has_prev_state = False
    for t in range(n):
        if t < short_len - 1 or t < long_len - 1:
            continue
        short_sum = 0.0
        long_sum = 0.0
        valid = True
        for i in range(t - short_len + 1, t + 1):
            if not np.isfinite(bar_term[i]):
                valid = False
                break
            short_sum += bar_term[i]
        if not valid:
            continue
        for i in range(t - long_len + 1, t + 1):
            if not np.isfinite(bar_term[i]):
                valid = False
                break
            long_sum += bar_term[i]
        if not valid:
            continue
        rv_short = np.sqrt(max(0.0, short_sum / short_len))
        rv_long = np.sqrt(max(0.0, long_sum / long_len))
        if rv_long <= 0.0 or rv_short < 0.0:
            continue
        ts_state = 0
        if rv_long - rv_short > tolerance * rv_long:
            ts_state = 1
        elif rv_short - rv_long > tolerance * rv_short:
            ts_state = -1
        if has_prev_state and ts_state != prev_state:
            entries[t] = True
        prev_state = ts_state
        has_prev_state = True
    return entries

def generate_entries(features, signal_params):
    short_len = int(signal_params['short_len'])
    long_len = int(signal_params['long_len'])
    tolerance = float(signal_params['ts_tolerance'])
    n = features.market.size
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    bar_term = np.full(n, np.nan, dtype=np.float64)
    valid = (highs > 0.0) & (lows > 0.0) & (highs >= lows)
    log_ratio = np.zeros(n, dtype=np.float64)
    log_ratio[valid] = np.log(highs[valid] / lows[valid])
    bar_term[valid] = log_ratio[valid] ** 2 / (4.0 * np.log(2.0))
    changed = _ts_changed_entries(bar_term, short_len, long_len, tolerance)
    long_entries = changed
    short_entries = np.zeros(n, dtype=np.bool_)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'ShortVsBaselineChange_2__reversion__follow', 'hypothesis': '已收盤 K 線上，當短期 Parkinson 波動率相對長期波動率偏離超過容忍比例時，狀態改變即觸發進場條件。', 'position': 'both', 'signal_parameter_names': ['short_len', 'long_len', 'ts_tolerance'], 'signal_parameter_specs': [{'name': 'short_len', 'family': 'lookback', 'anchor': 5}, {'name': 'long_len', 'family': 'lookback', 'anchor': 30}, {'name': 'ts_tolerance', 'family': 'fraction', 'anchor': 0.1}], 'signal_parameter_relations': [['short_len', 'lt', 'long_len']], 'signal_parameter_candidates': {'short_len': [5, 2, 10], 'long_len': [30, 15, 60], 'ts_tolerance': [0.1, 0.05, 0.2]}}, 'generate_signals': generate_signals}
