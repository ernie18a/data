Calculation: Bullish confluence = close > VWMA AND fast EMA > slow EMA AND RSI > bullish threshold AND Supertrend is bullish AND (ADX > threshold OR ADX filter is disabled)
Calculation: Bearish confluence = close < VWMA AND fast EMA < slow EMA AND RSI < bearish threshold AND Supertrend is bearish AND (ADX > threshold OR ADX filter is disabled)
Calculation: Signal trend state = bullish when bullish confluence holds, bearish when bearish confluence holds; otherwise retain its prior state until close crosses the Supertrend against that state, then become neutral
Calculation: Stop distance = absolute difference between signal-bar close and Supertrend level; for ATR-cap mode use the smaller of that distance and ATR × configured cap; for fixed-percentage mode use close × configured percentage
Calculation: Initial stop = signal-bar close minus stop distance for long, or plus stop distance for short
Calculation: After TP1 is reached, long stop = the greater of its prior value and the Supertrend level when Supertrend is bullish, otherwise entry price; short stop = the lesser of its prior value and the Supertrend level when Supertrend is bearish, otherwise entry price
Long: bullish confluence AND previous signal trend state is not bullish AND bars since last signal >= configured cooldown
Short: bearish confluence AND previous signal trend state is not bearish AND bars since last signal >= configured cooldown
Exit: long, low <= current stop OR Supertrend is bearish
Exit: short, high >= current stop OR Supertrend is bullish