Calculation: Smoothed MFI(L) = Smooth(MFI(MFI lookback), MFI smoothing method, L, MFI smoothing phase)
Calculation: Rising trend count = count of L = initial MFI smoothing lookback + i × MFI smoothing lookback increment, for i from zero through the number of MFI smoothing increments, where Smoothed MFI(L) > Smoothed MFI(L)[1]
Calculation: Falling trend count = count of L = initial MFI smoothing lookback + i × MFI smoothing lookback increment, for i from zero through the number of MFI smoothing increments, where Smoothed MFI(L) <= Smoothed MFI(L)[1]
Calculation: Smoothed rising trend count = Smooth(Rising trend count, count smoothing method, count smoothing lookback, count smoothing phase)
Calculation: Smoothed falling trend count = Smooth(Falling trend count, count smoothing method, count smoothing lookback, count smoothing phase)
Long: Smoothed rising trend count > Smoothed falling trend count
Short: Smoothed rising trend count < Smoothed falling trend count