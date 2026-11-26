Calculation: Shorter indicator = selected ROC/Momentum indicator(close, shorter lookback 1, type 1, T1 bars; sampled at signal-bar shift n, which may be forming or completed)
Calculation: Longer indicator = selected ROC/Momentum indicator(close, longer lookback 2, type 2, T1 bars; sampled at signal-bar shift n, which may be forming or completed)
Calculation: Signal-up = Shorter indicator when inversion is off, otherwise Longer indicator
Calculation: Signal-down = Longer indicator when inversion is off, otherwise Shorter indicator
Long: long-entry permission is enabled AND Signal-up[n+1] > Signal-down[n+1] AND Signal-up[n] <= Signal-down[n]
Short: short-entry permission is enabled AND Signal-up[n+1] < Signal-down[n+1] AND Signal-up[n] >= Signal-down[n]
Exit: short, short-exit permission is enabled AND Signal-up[n+1] > Signal-down[n+1] AND (long-entry permission is disabled OR Signal-up[n] > Signal-down[n])
Exit: long, long-exit permission is enabled AND Signal-up[n+1] < Signal-down[n+1] AND (short-entry permission is disabled OR Signal-up[n] < Signal-down[n])