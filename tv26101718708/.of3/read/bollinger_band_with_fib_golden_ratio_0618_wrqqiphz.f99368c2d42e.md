Calculation: lower band = VWMA(HLC3, band lookback) - band ratio * deviation multiplier * STDEV(HLC3, band lookback)
Calculation: upper band = VWMA(HLC3, band lookback) + band ratio * deviation multiplier * STDEV(HLC3, band lookback)
Long: EMA(close, shorter lookback) > EMA(close, longer lookback) AND low <= lower band
Exit: long, crosses above upper band OR close < entry price * (1 - stop-loss percentage / 100)