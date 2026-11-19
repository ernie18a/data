Calculation: Pivot = (highest T1 high + lowest T1 low + T1 close sampled at the first chart bar at or after the end-time parameter)/3; accumulate T1 high and low values from available chart history through that bar, using lookahead-off T1 values on chart bars (forming T1 bar in real time, completed T1 values historically)
Long: close > Pivot
Short: close < Pivot