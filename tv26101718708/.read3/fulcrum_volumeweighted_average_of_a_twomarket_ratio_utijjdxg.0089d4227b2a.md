Calculation: risk divisor = Nasdaq-100 volatility index close of the last completed T1 bar * 10-year Treasury yield close of the last completed T1 bar, captured at each T2 reset and held until the next reset; 1 if risk adjustment is off or either value is missing or not positive
Calculation: ratio = ratio multiplier * Nasdaq-100 close / S&P 500 close / risk divisor
Calculation: VWAP = anchored VWAP of ratio with weights w = sqrt(Nasdaq-100 volume * S&P 500 volume), anchored at each new T2 bar
Calculation: sigma = sqrt(sum(w * (ratio - VWAP)^2) / sum(w)), with w the VWAP weights, summed since the last T2 reset
Calculation: upper band(k) = VWAP + k * sigma
Calculation: lower band(k) = VWAP - k * sigma
Calculation: bands valid = observations since the last T2 reset > hide-observations parameter AND sum(w)^2 / sum(w^2) >= minimum effective N parameter AND sigma > |VWAP| * minimum dispersion parameter * 0.0001
Long: bar closed AND ratio crosses above VWAP
Short: bar closed AND ratio crosses below VWAP
Long: bar closed AND bands valid AND ratio crosses above upper band(inner band multiplier)
Long: bar closed AND bands valid AND ratio crosses above upper band(outer band multiplier)
Short: bar closed AND bands valid AND ratio crosses below lower band(inner band multiplier)
Short: bar closed AND bands valid AND ratio crosses below lower band(outer band multiplier)
Long: ratio >= VWAP
Short: ratio < VWAP