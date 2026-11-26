Long: close > close[1] for every bar in the consecutive-close lookback on T1 bars, using the last completed T1 bar AND Stochastic Slow(stochastic lookback, T1 bars, last completed bar) < stochastic level
Short: close < close[1] for every bar in the consecutive-close lookback on T1 bars, using the last completed T1 bar AND Stochastic Fast(stochastic lookback, T1 bars, last completed bar) > stochastic level
Calculation: smoothed fast stochastic = SMA(Stochastic Fast(reversal stochastic lookback), first smoothing lookback)
Calculation: second smoothed stochastic = SMA(smoothed fast stochastic, second smoothing lookback)
Long: close[2] < close[1] AND close > close[1] AND smoothed fast stochastic < second smoothed stochastic AND smoothed fast stochastic > reversal level
Short: close[2] > close[1] AND close < close[1] AND smoothed fast stochastic > second smoothed stochastic AND smoothed fast stochastic < reversal level
Calculation: T1-source MACD = MACD(hl2 of the T1 bar still forming, shorter EMA lookback, longer EMA lookback, signal SMA lookback), computed on chart bars taking values from T1
Long: T1-source MACD line > T1-source MACD signal line
Short: T1-source MACD line < T1-source MACD signal line
Long: close[2] < close[1] AND close > close[1] AND smoothed fast stochastic < second smoothed stochastic AND smoothed fast stochastic > reversal level AND T1-source MACD line > T1-source MACD signal line
Short: close[2] > close[1] AND close < close[1] AND smoothed fast stochastic > second smoothed stochastic AND smoothed fast stochastic < reversal level AND T1-source MACD line < T1-source MACD signal line