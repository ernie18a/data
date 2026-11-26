Calculation: HMA change = HMA(close, HMA lookback, T1 bars) − HMA(close, HMA lookback, T1 bars)[1], evaluated at the signal-offset bar (still forming at offset zero; completed otherwise)
Calculation: HMA-change standard deviation = StdDev(HMA change, deviation lookback, T1 bars), evaluated at the signal-offset bar
Long: HMA change > 0
Long: HMA change > first deviation multiplier × HMA-change standard deviation AND HMA change <= second deviation multiplier × HMA-change standard deviation
Long: HMA change > second deviation multiplier × HMA-change standard deviation
Long: HMA(close, HMA lookback, T1 bars)[signal offset + 2] > HMA(close, HMA lookback, T1 bars)[signal offset + 1] AND HMA(close, HMA lookback, T1 bars)[signal offset + 1] < HMA(close, HMA lookback, T1 bars)[signal offset]
Short: HMA change < 0
Short: HMA change < −first deviation multiplier × HMA-change standard deviation AND HMA change >= −second deviation multiplier × HMA-change standard deviation
Short: HMA change < −second deviation multiplier × HMA-change standard deviation
Short: HMA(close, HMA lookback, T1 bars)[signal offset + 2] < HMA(close, HMA lookback, T1 bars)[signal offset + 1] AND HMA(close, HMA lookback, T1 bars)[signal offset + 1] > HMA(close, HMA lookback, T1 bars)[signal offset]
Exit: long, HMA change < 0
Exit: short, HMA change > 0