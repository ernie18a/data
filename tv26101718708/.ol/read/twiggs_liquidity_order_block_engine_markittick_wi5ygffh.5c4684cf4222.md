Calculation: Twiggs Money Flow (TMF) = EMA of ((2 × (close − true low) / true range) − 1) × volume divided by EMA of volume, where true high = max(high, previous close), true low = min(low, previous close), and true range = true high − true low; use 0 for the multiplier when true range is 0
Calculation: TMF signal line = EMA of TMF
Calculation: Confirmed swing high/low = the high/low at the middle bar of a window with equal numbers of bars before and after it, strictly higher/lower than every other high/low in that window
Long: TMF two bars ago < 0 AND TMF one bar ago >= 0
Long: TMF one bar ago >= TMF signal line one bar ago
Long: The previous bar's close > the active confirmed swing high
Long: A bullish Change of Character has occurred AND current price retraces into its fresh bullish order block AND (TMF is rising OR TMF crosses above its signal line OR TMF crosses upward above the oversold threshold)
Short: TMF two bars ago >= 0 AND TMF one bar ago < 0
Short: TMF one bar ago < TMF signal line one bar ago
Short: The previous bar's close < the active confirmed swing low
Short: Current price rallies into a pre-existing bearish order block AND TMF is above the overbought threshold AND TMF crosses below its signal line
Exit: Long, Current price rallies into a pre-existing bearish order block AND TMF is above the overbought threshold AND TMF crosses below its signal line