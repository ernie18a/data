import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    volumes = np.asarray(features.market.volumes, dtype=np.float64)
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volume_sma = features.sma(signal_params['volume_sma_length'], 'volumes')
    relative_volume = np.divide(volumes, volume_sma, out=np.zeros(n, dtype=np.float64), where=volume_sma > 0)
    candle_range = highs - lows
    body_pct = np.divide(np.abs(closes - opens) * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    lower_wick = np.minimum(opens, closes) - lows
    upper_wick = highs - np.maximum(opens, closes)
    upper_wick_pct = np.divide(upper_wick * 100.0, candle_range, out=np.zeros(n, dtype=np.float64), where=candle_range > 0)
    candle_mid = (highs + lows) / 2.0
    long_entries = np.zeros(n, dtype=bool)
    short_entries = ((relative_volume >= signal_params['relative_volume_threshold']) & (body_pct <= signal_params['body_pct_max']) & (upper_wick_pct >= signal_params['upper_wick_pct_min']) & (upper_wick >= lower_wick * signal_params['upper_to_lower_wick_multiplier']) & (closes <= candle_mid)).astype(bool)
    return (long_entries, short_entries)

def i5_apply_trend_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.trend_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_trend_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Buying_Absorbed_Bearish__trend__reverse', 'hypothesis': '當相對成交量偏高、K線實體較小且上影線占比高於下影線時，若收盤價位於K線中點以下，則做空以捕捉上方賣壓。', 'position': 'both', 'signal_parameter_names': ['volume_sma_length', 'relative_volume_threshold', 'body_pct_max', 'upper_wick_pct_min', 'upper_to_lower_wick_multiplier'], 'signal_parameter_specs': [{'name': 'volume_sma_length', 'family': 'lookback', 'anchor': 20}, {'name': 'relative_volume_threshold', 'family': 'multiplier', 'anchor': 1.5}, {'name': 'body_pct_max', 'family': 'threshold_0_100', 'anchor': 40.0}, {'name': 'upper_wick_pct_min', 'family': 'threshold_0_100', 'anchor': 35.0}, {'name': 'upper_to_lower_wick_multiplier', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'volume_sma_length': [20, 10, 40], 'relative_volume_threshold': [1.5, 1.0499999999999998, 2.0999999999999996], 'body_pct_max': [40.0, 30.0, 50.0], 'upper_wick_pct_min': [35.0, 25.0, 45.0], 'upper_to_lower_wick_multiplier': [1.5, 1.0499999999999998, 2.0999999999999996]}}, 'generate_signals': generate_signals}
