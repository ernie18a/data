Calculation: Smoothed moving average = SMMA of median price on each of three higher timeframes, using completed bars; each timeframe uses its own averaging period and horizontal shift.
Calculation: First timeframe score = round(10000 × [w1 × (MA[1]−MA[2])/MA[1] + w2 × (MA[2]−MA[3])/MA[3] + w3 × (MA[3]−MA[4])/MA[4]]), using the last four completed bars.
Calculation: Second and third timeframe scores = round(10000 × [w1 × (MA[1]−MA[2])/MA[2] + w2 × (MA[2]−MA[3])/MA[3] + w3 × (MA[3]−MA[4])/MA[4]]), using the last four completed bars; each score uses its own weights.
Long: First timeframe score > 0 AND second timeframe score > 0 AND third timeframe score > 0
Short: First timeframe score > 0 AND second timeframe score < 0 AND third timeframe score < 0
Exit: long, current price <= stop loss OR current price >= take profit
Exit: short, current price >= stop loss OR current price <= take profit