Calculation: Price momentum = current close minus close at the start of the momentum lookback
Calculation: SMA change = current simple moving average of close minus its value one bar earlier
Calculation: Entry ATR = average true range on the entry bar; true range is the greatest of high − low, |high − prior close|, and |low − prior close|
Long: price momentum > 0 AND SMA change > 0 AND volume > its simple moving average × volume threshold AND close > long-term EMA AND position is flat
Short: price momentum < 0 AND SMA change < 0 AND volume > its simple moving average × volume threshold AND close < long-term EMA AND position is flat
Exit: long, low ≤ entry-bar low − entry ATR × long stop distance OR high ≥ entry price + current ATR × long target distance (long target distance = 2 × long stop distance)
Exit: short, high ≥ entry-bar high + entry ATR × short stop distance OR low ≤ entry price − current ATR × short target distance (short target distance = 2 × short stop distance)