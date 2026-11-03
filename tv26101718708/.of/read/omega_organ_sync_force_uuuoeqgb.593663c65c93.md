Calculation: Z-score = (value minus its simple moving average) divided by its standard deviation over the same lookback; use zero when the standard deviation is zero.
Calculation: Organ flow = EMA of a smoothed organ score. The organ score is the sum of the Z-scores of the change in the close EMA, close rate of change, change in on-balance volume, and signed ATR change. Signed ATR change is the ATR change multiplied by +1 when close is above its direction EMA and by -1 otherwise. Smooth the score with an EMA before applying the flow EMA.
Calculation: Organ signal = EMA of organ flow, using the same length as the flow EMA.
Calculation: Chaos = EMA of the mean of the three absolute pairwise differences among the trend, momentum, and on-balance-volume Z-scores, using the organ score's smoothing length.
Calculation: Timeframe force = chart-timeframe EMA of the weighted sum of organ flow from three selected timeframes. Each selected timeframe may be higher or lower than the chart timeframe; use its previous completed bar, and for a lower timeframe use the last available intrabar's previous bar.
Calculation: Positive timeframe count = number of the three selected timeframe organ flows above zero; negative timeframe count = number below zero.
Long: Organ flow crosses above the positive flip threshold AND chaos is below the low chaos threshold AND timeframe force is above zero AND positive timeframe count is at least two.
Short: Organ flow crosses below the negative flip threshold AND chaos is below the low chaos threshold AND timeframe force is below zero AND negative timeframe count is at least two.
Long: Organ flow is above organ signal AND timeframe force is above zero AND positive timeframe count is at least two AND the absolute difference between organ flow and organ signal is greater than on the previous bar.
Short: Organ flow is below organ signal AND timeframe force is below zero AND negative timeframe count is at least two AND the absolute difference between organ flow and organ signal is greater than on the previous bar.
Long: Chaos crosses below the collapse threshold AND its highest value over a lookback exceeds the high chaos threshold AND organ flow is above the positive flip threshold AND timeframe force is above zero AND positive timeframe count is at least two.
Short: Chaos crosses below the collapse threshold AND its highest value over the same lookback exceeds the high chaos threshold AND organ flow is below the negative flip threshold AND timeframe force is below zero AND negative timeframe count is at least two.
Long: Organ flow is above zero.
Short: Organ flow is below zero.
Long: Timeframe force is above zero AND positive timeframe count is at least two.
Short: Timeframe force is below zero AND negative timeframe count is at least two.
Long: Positive timeframe count equals three.
Short: Negative timeframe count equals three.
Long: Organ flow is above timeframe force.
Short: Organ flow is less than or equal to timeframe force.