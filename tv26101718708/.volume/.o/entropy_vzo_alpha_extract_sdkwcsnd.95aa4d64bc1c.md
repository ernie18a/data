Calculation: Signed pressure = clamp(0.65 × (close − open) / max(high − low, minimum price increment) + 0.35 × sign(change in HLC3), −1, 1)
Calculation: Volume flow oscillator = 100 × EMA(volume × signed pressure, volume-flow lookback) / max(EMA(volume, same lookback), 1)
Calculation: Normalized volume flow = (volume flow oscillator − EMA(volume flow oscillator, normalization lookback)) / max(standard deviation of volume flow oscillator over the normalization lookback, 0.000001)
Calculation: Directional entropy = binary entropy of the proportions of positive and negative close-to-close changes over its lookback, divided by ln(2); use 1 if there are no nonzero changes
Calculation: Fractal efficiency = abs(HLC3 − HLC3 from efficiency lookback bars ago) / sum of absolute HLC3 changes over that lookback, clamped to [0, 1]; use 0 if the sum is zero
Calculation: Information weight = clamp(0.55 × (1 − directional entropy) + 0.45 × fractal efficiency, 0.05, 1)
Calculation: Main oscillator = EMA of Gaussian-smoothed [max level × tanh(normalized volume flow × sensitivity × (0.65 + information weight))]; Gaussian smoothing uses the oscillator smoothing lookback and weights current values more than older values
Calculation: Signal line = EMA of the main oscillator using a longer smoothing lookback than the oscillator's Gaussian smoothing lookback
Long: (main oscillator > signal line AND main oscillator > 0) OR main oscillator crosses above signal line OR main oscillator crosses above 0
Short: (main oscillator < signal line AND main oscillator < 0) OR main oscillator crosses below signal line OR main oscillator crosses below 0