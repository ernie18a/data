import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    sto_k, sto_d = features.stoch(signal_params['stochastic_lookback'], signal_params['sto_k_smoothing'], signal_params['sto_d_smoothing'])
    prev_k = np.concatenate(([np.nan], sto_k[:-1]))
    prev_d = np.concatenate(([np.nan], sto_d[:-1]))
    long_entries = (sto_k > sto_d) & (prev_k <= prev_d)
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Stochastic_K_D_Crossover__trend__reverse', 'hypothesis': '當隨機指標的 K 線上穿 D 線時進場，以捕捉動能轉強。', 'position': 'both', 'signal_parameter_names': ['stochastic_lookback', 'sto_k_smoothing', 'sto_d_smoothing'], 'signal_parameter_specs': [{'name': 'stochastic_lookback', 'family': 'lookback', 'anchor': 9}, {'name': 'sto_k_smoothing', 'family': 'lookback', 'anchor': 3}, {'name': 'sto_d_smoothing', 'family': 'lookback', 'anchor': 3}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'stochastic_lookback': [9, 4, 18], 'sto_k_smoothing': [3, 2, 6], 'sto_d_smoothing': [3, 2, 6]}}, 'generate_signals': generate_signals}
