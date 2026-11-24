Calculation: HighPivot = highest(high, lookback depth) = high[lookback depth / 2]
Calculation: LowPivot = lowest(low, lookback depth) = low[lookback depth / 2]
Calculation: DevThreshold = deviation multiplier * ATR(ATR length) / close
Calculation: HighConfirm = HighPivot AND ((LastPivotSide[1] = high pivot AND high[lookback depth / 2] > LastPivotPrice[1]) OR (LastPivotSide[1] != high pivot AND ABS(high[lookback depth / 2] - LastPivotPrice[1]) / high[lookback depth / 2] > DevThreshold))
Calculation: LowConfirm = NOT HighPivot AND LowPivot AND ((LastPivotSide[1] = low pivot AND low[lookback depth / 2] < LastPivotPrice[1]) OR (LastPivotSide[1] != low pivot AND ABS(low[lookback depth / 2] - LastPivotPrice[1]) / low[lookback depth / 2] > DevThreshold))
Calculation: LastPivotPrice = IF HighConfirm THEN high[lookback depth / 2] ELSE IF LowConfirm THEN low[lookback depth / 2] ELSE LastPivotPrice[1]
Calculation: LastPivotSide = IF HighConfirm THEN high pivot ELSE IF LowConfirm THEN low pivot ELSE LastPivotSide[1]
Long: LastPivotSide = low pivot
Short: LastPivotSide = high pivot