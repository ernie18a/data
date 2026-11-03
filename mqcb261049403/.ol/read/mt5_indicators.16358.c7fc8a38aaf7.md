Calculation: Normalized oscillator = 100 × (current volume-weighted average of (2×close + high + low)/4 − lowest average over the extrema lookback) / max(highest average − lowest average over the extrema lookback, minimum price increment) − 50; the volume-weighted average uses its own lookback.
Calculation: First smoothed oscillator = smooth the normalized oscillator using the selected smoothing method and lookback.
Calculation: Second smoothed oscillator = smooth the first smoothed oscillator using the same smoothing method and lookback. If computed by the optional timeframe wrapper, use the higher-timeframe bar still forming.
Long: First smoothed oscillator > second smoothed oscillator
Short: First smoothed oscillator ≤ second smoothed oscillator