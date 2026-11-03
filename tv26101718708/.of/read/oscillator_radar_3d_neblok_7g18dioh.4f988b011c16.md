Calculation: Oscillator set = Any enabled subset of at least three of: RSI of source; stochastic %K of source against high and low, smoothed by a short SMA; MFI of typical price and volume; directional balance; normalized Aroon; normalized trend correlation; Bollinger %B; and percentage of up bars. All use the same main lookback. Source is a selected price series derived from the backtest fields.
Calculation: Directional balance = 100 × +DI / (+DI + -DI), or 50 when the denominator is zero; both DI calculations use the main lookback.
Calculation: Normalized Aroon = (Aroon up - Aroon down + 100) / 2, where Aroon up and down use the ages of the highest high and lowest low in the current bar and the preceding main-lookback bars, respectively, scaled as 100 × (main lookback - age) / main lookback.
Calculation: Normalized trend correlation = 50 × (Pearson correlation of source with bar index over the main lookback + 1).
Calculation: Bollinger %B = 100 × (source - lower Bollinger Band) / (upper Bollinger Band - lower Bollinger Band), or 50 when band width is zero; bands use the main lookback and a standard-deviation multiplier.
Calculation: Percentage of up bars = 100 × the number of bars in the main lookback where source exceeds its preceding-bar value / main lookback.
Calculation: Normalized oscillator = Replace an unavailable raw oscillator value with 50, clamp it to 0–100, and apply an EMA using a common smoothing length. Replace any unavailable resulting value with 50.
Calculation: Composite = Arithmetic mean of the enabled normalized oscillators.
Calculation: Bull-zone count = Number of enabled normalized oscillators greater than or equal to the bull-zone threshold.
Calculation: Bear-zone count = Number of enabled normalized oscillators less than or equal to the bear-zone threshold.
Long: Composite > 50.
Long: Any enabled normalized oscillator > 50.
Long: Bull-zone count >= confluence threshold AND previous bull-zone count < confluence threshold.
Short: Composite < 50.
Short: Any enabled normalized oscillator < 50.
Short: Bear-zone count >= confluence threshold AND previous bear-zone count < confluence threshold.