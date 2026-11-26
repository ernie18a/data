Calculation: Smoothed band position = JMA(second smoothing lookback, second smoothing phase, percentage scale × (Bollinger %B(applied price, centerline = moving average(applied price, first smoothing method, first smoothing lookback, first smoothing phase), deviation lookback, deviation multiplier) − band midpoint)), calculated on T1 bars and read on chart bars
Long: Smoothed band position(T1, last completed bar) > upper level AND Smoothed band position(T1, bar still forming) <= upper level
Short: Smoothed band position(T1, last completed bar) < lower level AND Smoothed band position(T1, bar still forming) >= lower level
Exit: long, Smoothed band position(T1, last completed bar) < zero
Exit: short, Smoothed band position(T1, last completed bar) > zero