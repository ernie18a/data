Calculation: MA slope percentage = 100 * (SMA(close, MA lookback, T1 selected bar) - SMA(close, MA lookback, T1 bar MA slope lookback bars earlier)) / SMA(close, MA lookback, T1 bar MA slope lookback bars earlier), using the last completed T1 bar when the confirmed-bar parameter is on, otherwise the T1 bar still forming
Calculation: Stage = on chart bars using T1 values, Stage 2 if T1 close > SMA(close, MA lookback, T1 selected bar) AND MA slope percentage > flat threshold; Stage 4 if T1 close < SMA(close, MA lookback, T1 selected bar) AND MA slope percentage < -flat threshold; otherwise Stage 1 if the most recent directional stage is not Stage 2, else Stage 3
Long: Stage = 2
Long: Stage = 2 AND previous chart bar Stage != 2
Short: Stage = 4
Short: Stage = 4 AND previous chart bar Stage != 4
Exit: long, Stage = 3
Exit: long, Stage = 3 AND previous chart bar Stage != 3