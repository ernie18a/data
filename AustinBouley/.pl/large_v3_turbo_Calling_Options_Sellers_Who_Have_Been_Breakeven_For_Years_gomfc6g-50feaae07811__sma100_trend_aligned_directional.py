import numpy as np

def generate_signals(features, signal_params):
    closes = np.asarray(features.market.closes, dtype=np.float64)
    size = features.market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    length = 100
    if size < length:
        return long_entries, long_exits, short_entries, short_exits

    finite = np.isfinite(closes)
    sums = np.cumsum(np.where(finite, closes, 0.0), dtype=np.float64)
    counts = np.cumsum(finite.astype(np.int64))
    rolling_sums = sums.copy()
    rolling_counts = counts.copy()
    rolling_sums[length:] -= sums[:-length]
    rolling_counts[length:] -= counts[:-length]
    valid = (np.arange(size) >= length - 1) & (rolling_counts == length)
    sma = np.zeros(size, dtype=np.float64)
    sma[valid] = rolling_sums[valid] / float(length)

    bullish = valid & (closes > sma)
    bearish = valid & (closes < sma)
    long_entries[:] = bullish
    short_entries[:] = bearish
    long_exits[:] = bearish
    short_exits[:] = bullish
    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    'strategy_id': 'sma100_trend_aligned_directional',
    'hypothesis': '原文規則（來源第 73-76、82-88 行）：收盤價高於 100 期 SMA 為多頭市場，只採用看多策略；低於同一 SMA 為空頭市場，只採用看空策略。形式化：以當根及之前 99 根收盤價的算術平均為 SMA；close > SMA 發出 long entry，close < SMA 發出 short entry，且窗口中任一收盤價非有限值時抑制訊號。原文未給出出場；推導出場為 long 在 close < 同一 100 期 SMA 時退出、short 在 close > 同一 SMA 時退出，分別鏡像進場的多／空方向與相同基準；等於 SMA 時不產生訊號。框架於下一根開盤成交。',
    'position': 'both',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}
