Calculation: Signal bar = last completed chart bar at the start of a new chart bar; previous bar = the chart bar immediately before the signal bar.
Calculation: Body = abs(close - open); upper wick = high - max(open, close); lower wick = min(open, close) - low; range = high - low.
Calculation: Doji = body <= doji-body threshold AND upper wick > body AND lower wick > body.
Calculation: Bullish candle = close > open AND candle is not a doji; bearish candle = close < open AND candle is not a doji.
Calculation: Long stop = minimum low of the signal bar and previous bar at entry; short stop = maximum high of the signal bar and previous bar at entry.
Long: Signal bar is bullish AND previous bar is bearish AND ((signal-bar lower wick > body-to-wick multiplier * signal-bar body AND signal-bar lower wick > wick-dominance multiplier * signal-bar upper wick) OR (signal-bar upper wick > body-to-wick multiplier * signal-bar body AND signal-bar upper wick > wick-dominance multiplier * signal-bar lower wick)).
Long: Signal bar is bullish AND previous bar is bullish AND signal-bar range > previous-bar range AND signal-bar body >= momentum multiplier * previous-bar body.
Short: Signal bar is bearish AND previous bar is bullish AND ((signal-bar upper wick > body-to-wick multiplier * signal-bar body AND signal-bar upper wick > wick-dominance multiplier * signal-bar lower wick) OR (signal-bar lower wick > body-to-wick multiplier * signal-bar body AND signal-bar lower wick > wick-dominance multiplier * signal-bar upper wick)).
Short: Signal bar is bearish AND previous bar is bearish AND signal-bar body > previous-bar body AND signal-bar range >= momentum multiplier * previous-bar range.
Exit: long, low <= long stop.
Exit: short, high >= short stop.