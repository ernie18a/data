Calculation: Structure(side, PivotLength, timeframe, last completed bar) = 1-2-3 state machine on bars of timeframe. For side bull: phase 0 -> 1 when PivotLow(low, PivotLength, PivotLength) is confirmed, with P1 = that low. In phase 1, a confirmed pivot low below P1 replaces P1, and a confirmed PivotHigh(high, PivotLength, PivotLength) above P1 sets phase 2 with P2 = that high. In phase 2, a confirmed pivot high above P2 replaces P2; a confirmed pivot low above P1 sets phase 3 with P3 = that low; a confirmed pivot low not above P1 sets phase 1 with P1 = that low. In phase 3, if high >= P3 + (P2 - P1), phase becomes 0 and PrevTarget = P3 + (P2 - P1); otherwise, if close < P1, Broken = true, and if Broken is true and a pivot low is confirmed, phase becomes 1 with P1 = that low and PrevTarget = P3 + (P2 - P1). Broken is cleared when phase leaves 3. For side bear, swap pivot highs with pivot lows, high with low, and each comparison with its opposite. Outputs: Phase, P1, P2, P3, Broken, PrevTarget.
Calculation: Intersect(side, PivotLength, IsectTol, timeframe, last completed bar) = Structure(side).Phase = 3 AND Structure(opposite side).Phase >= 2 AND abs(Target - Mid) / Mid < IsectTol / 100, where Target = P3 + (P2 - P1) of Structure(side) and Mid = (P1 + P2) / 2 of Structure(opposite side).
Calculation: Propagate(side, PivotLength, IsectTol, PropFactor, timeframe, last completed bar) = Structure(side).Phase >= 1 AND abs(P1 - PrevTarget) / PrevTarget < PropFactor * IsectTol / 100, with P1 and PrevTarget of Structure(side).
Long: Structure(bull, PivotLength, T1, last completed bar).Phase >= 1
Short: Structure(bear, PivotLength, T1, last completed bar).Phase >= 1
Long: Intersect(bull, PivotLength, IsectTol, T1, last completed bar) = true
Short: Intersect(bear, PivotLength, IsectTol, T1, last completed bar) = true
Long: Propagate(bull, PivotLength, IsectTol, PropFactor, T1, last completed bar) = true
Short: Propagate(bear, PivotLength, IsectTol, PropFactor, T1, last completed bar) = true
Exit: long, Structure(bull, PivotLength, T1, last completed bar).Broken = true
Exit: short, Structure(bear, PivotLength, T1, last completed bar).Broken = true
Long: Structure(bull, PivotLength, T2, last completed bar).Phase >= 1
Short: Structure(bear, PivotLength, T2, last completed bar).Phase >= 1
Long: Intersect(bull, PivotLength, IsectTol, T2, last completed bar) = true
Short: Intersect(bear, PivotLength, IsectTol, T2, last completed bar) = true
Long: Propagate(bull, PivotLength, IsectTol, PropFactor, T2, last completed bar) = true
Short: Propagate(bear, PivotLength, IsectTol, PropFactor, T2, last completed bar) = true
Exit: long, Structure(bull, PivotLength, T2, last completed bar).Broken = true
Exit: short, Structure(bear, PivotLength, T2, last completed bar).Broken = true
Long: Structure(bull, PivotLength, T3, last completed bar).Phase >= 1
Short: Structure(bear, PivotLength, T3, last completed bar).Phase >= 1
Long: Intersect(bull, PivotLength, IsectTol, T3, last completed bar) = true
Short: Intersect(bear, PivotLength, IsectTol, T3, last completed bar) = true
Long: Propagate(bull, PivotLength, IsectTol, PropFactor, T3, last completed bar) = true
Short: Propagate(bear, PivotLength, IsectTol, PropFactor, T3, last completed bar) = true
Exit: long, Structure(bull, PivotLength, T3, last completed bar).Broken = true
Exit: short, Structure(bear, PivotLength, T3, last completed bar).Broken = true
Long: Structure(bull, PivotLength, T1, last completed bar).Phase = 2 AND Structure(bull, PivotLength, T1, last completed bar).Phase[1] != 2
Long: Structure(bull, PivotLength, T1, last completed bar).Phase = 3 AND Structure(bull, PivotLength, T1, last completed bar).Phase[1] != 3
Short: Structure(bear, PivotLength, T1, last completed bar).Phase = 2 AND Structure(bear, PivotLength, T1, last completed bar).Phase[1] != 2
Short: Structure(bear, PivotLength, T1, last completed bar).Phase = 3 AND Structure(bear, PivotLength, T1, last completed bar).Phase[1] != 3
Long: Intersect(bull, PivotLength, IsectTol, T1, last completed bar) = true AND Intersect(bull, PivotLength, IsectTol, T1, last completed bar)[1] = false AND Intersect(bear, PivotLength, IsectTol, T1, last completed bar)[1] = false
Short: Intersect(bear, PivotLength, IsectTol, T1, last completed bar) = true AND Intersect(bull, PivotLength, IsectTol, T1, last completed bar)[1] = false AND Intersect(bear, PivotLength, IsectTol, T1, last completed bar)[1] = false
Long: Propagate(bull, PivotLength, IsectTol, PropFactor, T1, last completed bar) = true AND Propagate(bull, PivotLength, IsectTol, PropFactor, T1, last completed bar)[1] = false AND Propagate(bear, PivotLength, IsectTol, PropFactor, T1, last completed bar)[1] = false
Short: Propagate(bear, PivotLength, IsectTol, PropFactor, T1, last completed bar) = true AND Propagate(bull, PivotLength, IsectTol, PropFactor, T1, last completed bar)[1] = false AND Propagate(bear, PivotLength, IsectTol, PropFactor, T1, last completed bar)[1] = false