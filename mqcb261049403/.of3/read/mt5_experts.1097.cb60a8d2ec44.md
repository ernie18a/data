Calculation: channel high = highest(high, lookback, starting offset bars ago)
Calculation: channel low = lowest(low, lookback, starting offset bars ago)
Calculation: channel range = channel high - channel low
Calculation: upper boundary = channel high - channel range * channel inset / 100
Calculation: lower boundary = channel low + channel range * channel inset / 100
Calculation: stop upper boundary = channel high - channel range * (channel inset + stop-channel extension) / 100
Calculation: stop lower boundary = channel low + channel range * (channel inset + stop-channel extension) / 100
Calculation: primary direction = previous primary direction; set bearish if close < upper boundary AND close < lower boundary AND previous stop direction is bullish; set bullish if close > upper boundary AND close > lower boundary AND previous stop direction is bearish; otherwise retain previous primary direction
Calculation: intermediate stop direction = previous stop direction; set bearish if primary direction is bearish AND (close > stop upper boundary OR close > stop lower boundary); set bullish if primary direction is bullish AND (close < stop upper boundary OR close < stop lower boundary); otherwise retain previous stop direction
Calculation: final stop direction = intermediate stop direction; set bullish if close < upper boundary AND close < lower boundary AND intermediate stop direction is bearish; set bearish if close > upper boundary AND close > lower boundary AND intermediate stop direction is bullish; otherwise retain intermediate stop direction
Long: buy opening enabled AND (primary direction changes to bullish OR (close > upper boundary AND close > lower boundary AND intermediate stop direction is bullish)), on T1 at the configured signal offset (forming when the offset selects the current bar; otherwise completed)
Short: sell opening enabled AND (primary direction changes to bearish OR (close < upper boundary AND close < lower boundary AND intermediate stop direction is bearish)), on T1 at the configured signal offset (forming when the offset selects the current bar; otherwise completed)
Exit: long, long closing enabled AND previous stop direction is bearish AND final stop direction is bullish, on T1 at the configured signal offset (forming when the offset selects the current bar; otherwise completed)
Exit: short, short closing enabled AND previous stop direction is bullish AND final stop direction is bearish, on T1 at the configured signal offset (forming when the offset selects the current bar; otherwise completed)