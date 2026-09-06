import numpy as np

def generate_signals(features, signal_params):
    n = int(features.market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)

    if n < 50:
        return long_entries, long_exits, short_entries, short_exits

    lows = np.asarray(features.market.lows, dtype=np.float64)
    closes = np.asarray(features.market.closes, dtype=np.float64)
    sma20 = np.asarray(features.sma(20), dtype=np.float64)
    sma50 = np.asarray(features.sma(50), dtype=np.float64)

    valid = (
        np.isfinite(lows)
        & np.isfinite(closes)
        & np.isfinite(sma20)
        & np.isfinite(sma50)
    )
    if n >= 2:
        pair_valid = valid[:-1] & valid[1:]
        long_entries[1:] = (
            pair_valid
            & (sma20[1:] >= sma50[1:])
            & (lows[1:] <= sma50[1:])
            & (closes[1:] > sma50[1:])
        )
        long_exits[1:] = (
            pair_valid
            & (closes[:-1] >= sma50[:-1])
            & (closes[1:] < sma50[1:])
        )

    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    "strategy_id": "put_credit_bounce_long",
    "hypothesis": "原文條件（READ:21-25、54-64）：中長期市場偏多，主要賣 put credit spread；以 20／50 日均線與支撐／阻力觀察回撤，確認價格在均線附近反彈，並把支撐下方 1 ATR 作為選擇權價差的空間。形式化解讀：框架只有 underlying OHLCV，故以多頭持倉代表 put credit spread 的 bullish direction；採來源具體回顧中明確提到的 50 日均線作基準，以 SMA20 >= SMA50 作偏多過濾，且同一根資料須出現 low <= SMA50、再以 close > SMA50 確認反彈。來源列出的 volume、candlestick 等沒有固定額外門檻，這裡不跨用 READ:72-88 的 call-side 陽線示例；1 ATR 是選擇權履約價距離，框架沒有選擇權履約價資料，不能轉成 underlying 訊號。推導出場（非原文明示的 underlying exit）：依指定的鏡像規則，進場核心為在同一 SMA50 上方確認反彈，因此以 close 下穿同一 SMA50 出場；不加入反向開倉。",
    "position": "long",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
