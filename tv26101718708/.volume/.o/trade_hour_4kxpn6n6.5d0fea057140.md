Calculation: Long hour = the circular mean modulo 24 of each chart bar’s hour in the selected timezone, weighted by the mean of RSI(close, L) and MFI(close, L); include all chart bars through the current bar.
Calculation: Short hour = the circular mean modulo 24 of each chart bar’s hour in the selected timezone, weighted by the mean of RSI(1/close, L) and MFI(1/close, L); include all chart bars through the current bar.
Long: round(Long hour) = current chart bar’s hour in the selected timezone
Short: round(Short hour) = current chart bar’s hour in the selected timezone