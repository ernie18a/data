Calculation: Confirmed pivot low = a bar whose low is lower than the lows of the configured number of preceding and following chart bars; available after the following bars close
Calculation: Confirmed pivot high = a bar whose high is higher than the highs of the configured number of preceding and following chart bars; available after the following bars close
Calculation: Demand-zone upper edge = latest confirmed pivot low + current ATR × zone-width multiple
Calculation: Supply-zone lower edge = latest confirmed pivot high − current ATR × zone-width multiple
Calculation: Volume average = simple moving average of volume over the configured lookback
Calculation: Daily drawdown % = (equity at the start of the day − current equity) / equity at the start of the day × 100
Long: a confirmed pivot low occurs on this chart bar AND low <= demand-zone upper edge AND RSI >= long floor AND close > open AND volume >= volume average × volume multiple AND time in America/New_York is within the session AND daily trade count < limit AND daily drawdown % < limit AND position is flat
Short: a confirmed pivot high occurs on this chart bar AND high >= supply-zone lower edge AND RSI <= short ceiling AND close < open AND volume >= volume average × volume multiple AND time in America/New_York is within the session AND daily trade count < limit AND daily drawdown % < limit AND position is flat
Exit: Long, low <= entry price − ATR at entry × stop multiple
Exit: Long, high >= entry price + ATR at entry × first target multiple
Exit: Long, high >= entry price + ATR at entry × second target multiple
Exit: Long, high >= entry price + ATR at entry × third target multiple
Exit: Short, high >= entry price + ATR at entry × stop multiple
Exit: Short, low <= entry price − ATR at entry × first target multiple
Exit: Short, low <= entry price − ATR at entry × second target multiple
Exit: Short, low <= entry price − ATR at entry × third target multiple
Exit: Long, time in America/New_York >= session end
Exit: Short, time in America/New_York >= session end