Calculation: Bullish count = number of enabled tracked assets whose correlation parameter is positive and ROC(close, lookback, T1 bars, current bar including while forming) > 0, or whose correlation parameter is negative and ROC(close, lookback, T1 bars, current bar including while forming) < 0
Calculation: Bearish count = number of enabled tracked assets not counted as bullish
Long: For any enabled tracked asset, its correlation parameter is positive and ROC(close, lookback, T1 bars, current bar including while forming) > 0, or its correlation parameter is negative and ROC(close, lookback, T1 bars, current bar including while forming) < 0
Short: For any enabled tracked asset, its correlation parameter is positive and ROC(close, lookback, T1 bars, current bar including while forming) < 0, or its correlation parameter is negative and ROC(close, lookback, T1 bars, current bar including while forming) > 0
Long: At least one tracked asset is enabled AND bullish count >= bearish count
Short: At least one tracked asset is enabled AND bearish count > bullish count
Long: an enabled external asset has positive configured correlation AND its Rate of Change over P1 bars on T1 is > 0 OR it has negative configured correlation AND its Rate of Change over P1 bars on T1 is < 0
Short: an enabled external asset has positive configured correlation AND its Rate of Change over P1 bars on T1 is < 0 OR it has negative configured correlation AND its Rate of Change over P1 bars on T1 is > 0
Calculation: intermarket bias = sum over enabled external assets of 1 when (positive configured correlation AND Rate of Change over P1 bars on T1 > 0) OR (negative configured correlation AND Rate of Change over P1 bars on T1 < 0), otherwise −1
Long: at least one enabled external asset AND intermarket bias ≥ 0
Short: at least one enabled external asset AND intermarket bias < 0