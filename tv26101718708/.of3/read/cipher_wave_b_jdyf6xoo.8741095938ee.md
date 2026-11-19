Calculation: WaveTrend main line = WaveTrend(HLC3 of selected regular or Heikin-Ashi bars, channel lookback, average lookback) * amplitude
Calculation: WaveTrend signal line = SMA(WaveTrend main line, signal lookback)
Calculation: Money Flow = SMA((if selected high = selected low then 0 else (selected close - selected open) / (selected high - selected low)) * (volume / SMA(volume, lookback)) * scale, lookback) - vertical offset
Calculation: Smoothed Stochastic RSI = EMA(SMA(Stoch(RSI(selected close, RSI lookback), RSI(selected close, RSI lookback), RSI(selected close, RSI lookback), stochastic lookback), K smoothing), EMA smoothing lookback)
Long: WaveTrend main line crosses above WaveTrend signal line
Long: WaveTrend main line crosses above WaveTrend signal line AND WaveTrend signal line <= green dot level
Long: Money Flow >= 0
Long: Smoothed Stochastic RSI >= its value on the previous chart bar
Short: WaveTrend main line crosses below WaveTrend signal line
Short: WaveTrend main line crosses below WaveTrend signal line AND WaveTrend signal line >= red dot level
Short: Money Flow < 0
Short: Smoothed Stochastic RSI < its value on the previous chart bar