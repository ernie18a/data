Calculation: lower target band = VWMA(source, band lookback) - level parameter * level scale parameter * deviation multiplier * STDEV(source, band lookback)
Calculation: upper target band = VWMA(source, band lookback) + level parameter * level scale parameter * deviation multiplier * STDEV(source, band lookback)
Long: low < VWMA(source, band lookback) - outer-band multiple * deviation multiplier * STDEV(source, band lookback) AND RSI(close, RSI lookback)[1] crosses above oversold threshold AND high < lower target band
Short: high > VWMA(source, band lookback) + outer-band multiple * deviation multiplier * STDEV(source, band lookback) AND RSI(close, RSI lookback)[1] crosses below overbought threshold AND low > upper target band
Exit: long, high > lower target band at long entry OR low <= entry price * (1 - stop-loss parameter * scale parameter)
Exit: short, low < upper target band at short entry OR high >= entry price * (1 + stop-loss parameter * scale parameter)