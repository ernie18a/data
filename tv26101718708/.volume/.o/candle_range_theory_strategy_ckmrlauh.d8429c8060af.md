Calculation: Older completed HTF candle high/low = high/low from two completed HTF bars ago
Calculation: Recent completed HTF candle high/low/close = high/low/close from the last completed HTF bar
Calculation: Long trigger level = recent completed HTF candle high
Calculation: Short trigger level = recent completed HTF candle low
Calculation: Long target = older completed HTF candle high
Calculation: Long stop = recent completed HTF candle low − (older completed HTF candle high − recent completed HTF candle low) × stop-loss multiplier
Calculation: Short target = older completed HTF candle low
Calculation: Short stop = recent completed HTF candle high + (recent completed HTF candle high − older completed HTF candle low) × stop-loss multiplier
Long: Recent completed HTF candle low < older completed HTF candle low AND recent completed HTF candle close > older completed HTF candle low AND current chart bar high > long trigger level AND (volume filter disabled OR current forming HTF volume > simple moving average of HTF volume sampled on chart bars × volume threshold)
Short: Recent completed HTF candle high > older completed HTF candle high AND recent completed HTF candle close < older completed HTF candle high AND current chart bar low < short trigger level AND (volume filter disabled OR current forming HTF volume > simple moving average of HTF volume sampled on chart bars × volume threshold)
Exit: long, current bar low ≤ long stop OR current bar high ≥ long target
Exit: short, current bar high ≥ short stop OR current bar low ≤ short target