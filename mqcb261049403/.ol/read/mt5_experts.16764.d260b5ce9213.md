Calculation: Smoothed Heiken Ashi oscillator = the change from the previous bar in a moving average of the midpoint of Heiken Ashi open and close; calculate Heiken Ashi close as the average of pre-smoothed open, high, low, and close, and Heiken Ashi open as the average of the prior Heiken Ashi open and close (initialize with the current open and close average). Apply the configured post-smoothing moving average to the midpoint. Use the current, still-forming bar on the configured indicator timeframe.
Calculation: Oscillator signal average = a moving average of the smoothed Heiken Ashi oscillator, using the current, still-forming bar on the configured indicator timeframe.
Calculation: Pivot = (previous completed daily high + previous completed daily low + previous completed daily close) / 3; the daily bar is higher than the indicator timeframe.
Long: Smoothed Heiken Ashi oscillator >= 0
Short: Smoothed Heiken Ashi oscillator < 0
Long: Smoothed Heiken Ashi oscillator > Oscillator signal average
Short: Smoothed Heiken Ashi oscillator < Oscillator signal average
Long: Smoothed Heiken Ashi oscillator > Oscillator signal average AND close < Pivot
Short: Smoothed Heiken Ashi oscillator < Oscillator signal average AND close > Pivot
Exit: long, Smoothed Heiken Ashi oscillator < Oscillator signal average AND close > Pivot
Exit: short, Smoothed Heiken Ashi oscillator > Oscillator signal average AND close < Pivot