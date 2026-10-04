import numpy as np

def generate_entries(features, signal_params):
    sma_length = signal_params['sma_length']
    atr_ema_length = signal_params['atr_ema_length']
    closes = features.market.closes
    pgo = (closes - features.sma(sma_length)) / features.ema(atr_ema_length, features.atr(22))
    long_entries = pgo > 3.0
    short_entries = pgo < -3.0
    return (long_entries.astype(bool), short_entries.astype(bool))

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    long_entries, short_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'pgo_threshold_breakout__reversion__follow', 'hypothesis': '以收盤價相對其 14 期簡單均線的偏離，除以 ATR 的指數平滑值作為 PGO，超過正門檻做多、低於負門檻做空。', 'position': 'both', 'signal_parameter_names': ['sma_length', 'atr_ema_length'], 'signal_parameter_specs': [{'name': 'sma_length', 'family': 'lookback', 'anchor': 14}, {'name': 'atr_ema_length', 'family': 'lookback', 'anchor': 14}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'sma_length': [14, 7, 28], 'atr_ema_length': [14, 7, 28]}}, 'generate_signals': generate_signals}
