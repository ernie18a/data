import numpy as np

def generate_entries(features, signal_params):
    stoch_length = signal_params['stoch_length']
    stoch_k_smoothing_length = signal_params['stoch_k_smoothing_length']
    stoch_d_smoothing_length = signal_params['stoch_d_smoothing_length']
    n = features.market.size
    sto_k, sto_d = features.stoch(stoch_length, stoch_k_smoothing_length, stoch_d_smoothing_length)
    long_entries = np.zeros(n, dtype=bool)
    short_entries = np.zeros(n, dtype=bool)
    short_entries[1:] = (sto_k[1:] < sto_d[1:]) & (sto_k[:-1] >= sto_d[:-1])
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Stochastic_K_D_Crossunder__reversion__reverse', 'hypothesis': '以隨機指標的 %K 向下穿越 %D 作為進場訊號。', 'position': 'both', 'signal_parameter_names': ['stoch_length', 'stoch_k_smoothing_length', 'stoch_d_smoothing_length'], 'signal_parameter_specs': [{'name': 'stoch_length', 'family': 'lookback', 'anchor': 9}, {'name': 'stoch_k_smoothing_length', 'family': 'lookback', 'anchor': 3}, {'name': 'stoch_d_smoothing_length', 'family': 'lookback', 'anchor': 3}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'stoch_length': [9, 4, 18], 'stoch_k_smoothing_length': [3, 2, 6], 'stoch_d_smoothing_length': [3, 2, 6]}}, 'generate_signals': generate_signals}
