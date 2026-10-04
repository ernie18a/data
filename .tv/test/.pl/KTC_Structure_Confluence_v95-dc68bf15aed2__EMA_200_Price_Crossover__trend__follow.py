import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    ema_period = signal_params['ema_period']
    closes = features.market.closes
    ema = features.ema(ema_period)
    long_entries = np.zeros(n, dtype=bool)
    long_entries[1:] = (closes[1:] > ema[1:]) & (closes[:-1] <= ema[:-1])
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'EMA_200_Price_Crossover__trend__follow', 'hypothesis': '當收盤價向上穿越 200 期 EMA 時進場。', 'position': 'both', 'signal_parameter_names': ['ema_period'], 'signal_parameter_specs': [{'name': 'ema_period', 'family': 'lookback', 'anchor': 200}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'ema_period': [200, 100, 400]}}, 'generate_signals': generate_signals}
