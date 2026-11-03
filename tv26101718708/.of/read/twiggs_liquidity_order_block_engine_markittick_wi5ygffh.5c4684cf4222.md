Calculation: Money flow = smoothed money flow volume / smoothed volume, or 0 when smoothed volume is 0. True high = max(high, previous close); true low = min(low, previous close); money flow volume = volume × (2 × (close − true low) / (true high − true low) − 1), or 0 when true high equals true low. Smooth each series recursively with alpha = 1 / money flow period, initializing each with its first available value.
Calculation: Signal = money flow recursively smoothed with alpha = 1 / signal period, initialized with its first available money flow value.
Calculation: Active swing high = the latest confirmed swing high not yet broken; a swing high is the high at the swing lookback bars ago when it is strictly greater than every other high from one through twice the swing lookback bars ago. A new swing high replaces the previous one. A break deactivates it.
Calculation: Active swing low = the latest confirmed swing low not yet broken; a swing low is the low at the swing lookback bars ago when it is strictly less than every other low from one through twice the swing lookback bars ago. A new swing low replaces the previous one. A break deactivates it.
Calculation: Structure direction = initially neutral; set to bullish when previous close > active swing high and set to bearish when previous close < active swing low. Update swings before testing breaks; if both breaks occur on the same bar, process the bullish break first and the bearish break second.
Long: Money flow >= 0
Short: Money flow < 0
Long: Previous money flow > money flow two bars ago
Short: Previous money flow <= money flow two bars ago
Long: Previous money flow >= previous signal
Short: Previous money flow < previous signal
Long: Signal >= 0
Short: Signal < 0
Long: Money flow < oversold threshold
Short: Money flow > overbought threshold
Long: Money flow two bars ago < 0 AND previous money flow >= 0
Short: Money flow two bars ago >= 0 AND previous money flow < 0
Long: Money flow two bars ago > oversold threshold AND previous money flow <= oversold threshold
Short: Money flow two bars ago < overbought threshold AND previous money flow >= overbought threshold
Long: Money flow > signal AND previous money flow <= previous signal
Long: Previous close > active swing high
Short: Previous close < active swing low
Long: Structure direction = bullish
Short: Structure direction = bearish