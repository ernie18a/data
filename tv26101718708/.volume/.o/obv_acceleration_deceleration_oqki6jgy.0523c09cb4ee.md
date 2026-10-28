Calculation: Master Average = mean of six simple moving averages of close using Fibonacci-sequence lookbacks
Calculation: Custom OBV = cumulative sum of volume when the Master Average rises, minus volume when it falls, and unchanged when it is unchanged
Calculation: OBV velocity = absolute change in Custom OBV from the previous bar
Calculation: Average OBV velocity = simple moving average of OBV velocity over its lookback
Calculation: Custom OBV average = simple moving average of Custom OBV
Long: Custom OBV > Custom OBV average OR (Custom OBV > its previous-bar value AND OBV velocity > Average OBV velocity × the deceleration multiplier)
Short: Custom OBV < Custom OBV average OR (Custom OBV ≤ its previous-bar value AND OBV velocity > Average OBV velocity × the deceleration multiplier)