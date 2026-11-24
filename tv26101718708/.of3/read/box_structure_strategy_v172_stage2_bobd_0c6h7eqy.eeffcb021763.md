Calculation: Box top = mean of the latest confirmed pivot high and its nearest earlier confirmed pivot high within the box lookback whose bar separation is at least the minimum gap and whose price difference is at most current ATR × touch tolerance; each pivot uses the pivot lookback on both sides. Freeze this level when the box activates.
Calculation: Box bottom = mean of the latest confirmed pivot low and its nearest earlier confirmed pivot low within the box lookback whose bar separation is at least the minimum gap and whose price difference is at most current ATR × touch tolerance; each pivot uses the pivot lookback on both sides. Freeze this level when the box activates.
Calculation: Break buffer = current ATR × breakout tolerance.
Calculation: Close position = (close − low) / (high − low), or 0.5 when high equals low.
Long: Active box AND flat AND confirmed bar AND each of the last breakout-confirmation lookback bars closed above frozen box top + break buffer AND close position ≥ minimum breakout close position.
Short: Active box AND confirmed bar AND each of the last breakout-confirmation lookback bars closed below frozen box bottom − break buffer AND close position ≤ 1 − minimum breakout close position.
Long: MACD(close, fast lookback, slow lookback) line crosses above its signal line AND MACD line > 0.
Calculation: Initial stop = the selected stop mode: entry price − ATR × volatility stop multiple; frozen box bottom − ATR × structural ATR multiple; frozen box bottom × (1 − structural stop percentage / 100); frozen box midpoint; or the greater of the volatility and structural ATR stops. Select the volatility stop multiple by frozen breakout ATR percentage: low multiple below the first threshold, second multiple from the first to the second threshold, third multiple from the second to the third threshold, and fourth multiple at or above the third threshold.
Calculation: Risk = maximum of entry price − initial stop and ATR × minimum risk ATR multiple.
Calculation: TP1 = frozen box top + (frozen box top − frozen box bottom) × TP1 box-height multiple.
Calculation: TP2 = entry price + risk × TP2 risk multiple.
Calculation: Protection stop = entry price + risk × protection risk multiple.
Calculation: Runner stop = initial stop until TP1 is reached; then protection stop until TP2 is reached; then the greater of protection stop and highest close since entry − current ATR × runner trail multiple.
Exit: Long, high ≥ TP1.
Exit: Long, high ≥ TP2.
Exit: Long, highest high since entry < TP1 AND low ≤ initial stop.
Exit: Long, highest high since entry ≥ TP1 AND highest high since entry < TP2 AND low ≤ protection stop.
Exit: Long, highest high since entry ≥ TP1 AND highest high since entry ≥ TP2 AND low ≤ runner stop.