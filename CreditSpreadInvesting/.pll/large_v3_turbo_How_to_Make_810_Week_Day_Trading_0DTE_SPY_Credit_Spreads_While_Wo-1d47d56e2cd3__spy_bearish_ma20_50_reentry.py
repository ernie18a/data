import numpy as np

def generate_signals(features, signal_params):
    market = features.market
    n = int(market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    if n < 2:
        return long_entries, long_exits, short_entries, short_exits

    # The source does not specify the MA type; the framework's simple moving
    # average is used as the direct formalisation of "moving average".
    ma20 = np.asarray(features.sma(20), dtype=np.float64)
    ma50 = np.asarray(features.sma(50), dtype=np.float64)
    valid = np.isfinite(ma20) & np.isfinite(ma50)
    short_entries[1:] = (
        valid[1:]
        & valid[:-1]
        & (ma20[1:] < ma50[1:])
        & (ma20[:-1] >= ma50[:-1])
    )
    short_exits[1:] = (
        valid[1:]
        & valid[:-1]
        & (ma20[1:] > ma50[1:])
        & (ma20[:-1] <= ma50[:-1])
    )
    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {
    "strategy_id": "spy_bearish_ma20_50_reentry",
    "hypothesis": "原文條件（READ 第161-168行）：週四交易 402/403 call spread；在上升、回落、再上升的雙頂／下行背景中，文中明確說 20 period moving average crosses the 50 period moving average 是再次進場訊號。形式化解讀：以行情收盤價 SMA(20) 由前一根不低於 SMA(50) 穿至當前低於 SMA(50) 作為熊方進場，對應 call credit spread 的 bearish 方向；均線窗口不足或數值無效時抑制訊號。原文未提供此再次進場訊號的獨立出場，因此依指定鏡像同一方向關係，以 SMA(20) 由前一根不高於 SMA(50) 穿至當前高於 SMA(50) 出場；未新增反向開倉、風控或其他參數。",
    "position": "short",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}