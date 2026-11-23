Calculation: ResidualStdDev = sqrt(sum over j = 0..L-1 of (Src[j] - LinReg(Src, L, j))^2 / L)
Calculation: UpperBand = LinReg(Src, L, 0) + (KU * ResidualStdDev if BU is true, else max(0, max over j = 0..L-1 of (High[j] - LinReg(Src, L, j))))
Calculation: LowerBand = LinReg(Src, L, 0) - (KL * ResidualStdDev if BL is true, else max(0, max over j = 0..L-1 of (LinReg(Src, L, j) - Low[j])))
Calculation: BuyShare = (sum over j = 0..L-1 of Volume[j] where High[j] > Low[j] and Close[j] >= Open[j]) / (sum over j = 0..L-1 of Volume[j] where High[j] > Low[j]), or Tb if the denominator is 0
Calculation: PercentB = (close - LowerBand) / (UpperBand - LowerBand)
Long: LinRegSlope(Src, L) > 0
Short: LinRegSlope(Src, L) <= 0
Long: close > UpperBand
Short: close < LowerBand
Long: BuyShare > Tb
Short: BuyShare <= Tb
Long: UpperBand > LowerBand AND PercentB >= Tu
Short: UpperBand > LowerBand AND PercentB <= Tl