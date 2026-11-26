Calculation: Bullish FVG = low > high[2] AND close > open
Calculation: Bearish FVG = high < low[2] AND close < open
Long: Bullish FVG
Short: Bearish FVG
Long: close crosses above the most recent unbroken PivotHigh(high, structural lookback, structural lookback)
Short: close crosses below the most recent unbroken PivotLow(low, structural lookback, structural lookback)
Long: PivotLow(low, major pivot lookback, major pivot lookback) is confirmed OR NOT Bullish FVG AND NOT Bearish FVG AND (the latest confirmed major pivot is a PivotLow(low, major pivot lookback, major pivot lookback) OR no major pivot is confirmed yet AND close >= open)
Short: PivotHigh(high, major pivot lookback, major pivot lookback) is confirmed OR NOT Bullish FVG AND NOT Bearish FVG AND (the latest confirmed major pivot is a PivotHigh(high, major pivot lookback, major pivot lookback) OR no major pivot is confirmed yet AND close < open)