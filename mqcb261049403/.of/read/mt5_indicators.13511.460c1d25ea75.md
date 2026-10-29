Calculation: Two-stage smoothed price = apply a configurable smoother to an OHLC-derived price, then apply a second configurable smoother to the result.
Calculation: Oscillator = 100 × (two-stage smoothed price − lowest two-stage smoothed price over a configurable lookback) ÷ (highest − lowest over that lookback) − 50.
Long: Oscillator ≥ 0 AND Oscillator > its value on the previous bar
Short: Oscillator < 0 AND Oscillator < its value on the previous bar