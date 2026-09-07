import numpy as np

def generate_signals(features, signal_params):
    market = features.market
    opens = np.asarray(market.opens, dtype=np.float64)
    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    closes = np.asarray(market.closes, dtype=np.float64)
    n = market.size
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    length = 20
    if n < length + 1:
        return long_entries, long_exits, short_entries, short_exits

    ha_open = np.full(n, np.nan, dtype=np.float64)
    ha_close = np.full(n, np.nan, dtype=np.float64)
    if np.isfinite(opens[0]) and np.isfinite(highs[0]) and np.isfinite(lows[0]) and np.isfinite(closes[0]):
        ha_close[0] = (opens[0] + highs[0] + lows[0] + closes[0]) / 4.0
        ha_open[0] = (opens[0] + closes[0]) / 2.0
    for i in range(1, n):
        if (
            np.isfinite(opens[i])
            and np.isfinite(highs[i])
            and np.isfinite(lows[i])
            and np.isfinite(closes[i])
            and np.isfinite(ha_open[i - 1])
            and np.isfinite(ha_close[i - 1])
        ):
            ha_close[i] = (opens[i] + highs[i] + lows[i] + closes[i]) / 4.0
            ha_open[i] = (ha_open[i - 1] + ha_close[i - 1]) / 2.0

    ema = np.full(n, np.nan, dtype=np.float64)
    if np.all(np.isfinite(ha_close[:length])):
        ema[length - 1] = np.mean(ha_close[:length])
        alpha = 2.0 / (length + 1.0)
        for i in range(length, n):
            if np.isfinite(ha_close[i]) and np.isfinite(ema[i - 1]):
                ema[i] = alpha * ha_close[i] + (1.0 - alpha) * ema[i - 1]

    valid = np.isfinite(ha_open) & np.isfinite(ha_close) & np.isfinite(ema)
    green = ha_close > ha_open
    red = ha_close < ha_open
    for i in range(length, n):
        if not (valid[i] and valid[i - 1]):
            continue
        crosses_above = ha_close[i] > ema[i] and ha_close[i - 1] <= ema[i - 1]
        crosses_below = ha_close[i] < ema[i] and ha_close[i - 1] >= ema[i - 1]
        if crosses_above and green[i]:
            long_entries[i] = True
        if crosses_below and red[i]:
            short_entries[i] = True

    long_exits[:] = short_entries
    short_exits[:] = long_entries
    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    'strategy_id': 'heikin_ashi_ema20_trend',
    'hypothesis': '規則：在 Heikin Ashi 圖上，以 HA 收盤價上穿 20 期 EMA 且當根 HA 為綠（HA close > HA open）時做多；下穿且當根為紅時做空。原文依據：第 23 行選 Heikin Ashi、第 52–55 行將 EMA 由 12 改為 20、第 59–62 行稱為移動平均交叉且多頭需綠燭、向上並在 EMA 上方；第 69–71、76–81 行說跌破／紅色時向下交易。形式化解讀：EMA 作用於已切換的 HA 圖之 HA 收盤價；「交叉」為本根嚴格越過、前根在另一側或相等，綠／紅以 HA close 相對 HA open 表示；未定義窗口的盤前高、支撐／阻力只屬示例，未納入。出場：來源第 89、95–96 行明說反轉並跌破 EMA 後向下交易；因此多頭出場等於上述空頭進場，空頭出場等於上述多頭進場，保留相同交叉與燭色確認。',
    'position': 'both',
    'generate_signals': generate_signals,
    'signal_parameter_names': [],
    'signal_parameter_sets': [{}],
}
