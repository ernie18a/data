Calculation: Band state = initialize neutral; on each chart bar, set bearish if close < Lowest(low, lookback) + (Highest(high, lookback) - Lowest(low, lookback)) * (base-percentage parameter - risk parameter) / 100, then set bullish if close > Highest(high, lookback) - (Highest(high, lookback) - Lowest(low, lookback)) * (base-percentage parameter - risk parameter) / 100; otherwise retain the prior state
Long: Band state is bullish
Short: Band state is bearish
Long: Band state[signal-bar offset parameter] is bullish AND Band state[signal-bar offset parameter + 1] is bearish or neutral
Short: Band state[signal-bar offset parameter] is bearish AND Band state[signal-bar offset parameter + 1] is bullish or neutral