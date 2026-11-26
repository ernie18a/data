Calculation: Factor = trend-bound factor parameter + (1 - EfficiencyRatio(close, efficiency-ratio lookback)) * (chop-bound factor parameter - trend-bound factor parameter)
Calculation: Bull candidate = (high + low) / 2 - Factor * ATR(high, low, close, ATR length)
Calculation: Bear candidate = (high + low) / 2 + Factor * ATR(high, low, close, ATR length)
Calculation: Bull band = IF(close[1] > Bull band[1], MAX(Bull candidate, Bull band[1]), Bull candidate)
Calculation: Bear band = IF(close[1] < Bear band[1], MIN(Bear candidate, Bear band[1]), Bear candidate)
Calculation: Trend = IF(Trend[1] = bearish AND close > Bear band[1] + flip margin parameter * ATR(high, low, close, ATR length), bullish, IF(Trend[1] = bullish AND close < Bull band[1] - flip margin parameter * ATR(high, low, close, ATR length), bearish, Trend[1]))
Long: Trend[1] = bearish AND close > Bear band[1] + flip margin parameter * ATR(high, low, close, ATR length)
Short: Trend[1] = bullish AND close < Bull band[1] - flip margin parameter * ATR(high, low, close, ATR length)
Long: Trend = bullish
Short: Trend = bearish