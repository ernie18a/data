Calculation: WaveTrend 1 = EMA of the WaveTrend index (hlc3 minus its EMA, divided by 0.015 times the EMA of its absolute deviation); use equal lookbacks for the two channel EMAs.
Calculation: WaveTrend 2 = shorter-lookback SMA of WaveTrend 1 than WaveTrend 1's smoothing lookback.
Calculation: Trend up = close > chart-timeframe EMA and close > EMA on the selected higher timeframe, using its last completed bar.
Calculation: Trend down = close < chart-timeframe EMA.
Calculation: Bollinger width = upper Bollinger Band − lower Bollinger Band.
Calculation: High volatility = Bollinger width > its longer-lookback SMA.
Calculation: Score = (trend up ? 1 : trend down ? −1 : 0) + (WaveTrend 1 > WaveTrend 2 ? 1 : −1) + (RSI > 50 ? 1 : −1) + (ADX > 20 ? 1 : 0).
Long: (WaveTrend 1 crosses above WaveTrend 2 AND trend up AND RSI > 50 AND high volatility AND score ≥ 2) OR (ADX ≥ 15 AND trend up AND RSI > 50)
Short: (WaveTrend 1 crosses below WaveTrend 2 AND trend down AND RSI < 50 AND high volatility AND score ≤ −2) OR (ADX ≥ 15 AND trend down AND RSI < 50)