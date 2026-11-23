Calculation: MA close = ALMA(close, MA length, ALMA offset, ALMA sigma) on T1 bars, where [0] is the forming T1 bar
Calculation: MA open = ALMA(open, MA length, ALMA offset, ALMA sigma) on T1 bars, where [0] is the forming T1 bar
Calculation: ATR average = WMA(True Range(T2, last completed bar), ATR length)
Calculation: Upper limit = Highest(high, ATR length)[1] - ATR average[1] * ATR multiplier
Calculation: Lower limit = Lowest(low, ATR length)[1] + ATR average[1] * ATR multiplier
Calculation: ATR trend level = Upper limit if close(T2, last completed bar) > Upper limit AND close(T2, last completed bar) > Lower limit; Lower limit if close(T2, last completed bar) < Lower limit AND close(T2, last completed bar) < Upper limit; otherwise ATR trend level[1]
Calculation: Corr input = Corr smoothing factor * close(T3, last completed bar) + (1 - Corr smoothing factor) * Corr fit[1]; updated only when a new T3 bar starts, otherwise held
Calculation: Corr width = (running sum over chart bars of Abs(Corr input - Corr band[1])) / (chart bars since start - 1) * (2 - Efficiency Ratio(Corr input, Corr length)); updated only when a new T3 bar starts, otherwise held
Calculation: Corr band = Corr input if Abs(Corr input - Corr band[1]) > Corr width, otherwise Corr band[1]; updated only when a new T3 bar starts, otherwise held
Calculation: Corr alpha = last non-NA value of Correlation(Corr input, Corr band, Corr length) * StdDev(Corr input, Corr length) / StdDev(Corr band, Corr length); updated only when a new T3 bar starts, otherwise held
Calculation: Corr fit = Corr alpha * Corr band + SMA(Corr input, Corr length) - Corr alpha * SMA(Corr band, Corr length); updated only when a new T3 bar starts, otherwise held
Calculation: Trend combination level = (ATR trend level - Corr band) * Trend combination weight + Corr band
Calculation: Trend state = 1 if close(T2, last completed bar) >= Trend combination level; -1 if close(T2, last completed bar) < Trend combination level; otherwise Trend state[1]
Long: a new T1 bar starts AND MA close[1] >= MA open[1] AND MA close[2] < MA open[2]
Short: a new T1 bar starts AND MA close[1] < MA open[1] AND MA close[2] >= MA open[2]
Long: MA close[0] > MA open[0]
Short: MA close[0] < MA open[0]
Long: Trend state[1] = 1
Short: Trend state[1] != 1
Long: Trend state[2] = 1
Short: Trend state[2] != 1