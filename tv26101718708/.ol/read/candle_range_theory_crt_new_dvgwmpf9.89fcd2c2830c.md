Calculation: Range High = high of the last completed bar of a higher timeframe
Calculation: Range Low = low of the last completed bar of a higher timeframe
Calculation: Inside-range filter = at least one of the previous N chart bars closed between Range Low and Range High, inclusive
Calculation: High sweep = current chart bar high > Range High AND close <= Range High AND Inside-range filter
Calculation: Low sweep = current chart bar low < Range Low AND close >= Range Low AND Inside-range filter
Long: The most recent qualifying sweep since the current higher-timeframe range began is a Low sweep AND the current bar is not a Low sweep AND close > Range Low
Short: The most recent qualifying sweep since the current higher-timeframe range began is a High sweep AND the current bar is not a High sweep AND close < Range High