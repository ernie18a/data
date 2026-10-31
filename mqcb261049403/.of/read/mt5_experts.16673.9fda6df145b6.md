Calculation: Double-smoothed average = apply a selectable moving average to the selected OHLC-derived price, then apply a second selectable moving average to the result; the two smoothing methods and their parameters are independently selectable.
Calculation: Ultra-linear smoothing = for input x and smoothing length n, set a = 3/(n+2), initialize six states to the first x, and on each bar update sequentially f1 = (1-a)f1+a*x, f2 = a*f1+(1-a)f2, v1 = 1.5*f1-0.5*f2, f3 = (1-a)f3+a*v1, f4 = a*f3+(1-a)f4, v2 = 1.5*f3-0.5*f4, f5 = (1-a)f5+a*v2, f6 = a*f5+(1-a)f6; output 1.5*f5-0.5*f6.
Calculation: Smoothed strength = Jurik moving average of 100 times ultra-linear smoothing of the change in selected OHLC-derived price divided by ultra-linear smoothing of the absolute change; replace a zero absolute change with a positive price increment before smoothing. Both ultra-linear smoothers use the same length.
Long: Chart-timeframe smoothed strength is greater than its previous bar.
Short: Chart-timeframe smoothed strength is less than its previous bar.
Long: Chart-timeframe double-smoothed average is greater than its previous bar.
Short: Chart-timeframe double-smoothed average is less than its previous bar.
Long: Higher-timeframe smoothed strength on the bar still forming is greater than its previous bar AND is greater than an upper threshold.
Short: Higher-timeframe smoothed strength on the bar still forming is less than its previous bar AND is less than a lower threshold.
Long: Higher-timeframe double-smoothed average on the bar still forming is less than its previous bar.
Short: Higher-timeframe double-smoothed average on the bar still forming is greater than its previous bar.
Long: At the close of a lower-timeframe entry bar, its smoothed strength is greater than the preceding value AND the preceding value is less than or equal to the value before it AND the double-smoothed average on the last completed higher-timeframe trend bar is greater than its preceding value.
Short: At the close of a lower-timeframe entry bar, its smoothed strength is less than the preceding value AND the preceding value is greater than or equal to the value before it AND the double-smoothed average on the last completed higher-timeframe trend bar is less than its preceding value.
Exit: long, at the close of a lower-timeframe entry bar, the double-smoothed average on the last completed higher-timeframe trend bar is less than its preceding value OR the entry-bar smoothed strength is less than its preceding value.
Exit: short, at the close of a lower-timeframe entry bar, the double-smoothed average on the last completed higher-timeframe trend bar is greater than its preceding value OR the entry-bar smoothed strength is greater than its preceding value.
Exit: long, low is less than or equal to entry price minus stop distance OR high is greater than or equal to entry price plus profit distance.
Exit: short, high is greater than or equal to entry price plus stop distance OR low is less than or equal to entry price minus profit distance.