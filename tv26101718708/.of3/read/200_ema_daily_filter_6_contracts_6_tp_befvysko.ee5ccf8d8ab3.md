Calculation: EntryPeriodMaximumHigh = maximum(high from the entry bar through the current chart bar)
Calculation: EntryPeriodMinimumLow = minimum(low from the entry bar through the current chart bar)
Long: long entries enabled AND flat AND datetime >= start date parameter AND datetime <= end date parameter AND close crosses above EMA(close, EMA lookback) AND (daily filter disabled OR (close of the last completed T1 bar > open of that bar, evaluated on chart bars))
Short: short entries enabled AND flat AND datetime >= start date parameter AND datetime <= end date parameter AND close crosses below EMA(close, EMA lookback) AND (daily filter disabled OR (close of the last completed T1 bar < open of that bar, evaluated on chart bars))
Exit: long, initial stop enabled AND (TP1 enabled OR TP2 enabled OR TP3 enabled OR TP4 enabled OR TP5 enabled OR TP6 enabled) AND EntryPeriodMaximumHigh < entry price + EMA activation distance AND low <= entry-candle low
Exit: short, initial stop enabled AND (TP1 enabled OR TP2 enabled OR TP3 enabled OR TP4 enabled OR TP5 enabled OR TP6 enabled) AND EntryPeriodMinimumLow > entry price - EMA activation distance AND high >= entry-candle high
Exit: long, TP1 enabled AND high >= entry price + TP1 distance
Exit: long, TP2 enabled AND high >= entry price + TP2 distance
Exit: long, TP3 enabled AND high >= entry price + TP3 distance
Exit: long, TP4 enabled AND high >= entry price + TP4 distance
Exit: long, TP5 enabled AND high >= entry price + TP5 distance
Exit: long, TP6 enabled AND high >= entry price + TP6 distance
Exit: short, TP1 enabled AND low <= entry price - TP1 distance
Exit: short, TP2 enabled AND low <= entry price - TP2 distance
Exit: short, TP3 enabled AND low <= entry price - TP3 distance
Exit: short, TP4 enabled AND low <= entry price - TP4 distance
Exit: short, TP5 enabled AND low <= entry price - TP5 distance
Exit: short, TP6 enabled AND low <= entry price - TP6 distance
Exit: long, EntryPeriodMaximumHigh >= entry price + EMA activation distance AND close crosses below EMA(close, EMA lookback)
Exit: short, EntryPeriodMinimumLow <= entry price - EMA activation distance AND close crosses above EMA(close, EMA lookback)
Exit: long, datetime > end date parameter
Exit: short, datetime > end date parameter