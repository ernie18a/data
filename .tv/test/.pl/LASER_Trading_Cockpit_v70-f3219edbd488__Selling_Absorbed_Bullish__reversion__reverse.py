import numpy as np

def generate_entries(features, signal_params):
    n = features.market.size
    volume_sma_length = signal_params['volume_sma_length']
    relative_volume_min = signal_params['relative_volume_min']
    body_pct_max = signal_params['body_pct_max']
    lower_wick_pct_min = signal_params['lower_wick_pct_min']
    lower_wick_upper_wick_multiplier = signal_params['lower_wick_upper_wick_multiplier']
    opens = np.asarray(features.market.opens, dtype=np.float64)
    highs = np.asarray(features.market.highs, dtype=np.float64)
    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    volumes = np.asarray(features.market.volumes, dtype=np.float64)
    average_volume = np.asarray(features.sma(volume_sma_length, 'volumes'), dtype=np.float64)
    relative_volume = np.zeros(n, dtype=np.float64)
    valid_average = average_volume > 0
    np.divide(volumes, average_volume, out=relative_volume, where=valid_average)
    candle_range = highs - lows
    body_pct = np.zeros(n, dtype=np.float64)
    lower_wick_pct = np.zeros(n, dtype=np.float64)
    valid_range = candle_range > 0
    np.divide(np.abs(closes - opens) * 100.0, candle_range, out=body_pct, where=valid_range)
    lower_wick = np.minimum(opens, closes) - lows
    upper_wick = highs - np.maximum(opens, closes)
    np.divide(lower_wick * 100.0, candle_range, out=lower_wick_pct, where=valid_range)
    candle_mid = (highs + lows) / 2.0
    long_entries = ((relative_volume >= relative_volume_min) & (body_pct <= body_pct_max) & (lower_wick_pct >= lower_wick_pct_min) & (lower_wick >= upper_wick * lower_wick_upper_wick_multiplier) & (closes >= candle_mid)).astype(bool)
    short_entries = np.zeros(n, dtype=bool)
    return (long_entries, short_entries)

def i5_apply_reversion_exit(features: object, long_entries: object, short_entries: object, signal_params: dict) -> tuple:
    return features.reversion_exit(long_entries, short_entries)

def generate_signals(features, signal_params):
    short_entries, long_entries = generate_entries(features, signal_params)
    long_exits, short_exits = i5_apply_reversion_exit(features, long_entries, short_entries, signal_params)
    no_distances = np.full(features.market.size, np.nan, dtype=np.float64)
    return (long_entries, long_exits, short_entries, short_exits, no_distances, no_distances)

STRATEGY = {**{'strategy_id': 'Selling_Absorbed_Bullish__reversion__reverse', 'hypothesis': '當成交量相對 20 根均量放大且 K 棒實體較小、下影線占比高於上影線時，若收盤位於 K 棒中點以上則做多。', 'position': 'both', 'signal_parameter_names': ['volume_sma_length', 'relative_volume_min', 'body_pct_max', 'lower_wick_pct_min', 'lower_wick_upper_wick_multiplier'], 'signal_parameter_specs': [{'name': 'volume_sma_length', 'family': 'lookback', 'anchor': 20}, {'name': 'relative_volume_min', 'family': 'multiplier', 'anchor': 1.5}, {'name': 'body_pct_max', 'family': 'threshold_0_100', 'anchor': 40.0}, {'name': 'lower_wick_pct_min', 'family': 'threshold_0_100', 'anchor': 35.0}, {'name': 'lower_wick_upper_wick_multiplier', 'family': 'multiplier', 'anchor': 1.5}], 'signal_parameter_relations': [], 'signal_parameter_candidates': {'volume_sma_length': [20, 10, 40], 'relative_volume_min': [1.5, 1.0499999999999998, 2.0999999999999996], 'body_pct_max': [40.0, 30.0, 50.0], 'lower_wick_pct_min': [35.0, 25.0, 45.0], 'lower_wick_upper_wick_multiplier': [1.5, 1.0499999999999998, 2.0999999999999996]}}, 'generate_signals': generate_signals}
