Calculation: Prior range high = highest high over the preceding lookback bars, excluding the current bar
Calculation: Prior range low = lowest low over the preceding lookback bars, excluding the current bar
Calculation: Range size = prior range high − prior range low
Calculation: Relative volume = current volume / moving average of volume
Calculation: Range-valid condition = range size is within the configured minimum and maximum multiples of current ATR
Calculation: Long risk = max(entry price − frozen prior range low, minimum price increment)
Calculation: Short risk = max(frozen prior range high − entry price, minimum price increment)
Calculation: Long target = entry price + configured reward multiple × long risk
Calculation: Short target = entry price − configured reward multiple × short risk
Calculation: Long runner stop = the greater of the frozen prior range low and the selected trail (EMA or close − configured ATR multiple × ATR), ratcheted upward to never decrease
Calculation: Short runner stop = the lesser of the frozen prior range high and the selected trail (EMA or close + configured ATR multiple × ATR), ratcheted downward to never increase
Long: position is flat or short AND range-valid condition AND (stock close > stock EMA OR stock trend filter disabled) AND (current SPY close > SPY EMA OR market filter disabled) AND (ATR > its moving average OR ATR expansion filter disabled) AND (relative volume >= configured minimum OR volume filter disabled) AND current close > prior range high
Short: position is flat or long AND range-valid condition AND (stock close < stock EMA OR stock trend filter disabled) AND (current SPY close < SPY EMA OR market filter disabled) AND (ATR > its moving average OR ATR expansion filter disabled) AND (relative volume >= configured minimum OR volume filter disabled) AND current close < prior range low
Exit: long, low <= frozen prior range low OR high >= entry price + configured full-exit reward multiple × long risk OR low <= long runner stop OR close < stock EMA OR short-entry condition
Exit: short, high >= frozen prior range high OR low <= entry price − configured full-exit reward multiple × short risk OR high >= short runner stop OR close > stock EMA OR long-entry condition
Exit: long, high >= entry price + configured partial-exit reward multiple × long risk
Exit: short, low <= entry price − configured partial-exit reward multiple × short risk