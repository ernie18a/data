Long: close is higher than the preceding close on each bar of the consecutive-bar lookback parameter on T1 AND Slow Stochastic(close, high, low, textual stochastic lookback parameter, T1) < textual level parameter
Short: close is lower than the preceding close on each bar of the consecutive-bar lookback parameter on T1 AND Fast Stochastic(close, high, low, textual stochastic lookback parameter, T1) > textual level parameter
Calculation: Reversal signal = on chart bars, +1 when close[reversal lookback parameter] < close[1] AND close > close[1] AND Fast Stochastic(close, high, low, stochastic lookback parameter, fast smoothing parameter) < Slow Stochastic(close, high, low, same stochastic lookback and fast smoothing parameters, slow smoothing parameter) AND Fast Stochastic(close, high, low, stochastic lookback parameter, fast smoothing parameter) > level parameter; -1 when close[reversal lookback parameter] > close[1] AND close < close[1] AND Fast Stochastic(close, high, low, stochastic lookback parameter, fast smoothing parameter) > Slow Stochastic(close, high, low, same stochastic lookback and fast smoothing parameters, slow smoothing parameter) AND Fast Stochastic(close, high, low, stochastic lookback parameter, fast smoothing parameter) < level parameter; otherwise retain prior value, initially 0
Long: Reversal signal = +1
Short: Reversal signal = -1
Calculation: Boundary signal = on chart bars using the last completed T2 bar, set -1 when the boundary-mode parameter selects outer levels and chart high <= T2 low, or when it selects inner levels and chart high <= T2 high; otherwise set +1 when the parameter selects outer levels and chart low >= T2 high, or when it selects inner levels and chart low >= T2 low; otherwise retain prior value, initially 0
Long: Boundary signal = +1
Short: Boundary signal = -1
Calculation: Combined signal = +1 when Reversal signal = +1 AND Boundary signal = +1; -1 when Reversal signal = -1 AND Boundary signal = -1; otherwise 0
Long: (direction-reversal parameter preserves direction AND Combined signal = +1) OR (direction-reversal parameter reverses direction AND Combined signal = -1)
Short: (direction-reversal parameter preserves direction AND Combined signal = -1) OR (direction-reversal parameter reverses direction AND Combined signal = +1)
Exit: long, Combined signal = 0
Exit: short, Combined signal = 0