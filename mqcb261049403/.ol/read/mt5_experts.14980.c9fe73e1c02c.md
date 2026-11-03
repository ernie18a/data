Calculation: XMACD OHLC = for each OHLC input, its short-lookback XMA minus its long-lookback XMA; calculate on the indicator timeframe, which may be higher or lower than the chart timeframe, using completed bars.
Calculation: Signal line = an XMA of the selected XMACD open, high, low, or close series; its lookback is independent of the short and long XMA lookbacks. Calculate on the indicator timeframe using completed bars.
Long: XMACD close > XMACD open OR Signal line > its value on the preceding completed bar
Short: XMACD close < XMACD open OR Signal line < its value on the preceding completed bar
Exit: long, XMACD close < XMACD open OR Signal line < its value on the preceding completed bar
Exit: short, XMACD close > XMACD open OR Signal line > its value on the preceding completed bar