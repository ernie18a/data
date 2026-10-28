Calculation: Session VWAP = cumulative sum of typical price × weight since the configured session began, divided by cumulative weight; typical price = (high + low + close) / 3 and weight = max(volume, 1)
Calculation: Session standard deviation = square root of max(cumulative weighted typical-price squared / cumulative weight − Session VWAP², 0)
Calculation: Upper and lower 2σ bands = Session VWAP ± 2 × Session standard deviation
Long: close > Session VWAP AND previous close ≤ previous Session VWAP
Long: low ≤ lower 2σ band AND previous low > previous lower 2σ band
Short: close < Session VWAP AND previous close ≥ previous Session VWAP
Short: high ≥ upper 2σ band AND previous high < previous upper 2σ band