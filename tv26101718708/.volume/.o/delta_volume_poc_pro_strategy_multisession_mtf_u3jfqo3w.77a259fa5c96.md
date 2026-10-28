Calculation: Prior low = lowest low of the preceding N completed bars on the signal-analysis timeframe
Calculation: Prior high = highest high of the preceding N completed bars on the signal-analysis timeframe
Long: current signal-analysis-timeframe low < prior low AND current signal-analysis-timeframe close > prior low AND (trend filter disabled OR chart-timeframe close > chart-timeframe EMA) AND (session filter disabled OR bar is in an enabled session) AND chart bar is confirmed
Short: current signal-analysis-timeframe high > prior high AND current signal-analysis-timeframe close < prior high AND (trend filter disabled OR chart-timeframe close < chart-timeframe EMA) AND (session filter disabled OR bar is in an enabled session) AND chart bar is confirmed
Calculation: Long stop = average entry price × (1 − stop-loss fraction)
Calculation: Long target = average entry price × (1 + take-profit fraction)
Calculation: Short stop = average entry price × (1 + stop-loss fraction)
Calculation: Short target = average entry price × (1 − take-profit fraction)
Exit: long, low ≤ long stop OR high ≥ long target OR (trailing enabled AND trailing stop is hit after price reaches the trailing activation level above entry)
Exit: short, high ≥ short stop OR low ≤ short target OR (trailing enabled AND trailing stop is hit after price reaches the trailing activation level below entry)