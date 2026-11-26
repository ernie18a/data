Calculation: DirectionalVolume = volume when a T1 bar's close is above its previous T1 close, −volume when below, and 0 when equal.
Calculation: RawPressure = Scale × summed DirectionalVolume divided by summed volume across the current T2 bucket and up to FlowWindow − 1 most recent completed T2 buckets; include only T1 bars in Session, and set RawPressure to 0 when the chart bar is outside Session or the summed volume is 0. Evaluate on chart bars using all available T1 bars, including any still forming, and include the current, potentially still-forming T2 bucket.
Calculation: Pressure = EMA(RawPressure, SmoothingLength), evaluated on chart bars.
Long: Pressure > 0
Long: Pressure crosses above 0
Long: Pressure < 0 AND Pressure > Pressure[1] AND Pressure[1] > Pressure[2]
Long: Pressure crosses above PressureThreshold
Short: Pressure < 0
Short: Pressure crosses below 0
Short: Pressure > 0 AND Pressure < Pressure[1] AND Pressure[1] < Pressure[2]
Short: Pressure crosses below −PressureThreshold