Calculation: Fast stochastic = the stochastic oscillator of close, high, and low, smoothed by a shorter simple moving average
Calculation: Slow stochastic = a longer simple moving average of the fast stochastic
Calculation: 123 reversal state = 1 when close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > level; -1 when close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < level; otherwise retain the previous state
Calculation: D_ELI = EMA(hl2 from the higher daily timeframe’s last completed bar, length) - EMA(hl2 from the higher daily timeframe’s last completed bar, twice the length) - EMA(the difference of those EMAs, length)
Long: close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > level OR D_ELI > 0
Short: close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < level OR D_ELI < 0
Long: 123 reversal state = 1 AND D_ELI > 0
Short: 123 reversal state = -1 AND D_ELI < 0
Exit: long, 123 reversal state != 1 OR D_ELI <= 0
Exit: short, 123 reversal state != -1 OR D_ELI >= 0