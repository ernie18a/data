Calculation: Price range = max(high - low, minimum price increment).
Calculation: Body percentage = 100 * abs(close - open) / price range.
Calculation: Delta flow = 100 * (((close - low) / price range * volume) - ((high - close) / price range * volume)) / max(volume, 1); smoothed delta = EMA of delta flow.
Calculation: Relative volume = volume / SMA(volume) when SMA(volume) > 0, otherwise 0.
Calculation: Confirmed pivot high or low = a high or low confirmed by the same number of bars on each side; retain the most recently confirmed value, including one confirmed on the current bar.
Calculation: Bullish structure shift = close > latest confirmed pivot high AND previous close <= that same pivot high AND close - pivot high > ATR * displacement threshold. Bearish structure shift = close < latest confirmed pivot low AND previous close >= that same pivot low AND pivot low - close > ATR * displacement threshold.
Calculation: Structure state = 1 after a bullish structure shift, -1 after a bearish structure shift, and otherwise the previous state; initially 0.
Calculation: Fast and slow flow = shorter- and longer-period EMAs of (high + low + close) / 3, respectively; the slow period is twice the fast period. Calculate the corresponding higher-timeframe flows and smoothed delta on higher-timeframe bars, using the last completed higher-timeframe bar on historical chart bars and the bar still forming in real time.
Calculation: Bullish higher-timeframe pass = higher-timeframe filter disabled OR (higher-timeframe fast flow >= slow flow AND higher-timeframe smoothed delta >= 0). Bearish higher-timeframe pass = higher-timeframe filter disabled OR (higher-timeframe fast flow <= slow flow AND higher-timeframe smoothed delta <= 0).
Calculation: Bullish score = 2 if bullish structure shift, plus 1 each for relative volume >= volume threshold, (close > open AND delta flow > 0 AND smoothed delta > 0), (body percentage >= body threshold AND close > fast flow), fast flow > slow flow, and bullish higher-timeframe pass. Bearish score = 2 if bearish structure shift, plus 1 each for relative volume >= volume threshold, (close < open AND delta flow < 0 AND smoothed delta < 0), (body percentage >= body threshold AND close < fast flow), fast flow < slow flow, and bearish higher-timeframe pass.
Long: bullish structure shift AND bullish higher-timeframe pass AND bullish score >= minimum catalyst score.
Short: bearish structure shift AND bearish higher-timeframe pass AND bearish score >= minimum catalyst score.
Long: structure state = 1.
Short: structure state = -1.
Long: fast flow >= slow flow.
Short: fast flow < slow flow.
Long: higher-timeframe fast flow > higher-timeframe slow flow.
Short: higher-timeframe fast flow < higher-timeframe slow flow.
Long: smoothed delta > 0.
Short: smoothed delta < 0.