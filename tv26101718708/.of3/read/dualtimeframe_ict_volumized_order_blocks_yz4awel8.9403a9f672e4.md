Calculation: SwingState = high if high[swing length] > Highest(high, swing length), low if low[swing length] < Lowest(low, swing length), otherwise SwingState[1]
Calculation: SwingHighBar = the bar swing length bars before the bar where SwingState changes from low to high, held until the next such change
Calculation: SwingHigh = high of SwingHighBar
Calculation: SwingLowBar = the bar swing length bars before the bar where SwingState changes from high to low, held until the next such change
Calculation: SwingLow = low of SwingLowBar
Calculation: BullZoneRange = high minus low of the bar with the lowest low among bars strictly between SwingHighBar and the current bar
Calculation: BearZoneRange = high minus low of the bar with the highest high among bars strictly between SwingLowBar and the current bar
Calculation: BullICTRange = highest high minus lowest low over the most recent bar strictly between SwingHighBar and the current bar with close < open, together with, when candle-series mode is on, the consecutive older bars with close < open within that interval; undefined if no such bar
Calculation: BearICTRange = highest high minus lowest low over the most recent bar strictly between SwingLowBar and the current bar with close > open, together with, when candle-series mode is on, the consecutive older bars with close > open within that interval; undefined if no such bar
Calculation: BullDisplacement = abs(close - open) >= ATR(high, low, close, ATR lookback) * displacement multiplier AND (fair value gap not required OR low > high[2])
Calculation: BearDisplacement = abs(close - open) >= ATR(high, low, close, ATR lookback) * displacement multiplier AND (fair value gap not required OR high < low[2])
Long: first bar since SwingHigh was set where close > SwingHigh, AND BullZoneRange <= ATR(high, low, close, ATR lookback) * size multiplier
Long: first bar since SwingHigh was set where close > SwingHigh AND BullDisplacement AND BullICTRange exists, AND BullICTRange <= ATR(high, low, close, ATR lookback) * size multiplier
Short: first bar since SwingLow was set where close < SwingLow, AND BearZoneRange <= ATR(high, low, close, ATR lookback) * size multiplier
Short: first bar since SwingLow was set where close < SwingLow AND BearDisplacement AND BearICTRange exists, AND BearICTRange <= ATR(high, low, close, ATR lookback) * size multiplier