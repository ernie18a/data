Calculation: Strong candle = absolute(open − close) > a configurable fraction of (high − low)
Calculation: Bullish fair value gap = current low − high two bars ago, greater than a configurable minimum gap size
Calculation: Bearish fair value gap = low two bars ago − current high, greater than a configurable minimum gap size
Calculation: Bullish CISD = a strong candle and, on at least one of the requested timeframes, the current candle closes above its open while the preceding candle closed below its open
Calculation: Bearish CISD = a strong candle and, on at least one of the requested timeframes, the current candle closes below its open while the preceding candle closed above its open
Long: close crosses above the most recent confirmed swing high (previous close ≤ swing high) OR bullish CISD OR bullish fair value gap
Short: close crosses below the most recent confirmed swing low (previous close ≥ swing low) OR bearish CISD OR bearish fair value gap