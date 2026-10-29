Calculation: Relative volume = volume / its simple moving average, or 0 when that average is not positive
Calculation: Candle pressure = the exponential moving average of the average of candle position and candle direction; candle position = 2 × (close − low) / (high − low) − 1 when high > low, otherwise −1; candle direction = +1 when close > open, −1 when close < open, otherwise 0
Calculation: Volume-weighted pressure = candle pressure × relative volume
Calculation: Bullish structure = close > the exponential moving average of close
Calculation: Bearish structure = close < the exponential moving average of close
Calculation: Bullish pressure = volume-weighted pressure > 0
Calculation: Bearish pressure = volume-weighted pressure < 0
Calculation: High volume = relative volume ≥ the high-volume threshold
Calculation: Volume expansion = relative volume > the high-volume threshold AND relative volume > the prior bar's relative volume
Calculation: Bull signal strength = the count of true conditions among bullish structure, bullish pressure, high volume, and volume expansion
Calculation: Bear signal strength = the count of true conditions among bearish structure, bearish pressure, high volume, and volume expansion
Long: bullish structure AND bullish pressure AND bull signal strength ≥ the minimum signal strength AND NOT (bullish structure AND bullish pressure AND bull signal strength ≥ the minimum signal strength on the prior bar)
Short: bearish structure AND bearish pressure AND bear signal strength ≥ the minimum signal strength AND NOT (bearish structure AND bearish pressure AND bear signal strength ≥ the minimum signal strength on the prior bar)