Calculation: Source = a selected price series derived from the chart bar's open, high, low, and close.
Calculation: Anchored VWAP = cumulative sum of Source × volume divided by cumulative volume from the anchor bar through the current bar. For time anchoring, the anchor is the first bar whose datetime is at or after the selected time. For bars-back anchoring, accumulation starts at the first dataset bar. The result is unavailable when cumulative volume is zero.
Calculation: Band deviation = either the volume-weighted standard deviation of Source since the anchor, sqrt(max(cumulative sum of Source² × volume / cumulative volume − Anchored VWAP², 0)), or the rolling standard deviation of Source.
Calculation: Upper band = Anchored VWAP + a multiplier × Band deviation; lower band = Anchored VWAP − the same multiplier × Band deviation.
Long: close >= Anchored VWAP
Short: close < Anchored VWAP
Long: (low <= Anchored VWAP × (1 + tolerance) AND close > Anchored VWAP AND previous close <= previous Anchored VWAP) AND (close confirmation disabled OR close > open) AND (slope filter disabled OR Anchored VWAP > Anchored VWAP at the slope lookback)
Long: low <= lower band AND close > lower band AND (close confirmation disabled OR close > open) AND (slope filter disabled OR Anchored VWAP > Anchored VWAP at the slope lookback)
Long: low <= lower band × (1 + tolerance) AND (close > open OR close >= low + 0.30 × (high − low))
Short: (high >= Anchored VWAP × (1 − tolerance) AND close < Anchored VWAP AND previous close >= previous Anchored VWAP) AND (close confirmation disabled OR close < open) AND (slope filter disabled OR Anchored VWAP < Anchored VWAP at the slope lookback)
Short: high >= upper band AND close < upper band AND (close confirmation disabled OR close < open) AND (slope filter disabled OR Anchored VWAP < Anchored VWAP at the slope lookback)