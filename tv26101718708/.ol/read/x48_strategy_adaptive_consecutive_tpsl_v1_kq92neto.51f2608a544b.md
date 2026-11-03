Calculation: Fast MA = selected moving average of close using a shorter lookback than the mid-term and long-term MAs
Calculation: Mid-term MA = selected moving average of close using a longer lookback than the fast MA and a shorter lookback than the long-term MA
Calculation: Long-term MA = selected moving average of close using a longer lookback than the fast and mid-term MAs
Calculation: Consecutive rising closes = the number of consecutive bars whose close is greater than the previous bar's close
Calculation: Consecutive falling closes = the number of consecutive bars whose close is less than the previous bar's close
Calculation: Fast and slow ATR trails = recursively ratcheted close-based trails, each offset by its own ATR lookback multiplied by its own factor; the fast trail uses a shorter ATR lookback than the slow trail
Calculation: Highest high and lowest low = highest high and lowest low over the breakout lookback
Long: Consecutive rising closes >= the entry lookback AND close > long-term MA AND fast MA > long-term MA
Short: Consecutive falling closes >= the entry lookback AND close < long-term MA AND fast MA < long-term MA
Exit: Long, (Consecutive falling closes >= the long-exit lookback AND close > long-term MA AND close[2] < mid-term MA AND close[1] < mid-term MA AND close < mid-term MA) OR fast ATR trail crosses below slow ATR trail OR close < highest high * (1 - trailing callback percentage) OR high >= entry price * (1 + take-profit percentage) OR low <= entry price * (1 - stop-loss percentage)
Exit: Short, (Consecutive rising closes >= the short-exit lookback AND close < long-term MA AND close[2] > mid-term MA AND close[1] > mid-term MA AND close > mid-term MA) OR fast ATR trail crosses above slow ATR trail OR close > lowest low * (1 + trailing callback percentage) OR low <= entry price * (1 - take-profit percentage) OR high >= entry price * (1 + stop-loss percentage)