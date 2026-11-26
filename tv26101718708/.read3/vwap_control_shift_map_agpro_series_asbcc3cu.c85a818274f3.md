Calculation: Center = VWMA(HLC3, volume if positive else 1, control lookback)
Calculation: Width = MAX(STDEV(HLC3 - Center, band lookback) * band multiplier, ATR(atr length) * ATR floor multiplier)
Calculation: Upper = Center + Width
Calculation: Lower = Center - Width
Calculation: Inside = Lower <= close AND close <= Upper
Calculation: AcceptUp = SUM(close > Upper, acceptance count) = acceptance count
Calculation: AcceptDown = SUM(close < Lower, acceptance count) = acceptance count
Calculation: AcceptSide = 1 if AcceptUp, -1 if AcceptDown, else AcceptSide[1]
Calculation: UpShift = AcceptUp AND (AcceptSide[1] != 1 OR Rejected[1])
Calculation: DownShift = AcceptDown AND (AcceptSide[1] != -1 OR Rejected[1])
Calculation: Shift = UpShift OR DownShift
Calculation: Rejection = Inside AND NOT Inside[1] AND SUM(Shift, rejection window + 1) > 0
Calculation: Rejected = NOT Shift AND (Rejected[1] OR Rejection)
Long: UpShift
Short: DownShift
Exit: long, Rejection
Exit: short, Rejection