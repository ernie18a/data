Calculation: Anchored volume-weighted deviation = √(Σ(volume × source²) / Σ(volume) − AVWAP(source, anchor)²), summing from the selected anchor
Calculation: Outer bands = AVWAP(source, anchor) ± outer-band multiplier × anchored volume-weighted deviation
Calculation: Bull outcome samples = on confirmed chart bars while the probability read is enabled, append the percentage return from close at horizon bars ago to the current close when close at horizon bars ago is below the lower outer band at that bar; retain at most the maximum-sample count
Calculation: Bear outcome samples = on confirmed chart bars while the probability read is enabled, append the negative of the percentage return from close at horizon bars ago to the current close when close at horizon bars ago is above the upper outer band at that bar; retain at most the maximum-sample count
Calculation: Recent outcomes = the most recent recent-window samples for the relevant direction, or all available samples if fewer
Calculation: Recent Wilson lower bound = Wilson score lower bound for the fraction of recent outcomes greater than zero, at the confidence parameter
Calculation: Outer-band excursion = max(0, abs(close − AVWAP(source, anchor)) / anchored volume-weighted deviation − outer-band multiplier)
Long: close > AVWAP(source, anchor)
Short: close < AVWAP(source, anchor)
Long: close at confirmation-lag bars ago < lower outer band at that bar AND current chart bar confirmed
Short: close at confirmation-lag bars ago > upper outer band at that bar AND current chart bar confirmed
Long: current close ≥ lower outer band AND previous close < lower outer band at the previous bar AND current chart bar confirmed
Short: current close ≤ upper outer band AND previous close > upper outer band at the previous bar AND current chart bar confirmed
Long: close crosses above AVWAP(source, anchor) AND current chart bar confirmed
Short: close crosses below AVWAP(source, anchor) AND current chart bar confirmed
Long: close at confirmation-lag bars ago < lower outer band at that bar AND current chart bar confirmed AND probability read enabled AND bull outcome sample count ≥ minimum sample count AND median(recent bull outcomes) > 0 AND recent bull Wilson lower bound > win-rate lower-bound threshold
Short: close at confirmation-lag bars ago > upper outer band at that bar AND current chart bar confirmed AND probability read enabled AND bear outcome sample count ≥ minimum sample count AND median(recent bear outcomes) > 0 AND recent bear Wilson lower bound > win-rate lower-bound threshold
Long: close at confirmation-lag bars ago < lower outer band at that bar AND current chart bar confirmed AND probability read enabled AND bull outcome sample count ≥ minimum sample count AND median(recent bull outcomes) > 0 AND recent bull Wilson lower bound > win-rate lower-bound threshold AND outer-band excursion at confirmation-lag bars ago ≥ strongest-excursion threshold
Short: close at confirmation-lag bars ago > upper outer band at that bar AND current chart bar confirmed AND probability read enabled AND bear outcome sample count ≥ minimum sample count AND median(recent bear outcomes) > 0 AND recent bear Wilson lower bound > win-rate lower-bound threshold AND outer-band excursion at confirmation-lag bars ago ≥ strongest-excursion threshold