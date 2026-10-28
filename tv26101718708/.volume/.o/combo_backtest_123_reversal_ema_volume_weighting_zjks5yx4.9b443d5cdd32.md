Calculation: Fast stochastic = SMA of 100 × (close − lowest low over its lookback) / (highest high over its lookback − lowest low over its lookback), using the shorter smoothing lookback.
Calculation: Slow stochastic = SMA of Fast stochastic using a longer smoothing lookback.
Calculation: Reversal state = 1 when close two bars ago < prior close AND current close > prior close AND Fast stochastic < Slow stochastic AND Fast stochastic > level; −1 when close two bars ago > prior close AND current close < prior close AND Fast stochastic > Slow stochastic AND Fast stochastic < level; otherwise retain the prior state, initially 0.
Calculation: Volume-weighted EMA = EMA(volume × close) / EMA(volume), using the same lookback for both EMAs.
Calculation: Volume state = 1 when Volume-weighted EMA < prior close; −1 when Volume-weighted EMA > prior close; otherwise retain the prior state, initially 0.
Long: Reverse disabled AND Reversal state = 1 AND Volume state = 1 OR Reverse enabled AND Reversal state = −1 AND Volume state = −1
Short: Reverse disabled AND Reversal state = −1 AND Volume state = −1 OR Reverse enabled AND Reversal state = 1 AND Volume state = 1
Exit: Long, NOT (Reverse disabled AND Reversal state = 1 AND Volume state = 1 OR Reverse enabled AND Reversal state = −1 AND Volume state = −1)
Exit: Short, NOT (Reverse disabled AND Reversal state = −1 AND Volume state = −1 OR Reverse enabled AND Reversal state = 1 AND Volume state = 1)