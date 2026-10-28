Calculation: ROC = 100 × (close − close N bars ago) / close N bars ago
Calculation: Bollinger bands of ROC = SMA(ROC, N) ± multiplier × standard deviation(ROC, N), using the same lookback N as ROC
Calculation: Oscillator = MFI, or RSI when configured to use RSI; its Bollinger bands use a separate lookback. MFI is RSI of the N-bar sums of volume × HLC3 on bars where HLC3 rose and fell, respectively.
Calculation: Recent oscillator state = +1 on a bar where the oscillator is below its lower Bollinger band, −1 where it is above its upper band; otherwise retain the prior nonzero sign and increment its age. Reset to 0 when its age exceeds 10 bars.
Long: ROC crosses above its lower Bollinger band AND recent oscillator state > 0
Short: ROC crosses below its upper Bollinger band AND recent oscillator state < 0