Calculation: MA slope(x) = x minus x[n chart bars ago], where n is a parameter.
Long: MA slope(SMA(close, T1 shorter lookback, T1; chart bars use T1's still-forming value in real time)) > 0.
Short: MA slope(SMA(close, T1 shorter lookback, T1; chart bars use T1's still-forming value in real time)) <= 0.
Long: MA slope(SMA(close, T1 longer lookback, T1; chart bars use T1's still-forming value in real time)) > 0.
Short: MA slope(SMA(close, T1 longer lookback, T1; chart bars use T1's still-forming value in real time)) <= 0.
Long: MA slope(SMA(close, T2 macro shorter lookback, T2; chart bars use T2's still-forming value in real time)) > 0.
Short: MA slope(SMA(close, T2 macro shorter lookback, T2; chart bars use T2's still-forming value in real time)) <= 0.
Long: MA slope(SMA(close, T2 macro longer lookback, T2; chart bars use T2's still-forming value in real time)) > 0.
Short: MA slope(SMA(close, T2 macro longer lookback, T2; chart bars use T2's still-forming value in real time)) <= 0.
Long: MA slope(SMA(close, T2 bias lookback, T2; chart bars use T2's still-forming value in real time)) > 0.
Short: MA slope(SMA(close, T2 bias lookback, T2; chart bars use T2's still-forming value in real time)) <= 0.
Long: MA slope(SMA(close, T3 bias lookback, T3; chart bars use T3's still-forming value in real time)) > 0.
Short: MA slope(SMA(close, T3 bias lookback, T3; chart bars use T3's still-forming value in real time)) <= 0.
Long: MA slope(SMA(close, T3 long-term lookback, T3; chart bars use T3's still-forming value in real time)) > 0.
Short: MA slope(SMA(close, T3 long-term lookback, T3; chart bars use T3's still-forming value in real time)) <= 0.
Long: SMA(close, T1 shorter lookback, T1; chart bars use T1's still-forming value in real time) > SMA(close, T1 longer lookback, T1; chart bars use T1's still-forming value in real time).
Short: SMA(close, T1 shorter lookback, T1; chart bars use T1's still-forming value in real time) <= SMA(close, T1 longer lookback, T1; chart bars use T1's still-forming value in real time).
Long: SMA(close, T2 macro shorter lookback, T2; chart bars use T2's still-forming value in real time) > SMA(close, T2 macro longer lookback, T2; chart bars use T2's still-forming value in real time).
Short: SMA(close, T2 macro shorter lookback, T2; chart bars use T2's still-forming value in real time) <= SMA(close, T2 macro longer lookback, T2; chart bars use T2's still-forming value in real time).
Long: SMA(close, T2 bias lookback, T2; chart bars use T2's still-forming value in real time) > SMA(close, T3 bias lookback, T3; chart bars use T3's still-forming value in real time).
Short: SMA(close, T2 bias lookback, T2; chart bars use T2's still-forming value in real time) <= SMA(close, T3 bias lookback, T3; chart bars use T3's still-forming value in real time).
Long: close > the close of the last completed T4 bar.
Short: close <= the close of the last completed T4 bar.
Calculation: OB volatility measure = ATR(lookback) or cumulative sum(True Range)/bar_index, selected by the volatility-method parameter; a high-volatility bar has high-low >= volatility-multiplier parameter times this measure.
Calculation: Parsed high/low = low/high, respectively, on a high-volatility bar; otherwise high/low.
Calculation: OB body ratio = high > low ? abs(close-open)/(high-low) : 0.
Calculation: Active bullish OB zones = when order blocks are enabled, close crosses above the latest confirmed pivot high (pivot lookback on both sides), and OB body ratio >= its minimum parameter, create a zone using parsed high and parsed low at the bar with the lowest parsed low from the pivot bar through the bar before the cross; invalidate after the invalidation-lookback parameter consecutive closes below the bottom, resetting the count when a close is not below it.
Calculation: Active bearish OB zones = when order blocks are enabled, close crosses below the latest confirmed pivot low (pivot lookback on both sides), and OB body ratio >= its minimum parameter, create a zone using parsed high and parsed low at the bar with the highest parsed high from the pivot bar through the bar before the cross; invalidate after the invalidation-lookback parameter consecutive closes above the top, resetting the count when a close is not above it.
Calculation: Retain only the most recent maximum-zone parameter number of OB zones across both directions.
Long: high >= bottom and low <= top of an active bullish OB zone AND OB alerts are enabled AND that zone's cooldown has elapsed (cooldown parameter C1 when the chart timeframe is T1, otherwise C2) AND the bar is within an enabled OB alert session window.
Short: high >= bottom and low <= top of an active bearish OB zone AND OB alerts are enabled AND that zone's cooldown has elapsed (cooldown parameter C1 when the chart timeframe is T1, otherwise C2) AND the bar is within an enabled OB alert session window.