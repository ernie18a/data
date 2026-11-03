Calculation: MACD = shorter-lookback EMA(close) minus longer-lookback EMA(close)
Calculation: Signal line = longer-lookback SMA(MACD)
Calculation: ATR trailing stop = hl2 minus ATR times a factor while rising, ratcheled upward to at least its prior value when prior close exceeds the prior rising stop; otherwise reset to hl2 minus ATR times the factor. The falling stop is hl2 plus ATR times the factor, ratcheled downward to at most its prior value when prior close is below the prior falling stop; otherwise reset to hl2 plus ATR times the factor. Use the rising stop when close is above the prior falling stop, the falling stop when close is below the prior rising stop, and otherwise retain the prior direction (default rising).
Calculation: Volatility measure = (highest close over a lookback minus low) / highest close over that lookback, times 100
Calculation: Upper volatility band = SMA of the volatility measure plus a multiplier times its standard deviation, using the same lookback for the SMA and standard deviation
Calculation: Volatility ceiling = highest volatility measure over a lookback times a factor
Calculation: Volatility trigger = volatility measure >= upper volatility band OR volatility measure >= volatility ceiling
Calculation: Recent average = VWMA of OHLC4
Long: MACD > signal line OR bars since close crossed above the ATR trailing stop < bars since close crossed below it (if these counts are equal while close is above the stop, increment the count since crossing below) AND position size < a position limit AND volatility trigger OR bars since close crossed above the ATR trailing stop < bars since close crossed below it (with the same tie adjustment) AND MACD crosses above signal line AND close < recent average minus an offset AND volatility trigger
Short: MACD < signal line
Exit: Long, volatility trigger is false AND ((high < prior high AND low < prior low) OR close < prior low)
Exit: Long, open profit < a loss limit
Exit: Long, current point-and-figure close < prior point-and-figure close