Calculation: Filtered high/low = raw high/low or the selected smoothing of each; available smoothing methods are SMA, EMA, RMA, WMA applied twice, VWMA applied three times, HMA, SMA plus half-window slope adjustment, or recursive Kalman smoothing.
Calculation: Pivot high/low = a filtered high/low strictly greater/less than every value in the symmetric lookback window; confirm it after the right-side bars complete and assign it to the center bar.
Calculation: Significant zigzag pivots = keep the first pivot; replace the latest pivot when a same-type pivot is more extreme; append an opposite-type pivot only when the absolute price difference meets the threshold, set to either ATR times a multiplier or close times a percentage.
Calculation: Bollinger basis = SMA of close.
Calculation: ADX = Average Directional Index from DMI.
Long: On a confirmed chart bar, a new unique latest three-pivot sequence A-B-C is low-high-low, C > A and C < B, the prior completed bar close > its Bollinger basis or the Bollinger filter is disabled, and ADX >= its threshold or the ADX filter is disabled.
Short: On a confirmed chart bar, a new unique latest three-pivot sequence A-B-C is high-low-high, C < A and C > B, the prior completed bar close < its Bollinger basis or the Bollinger filter is disabled, and ADX >= its threshold or the ADX filter is disabled.
Exit: long, previous completed chart-bar close < A price of an active bullish structure.
Exit: short, previous completed chart-bar close > A price of an active bearish structure.