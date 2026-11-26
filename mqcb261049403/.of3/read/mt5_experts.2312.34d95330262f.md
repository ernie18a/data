Calculation: main = Stochastic CG Oscillator main line(close, lookback, T1), read on chart bars taking T1 values ([1] last completed T1 bar; [0] still-forming T1 bar)
Calculation: signal = Stochastic CG Oscillator signal line(close, lookback, T1), read on chart bars taking T1 values ([1] last completed T1 bar; [0] still-forming T1 bar)
Long: main[1] > signal[1] AND main[0] <= signal[0]
Short: main[1] < signal[1] AND main[0] >= signal[0]
Exit: long, main[1] < signal[1]
Exit: short, main[1] > signal[1]