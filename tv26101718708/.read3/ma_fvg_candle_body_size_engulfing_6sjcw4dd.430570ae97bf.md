Long: open <= close[1] AND open < open[1] AND close > open[1]
Short: open >= close[1] AND open > open[1] AND close < open[1]
Long: FVG display enabled AND low(T1, current bar, sampled on chart bars with lookahead off; still forming in real time) > high(T1, two bars ago)
Short: FVG display enabled AND high(T1, current bar, sampled on chart bars with lookahead off; still forming in real time) < low(T1, two bars ago)