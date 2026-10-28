Calculation: Latest pivot high/low = most recent confirmed pivot high/low, using unspecified left and right lookbacks on chart bars
Calculation: ATR = average true range over an unspecified lookback on chart bars
Calculation: Volume average = simple moving average of volume over an unspecified lookback on chart bars
Calculation: Long stop = lower of the signal bar low and latest pivot low
Calculation: Short stop = higher of the signal bar high and latest pivot high
Calculation: Long target = signal bar close + (signal bar close − long stop) × an unspecified reward multiple
Calculation: Short target = signal bar close − (short stop − signal bar close) × an unspecified reward multiple
Long: signal bar low is within an unspecified percentage of the latest pivot low AND latest pivot high − signal bar low > ATR × an unspecified multiplier AND volume > volume average × an unspecified multiplier AND (close > open OR close > previous chart bar high)
Short: signal bar high is within an unspecified percentage of the latest pivot high AND signal bar close − latest pivot low > ATR × an unspecified multiplier AND volume > volume average × an unspecified multiplier AND (close < open OR close < previous chart bar low)
Exit: Long, low <= long stop OR high >= long target
Exit: Short, high >= short stop OR low <= short target