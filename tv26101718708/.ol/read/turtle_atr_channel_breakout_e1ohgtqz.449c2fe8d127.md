Calculation: Channel basis = moving average of close over the channel lookback
Calculation: Upper band = channel basis + selected channel width; selected width is either a standard deviation of close over the channel lookback multiplied by its multiplier, or ATR multiplied by its multiplier
Calculation: Lower band = channel basis − selected channel width
Calculation: ATR = average true range using Wilder smoothing
Long: close > upper band AND channel basis > its value at the slope lookback ago
Short: close < lower band AND channel basis < its value at the slope lookback ago
Long: close >= last add price + add-on step × ATR captured at initial entry, while long and below the maximum units
Short: close <= last add price − add-on step × ATR captured at initial entry, while short and below the maximum units
Exit: long, close < channel basis OR low <= stop level
Exit: short, close > channel basis OR high >= stop level