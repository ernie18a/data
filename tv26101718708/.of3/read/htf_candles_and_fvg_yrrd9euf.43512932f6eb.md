Calculation: newT1Bar = datetime of last completed T1 bar differs from datetime of last completed T1 bar on previous chart bar
Calculation: upGap = low(T1)[0] > high(T1)[2]
Calculation: downGap = high(T1)[0] < low(T1)[2]
Calculation: upMitPrice = low(T1)[0] if P1 is wick, else close(T1)[0]
Calculation: downMitPrice = high(T1)[0] if P1 is wick, else close(T1)[0]
Calculation: openUpGapBottom = maximum of high(T1)[k+2] over all k >= 1 with upGap[k] AND upMitPrice[m] > high(T1)[k+2] for all 1 <= m < k, or negative infinity if no k qualifies
Calculation: openDownGapTop = minimum of low(T1)[k+2] over all k >= 1 with downGap[k] AND downMitPrice[m] < low(T1)[k+2] for all 1 <= m < k, or positive infinity if no k qualifies
Long: newT1Bar AND upGap
Short: newT1Bar AND downGap
Long: newT1Bar AND upMitPrice <= openUpGapBottom
Short: newT1Bar AND downMitPrice >= openDownGapTop