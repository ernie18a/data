Calculation: Confirmed pivot high/low = a high/low whose value is the highest/lowest over equal numbers of bars before and after it; it becomes available on its confirmation bar. The latest pivot is updated before evaluating that bar’s decisions.
Calculation: Break up/down = close crosses above/below the latest confirmed pivot high/low, comparing both the current and previous close with the corresponding bar’s latest pivot level.
Calculation: Sweep up/down = low/high crosses beyond the latest confirmed pivot low/high and close is back above/below that level on the same bar.
Calculation: Body = absolute value of close minus open; lower wick = min(open, close) minus low; upper wick = high minus max(open, close).
Calculation: Bull/bear rejection = lower/upper wick > body × rejection multiplier AND close >/< open.
Calculation: Demand/supply zone = volume > volume SMA × volume multiplier AND close >/< open AND lower/upper wick > body × zone wick multiplier.
Calculation: Bull/bear trend = short EMA >/< medium EMA AND close >/< long EMA.
Calculation: Higher-timeframe bull/bear trend = higher-timeframe short EMA >/< higher-timeframe medium EMA, using the last completed higher-timeframe bar on historical bars and the still-forming higher-timeframe bar in realtime.
Calculation: Wave = short EMA of close minus longer EMA of close; wave signal = EMA of wave.
Calculation: Score = sum of configurable weights for each true condition: bull or bear trend; ADX above its threshold; chart and higher-timeframe trends aligned; ATR above its SMA; volume above its SMA with a non-doji candle; chart bar opening within the overlap of two configurable New York sessions; break up or down; sweep up or down; low above the high a configurable number of bars earlier or high below the low that many bars earlier; enabled bullish or bearish order block; enabled demand or supply zone; enabled equal pivot highs or lows; wave above its signal and zero with bull trend or below both with bear trend; close above SuperTrend with bull trend or below it with bear trend; candle body divided by range above a threshold and range above ATR; and news allowed. Apply a configurable negative weight instead of the news-allowed weight when news is blocked. An order block requires the corresponding break and an oppositely directed previous candle. Equal pivots require the absolute difference between consecutive confirmed same-side pivots <= ATR × tolerance; update the prior pivot only while that feature is enabled. Demand and supply zones contribute only while their feature is enabled. News is allowed when the news filter is disabled or the bar opens outside a configurable New York blackout session.
Long: Break up OR sweep up.
Short: Break down OR sweep down.
Long: Bull rejection OR demand zone.
Short: Bear rejection OR supply zone.
Long: Low > high a configurable number of bars earlier.
Short: High < low a configurable number of bars earlier.
Long: A newly confirmed pivot low differs from the preceding confirmed pivot low by <= ATR × tolerance.
Short: A newly confirmed pivot high differs from the preceding confirmed pivot high by <= ATR × tolerance.
Long: Wave crosses above wave signal.
Short: Wave crosses below wave signal.
Long: Bull trend OR close > SuperTrend OR wave > wave signal AND wave > 0 OR EMA of close change over a configurable lookback > 0 OR close > open AND volume > volume SMA.
Short: Bear trend OR close < SuperTrend OR wave < wave signal AND wave < 0 OR EMA of close change over a configurable lookback < 0 OR close < open AND volume > volume SMA.
Long: Bull trend AND RSI > threshold AND close > session VWAP of close AND higher-timeframe bull trend AND ADX > threshold AND close < midpoint of rolling highest high and lowest low AND close > SuperTrend AND wave > wave signal AND wave > 0 AND (break up OR sweep up OR enabled bull rejection OR enabled demand zone) AND news allowed AND score >= threshold.
Short: Bear trend AND RSI < threshold AND close < session VWAP of close AND higher-timeframe bear trend AND ADX > threshold AND close > midpoint of rolling highest high and lowest low AND close < SuperTrend AND wave < wave signal AND wave < 0 AND (break down OR sweep down OR enabled bear rejection OR enabled supply zone) AND news allowed AND score >= threshold.