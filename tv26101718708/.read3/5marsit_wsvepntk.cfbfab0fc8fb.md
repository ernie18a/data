Calculation: Trendline slope = ATR(lookback) / lookback * slope multiplier when the slope method is ATR; StDev(close, lookback) / lookback * slope multiplier when it is StDev; abs(SMA(close * bar index, lookback) - SMA(close, lookback) * SMA(bar index, lookback)) / Variance(bar index, lookback) / 2 * slope multiplier when it is LinReg
Calculation: Upper pivot slope = trendline slope when PivotHigh(high, lookback, lookback) is confirmed; otherwise previous upper pivot slope (initially 0)
Calculation: Lower pivot slope = trendline slope when PivotLow(low, lookback, lookback) is confirmed; otherwise previous lower pivot slope (initially 0)
Calculation: Upper trendline = PivotHigh(high, lookback, lookback) when confirmed; otherwise previous upper trendline minus upper pivot slope (initially 0)
Calculation: Lower trendline = PivotLow(low, lookback, lookback) when confirmed; otherwise previous lower trendline plus lower pivot slope (initially 0)
Calculation: Upper break state = 0 when PivotHigh(high, lookback, lookback) is confirmed; otherwise 1 when close > upper trendline - upper pivot slope * lookback; otherwise previous upper break state (initially 0)
Calculation: Lower break state = 0 when PivotLow(low, lookback, lookback) is confirmed; otherwise 1 when close < lower trendline + lower pivot slope * lookback; otherwise previous lower break state (initially 0)
Long: Upper break state > upper break state[1]
Short: Lower break state > lower break state[1]