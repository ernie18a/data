Calculation: VPC = volume-weighted moving average of close over the longer lookback minus simple moving average of close over the same lookback
Calculation: VPR = volume-weighted moving average of close over the shorter lookback divided by simple moving average of close over the same lookback
Calculation: VM = simple moving average of volume over the shorter lookback divided by simple moving average of volume over the longer lookback
Calculation: VPCI = VPC × VPR × VM
Calculation: AVSL price component = for each bar in a window of length round(abs(VPCI − 3)) when VPC < 0, otherwise round(VPCI + 3), use low divided by VPC adjusted to −1 when −1 < VPC < 0 or +1 when 0 ≤ VPC < 1, divided by VPR; average those values and divide by 100
Calculation: AVSL deviation = standard-deviation multiplier × VPCI × VM
Calculation: AVSL = simple moving average over the longer lookback of low − AVSL price component + AVSL deviation
Exit: long, low ≤ AVSL