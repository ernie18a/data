Calculation: Session VWAP = cumulative average of the source price weighted by max(volume, 1), reset at the configured session start; the default source is (high + low + close) / 3
Calculation: Session standard deviation = sqrt(max(cumulative weighted average of source price squared - Session VWAP², 0)), using the same weights and session
Calculation: Upper/lower 2σ bands = Session VWAP ± 2 × Session standard deviation
Long: close > Session VWAP AND previous close ≤ previous Session VWAP OR low ≤ lower 2σ band AND previous low > previous lower 2σ band
Short: close < Session VWAP AND previous close ≥ previous Session VWAP OR high ≥ upper 2σ band AND previous high < previous upper 2σ band