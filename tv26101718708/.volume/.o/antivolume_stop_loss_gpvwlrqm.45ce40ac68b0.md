Calculation: VPC = volume-weighted moving average of close over the longer lookback − simple moving average of close over the longer lookback
Calculation: VPR = volume-weighted moving average of close over the shorter lookback ÷ simple moving average of close over the shorter lookback
Calculation: VM = simple moving average of volume over the shorter lookback ÷ simple moving average of volume over the longer lookback
Calculation: VPCI = VPC × VPR × VM
Calculation: AVSL = simple moving average over the longer lookback of [low − P + (deviation multiplier × VPCI × VM)], where for each bar P is the average over N bars of [low ÷ C ÷ VPR] divided by 100; N = round(|VPCI − 3|) when VPC < 0, otherwise round(VPCI + 3); C = −1 when −1 < VPC < 0, 1 when 0 ≤ VPC < 1, otherwise VPC. N is determined from the current bar, and P uses the current and preceding bars.
Exit: long, low ≤ AVSL