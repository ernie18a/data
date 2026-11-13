Calculation: Fractal(n) = a bar whose low (high-type: high) is the lowest (highest) among the n bars before it and n bars after it, itself included; the same n is used for both types; candidates start 2 bars back from the forming bar (shift 0), so the n newer bars include the forming bar. Computed on bars of a timeframe lower than or equal to the chart timeframe; shift 0 is the bar still forming.
Calculation: FractalLine = line through the most recent Fractal (bar k1, price p1) and the next older Fractal of the same type as the most recent one (bar k2, price p2), ignoring opposite-type Fractals; slope m = (p2-p1)/(k2-k1) per bar going back in time; value at shift s = p1 + m*(s-k1)
Calculation: ParallelLine = line with the same slope m as FractalLine and value c + m*s at shift s, where c = min over shifts s=2..k2 of (low[s] - m*s) if the Fractals are high-type, or max over shifts s=2..k2 of (high[s] - m*s) if the Fractals are low-type
Calculation: Upper, Lower = whichever of FractalLine and ParallelLine has the higher (Upper) or lower (Lower) value at the current bar (shift 0)
Calculation: Flat = abs(m) * N < K * ATR(M), where ATR(M) is computed on the same bars, N is a fixed number of bars, K is a coefficient, and M is the ATR period
Calculation: SlopeDown = m > 0 (channel falls over time); SlopeUp = m <= 0
Long: (Flat OR SlopeUp) AND current bar low <= Lower
Short: (Flat OR SlopeDown) AND current bar high >= Upper
Exit: long, NOT Flat AND SlopeUp AND current bar high >= Upper
Exit: short, NOT Flat AND SlopeDown AND current bar low <= Lower