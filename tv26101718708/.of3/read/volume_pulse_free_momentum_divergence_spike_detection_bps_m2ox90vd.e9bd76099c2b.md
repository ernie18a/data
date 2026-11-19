Calculation: Volume momentum = selected MA(EMA(projected price, OBV smoothing), fast MA lookback, MA type) - EMA(close, slow EMA lookback), where signed volume = cumulative sum(sign(change(close)) * volume), signed-volume average = SMA(signed volume, volume smoothing), price spread = standard deviation(high - low, volatility lookback), signed-volume spread = standard deviation(signed volume - signed-volume average, volatility lookback), shadow = (signed volume - signed-volume average) / signed-volume spread * price spread when signed-volume spread is nonzero and 0 otherwise, and projected price = high + shadow when shadow is positive and low + shadow otherwise.
Calculation: Chart regression = Linear regression(volume momentum, regression lookback) on chart bars.
Calculation: Adaptive deviation = cumulative sum of the absolute difference between chart regression and the previous trend band, divided by the number of prior chart bars, multiplied by trend sensitivity; use zero when there are no prior bars.
Calculation: Trend band = chart regression when it is above the previous trend band by more than adaptive deviation or below it by more than adaptive deviation; otherwise the previous trend band, using chart regression when no previous trend band exists.
Calculation: Trend direction = upward when the trend band increases, downward when it decreases, and otherwise the previous direction; initialize as neutral.
Calculation: Regression pivot-high tracker = chart regression when it is the highest chart regression in the divergence lookback, otherwise the greater of chart regression and the previous tracker; initialize to chart regression.
Calculation: Regression pivot-low tracker = chart regression when it is the lowest chart regression in the divergence lookback, otherwise the lesser of chart regression and the previous tracker; initialize to chart regression.
Calculation: Pivot-high marker = regression pivot-high tracker equals its value at the pivot equality lag and that lagged value differs from its value at the pivot comparison lag.
Calculation: Pivot-low marker = regression pivot-low tracker equals its value at the pivot equality lag and that lagged value differs from its value at the pivot comparison lag.
Calculation: Bearish divergence warning = pivot-high marker AND chart regression is above the previous regression pivot-high tracker AND trend direction is upward.
Calculation: Bullish divergence warning = pivot-low marker AND chart regression is below the previous regression pivot-low tracker AND trend direction is downward.
Calculation: Volume spike = volume > SMA(volume, volume spike lookback) * volume spike multiplier.
Calculation: T1 direction = bullish if Linear regression(volume momentum calculated on T1 bars, max(regression lookback, minimum dashboard regression lookback)) on the T1 bar still forming is above zero, otherwise bearish.
Calculation: T2 direction = bullish if Linear regression(volume momentum calculated on T2 bars, max(regression lookback, minimum dashboard regression lookback)) on the T2 bar still forming is above zero, otherwise bearish.
Calculation: T3 direction = bullish if Linear regression(volume momentum calculated on T3 bars, max(regression lookback, minimum dashboard regression lookback)) on the T3 bar still forming is above zero, otherwise bearish.
Calculation: T4 direction = bullish if Linear regression(volume momentum calculated on T4 bars, max(regression lookback, minimum dashboard regression lookback)) on the T4 bar still forming is above zero, otherwise bearish.
Calculation: Bullish alignment = the number of bullish directions among T1, T2, T3, and T4 is at least the alignment threshold.
Long: trend direction changes to upward.
Short: trend direction changes to downward.
Long: pivot-low marker.
Short: pivot-high marker.
Long: Bullish divergence warning.
Short: Bearish divergence warning.
Long: Volume spike AND trend direction is upward AND NOT Bearish divergence warning.
Short: Volume spike AND trend direction is downward AND NOT Bullish divergence warning.
Long: Bullish alignment AND NOT Bearish divergence warning AND NOT Bullish divergence warning AND NOT (Volume spike AND (trend direction is upward OR trend direction is downward)).
Short: at least the alignment threshold of T1, T2, T3, and T4 directions are bearish AND NOT Bearish divergence warning AND NOT Bullish divergence warning AND NOT (Volume spike AND (trend direction is upward OR trend direction is downward)) AND NOT Bullish alignment.