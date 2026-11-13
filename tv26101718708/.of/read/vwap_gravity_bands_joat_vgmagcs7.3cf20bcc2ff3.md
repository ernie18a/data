Calculation: Unit = ATR(shorter-than-trend smoothing length) * step multiplier S; all conditions are evaluated on completed chart-timeframe bars
Calculation: VWAP = volume-weighted average of hlc3 computed from chart bars, reset at the start of each calendar period (day, week or month; a higher timeframe than the chart, detected by the period change); if na use hlc3
Calculation: Basis = T3 smoothing of VWAP: e1..e6 = six successive EMAs (same length) of VWAP; v = T3 factor in (0,1); Basis = c1*e6 + c2*e5 + c3*e4 + c4*e3 with c1=-v^3, c2=3v^2+3v^3, c3=-6v^2-3v-3v^3, c4=1+3v+3v^2+v^3
Calculation: Band(k) = Basis + k*Unit (upper) or Basis - k*Unit (lower); k=2 is a fixed middle band; E = expansion multiplier, R = reaction multiplier, with R > E > 1 (R lies between band 2 and band 3 or beyond)
Calculation: Slope = Basis - Basis of previous bar; Distance = (close - Basis)/Unit
Long: (close > Basis + E*Unit AND Slope > 0 AND Distance > previous bar Distance) OR (low <= Basis - R*Unit AND close > Basis - R*Unit) OR (low <= Basis - 2*Unit AND close > Basis - 2*Unit AND Slope >= -(small fraction of ATR))
Short: (close < Basis - E*Unit AND Slope < 0 AND Distance < previous bar Distance) OR (high >= Basis + R*Unit AND close < Basis + R*Unit) OR (high >= Basis + 2*Unit AND close < Basis + 2*Unit AND Slope <= small fraction of ATR)
Exit: long, high >= Basis + R*Unit AND close < Basis + R*Unit
Exit: short, low <= Basis - R*Unit AND close > Basis - R*Unit