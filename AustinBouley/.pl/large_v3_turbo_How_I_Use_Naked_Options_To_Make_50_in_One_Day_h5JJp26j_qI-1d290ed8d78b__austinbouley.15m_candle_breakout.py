import numpy as np


def generate_signals(features, signal_params):
    market = features.market
    size = market.size
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    if size < 2:
        return long_entries, long_exits, short_entries, short_exits

    closes = market.closes
    highs = market.highs
    lows = market.lows
    valid = (
        np.isfinite(closes[1:])
        & np.isfinite(highs[:-1])
        & np.isfinite(lows[:-1])
    )

    # The prior completed candle supplies the two breakout reference lines.
    long_entries[1:] = valid & (closes[1:] > highs[:-1])
    short_entries[1:] = valid & (closes[1:] < lows[:-1])

    # Derived exits mirror each entry's directional relation to its upper/lower line.
    long_exits[1:] = valid & (closes[1:] < highs[:-1])
    short_exits[1:] = valid & (closes[1:] > lows[:-1])

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "austinbouley.15m_candle_breakout",
    "hypothesis": (
        "原文條件（READ 第 81、89-94 行）：等待一根 15 分鐘 K 線完成，"
        "把其高、低畫為界線；下一根收盤嚴格高於前根高時買 call，"
        "嚴格低於前根低時買 put。形式化解讀：對框架提供的相鄰 K 線，"
        "在索引 t 以 close[t] > high[t-1] 產生多方訊號，"
        "以 close[t] < low[t-1] 產生空方訊號；任一所需價格非有限值或"
        "不足兩根 K 線時不發訊號。推導出場：來源未給出出場，故鏡像進場"
        "對同一『前一根完成 K 線』界線的方向關係與一根後判定順序："
        "多方在 close[t] < high[t-1] 出場，空方在 close[t] > low[t-1] 出場。"
    ),
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [],
    "signal_parameter_sets": [{}],
}
