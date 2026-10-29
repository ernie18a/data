Calculation: Negative Volume Index = previous value multiplied by 1 + the percentage change in close when volume is lower than the previous bar; otherwise unchanged.
Calculation: NVI Oscillator = (EMA-smoothed Negative Volume Index − its longer-term EMA) / its longer-term EMA × 100.
Calculation: Signal line = a configurable EMA, SMA, RMA, or WMA of the NVI Oscillator.
Calculation: Confirmed oscillator pivot low/high = a low/high with equal left and right lookbacks, available after the right-side bars complete.
Calculation: Bullish divergence = latest confirmed oscillator pivot low is higher than the previous one, its corresponding price low is lower than the previous one, and it is the oscillator low over a longer lookback than the pivot confirmation lookback.
Calculation: Bearish divergence = latest confirmed oscillator pivot high is lower than the previous one, its corresponding price high is higher than the previous one, and it is the oscillator high over a longer lookback than the pivot confirmation lookback.
Long: NVI Oscillator crosses above Signal line OR Bullish divergence
Short: NVI Oscillator crosses below Signal line OR Bearish divergence