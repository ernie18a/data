Calculation: New-high marker(n) = high[n] > high[n + lookback] on T1 bars; n=0 is the forming bar and n>0 is a completed bar
Calculation: New-low marker(n) = low[n] < low[n + lookback] on T1 bars; n=0 is the forming bar and n>0 is a completed bar
Long: New-high marker(n), for each T1 bar
Short: New-low marker(n), for each T1 bar
Long: New-high marker(signal offset) AND NOT New-low marker(signal offset) AND New-low marker(signal offset + 1)
Short: New-low marker(signal offset) AND NOT New-high marker(signal offset) AND New-high marker(signal offset + 1)