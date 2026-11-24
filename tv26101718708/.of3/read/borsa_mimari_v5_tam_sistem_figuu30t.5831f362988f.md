Calculation: Score = the sum of a positive vote increment or negative vote decrement for each of: MACD line above its signal line; RSI above its bullish threshold and at or below its overbought threshold; ADX above its strength threshold with +DI above -DI; close above the shorter EMA; close above the longer EMA; bullish SuperTrend; volume above SMA(volume, volume lookback) multiplied by the volume ratio.
Calculation: Dip upper level = EMA(close, longer EMA lookback) - ATR(ATR lookback) * (dip ATR multiplier - dip-zone offset).
Calculation: Top lower level = EMA(close, shorter EMA lookback) + ATR(ATR lookback) * (top ATR multiplier - top-zone offset).
Calculation: Nearest Fibonacci retracement level = the retracement level closest to close among the levels calculated from Highest(high, Fibonacci lookback), Lowest(low, Fibonacci lookback), and the five separate Fibonacci retracement ratio parameters.
Calculation: Descending pivot-high resistance = the line through the two most recent confirmed PivotHigh(high, pivot lookback, pivot lookback) values when the older pivot is higher than the newer pivot; extend the line using its pivot-to-pivot slope and retain it until another descending pair replaces it.
Calculation: Dip signal condition = bullish SuperTrend AND close < Dip upper level AND MACD line > MACD signal line AND RSI(close, RSI lookback) > RSI bullish threshold AND RSI(close, RSI lookback) <= RSI overbought threshold AND Score >= dip score threshold.
Calculation: Strong dip condition = bullish SuperTrend AND close < Dip upper level AND MACD line > MACD signal line AND RSI(close, RSI lookback) > RSI bullish threshold AND volume > SMA(volume, volume lookback) * volume ratio AND Score >= strong dip score threshold.
Calculation: Full-buy condition = bullish SuperTrend AND MACD line > MACD signal line AND RSI(close, RSI lookback) > RSI bullish threshold AND RSI(close, RSI lookback) <= RSI overbought threshold AND ADX(ADX lookback) > ADX strength threshold AND +DI(ADX lookback) > -DI(ADX lookback) AND close > EMA(close, shorter EMA lookback) AND close > EMA(close, longer EMA lookback) AND Score >= full-buy score threshold.
Calculation: Full-sell condition = bearish SuperTrend AND MACD line <= MACD signal line AND RSI(close, RSI lookback) <= RSI bullish threshold AND ADX(ADX lookback) > ADX strength threshold AND +DI(ADX lookback) <= -DI(ADX lookback) AND close <= EMA(close, shorter EMA lookback) AND close <= EMA(close, longer EMA lookback) AND Score <= full-sell score threshold.
Calculation: New dip event = (Dip signal condition AND NOT Dip signal condition[1]) OR (Strong dip condition AND NOT Strong dip condition[1]).
Calculation: New full-buy event = Full-buy condition AND NOT Full-buy condition[1].
Calculation: Long trailing stop = set to SuperTrend on a new dip event; clear it when close falls below the active stop; set it to SuperTrend on a new full-buy event; while active and SuperTrend is bullish, update it to the maximum of its previous value and current SuperTrend.
Calculation: Target 1 = on a new dip event, Lowest(low, target-base lookback) + ATR(ATR lookback) * target 1 ATR multiplier; otherwise, on a new full-buy event when absent or already hit, close + ATR(ATR lookback) * target 1 ATR multiplier; otherwise retain its value. Reset its hit state on assignment and clear it with all targets after all three are hit.
Calculation: Target 2 = on a new dip event, Lowest(low, target-base lookback) + ATR(ATR lookback) * target 2 ATR multiplier; otherwise, on a new full-buy event when absent or already hit, close + ATR(ATR lookback) * target 2 ATR multiplier; otherwise retain its value. Reset its hit state on assignment and clear it with all targets after all three are hit.
Calculation: Target 3 = on a new dip event, Lowest(low, target-base lookback) + ATR(ATR lookback) * target 3 ATR multiplier; otherwise, on a new full-buy event when absent or already hit, close + ATR(ATR lookback) * target 3 ATR multiplier; otherwise retain its value. Reset its hit state on assignment and clear it with all targets after all three are hit.
Long: MACD line(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) > MACD signal(close, MACD fast lookback, MACD slow lookback, MACD signal lookback).
Short: MACD line(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) <= MACD signal(close, MACD fast lookback, MACD slow lookback, MACD signal lookback).
Long: RSI(close, RSI lookback) > RSI bullish threshold AND RSI(close, RSI lookback) <= RSI overbought threshold.
Short: RSI(close, RSI lookback) <= RSI bullish threshold.
Long: ADX(ADX lookback) > ADX strength threshold AND +DI(ADX lookback) > -DI(ADX lookback).
Short: ADX(ADX lookback) > ADX strength threshold AND +DI(ADX lookback) <= -DI(ADX lookback).
Long: close > EMA(close, shorter EMA lookback).
Short: close <= EMA(close, shorter EMA lookback).
Long: close > EMA(close, longer EMA lookback).
Short: close <= EMA(close, longer EMA lookback).
Long: SuperTrend(SuperTrend multiplier, SuperTrend lookback) is bullish.
Short: SuperTrend(SuperTrend multiplier, SuperTrend lookback) is bearish.
Long: Score >= general buy score threshold.
Short: Score < neutral score threshold.
Long: close >= Nearest Fibonacci retracement level AND close < Nearest Fibonacci retracement level + ATR(ATR lookback).
Short: close <= Nearest Fibonacci retracement level AND close > Nearest Fibonacci retracement level - ATR(ATR lookback).
Long: close <= EMA(close, longer EMA lookback) - ATR(ATR lookback) * (dip ATR multiplier - dip-zone offset) AND close >= EMA(close, longer EMA lookback) - ATR(ATR lookback) * (dip ATR multiplier + deep-zone offset).
Short: close >= EMA(close, shorter EMA lookback) + ATR(ATR lookback) * (top ATR multiplier - top-zone offset) AND close <= EMA(close, shorter EMA lookback) + ATR(ATR lookback) * (top ATR multiplier + extreme-zone offset).
Long: (Dip signal condition) OR (Strong dip condition).
Short: bearish SuperTrend AND close > Top lower level AND MACD line <= MACD signal line AND RSI(close, RSI lookback) <= RSI overbought threshold AND Score <= top score threshold.
Long: Full-buy condition AND NOT Full-buy condition[1].
Short: Full-sell condition AND NOT Full-sell condition[1].
Long: SuperTrend(SuperTrend multiplier, SuperTrend lookback) is bullish AND SuperTrend(SuperTrend multiplier, SuperTrend lookback)[1] was bearish.
Short: SuperTrend(SuperTrend multiplier, SuperTrend lookback) is bearish AND SuperTrend(SuperTrend multiplier, SuperTrend lookback)[1] was bullish.
Long: close[1] < Bollinger lower band(close, trade-zone lookback, trade-zone multiplier)[1] AND close >= Bollinger lower band(close, trade-zone lookback, trade-zone multiplier) AND close <= Bollinger upper band(close, trade-zone lookback, trade-zone multiplier).
Long: A descending pivot-high resistance line exists AND close > Descending pivot-high resistance at the current bar AND close[1] <= Descending pivot-high resistance at the previous bar.
Long: Heikin-Ashi close > Heikin-Ashi open.
Short: Heikin-Ashi close <= Heikin-Ashi open.
Long: Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi close[1] <= Heikin-Ashi open[1].
Short: Heikin-Ashi close <= Heikin-Ashi open AND Heikin-Ashi close[1] > Heikin-Ashi open[1].
Exit: long, close < active Long trailing stop.
Exit: long, Target 1 is active AND has not already been hit since its last assignment AND high >= Target 1.
Exit: long, Target 2 is active AND has not already been hit since its last assignment AND high >= Target 2.
Exit: long, Target 3 is active AND has not already been hit since its last assignment AND high >= Target 3.