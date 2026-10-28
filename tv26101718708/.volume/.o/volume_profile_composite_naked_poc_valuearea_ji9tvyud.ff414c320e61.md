Calculation: Efficiency ratio = absolute 14-bar close change divided by the sum of absolute 1-bar close changes over 14 bars
Calculation: Volatility cluster = z-score of the recursively smoothed absolute log return (decay factor e^-0.20; z-score over 100 bars) > 1.5
Calculation: Trend = ADX(14) > 20 AND Efficiency ratio > 0.35
Long: (Trend AND close > EMA(50)) OR (NOT Trend AND NOT Volatility cluster AND (close < VAL OR (VAL <= close AND close <= VAH AND close < POC)))
Short: (Trend AND close <= EMA(50)) OR (NOT Trend AND NOT Volatility cluster AND (close > VAH OR (VAL <= close AND close <= VAH AND close > POC)))