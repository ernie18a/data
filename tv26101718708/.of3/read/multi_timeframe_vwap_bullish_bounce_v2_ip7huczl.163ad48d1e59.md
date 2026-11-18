Calculation: VWAP(T) = VWAP(hlc3) calculated on T bars using the current, possibly forming bar, sampled on chart bars
Calculation: PriorClosesAboveVWAP(T) = lowest(close[1], lookback chart bars) > VWAP(T)[1]
Long: PriorClosesAboveVWAP(T1) AND low <= VWAP(T1) AND close > VWAP(T1)
Long: PriorClosesAboveVWAP(T2) AND low <= VWAP(T2) AND close > VWAP(T2)
Long: PriorClosesAboveVWAP(T1) AND low <= VWAP(T1) AND close > VWAP(T1) AND PriorClosesAboveVWAP(T2) AND low <= VWAP(T2) AND close > VWAP(T2)