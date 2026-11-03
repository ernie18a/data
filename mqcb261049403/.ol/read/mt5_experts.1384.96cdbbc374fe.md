Calculation: +DI = smooth(100 × positive directional movement / true range), using the same smoothing settings as −DI; positive directional movement is the current high rise from the previous high only when it is positive and greater than the current low’s fall from the previous low, otherwise zero
Calculation: −DI = smooth(100 × negative directional movement / true range), using the same smoothing settings as +DI; negative directional movement is the current low’s fall from the previous low only when it is positive and greater than the current high’s rise from the previous high, otherwise zero
Calculation: ADX = smooth(100 × |(+DI − −DI) / (+DI + −DI)|), or zero when +DI + −DI is zero
Long: +DI > −DI OR, on the indicator timeframe’s last completed bar, +DI > −DI AND on the preceding completed bar +DI ≤ −DI AND ADX > the trend-strength threshold
Short: +DI < −DI OR, on the indicator timeframe’s last completed bar, +DI < −DI AND on the preceding completed bar +DI ≥ −DI AND ADX > the trend-strength threshold
Exit: long, +DI < −DI on the indicator timeframe’s last completed bar
Exit: short, +DI > −DI on the indicator timeframe’s last completed bar