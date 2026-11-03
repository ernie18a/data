Calculation: Weekly moving average = simple moving average of close over a longer lookback of higher-timeframe bars, using the last completed higher-timeframe bar
Calculation: Moving-average slope = current weekly moving average minus its value from a shorter lookback of higher-timeframe bars ago
Calculation: Accumulation day = close rose by more than a threshold from the prior chart bar and volume exceeded its longer-lookback simple average
Calculation: Distribution day = close fell by more than a threshold from the prior chart bar and volume exceeded its longer-lookback simple average
Calculation: Net accumulation = accumulation-day count minus distribution-day count over a shorter rolling lookback
Calculation: Bullish breadth = breadth index low over a rolling lookback and current breadth index above a recovery threshold
Calculation: Bearish breadth = breadth index high over a rolling lookback and current breadth index below a recovery threshold
Long: close > weekly moving average AND moving-average slope > 0 AND net accumulation >= threshold AND bullish breadth AND NOT (all these conditions were true on the prior chart bar)
Exit: long, (close > weekly moving average AND moving-average slope <= 0 AND distribution-day count over a rolling lookback >= warning threshold) OR (prior chart bar had close > weekly moving average AND moving-average slope > 0 AND current close < weekly moving average) OR bearish breadth; AND NOT (an exit condition was true on the prior chart bar)