Calculation: Reversal state = 1 when close[longer close lag] < close[shorter close lag] AND close > close[shorter close lag] AND Stochastic Fast(stochastic lookback, fast smoothing) < Stochastic Slow(stochastic lookback, fast smoothing, slow smoothing) AND Stochastic Fast(stochastic lookback, fast smoothing) > stochastic level; -1 when close[longer close lag] > close[shorter close lag] AND close < close[shorter close lag] AND Stochastic Fast(stochastic lookback, fast smoothing) > Stochastic Slow(stochastic lookback, fast smoothing, slow smoothing) AND Stochastic Fast(stochastic lookback, fast smoothing) < stochastic level; otherwise its previous value, initially 0; longer close lag > shorter close lag
Calculation: Volume-up ROC index = its previous value + ROC(close, ROC lookback) when volume > volume[volume comparison lag], otherwise its previous value; initially 0
Calculation: Synchronized signal = 1 when Reversal state = 1 AND Volume-up ROC index > EMA(Volume-up ROC index, EMA lookback); -1 when Reversal state = -1 AND Volume-up ROC index < EMA(Volume-up ROC index, EMA lookback); otherwise 0
Calculation: Trade signal = Synchronized signal when the direction-reversal parameter preserves direction, otherwise -Synchronized signal
Long: Trade signal = 1
Short: Trade signal = -1
Exit: long, Trade signal = 0
Exit: short, Trade signal = 0