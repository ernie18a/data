Calculation: Anchor pivot high/low = most recent pivot high/low from the configured higher-timeframe bars, using the configured left/right pivot lookbacks; use the latest value projected from the still-forming anchor bar
Calculation: Equilibrium = (anchor pivot high + anchor pivot low) / 2
Calculation: At level = close is within the configured ATR-based tolerance of the anchor pivot high, anchor pivot low, or equilibrium
Calculation: Bullish sweep = low < anchor pivot low AND close > anchor pivot low AND open > anchor pivot low OR low < equilibrium AND close > equilibrium AND open > equilibrium AND prior close > prior equilibrium
Calculation: Bearish sweep = high > anchor pivot high AND close < anchor pivot high AND open < anchor pivot high OR high > equilibrium AND close < equilibrium AND open < equilibrium AND prior close < prior equilibrium
Calculation: Bullish engulfing = current bullish candle's body engulfs the preceding bearish candle's body, subject to the configured equality rule
Calculation: Bearish engulfing = current bearish candle's body engulfs the preceding bullish candle's body, subject to the configured equality rule
Calculation: Bullish absorption = volume exceeds its configured moving-average multiple AND lower wick is at least the configured fraction of bar range AND (at the anchor pivot low OR at equilibrium with prior close below prior equilibrium)
Calculation: Bearish absorption = volume exceeds its configured moving-average multiple AND upper wick is at least the configured fraction of bar range AND (at the anchor pivot high OR at equilibrium with prior close above prior equilibrium)
Calculation: Bullish score and bearish score = sum of their configured points for being at a level, respective sweep, respective engulfing, respective absorption, volume spike with any respective trigger, aligned cumulative signed volume delta, and aligned discount/premium; use the configured point weights
Calculation: Bullish setup = a bullish trigger exists AND bullish score > bearish score AND bullish score meets the configured setup grade threshold
Calculation: Bearish setup = a bearish trigger exists AND bearish score > bullish score AND bearish score meets the configured setup grade threshold
Long: bullish sweep OR (bullish engulfing AND at level) OR bullish absorption OR close crosses above its shorter-period EMA AND volume exceeds its longer-period moving average by the configured multiple OR bullish setup
Short: bearish sweep OR (bearish engulfing AND at level) OR bearish absorption OR close crosses below its shorter-period EMA AND volume exceeds its longer-period moving average by the configured multiple OR bearish setup
