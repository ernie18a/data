Calculation: Range center = simple moving average of close; range width = multiplier × standard deviation of close over the same lookback; upper and lower range bands = range center ± range width
Calculation: Upper band entry = upper range band + band buffer × (upper range band − lower range band); lower band entry = lower range band − band buffer × (upper range band − lower range band)
Calculation: Midpoint pass zone = range center ± midpoint buffer percent of range center
Calculation: ATR = average true range over a lookback
Calculation: Average volume = simple moving average of volume over a lookback
Calculation: Swing stop for a long = the lower of the lowest low over twice the swing lookback minus a price buffer, and close minus half an ATR; swing stop for a short = the higher of the highest high over twice the swing lookback plus a price buffer, and close plus half an ATR
Calculation: Long risk = close minus long swing stop; short risk = short swing stop minus close
Calculation: Momentum = close minus close at the momentum lookback; momentum average = simple moving average of momentum over a shorter lookback
Calculation: Momentum weakening = absolute momentum < absolute momentum average × a threshold
Long: close crosses above range center OR (close crosses above upper band entry AND close − upper range band ≥ ATR × minimum band distance) OR (close is within the midpoint pass zone AND absolute close change from prior bar ≥ ATR × minimum move AND close > prior close AND close > open AND close > range center); volume > average volume × volume multiplier AND volume > minimum volume AND long risk > half an ATR
Short: close crosses below range center OR (close crosses below lower band entry AND lower range band − close ≥ ATR × minimum band distance) OR (close is within the midpoint pass zone AND absolute close change from prior bar ≥ ATR × minimum move AND close < prior close AND close < open AND close < range center); volume > average volume × volume multiplier AND volume > minimum volume AND short risk > half an ATR
Exit: Long, short-entry condition OR momentum weakening AND momentum < 0 OR RSI > overbought level OR low ≤ trailing stop
Exit: Short, long-entry condition OR momentum weakening AND momentum > 0 OR RSI < oversold level OR high ≥ trailing stop