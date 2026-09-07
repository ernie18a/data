import numpy as np

def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    closes = np.asarray(market.closes, dtype=np.float64)
    middle = features.sma(200)
    deviation = features.std(200)
    upper = middle + deviation
    lower = middle - deviation
    valid = (
        np.isfinite(closes)
        & np.isfinite(middle)
        & np.isfinite(deviation)
        & np.isfinite(upper)
        & np.isfinite(lower)
    )

    long_entries[valid] = closes[valid] > upper[valid]
    long_exits[valid] = closes[valid] < upper[valid]
    short_entries[valid] = closes[valid] < lower[valid]
    short_exits[valid] = closes[valid] > lower[valid]
    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "bollinger_trend_credit_spread_directional",
    "hypothesis": "來源第 34-35 行將順勢布林設定為長度 200、標準差 1；第 36-42 行稱價格在布林線上方為上升趨勢、在下方藍線下方為下降趨勢，並分別使用看漲 put credit spread 與看跌 call credit spread。形式化解讀：依第 38 行的『bottom blue Bollinger Band』消解第 36 行的上方『Bollinger Band line』為上軌；中線為 200 期收盤 SMA，軌道為中線加減同窗口收盤標準差。收盤高於上軌時發多方訊號，收盤低於下軌時發空方訊號；以框架的標的 long/short 表達原文已明示的 bullish/bearish 方向。原文未給出場；鏡像推導為多方收盤低於同一上軌時出場、空方收盤高於同一下軌時出場，保留進場的方向關係與參考軌。前 199 根或任何相關數值非有限時不發訊號。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
