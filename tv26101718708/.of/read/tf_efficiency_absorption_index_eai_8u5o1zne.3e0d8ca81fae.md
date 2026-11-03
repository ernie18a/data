Calculation: Safe ATR = maximum of the previous bar’s ATR and a minimum price increment parameter.
Calculation: Relative volume = current volume divided by the median volume of the preceding volume-lookback bars; it is defined only when both are positive.
Calculation: Net progress = (close − previous close) / safe ATR.
Calculation: Rejection bias = clamp(0.65 × (lower wick − upper wick) / (high − low) + 0.35 × (2 × close − high − low) / (high − low), −1, 1); use 0 when high equals low. Lower wick = min(open, close) − low; upper wick = high − max(open, close).
Calculation: Prior range = lowest low and highest high over the range-lookback bars preceding the current bar. Low test position = clamp((current low − prior range low) / prior range span, 0, 1); high test position = clamp((current high − prior range low) / prior range span, 0, 1). Use 0.5 for both when the span is zero.
Calculation: Prior approach = (previous close − close from one plus the approach-lookback bars ago) / safe ATR. The approach and range lookbacks are independent parameters.
Calculation: Limited-progress event = relative volume ≥ volume threshold AND absolute net progress ≤ progress threshold AND (high − low) / safe ATR ≥ range threshold.
Calculation: Bullish absorption = limited-progress event AND prior approach < −approach threshold AND low test position ≤ 1 − edge threshold AND rejection bias > rejection threshold.
Calculation: Bearish absorption = limited-progress event AND prior approach > approach threshold AND high test position ≥ edge threshold AND rejection bias < −rejection threshold.
Calculation: Efficiency = EMA of net progress / sqrt(clamp(relative volume, 0.25, 4)).
Calculation: Efficiency bands = SMA of efficiency over the preceding band-lookback bars ± band multiplier × standard deviation of efficiency over those same preceding bars. The efficiency smoothing and band lookbacks are independent parameters.
Long: Bullish absorption OR (NOT bullish absorption AND NOT bearish absorption AND efficiency > 0) OR (NOT limited-progress event AND efficiency > upper efficiency band).
Short: Bearish absorption OR (NOT bullish absorption AND NOT bearish absorption AND efficiency < 0) OR (NOT limited-progress event AND efficiency < lower efficiency band).