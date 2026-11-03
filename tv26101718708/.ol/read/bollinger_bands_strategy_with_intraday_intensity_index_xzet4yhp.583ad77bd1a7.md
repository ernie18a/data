Calculation: Bollinger bands = basis is an SMA or EMA of the price source; deviation is the square root of the mean squared difference between the price source and the current basis over the lookback; upper/lower band = basis plus/minus multiplier × deviation
Calculation: Intraday Intensity Index sum = rolling sum of ((2 × close − high − low) × volume) divided by (high − low, or 1 when high equals low)
Long: prior close < prior lower Bollinger band AND close > lower Bollinger band AND (III filter disabled OR Intraday Intensity Index sum > 0)
Short: prior close > prior upper Bollinger band AND close < upper Bollinger band AND (III filter disabled OR Intraday Intensity Index sum < 0)
Exit: Long, close > Bollinger basis OR (early profit exit enabled AND close > entry price) OR bars since long-entry signal > time-stop length
Exit: Short, close < Bollinger basis OR (early profit exit enabled AND close < entry price) OR bars since short-entry signal > time-stop length