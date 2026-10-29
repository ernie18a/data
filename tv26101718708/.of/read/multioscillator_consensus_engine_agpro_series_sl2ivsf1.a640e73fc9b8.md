Calculation: Normalized CCI = rescale CCI to 0–100 using its minimum and maximum over a lookback twice the CCI lookback; use 50 if the range is zero.
Calculation: Normalized ROC = rescale rate of change to 0–100 using its minimum and maximum over a lookback twice the ROC lookback; use 50 if the range is zero.
Calculation: Normalized MACD histogram = rescale the MACD histogram to 0–100 using its minimum and maximum over a lookback twice the MACD slow-EMA length; use 50 if the range is zero.
Calculation: Bull and bear vote counts = count the bullish and bearish votes, respectively, from RSI, Stochastic, normalized CCI, MFI, Williams %R plus 100, normalized ROC, Ultimate Oscillator, normalized MACD histogram, DI+ as a percentage of DI+ plus DI−, and Aroon balance (Aroon Up minus Aroon Down plus 100, divided by 2). Each oscillator votes bullish at or above the bullish threshold, bearish at or below the bearish threshold, and otherwise neutral. Use 50 when the DI sum is zero.
Calculation: Agreement percentage = 10 times the larger of the bull and bear vote counts.
Long: Bull vote count reaches the consensus threshold AND the previous bar was not in the consensus bull regime
Long: Agreement percentage crosses up through the extreme-agreement threshold AND bull vote count is greater than or equal to bear vote count
Short: Bear vote count reaches the consensus threshold AND the previous bar was not in the consensus bear regime
Short: Agreement percentage crosses up through the extreme-agreement threshold AND bear vote count is greater than bull vote count
Exit: Long, bear vote count reaches the consensus threshold AND the previous bar was not in the consensus bear regime
Exit: Short, bull vote count reaches the consensus threshold AND the previous bar was not in the consensus bull regime