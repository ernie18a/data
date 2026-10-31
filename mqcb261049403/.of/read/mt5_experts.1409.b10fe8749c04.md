Calculation: Oscillator = for each bar, let N be the lookback; B = highest high over the N bars ending at that bar minus lowest low over the preceding N bars, and S = highest high over the preceding N bars minus lowest low over the N bars ending at that bar. Raw value = 200 × (B − S) / (B + S), or zero if B + S = 0. Smooth the raw values with six successive EMAs using alpha = 2 / (1 + (1 + smoothing length) / 2), each seeded with the first raw value. With b = curvature parameter / 100 and E3 through E6 the third through sixth EMA outputs, oscillator = −b³ × E6 + 3(b² + b³) × E5 − 3(2b² + b + b³) × E4 + (1 + 3b + 3b² + b³) × E3. Calculate on the selected indicator timeframe, which may be higher or lower than the chart timeframe; the signal bar can be the last completed bar or the still-forming bar. Previous values refer to preceding indicator-timeframe bars.
Long: mode = oscillator direction change AND oscillator > previous oscillator AND previous oscillator <= oscillator two bars ago
Long: mode = level breakthrough AND oscillator > upper level AND previous oscillator <= upper level
Short: mode = oscillator direction change AND oscillator < previous oscillator AND previous oscillator >= oscillator two bars ago
Short: mode = level breakthrough AND oscillator < lower level AND previous oscillator >= lower level
Exit: long, mode = oscillator direction change AND oscillator < previous oscillator
Exit: short, mode = oscillator direction change AND oscillator > previous oscillator
Exit: short, mode = level breakthrough AND oscillator > lower level
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance