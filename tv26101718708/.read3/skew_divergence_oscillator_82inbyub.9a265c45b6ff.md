Calculation: Skew = Skewness(return of close, skew window) on T1 bars, last completed T1 bar; return is log or simple by return type
Calculation: Normalized skew = Z(Skew, normalization window) in single-window mode, else Median(Z(Skew, shorter normalization window), Z(Skew, normalization window), Z(Skew, longer normalization window)); Z is robust z-score (median and scaled median absolute deviation) in robust mode, else classic z-score (mean and standard deviation)
Calculation: Bullish divergence = PivotLow(low, pivot length, pivot length) confirmed on this bar AND ((low[pivot length] < low at previous confirmed pivot low AND Normalized skew[pivot length] > Normalized skew at previous confirmed pivot low) OR (hidden divergence on AND low[pivot length] > low at previous confirmed pivot low AND Normalized skew[pivot length] < Normalized skew at previous confirmed pivot low)) AND bars between the two pivot lows <= max bars between pivots
Calculation: Bearish divergence = PivotHigh(high, pivot length, pivot length) confirmed on this bar AND ((high[pivot length] > high at previous confirmed pivot high AND Normalized skew[pivot length] < Normalized skew at previous confirmed pivot high) OR (hidden divergence on AND high[pivot length] < high at previous confirmed pivot high AND Normalized skew[pivot length] > Normalized skew at previous confirmed pivot high)) AND bars between the two pivot highs <= max bars between pivots
Calculation: HTF bullish divergence = on T2 bars, last completed T2 bar: PivotLow(low, HTF pivot length, HTF pivot length) confirmed on this bar AND low[HTF pivot length] < low at previous confirmed pivot low AND Normalized skew[HTF pivot length] > Normalized skew at previous confirmed pivot low
Calculation: HTF bearish divergence = on T2 bars, last completed T2 bar: PivotHigh(high, HTF pivot length, HTF pivot length) confirmed on this bar AND high[HTF pivot length] > high at previous confirmed pivot high AND Normalized skew[HTF pivot length] < Normalized skew at previous confirmed pivot high
Calculation: HTF bullish state = HTF bullish divergence OR (HTF bullish state[1] AND NOT HTF bearish divergence), on T2 bars, last completed T2 bar
Calculation: HTF bearish state = HTF bearish divergence OR (HTF bearish state[1] AND NOT HTF bullish divergence), on T2 bars, last completed T2 bar
Calculation: Confirmed bullish divergence = Bullish divergence AND (HTF confirmation off OR HTF bullish state)
Calculation: Confirmed bearish divergence = Bearish divergence AND (HTF confirmation off OR HTF bearish state)
Calculation: Regime pass = regime gate off OR (regime gate favors reverting AND Kaufman efficiency ratio(close, efficiency window) < efficiency threshold) OR (regime gate favors trending AND Kaufman efficiency ratio(close, efficiency window) >= efficiency threshold)
Calculation: Time-of-day pass = time-of-day gate off OR bar-to-bar close change in the current time-of-day slot (slot size) is statistically significant at time-of-day z threshold
Long: Confirmed bullish divergence
Long: Confirmed bullish divergence AND Regime pass AND Time-of-day pass
Long: Bullish divergence AND HTF confirmation on AND NOT HTF bullish state AND NOT Confirmed bearish divergence
Long: Normalized skew crosses above zero
Short: Confirmed bearish divergence
Short: Confirmed bearish divergence AND Regime pass AND Time-of-day pass
Short: Bearish divergence AND HTF confirmation on AND NOT HTF bearish state AND NOT Confirmed bullish divergence
Short: Normalized skew crosses below zero