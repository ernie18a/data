Calculation: Session volume profile = for the current, still-forming daily or weekly session, distribute each included bar’s volume evenly across rounded tick-size bins spanning its rounded low to rounded high; include only bars in the RTH window when RTH-only volume is enabled.
Calculation: dPOC = price bin with the greatest accumulated session volume.
Calculation: VAH and VAL = boundaries of the value area formed by starting at dPOC and adding adjacent bins in order of greater volume (upper bin first on ties) until the configured percentage of session volume is included.
Calculation: pPOC = the previous completed session’s dPOC; it is naked until a bar’s high-low range contains it.
Long: Enter the dPOC touch zone and the previous bar was outside it, and close >= dPOC.
Short: Enter the dPOC touch zone and the previous bar was outside it, and close < dPOC.
Long: Enter the VAL touch zone and the previous bar was outside it.
Short: Enter the VAH touch zone and the previous bar was outside it.
Long: Enter the pPOC touch zone and the previous bar was outside it, pPOC is naked, and close >= pPOC.
Short: Enter the pPOC touch zone and the previous bar was outside it, pPOC is naked, and close < pPOC.
Long: Close > VAH and previous close <= previous bar’s VAH.
Short: Close < VAL and previous close >= previous bar’s VAL.