import numpy as np

def generate_signals(features, signal_params):
    market = features.market
    n = int(market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)

    opens = np.asarray(market.opens, dtype=np.float64)
    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    closes = np.asarray(market.closes, dtype=np.float64)
    valid = (
        np.isfinite(opens)
        & np.isfinite(highs)
        & np.isfinite(lows)
        & np.isfinite(closes)
        & (highs >= np.maximum(opens, closes))
        & (lows <= np.minimum(opens, closes))
    )
    body = np.abs(closes - opens)
    lower_wick = np.minimum(opens, closes) - lows
    upper_wick = highs - np.maximum(opens, closes)

    bullish_rejection = (
        valid
        & (closes > opens)
        & (lower_wick > body)
        & (upper_wick < body)
    )
    bearish_rejection = (
        valid
        & (closes < opens)
        & (upper_wick > body)
        & (lower_wick < body)
    )

    long_entries[:] = bullish_rejection
    long_exits[:] = bearish_rejection
    short_entries[:] = bearish_rejection
    short_exits[:] = bullish_rejection
    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    "strategy_id": "candlestick_rejection_mirror",
    "hypothesis": "原文條件（READ 第 98-108、115-126、164-173、179-181 行）：收盤高於開盤且低點遭大量拒絕、上方僅輕微拒絕，被稱為 very bullish；其後明示反向的上方拒絕／賣壓為 bearish，並以 hammer／shooting star 說明低／高位拒絕。原文還描述雙邊長影線、doji、大小 K 線為 indecision 或形態說明（第 81-97、176-199 行），未給交易觸發，故不納入。口語形式化：body=abs(close-open)，lower_wick=min(open,close)-low，upper_wick=high-max(open,close)；bullish rejection 為 close>open AND lower_wick>body AND upper_wick<body，bearish rejection 為其方向與影線關係鏡像；只在 OHLC 有限且幾何有效時發訊號。推導出場：原文未明示出場，long_exit 鏡像 long_entry 的方向核心為 bearish rejection，short_exit 鏡像 short_entry 的方向核心為 bullish rejection；未新增指標、門檻、窗口或反向以外的風控。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
