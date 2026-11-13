Calculation: SMA_S[k], SMA_L[k] = simple moving average of close, using the same lookback for both. SMA_S is computed on bars of the shorter timeframe (equal to the chart timeframe) and SMA_L on bars of the longer timeframe (higher than the chart timeframe). Evaluate only at the open of each new chart bar. k=1 is the last completed bar of that timeframe at that moment and k=2 is the completed bar before it. The still-forming bar is never used.
Long: SMA_S[1] > SMA_S[2] AND SMA_L[1] > SMA_L[2]
Short: SMA_S[1] < SMA_S[2] AND SMA_L[1] < SMA_L[2]
Exit: long, SMA_S[1] < SMA_S[2] OR SMA_L[1] < SMA_L[2]
Exit: short, SMA_S[1] > SMA_S[2] OR SMA_L[1] > SMA_L[2]