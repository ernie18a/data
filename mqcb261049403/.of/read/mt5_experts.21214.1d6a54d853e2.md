Calculation: SilverTrend state = On the lower signal timeframe, using the last completed bar and its prior completed bar: let K = 33 − risk, HH = highest high and LL = lowest low over the SSP-bar lookback, with LL also including the current close; lower threshold = LL + (HH − LL) × K/100 and upper threshold = HH − (HH − LL) × K/100. State is bullish when close > upper threshold, bearish when close < lower threshold, otherwise retain the prior state; initial state is neutral.
Calculation: ColorJFATL color = On the lower signal timeframe, using the last completed bar and its prior completed bar, apply the 39-term FATL digital filter to the configured OHLC price, smooth the result with JMA, and round it to the configured precision; color is 2 when the rounded line is above its prior value, 0 when below, and otherwise retains the prior color.
Long: SilverTrend state changes from neutral or bearish to bullish
Short: SilverTrend state changes from neutral or bullish to bearish
Exit: long, SilverTrend state changes from neutral or bullish to bearish
Exit: short, SilverTrend state changes from neutral or bearish to bullish
Long: ColorJFATL color changes from below 2 to 2
Short: ColorJFATL color changes from above 0 to 0
Exit: long, ColorJFATL color = 0
Exit: short, ColorJFATL color = 2