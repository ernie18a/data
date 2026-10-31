Calculation: Volume-weighted RSI = smooth((RSI of selected OHLC-derived price − 50) × volume), using the selected moving-average method and length.
Calculation: Smoothed volume = smooth(volume), using the same method and length as volume-weighted RSI.
Calculation: Direction = sign of the change in volume-weighted RSI from the preceding bar; if the change is zero, retain the preceding direction.
Long: Volume-weighted RSI > upper overbought threshold × smoothed volume OR volume-weighted RSI > lower overbought threshold × smoothed volume OR direction > 0.
Short: Volume-weighted RSI < lower oversold threshold × smoothed volume OR volume-weighted RSI < upper oversold threshold × smoothed volume OR direction < 0.
Long: On a higher timeframe, using its still-forming bar, volume-weighted RSI > upper overbought threshold × smoothed volume OR volume-weighted RSI > lower overbought threshold × smoothed volume OR direction > 0.
Short: On a higher timeframe, using its still-forming bar, volume-weighted RSI < lower oversold threshold × smoothed volume OR volume-weighted RSI < upper oversold threshold × smoothed volume OR direction < 0.