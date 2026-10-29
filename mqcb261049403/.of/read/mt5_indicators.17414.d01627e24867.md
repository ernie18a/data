Calculation: Velocity = weighted average of the selected price over a lookback, with linearly descending weights squared, minus its weighted average with the same descending weights
Calculation: Upper and lower velocity bands = moving average of velocity plus or minus its standard deviation times a multiplier; during a downtrend the upper band cannot rise, and during an uptrend the lower band cannot fall
Calculation: Trend state = 1 when velocity is above the previous bar’s upper velocity band; −1 when velocity is below the previous bar’s lower velocity band; otherwise the previous trend state
Long: Trend state changes to 1
Short: Trend state changes to −1