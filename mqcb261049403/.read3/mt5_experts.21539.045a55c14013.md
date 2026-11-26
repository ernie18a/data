Calculation: bullish breakout = T1 close >= T1 open AND T1 close > upper channel value at the candle offset by the horizontal-shift parameter, read on chart bars
Calculation: bearish breakout = T1 close < T1 open AND T1 close < lower channel value at the candle offset by the horizontal-shift parameter, read on chart bars
Long: bullish breakout[1, T1, last completed] AND NOT bullish breakout[0, T1, still forming]
Short: bearish breakout[1, T1, last completed] AND NOT bearish breakout[0, T1, still forming]
Exit: long, T1 close[1, last completed] < T1 open[1, last completed] OR elapsed holding time in minutes > holding-duration parameter
Exit: short, T1 close[1, last completed] >= T1 open[1, last completed] OR elapsed holding time in minutes > holding-duration parameter