Calculation: Descending pivot-high trendline = Connect the two most recent confirmed pivot highs when the latest is lower than the prior one; extend the line using the slope between them.
Calculation: High volume = Volume greater than its 20-bar simple moving average multiplied by a configurable factor.
Calculation: Wide spread = High minus low greater than its 20-bar simple moving average multiplied by a configurable factor.
Calculation: Bullish VPA bar = Close > open AND high volume AND wide spread.
Calculation: Bearish VPA bar = Close < open AND high volume AND wide spread.
Calculation: Buying pressure = Lower wick > 2 × candle body AND high volume.
Calculation: Selling pressure = Upper wick > 2 × candle body AND high volume.
Calculation: EMA slope = Percentage change of the 50-bar exponential moving average from its value 5 bars earlier.
Calculation: Trailing stop = Highest value since entering the long position of close minus ATR(14) multiplied by a configurable factor.
Long: Bullish VPA bar AND close crosses above the descending pivot-high trendline AND EMA slope > -0.05 OR descending pivot-high trendline exists AND close crosses above it OR buying pressure OR EMA slope > 0
Short: Bearish VPA bar OR selling pressure OR EMA slope <= 0
Exit: Long, close < trailing stop OR bearish VPA bar