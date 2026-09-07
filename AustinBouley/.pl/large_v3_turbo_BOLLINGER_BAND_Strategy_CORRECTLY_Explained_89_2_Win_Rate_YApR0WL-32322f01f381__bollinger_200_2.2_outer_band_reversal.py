import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    closes = np.asarray(market.closes, dtype=np.float64)
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    period = 200
    deviation_multiplier = 2.2
    if size < period + 1:
        return long_entries, long_exits, short_entries, short_exits

    finite = np.isfinite(closes)
    safe_closes = np.where(finite, closes, 0.0)
    cumulative = np.empty(size + 1, dtype=np.float64)
    cumulative_squares = np.empty(size + 1, dtype=np.float64)
    finite_count = np.empty(size + 1, dtype=np.int64)
    cumulative[0] = 0.0
    cumulative_squares[0] = 0.0
    finite_count[0] = 0
    cumulative[1:] = np.cumsum(safe_closes, dtype=np.float64)
    cumulative_squares[1:] = np.cumsum(safe_closes * safe_closes, dtype=np.float64)
    finite_count[1:] = np.cumsum(finite, dtype=np.int64)

    middle = np.full(size, np.nan, dtype=np.float64)
    standard_deviation = np.full(size, np.nan, dtype=np.float64)
    valid = np.zeros(size, dtype=np.bool_)
    window_sums = cumulative[period:] - cumulative[:-period]
    window_square_sums = cumulative_squares[period:] - cumulative_squares[:-period]
    window_finite_counts = finite_count[period:] - finite_count[:-period]
    window_valid = window_finite_counts == period
    means = window_sums / period
    variances = np.maximum(window_square_sums / period - means * means, 0.0)
    middle[period - 1:] = np.where(window_valid, means, np.nan)
    standard_deviation[period - 1:] = np.where(
        window_valid, np.sqrt(variances), np.nan
    )
    valid[period - 1:] = window_valid
    upper = middle + deviation_multiplier * standard_deviation
    lower = middle - deviation_multiplier * standard_deviation

    valid_pair = valid[1:] & valid[:-1]
    short_entries[1:] = valid_pair & (closes[1:] > upper[1:]) & (
        closes[:-1] <= upper[:-1]
    )
    long_entries[1:] = valid_pair & (closes[1:] < lower[1:]) & (
        closes[:-1] >= lower[:-1]
    )
    short_exits[1:] = valid_pair & (closes[1:] < upper[1:]) & (
        closes[:-1] >= upper[:-1]
    )
    long_exits[1:] = valid_pair & (closes[1:] > lower[1:]) & (
        closes[:-1] <= lower[:-1]
    )
    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'bollinger_200_2.2_outer_band_reversal',
    'hypothesis': '原文條件：20 期中線與 2 個標準差的 Bollinger Bands 定義（READ 15–23）；作者改設為 200 期與 2.2 倍標準差（READ 54–56）。原文交易方向：價格突破上軌時做空（READ 70–73），跌破下軌時做多（READ 79–81）。形式化解讀：以每根已收盤的 close 計算 200 期 SMA 與母體標準差；突破／跌破定義為本根 close 分別由不高於上軌轉為高於上軌、由不低於下軌轉為低於下軌。推導出場：原文未指定出場；空單於 close 由不低於上軌轉為低於上軌時退出，多單於 close 由不高於下軌轉為高於下軌時退出，僅鏡像各自進場的同一外軌穿越關係。',
    'position': 'both',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}
