Calculation: Trend state = 1 when VWMA(T1 close from the still-forming T1 bar, VWMA lookback), evaluated on chart bars, is rising over the direction lookback; -1 when it is falling over the direction lookback; otherwise its previous value, initially 0
Long: Trend state > 0
Long: Trend state > 0 AND Trend state[1] < 0
Short: Trend state < 0
Short: Trend state < 0 AND Trend state[1] > 0