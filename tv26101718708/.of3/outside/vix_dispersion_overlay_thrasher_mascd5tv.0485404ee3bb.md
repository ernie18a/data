Calculation: VIX dispersion = Standard Deviation(VIX closing price, P1 chart bars)
Calculation: VVIX dispersion = Standard Deviation(VVIX closing price, P1 chart bars)
Exit: long, VIX dispersion <= P2 AND VVIX dispersion > P3
Exit: long, VVIX dispersion <= P3 AND VIX dispersion > P2
Short: VIX dispersion <= P2 AND VVIX dispersion <= P3 AND (bars since previous combined condition >= P4 OR VIX3M closing price - VIX closing price < 0)