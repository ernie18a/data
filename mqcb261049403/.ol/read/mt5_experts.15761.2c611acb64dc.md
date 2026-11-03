Calculation: Smoothed RSI candle = on the indicator timeframe (which may be higher or lower than the chart timeframe), calculate RSI separately from open, high, low, and close, smooth each RSI series with the first and second smoothing stages, and use the selected stage; bullish if smoothed close RSI > smoothed open RSI, bearish if smoothed close RSI < smoothed open RSI, otherwise neutral. Evaluate the signal candle and its predecessor using their last completed bars.
Long: Signal candle is bullish AND preceding candle is not bullish
Short: Signal candle is bearish AND preceding candle is not bearish
Exit: long, Signal candle is bearish AND preceding candle is not bearish
Exit: short, Signal candle is bullish AND preceding candle is not bullish