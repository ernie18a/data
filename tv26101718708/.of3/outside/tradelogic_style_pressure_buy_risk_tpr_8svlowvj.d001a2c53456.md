Calculation: smoothed relative strength = EMA(closing price / benchmark closing price, P1)
Calculation: trend checklist score = P2 × count(closing price > EMA(closing price, P8), closing price > SMA(closing price, P9), SMA(closing price, P9) > SMA(closing price, P10), SMA(closing price, P10) > SMA(closing price, P11), SMA(closing price, P11) > SMA(closing price, P11)[P12 bars ago], smoothed relative strength > smoothed relative strength[P13 bars ago])
Calculation: trend persistence score = P3 × count(closing price > EMA(closing price, P8), closing price > SMA(closing price, P9), SMA(closing price, P9) > SMA(closing price, P10), SMA(closing price, P10) > SMA(closing price, P11), smoothed relative strength > smoothed relative strength[P14 bars ago])
Long: trend checklist score >= P4
Short: trend checklist score < P5
Long: trend persistence score >= P6
Short: trend persistence score < P7