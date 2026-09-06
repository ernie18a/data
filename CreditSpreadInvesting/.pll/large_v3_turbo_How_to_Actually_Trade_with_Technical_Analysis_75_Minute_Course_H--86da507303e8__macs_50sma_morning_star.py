import numpy as np

def generate_signals(features, signal_params):
    market = features.market
    n = int(market.size)
    long_entries = np.zeros(n, dtype=np.bool_)
    long_exits = np.zeros(n, dtype=np.bool_)
    short_entries = np.zeros(n, dtype=np.bool_)
    short_exits = np.zeros(n, dtype=np.bool_)
    if n < 3:
        return long_entries, long_exits, short_entries, short_exits

    opens = np.asarray(market.opens, dtype=np.float64)
    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    closes = np.asarray(market.closes, dtype=np.float64)
    sma50 = np.full(n, np.nan, dtype=np.float64)
    for i in range(49, n):
        window = closes[i - 49 : i + 1]
        if np.all(np.isfinite(window)):
            sma50[i] = np.mean(window)

    morning_star = np.zeros(n, dtype=np.bool_)
    evening_star = np.zeros(n, dtype=np.bool_)
    for i in range(2, n):
        if not (
            np.isfinite(opens[i - 2])
            and np.isfinite(highs[i - 2])
            and np.isfinite(lows[i - 2])
            and np.isfinite(closes[i - 2])
            and np.isfinite(opens[i - 1])
            and np.isfinite(highs[i - 1])
            and np.isfinite(lows[i - 1])
            and np.isfinite(closes[i - 1])
            and np.isfinite(opens[i])
            and np.isfinite(highs[i])
            and np.isfinite(lows[i])
            and np.isfinite(closes[i])
        ):
            continue
        middle_upper = highs[i - 1] - max(opens[i - 1], closes[i - 1])
        middle_lower = min(opens[i - 1], closes[i - 1]) - lows[i - 1]
        doji = closes[i - 1] == opens[i - 1] and middle_upper == middle_lower
        morning_star[i] = (
            closes[i - 2] < opens[i - 2]
            and doji
            and closes[i] > opens[i]
            and closes[i] > closes[i - 2]
        )
        evening_star[i] = (
            closes[i - 2] > opens[i - 2]
            and doji
            and closes[i] < opens[i]
            and closes[i] < closes[i - 2]
        )

    for i in range(2, n):
        if (
            morning_star[i]
            and np.isfinite(sma50[i])
            and np.isfinite(sma50[i - 1])
            and np.isfinite(lows[i])
            and np.isfinite(highs[i])
        ):
            sma50_up = sma50[i] > sma50[i - 1]
            sma50_support_touch = lows[i] <= sma50[i] <= highs[i]
            long_entries[i] = sma50_up and sma50_support_touch
        if evening_star[i]:
            long_exits[i] = True

    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {'strategy_id': 'macs_50sma_morning_star', 'hypothesis': '原文條件（READ 第625-632行）：趨勢向上；50-period moving average 位於可由 resistance 轉為 support 的區域；出現 morning star 這個 bullish reversal，於下一根 K 線開盤進場。形式化解讀：50 為 SMA（READ 第319-324行）；以 50 SMA 單期斜率向上表示該 setup 的 uptrend，三根訊號 K 線的第三根 high/low 觸及 50 SMA；morning star 為第一根陰線、第二根零實體且上下影線相等的 indecision K 線、第三根陽線，並保留原文「closed up higher than what it was two periods ago」為第三根收盤高於第一根收盤。FRAMEWORK engine.py 第337-418行於訊號後一根開盤成交。原文只給圖表特定 swing high 作為目標，沒有可泛化的 swing 定義；依進場核心的方向鏡像，以 evening star（陽線、同樣 doji、陰線且第三根收盤低於第一根）作為 long exit，不附加 50 SMA 或趨勢進場資格。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': [], 'signal_parameter_sets': [{}]}