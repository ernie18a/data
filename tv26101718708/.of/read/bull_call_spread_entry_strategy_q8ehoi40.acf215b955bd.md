Calculation: Bollinger Bands = SMA of close plus or minus a multiplier times the standard deviation of close over the same lookback.
Calculation: Keltner Channel = EMA of close plus or minus a multiplier times the EMA of true range over the same lookback.
Calculation: Outside channels = 1 if the lower Bollinger Band < the lower Keltner Channel AND the upper Bollinger Band > the upper Keltner Channel; otherwise 0.
Calculation: Bull score = 0 if RSI > the upper RSI threshold; otherwise the sum of 1 for each true condition: RSI > previous RSI; −DI < previous −DI; close < Bollinger basis AND close > lower Bollinger Band; close < lower Keltner Channel; outside channels = 1; lowest low over a lookback including the current bar <= current lower Bollinger Band; ADX > previous ADX; RSI < the lower RSI threshold.
Calculation: Bear score = 0 if RSI < the lower RSI threshold; otherwise the sum of 1 for each true condition: RSI < previous RSI; +DI > previous +DI; close > Bollinger basis AND close < upper Bollinger Band; close > upper Keltner Channel; outside channels = 1; highest high over a lookback including the current bar >= current upper Bollinger Band; ADX < previous ADX; RSI > the upper RSI threshold.
Long: Bull score > 0.
Short: Bear score > 0.
Exit: long, bars since entry >= holding-period threshold AND day of week = Thursday.