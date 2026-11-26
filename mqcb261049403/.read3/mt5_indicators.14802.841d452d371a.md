Calculation: Oscillator = 100 × (C − L′) / (H′ − L′), or 100 if H′ = L′; C is the sum of close over the Slowing bars; H and L are sums over those bars of the rolling K-lookback highest and lowest selected price; selected price is close for both extrema in close/close mode and high/low otherwise; when H − L < sensitivity, H′ = H + sensitivity/2 and L′ = L − sensitivity/2, otherwise H′ = H and L′ = L
Long: Oscillator > 50 AND Oscillator != Oscillator[1]
Short: Oscillator < 50 AND Oscillator != Oscillator[1]
Long: Oscillator > MovingAverage(Oscillator, D lookback, smoothing method)
Short: Oscillator < MovingAverage(Oscillator, D lookback, smoothing method)
Long: Oscillator(T1, still-forming bar sampled on chart bars) > 50 AND Oscillator(T1, still-forming bar sampled on chart bars) != Oscillator(T1, preceding T1 bar)
Short: Oscillator(T1, still-forming bar sampled on chart bars) < 50 AND Oscillator(T1, still-forming bar sampled on chart bars) != Oscillator(T1, preceding T1 bar)
Long: Oscillator(T1, still-forming bar sampled on chart bars) > MovingAverage(Oscillator(T1), D lookback, smoothing method, still-forming bar sampled on chart bars)
Short: Oscillator(T1, still-forming bar sampled on chart bars) < MovingAverage(Oscillator(T1), D lookback, smoothing method, still-forming bar sampled on chart bars)