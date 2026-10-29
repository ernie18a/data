Calculation: Volatility stop = an ATR trailing stop: in an uptrend, the greater of the prior stop and the highest close since the trend began minus ATR; in a downtrend, the lesser of the prior stop and the lowest close since the trend began plus ATR. Reset the close extreme and stop when the trend flips. Use bars lower than the chart timeframe and the last completed bar.
Long: Close >= Volatility stop
Short: Close < Volatility stop
Exit: long, Close < Volatility stop
Exit: short, Close > Volatility stop