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

    opens = np.asarray(market.opens, dtype=np.float64)
    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    closes = np.asarray(market.closes, dtype=np.float64)

    sma20 = np.full(n, np.nan, dtype=np.float64)
    sma50 = np.full(n, np.nan, dtype=np.float64)
    ema200 = np.full(n, np.nan, dtype=np.float64)
    for i in range(n):
        if i >= 19:
            window = closes[i - 19 : i + 1]
            if np.all(np.isfinite(window)):
                sma20[i] = np.mean(window)
        if i >= 49:
            window = closes[i - 49 : i + 1]
            if np.all(np.isfinite(window)):
                sma50[i] = np.mean(window)
    if np.isfinite(closes[0]):
        ema200[0] = closes[0]
    alpha = 2.0 / 201.0
    for i in range(1, n):
        if np.isfinite(closes[i]) and np.isfinite(ema200[i - 1]):
            ema200[i] = alpha * closes[i] + (1.0 - alpha) * ema200[i - 1]

    bullish_engulfing = np.zeros(n, dtype=np.bool_)
    for i in range(1, n):
        if not (
            np.isfinite(opens[i - 1])
            and np.isfinite(highs[i - 1])
            and np.isfinite(lows[i - 1])
            and np.isfinite(closes[i - 1])
            and np.isfinite(opens[i])
            and np.isfinite(highs[i])
            and np.isfinite(lows[i])
            and np.isfinite(closes[i])
        ):
            continue
        bullish_engulfing[i] = (
            closes[i - 1] < opens[i - 1]
            and closes[i] > opens[i]
            and opens[i] <= closes[i - 1]
            and closes[i] >= opens[i - 1]
        )

    for i in range(1, n):
        if (
            np.isfinite(sma20[i])
            and np.isfinite(sma20[i - 1])
            and np.isfinite(sma50[i])
            and np.isfinite(sma50[i - 1])
            and np.isfinite(ema200[i])
            and np.isfinite(lows[i])
            and np.isfinite(highs[i])
        ):
            downtrend_confirmation = (
                sma20[i] < sma20[i - 1] or sma50[i] < sma50[i - 1]
            )
            ema200_touch = lows[i] <= ema200[i] <= highs[i]
            long_entries[i] = bullish_engulfing[i] and downtrend_confirmation and ema200_touch
        if (
            np.isfinite(sma20[i])
            and np.isfinite(sma20[i - 1])
            and np.isfinite(closes[i - 1])
            and np.isfinite(highs[i])
        ):
            long_exits[i] = closes[i - 1] < sma20[i - 1] and highs[i] >= sma20[i]

    return long_entries, long_exits, short_entries, short_exits

STRATEGY = {'strategy_id': 'macs_200ema_bullish_engulfing', 'hypothesis': '原文條件（READ 第489-499行）：200-period moving average 作為支撐區；20 或 50 moving average 向下確認 downtrend；在該支撐看到 bullish engulfing，於下一根 K 線開盤進場。形式化解讀：20、50 為 SMA，200 為 EMA（READ 第319-324、330-332行的明確說明）；訊號 K 線 high/low 觸及 200 EMA，且前一根為陰線、本根為陽線，本根實體開盤不高於前收且收盤不低於前開；20 或 50 SMA 的單期斜率為負。FRAMEWORK engine.py 第337-418行會以訊號 K 線後一根開盤成交。保留同 setup 明確的 20 SMA 目標（READ 第497-499行）：訊號 K 線 high 觸及 20 SMA 且前收在其下時出場；未把進場的 200 EMA 或趨勢資格搬入出場。原文 ATR stop 屬風控，由 FRAMEWORK 風控網格處理；本策略不選週期或風控。', 'position': 'long', 'generate_signals': generate_signals, 'signal_parameter_names': [], 'signal_parameter_sets': [{}]}