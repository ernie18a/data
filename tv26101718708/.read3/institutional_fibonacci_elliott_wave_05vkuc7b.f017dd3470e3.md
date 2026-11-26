Calculation: SwingHigh(L1) = value of the most recent PivotHigh(high, L1, L1)
Calculation: SwingLow(L1) = value of the most recent PivotLow(low, L1, L1)
Calculation: Grid(L1) = Bullish if the most recent confirmed pivot among PivotHigh(high, L1, L1) and PivotLow(low, L1, L1) is a high, otherwise Bearish
Calculation: Retracement(K, L1) = SwingHigh(L1) - K * (SwingHigh(L1) - SwingLow(L1)) if Grid(L1) = Bullish, otherwise SwingLow(L1) + K * (SwingHigh(L1) - SwingLow(L1))
Calculation: Extension(E, L1) = SwingLow(L1) + E * (SwingHigh(L1) - SwingLow(L1)) if Grid(L1) = Bullish, otherwise SwingHigh(L1) - E * (SwingHigh(L1) - SwingLow(L1))
Calculation: ImpulsePhase(L2) = Bullish if the last six confirmed pivots of PivotHigh(high, L2, L2) and PivotLow(low, L2, L2), ordered oldest first as p0 to p5, alternate low, high, low, high, low, high AND p2 > p0 AND p3 - p2 >= p1 - p0 AND p3 - p2 >= p5 - p4 AND p4 > p1; Bearish if they alternate high, low, high, low, high, low AND p2 < p0 AND p2 - p3 >= p0 - p1 AND p2 - p3 >= p4 - p5 AND p4 < p1; otherwise ImpulsePhase(L2)[1]
Long: Grid(L1) = Bullish AND close crosses below Retracement(K, L1)
Short: Grid(L1) = Bearish AND close crosses below Retracement(K, L1)
Exit: long, Grid(L1) = Bullish AND close crosses above Extension(E1, L1)
Exit: long, Grid(L1) = Bullish AND close crosses above Extension(E2, L1)
Exit: long, Grid(L1) = Bullish AND close crosses above Extension(E3, L1)
Exit: short, Grid(L1) = Bearish AND close crosses above Extension(E1, L1)
Exit: short, Grid(L1) = Bearish AND close crosses above Extension(E2, L1)
Exit: short, Grid(L1) = Bearish AND close crosses above Extension(E3, L1)
Long: ImpulsePhase(L2) = Bullish
Short: ImpulsePhase(L2) = Bearish