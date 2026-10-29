Calculation: Buy volume = 0 if high = low; otherwise volume × (close − low) ÷ (high − low)
Calculation: Sell volume = 0 if high = low; otherwise volume × (high − close) ÷ (high − low)
Calculation: Upper Bollinger Band = SMA(close, lookback) + multiplier × standard deviation(close, same lookback)
Calculation: Inner upper Bollinger Band = SMA(close, lookback) + a smaller multiplier × standard deviation(close, same lookback)
Calculation: Inner lower Bollinger Band = SMA(close, lookback) − the same smaller multiplier × standard deviation(close, same lookback)
Calculation: In-position high = high of the most recent bar on which the position was open
Long: close > inner upper Bollinger Band AND high > upper Bollinger Band AND buy volume > sell volume AND buy volume > SMA(volume, one lookback) AND close > short-term SMA AND medium-term SMA > longer-term SMA AND RSI < its upper threshold
Short: close < inner lower Bollinger Band AND close < lower Bollinger Band AND sell volume > buy volume AND sell volume > SMA(volume, another lookback) AND close < short-term SMA AND the shorter-lookback SMA crosses below the longer-lookback SMA
Exit: long, close > entry price × upper profit threshold OR (in-position high × trailing factor < close AND close > entry price × minimum profit factor) OR close < entry price × loss factor
Exit: short, close < entry price × loss factor