Calculation: Darvas box upper and lower boundaries = reset every five bars; bar 1 sets upper to high and, when symmetry is enabled, lower to low; bar 2 raises upper to the maximum of itself and high; bar 3 sets lower to low if high is below upper, otherwise sets upper to high; bars 4–5 set upper to high when high is at least upper, otherwise keep upper and lower lower to the minimum of itself and low. Repeat this sequence.
Long: On the indicator timeframe’s last completed bar, close > Darvas box upper boundary from the configured number of bars earlier.
Short: On the indicator timeframe’s last completed bar, close < Darvas box lower boundary from the configured number of bars earlier.
Long: Current bar is bullish-marked AND previous bar is not bullish-marked.
Short: Current bar is bearish-marked AND previous bar is not bearish-marked.
Exit: Long, current bar is bearish-marked.
Exit: Short, current bar is bullish-marked.