Calculation: Fibonacci border = rolling highest high and lowest low over the configured lookback; from their range, borders are highest high, highest high minus 0.236/0.382/0.618/0.764 of the range, and lowest low
Calculation: Safety-order threshold = initial entry price minus cumulative price deviations, with each successive deviation scaled by the configured step scale
Long: Flat AND within configured date range AND volume filters pass AND RSI is below its configured maximum (when enabled) AND ((source crosses the selected Fibonacci border in the configured direction AND ADX is within its configured range AND +DI and -DI are within their configured ranges AND (if bullish DI is required, +DI > -DI)) OR the same conditions for the second Fibonacci zone) AND (if ranged-volume filter is enabled, highest volume over its configured lookback exceeds the prior bar's highest-volume value AND source > open)
Long: Position is open AND low <= safety-order threshold AND safety orders remain AND no take-profit trailing phase has begun
Short: 
Exit: Long, source crosses the configured Fibonacci stop border in its configured direction
Exit: Long, +DI crosses above -DI AND previous bar close < previous bar open
Exit: Long, -DI crosses below +DI AND previous bar close > previous bar open
Exit: Long, selected take-profit trigger occurs: source crosses the selected Fibonacci take-profit border in the configured direction OR high reaches the configured percentage target above average entry price
Exit: Long, take-profit trigger has occurred AND trailing is enabled AND close <= the highest trailing stop reached since the trigger (or high <= that stop when wick-based exit is enabled)