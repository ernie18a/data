import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    ema_length = signal_params['ema_length']
    closes = features.market.closes
    ema_values = features.ema(ema_length, 'closes')
    previous_closes = np.concatenate(([np.nan], closes[:-1]))
    previous_ema = np.concatenate(([np.nan], ema_values[:-1]))
    long_entries = np.zeros(n, dtype=bool)
    short_entries = (closes < ema_values) & (previous_closes >= previous_ema)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'EMA_200_Price_Crossunder__trend__reverse', 'hypothesis': '收盤價向下跌破 200 期 EMA 時進場，捕捉價格轉弱訊號。', 'position': 'both', 'signal_parameter_names': ['ema_length'], 'signal_parameter_specs': [{'name': 'ema_length', 'family': 'lookback', 'anchor': 200}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'ema_length': [200, 100, 400]}}, 'generate_signals': generate_signals}
