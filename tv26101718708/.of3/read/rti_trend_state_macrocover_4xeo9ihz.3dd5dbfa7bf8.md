Calculation: RTI on chart bars = EMA(100 * (close - lowest(low, range lookback)) / (highest(high, range lookback) - lowest(low, range lookback)), smoothing lookback)
Calculation: RTI base state on chart bars = 1 when RTI > upper band, -1 when RTI < lower band, otherwise its previous value, initially 0
Calculation: AlphaTrend state on T1 bars = 1 on crossover of the AlphaTrend line above its value comparison lag bars ago, -1 on crossunder, otherwise its previous value, initially 0; the line initializes to hl2, then holds its prior value when momentum is unavailable, otherwise takes the maximum of its prior value and low - SMA(TrueRange, ATR lookback) * ATR multiplier when momentum is at least the momentum midpoint, or the minimum of its prior value and high + SMA(TrueRange, ATR lookback) * ATR multiplier otherwise; momentum is MFI(hlc3, momentum lookback) when SMA(volume, volume lookback) is positive, otherwise RSI(close, momentum lookback)
Calculation: RTI state on chart bars = 0 when (MacroCover is enabled and RTI base state < 0 and close > EMA(close, macro lookback)) or (T1 gate is enabled and RTI base state is nonzero and the AlphaTrend state on the last completed T1 bar has the opposite sign); otherwise RTI base state
Calculation: Laguerre state on chart bars = sign of the 4-pole Ehlers Laguerre filter(close, gamma) minus its value slope lookback bars ago when the difference is nonzero, otherwise its previous value, initially 0; set to 0 when MacroCover is enabled, Laguerre state is negative, and close > EMA(close, macro lookback)
Long: RTI state > 0
Short: RTI state < 0
Long: RTI state > 0 AND RTI state[1] <= 0
Short: RTI state < 0 AND RTI state[1] >= 0
Exit: Long, RTI state = 0 AND RTI state[1] > 0
Exit: Short, RTI state = 0 AND RTI state[1] < 0
Long: Laguerre is enabled AND Laguerre state > 0
Short: Laguerre is enabled AND Laguerre state < 0
Exit: Short, Laguerre is enabled AND Laguerre state = 0 AND Laguerre state[1] < 0
Long: AlphaTrend state on the last completed T1 bar > 0
Short: AlphaTrend state on the last completed T1 bar < 0
Long: Laguerre is enabled AND RTI state > 0 AND Laguerre state > 0
Short: Laguerre is enabled AND RTI state < 0 AND Laguerre state < 0