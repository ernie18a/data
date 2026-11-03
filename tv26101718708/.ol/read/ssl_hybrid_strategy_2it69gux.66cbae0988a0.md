Calculation: SSL1 = State is +1 when close > the long-lookback moving average of high, -1 when close < the long-lookback moving average of low, otherwise retain prior state; line is the moving average of low when state is +1, otherwise the moving average of high
Calculation: SSL2 = Same state and line calculation as SSL1, using a shorter lookback than SSL1
Calculation: SSL exit line = Same state and line calculation as SSL1, using its own lookback
Calculation: Baseline channel = Selected long-lookback moving average of source, plus or minus its multiplier times an EMA of true range or high-low range over the same lookback
Calculation: CF moving-average direction = Selected moving average of close on the configured timeframe, compared with its value a configurable number of bars earlier; the timeframe may be higher or lower than the chart timeframe. Use the current target-timeframe bar while it is forming and its completed value on historical bars
Long: First SSL1 entry when close crosses above SSL1; thereafter when close > SSL1, not already in the SSL long state, and within the configured date range; if the optional CF filter is enabled, CF moving-average direction is up
Short: First SSL1 entry when close crosses below SSL1; thereafter when close < SSL1, not already in the SSL short state, and within the configured date range; if the optional CF filter is enabled, CF moving-average direction is down
Long: Close > baseline channel upper boundary
Short: Close < baseline channel lower boundary
Long: Close > baseline moving average AND close > SSL2 AND close minus the ATR-based continuation threshold < SSL2
Short: Close < baseline moving average AND close < SSL2 AND close plus the ATR-based continuation threshold > SSL2
Long: CF moving-average direction is up
Short: CF moving-average direction is down
Long: Open < configured CF moving average AND close > configured CF moving average
Short: Open > configured CF moving average AND close < configured CF moving average
Exit: long, low <= entry price minus ATR times the configured stop multiplier OR high >= entry price plus ATR times any configured take-profit multiplier OR (break-even stop enabled and first take-profit reached and low <= entry price) OR close crosses below SSL exit line
Exit: short, high >= entry price plus ATR times the configured stop multiplier OR low <= entry price minus ATR times any configured take-profit multiplier OR (break-even stop enabled and first take-profit reached and high >= entry price) OR close crosses above SSL exit line