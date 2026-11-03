Calculation: body = |close - open|; upper wick = high - max(open, close); lower wick = min(open, close) - low; range = high - low
Calculation: average body = simple moving average of body
Calculation: trend context = close[1], close[2], or close[3] compared with the corresponding prior value of a simple moving average of close: down if below, up if above
Calculation: bullish engulfing = prior candle bearish AND current candle bullish AND current open <= prior close AND current close >= prior open
Calculation: bearish engulfing = prior candle bullish AND current candle bearish AND current open >= prior close AND current close <= prior open
Calculation: hammer shape = body <= average body × small-body threshold AND lower wick >= body × long-wick ratio AND upper wick <= body × 0.5
Calculation: inverted hammer shape = body <= average body × small-body threshold AND upper wick >= body × long-wick ratio AND lower wick <= body × 0.5
Calculation: bullish hammer = hammer shape AND trend context down at bar 1
Calculation: hanging man = hammer shape AND trend context up at bar 1
Calculation: bullish inverted hammer = inverted hammer shape AND trend context down at bar 1
Calculation: shooting star = inverted hammer shape AND trend context up at bar 1
Calculation: harami inside = current real body is within or equal to prior real body AND current body <= prior body × 0.6
Calculation: bullish harami = harami inside AND prior candle bearish AND trend context down at bar 2
Calculation: bearish harami = harami inside AND prior candle bullish AND trend context up at bar 2
Calculation: bullish morning star = candle 2 bars ago bearish AND its body >= its average body × large-body threshold AND prior body <= its body × 0.5 AND current candle bullish AND current close > midpoint of candle 2 bars ago AND trend context down at bar 3
Calculation: bearish evening star = candle 2 bars ago bullish AND its body >= its average body × large-body threshold AND prior body <= its body × 0.5 AND current candle bearish AND current close < midpoint of candle 2 bars ago AND trend context up at bar 3
Calculation: bullish piercing line = prior candle bearish AND prior body >= prior average body × large-body threshold AND current candle bullish AND current open < prior close AND current close > prior body midpoint AND current close < prior open AND trend context down at bar 2
Calculation: dark cloud cover = prior candle bullish AND prior body >= prior average body × large-body threshold AND current candle bearish AND current open > prior close AND current close < prior body midpoint AND current close > prior open AND trend context up at bar 2
Calculation: three white soldiers = current and prior two candles bullish AND closes strictly increase across the three candles AND each candle opens inside the prior candle's real body AND each body >= its range × 0.5
Calculation: three black crows = current and prior two candles bearish AND closes strictly decrease across the three candles AND each candle opens inside the prior candle's real body AND each body >= its range × 0.5
Calculation: per-pattern reliability = wins / graded occurrences in that pattern's rolling window; grade each occurrence after the evaluation-forward-bars count, as a win when close then is higher than occurrence close for bullish patterns or lower for bearish patterns
Calculation: pattern reliability gate = graded occurrence count < minimum tracked occurrences OR per-pattern reliability >= minimum reliability
Calculation: volume confirmation = current volume >= simple moving average of volume × volume-confirmation multiplier
Calculation: higher-timeframe directional agreement = count of enabled higher timeframes whose most recently completed bar has any detected pattern in the signal direction; only higher timeframes are used
Long: any of bullish engulfing, bullish hammer, bullish inverted hammer, bullish harami, bullish morning star, bullish piercing line, or three white soldiers AND that pattern's reliability gate AND (volume confirmation not required OR volume confirmation) AND (MTF gate not enabled OR no higher timeframes enabled OR higher-timeframe directional agreement >= required higher-timeframe count)
Short: any of bearish engulfing, hanging man, shooting star, bearish harami, bearish evening star, dark cloud cover, or three black crows AND that pattern's reliability gate AND (volume confirmation not required OR volume confirmation) AND (MTF gate not enabled OR no higher timeframes enabled OR higher-timeframe directional agreement >= required higher-timeframe count)