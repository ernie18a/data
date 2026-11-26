Calculation: CVD bar delta = the value obtained by setting volume * (2 * close - high - low) / (high - low) when high != low, volume / 2 when high = low and close > open, -volume / 2 when high = low and close < open, or 0 otherwise, then setting values whose absolute value is below the zero-threshold parameter to 0
Long: CVD bar delta >= 0
Short: CVD bar delta < 0