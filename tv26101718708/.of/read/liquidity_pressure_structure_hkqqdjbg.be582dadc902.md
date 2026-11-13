Calculation: SwingHigh = most recent confirmed pivot high (a bar whose high is the highest among an equal number of bars on each side; known only after that many bars have closed following it), held unchanged until the next pivot high is confirmed
Calculation: SwingLow = most recent confirmed pivot low (a bar whose low is the lowest among an equal number of bars on each side; known only after that many bars have closed following it), held unchanged until the next pivot low is confirmed
Calculation: Pressure = EMA (short smoothing length) of ((((close - low) / max(high - low, minimum tick)) * 2 - 1) + sign(close - open)) / 2
Calculation: VolExp = volume >= a multiple (greater than 1) of the simple moving average of volume
Calculation: LongSetup = (low < SwingLow AND close > SwingLow AND Pressure > 0 AND close > open) OR (close > SwingHigh AND Pressure > 0 AND VolExp)
Calculation: ShortSetup = (high > SwingHigh AND close < SwingHigh AND Pressure < 0 AND close < open) OR (close < SwingLow AND Pressure < 0 AND VolExp)
Long: LongSetup is true on the current bar AND LongSetup was false on the previous bar
Short: ShortSetup is true on the current bar AND ShortSetup was false on the previous bar