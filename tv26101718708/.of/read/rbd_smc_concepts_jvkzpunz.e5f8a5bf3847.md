Calculation: Confirmed pivot high or low = a high or low with a specified number of bars on each side satisfying the pivot-high or pivot-low comparison; it becomes available only after the right-side bars complete. Use independently parameterized pivots for chart-timeframe structure, chart-timeframe sweeps, and higher-timeframe bias.
Calculation: Higher-timeframe bias = bullish when the two latest distinct confirmed pivot highs and the two latest distinct confirmed pivot lows are both rising; bearish when both are falling; otherwise neutral. Use the last completed higher-timeframe bar and ignore a newly reported pivot equal to the latest stored pivot of the same kind.
Calculation: Structure break up or down = close crosses above the latest confirmed chart-timeframe structure pivot high or below the latest confirmed chart-timeframe structure pivot low, respectively; compare the prior close with the prior bar's stored pivot level.
Calculation: Active order block = the high-to-low range of the most recent opposing candle within a configurable lookback preceding a corresponding structure break. Create a bullish block on an up break and a bearish block on a down break; retain a configurable maximum per side, discarding the oldest. A new block is fresh and is first checked on the following bar. With lifecycle tracking enabled, a fresh bullish block becomes mitigated when low <= its high unless close < its low, and a fresh bearish block becomes mitigated when high >= its low unless close > its high. A fresh or mitigated bullish block becomes a bearish breaker when close < its low; a fresh or mitigated bearish block becomes a bullish breaker when close > its high. Breakers do not change state. With lifecycle tracking disabled, remove a bullish block when low <= its high and a bearish block when high >= its low.
Calculation: Sweep body = absolute value of close minus open when nonzero, otherwise a configurable minimum positive price increment.
Long: Higher-timeframe bias = bullish.
Short: Higher-timeframe bias = bearish.
Long: Structure break up = true.
Short: Structure break down = true.
Long: Structure break up = true AND a preceding down candle exists within the order-block lookback.
Short: Structure break down = true AND a preceding up candle exists within the order-block lookback.
Long: A fresh bullish order block becomes mitigated.
Short: A fresh bearish order block becomes mitigated.
Long: A bearish order block becomes a bullish breaker.
Short: A bullish order block becomes a bearish breaker.
Long: Low < latest confirmed sweep pivot low AND close > latest confirmed sweep pivot low AND pivot low minus low >= a configurable multiple of ATR AND (min(open, close) minus low >= a configurable multiple of sweep body OR engulfing is enabled AND close > open AND prior close < prior open AND close >= prior open) AND (alignment filter is disabled OR higher-timeframe bias = bullish).
Short: High > latest confirmed sweep pivot high AND close < latest confirmed sweep pivot high AND high minus pivot high >= a configurable multiple of ATR AND (high minus max(open, close) >= a configurable multiple of sweep body OR engulfing is enabled AND close < open AND prior close > prior open AND close <= prior open) AND (alignment filter is disabled OR higher-timeframe bias = bearish).
Long: Low > high two bars ago AND (alignment filter is disabled OR higher-timeframe bias != bearish).
Short: High < low two bars ago AND (alignment filter is disabled OR higher-timeframe bias != bullish).
Long: ATR > 0 AND prior high minus prior low <= a configurable multiple of current ATR AND close > open AND absolute value of close minus open >= a separate configurable multiple of current ATR.
Short: ATR > 0 AND prior high minus prior low <= a configurable multiple of current ATR AND close < open AND absolute value of close minus open >= a separate configurable multiple of current ATR.