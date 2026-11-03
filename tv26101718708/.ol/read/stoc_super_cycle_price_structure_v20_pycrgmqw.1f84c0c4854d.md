Calculation: Resistance = highest high over the resistance lookback, excluding the current bar
Calculation: Base depth = (highest high − lowest low) / highest high × 100 over the base lookback
Calculation: ATR percentage = ATR(14) / close × 100
Calculation: Relative volume = volume / 50-bar average volume
Long: (close > Resistance AND previous close <= current Resistance AND close > Base EMA AND Base EMA > longer-term SMA 1 AND SMA 1 > longer-term SMA 2 AND SMA 2 > its value 20 bars ago AND (volume filter disabled OR Relative volume >= its threshold) AND (contraction filter disabled OR a qualifying contraction occurred within its prior-bar window)) OR (close > Base EMA AND Base EMA > longer-term SMA 1 AND SMA 1 > longer-term SMA 2 AND SMA 2 > its value 20 bars ago AND low <= Fast EMA AND close > Fast EMA AND close > open AND a prior bar in the current long-trend sequence had low > Fast EMA AND minimum pullback spacing has elapsed AND no breakout occurs on this bar)
Short: 
Exit: Long, close crosses below Base EMA AND (linked exits disabled OR a prior breakout or pullback signal has activated the cycle)