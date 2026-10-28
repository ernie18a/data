Calculation: High channel average = arithmetic mean of the SMA, EMA, WMA, ALMA, SMMA, least-squares moving average, and VWMA of high, all using the same lookback.
Calculation: Low channel average = arithmetic mean of the SMA, EMA, WMA, ALMA, SMMA, least-squares moving average, and VWMA of low, all using the same lookback.
Long: close > high channel average
Short: close < low channel average
Exit: long, low crosses below low channel average OR high >= entry price + close × take-profit fraction OR low <= entry price − close × stop-loss fraction
Exit: short, high crosses above high channel average OR low <= entry price − close × take-profit fraction OR high >= entry price + close × stop-loss fraction