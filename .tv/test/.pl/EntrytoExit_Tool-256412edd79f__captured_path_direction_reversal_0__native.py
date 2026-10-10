import numpy as np
from numba import njit

import numpy as np
from numba import njit

@njit
def _read_strategy_signals(closes, ref_path_min_captured_path_pct, minimum_profit_for_opposite_exit_pct):
    n = closes.size
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    if n == 0:
        return (long_entries, long_exits, short_entries, short_exits)
    eps = 1e-06
    pivot_price = closes[0]
    pivot_index = 0
    direction = 0
    extreme_price = closes[0]
    extreme_index = 0
    previous_direction = 0
    position = 0
    entry_price = np.nan
    for i in range(1, n):
        close = closes[i]
        change = close - pivot_price
        if change > 0.0:
            sign_change = 1
        elif change < 0.0:
            sign_change = -1
        else:
            sign_change = 0
        if direction == 0 and sign_change != 0:
            direction = sign_change
            extreme_price = close
            extreme_index = i
        elif direction > 0:
            if close >= extreme_price:
                extreme_price = close
                extreme_index = i
            else:
                captured_path_pct = abs(extreme_price - pivot_price) * 100.0 / max(abs(pivot_price), eps)
                if captured_path_pct >= ref_path_min_captured_path_pct:
                    pivot_price = extreme_price
                    pivot_index = extreme_index
                    direction = -1
                    extreme_price = close
                    extreme_index = i
                elif close < pivot_price:
                    direction = -1
                    extreme_price = close
                    extreme_index = i
        elif direction < 0:
            if close <= extreme_price:
                extreme_price = close
                extreme_index = i
            else:
                captured_path_pct = abs(extreme_price - pivot_price) * 100.0 / max(abs(pivot_price), eps)
                if captured_path_pct >= ref_path_min_captured_path_pct:
                    pivot_price = extreme_price
                    pivot_index = extreme_index
                    direction = 1
                    extreme_price = close
                    extreme_index = i
                elif close > pivot_price:
                    direction = 1
                    extreme_price = close
                    extreme_index = i
        current_direction = close - pivot_price
        if current_direction > 0.0:
            current_direction = 1
        elif current_direction < 0.0:
            current_direction = -1
        else:
            current_direction = direction
        long_candidate = previous_direction < 0 and current_direction > 0
        short_candidate = previous_direction > 0 and current_direction < 0
        if position == 1 and short_candidate:
            profit_pct = (close - entry_price) * 100.0 / max(abs(entry_price), eps)
            if profit_pct >= minimum_profit_for_opposite_exit_pct:
                long_exits[i] = True
                position = 0
                entry_price = np.nan
        elif position == -1 and long_candidate:
            profit_pct = (entry_price - close) * 100.0 / max(abs(entry_price), eps)
            if profit_pct >= minimum_profit_for_opposite_exit_pct:
                short_exits[i] = True
                position = 0
                entry_price = np.nan
        if position == 0:
            if long_candidate:
                long_entries[i] = True
                position = 1
                entry_price = close
            elif short_candidate:
                short_entries[i] = True
                position = -1
                entry_price = close
        previous_direction = current_direction
    return (long_entries, long_exits, short_entries, short_exits)

def generate_signals(features, signal_params):
    n = features.market.size
    ref_path_min_captured_path_pct = signal_params['refPathMinCapturedPathPct']
    minimum_profit_for_opposite_exit_pct = signal_params['minimumProfitForOppositeExitPct']
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    stop_distances = np.full(n, np.nan, dtype=np.float64)
    target_distances = np.full(n, np.nan, dtype=np.float64)
    history_size = min(n, 5001)
    if history_size > 0:
        start = n - history_size
        closes = np.asarray(features.market.closes, dtype=np.float64)[start:]
        recent_long_entries, recent_long_exits, recent_short_entries, recent_short_exits = _read_strategy_signals(closes, ref_path_min_captured_path_pct, minimum_profit_for_opposite_exit_pct)
        long_entries[start:] = recent_long_entries
        long_exits[start:] = recent_long_exits
        short_entries[start:] = recent_short_entries
        short_exits[start:] = recent_short_exits
    return (long_entries, long_exits, short_entries, short_exits, stop_distances, target_distances)

STRATEGY = {**{'strategy_id': 'captured_path_direction_reversal_0__native', 'hypothesis': '以收盤價路徑反轉且回撤至少達前段路徑的 20% 作為暫定進場訊號，持倉遇反向訊號並達最低獲利比例時出場。', 'position': 'both', 'signal_parameter_names': ['refPathMinCapturedPathPct', 'minimumProfitForOppositeExitPct'], 'signal_parameter_specs': [{'name': 'refPathMinCapturedPathPct', 'family': 'fraction', 'anchor': 0.2}, {'name': 'minimumProfitForOppositeExitPct', 'family': 'fraction', 'anchor': 0.0}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'refPathMinCapturedPathPct': [0.2, 0.1, 0.4], 'minimumProfitForOppositeExitPct': [0.0]}}, 'generate_signals': generate_signals}
