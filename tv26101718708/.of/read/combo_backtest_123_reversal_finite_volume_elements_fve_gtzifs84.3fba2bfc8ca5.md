Calculation: Fast stochastic = SMA of the stochastic oscillator over a shorter lookback; stochastic oscillator = 100 × (close − lowest low) / (highest high − lowest low)
Calculation: Slow stochastic = SMA of Fast stochastic over a longer lookback
Calculation: Reversal state = 1 when close[2] < close[1] AND close > close[1] AND Fast stochastic < Slow stochastic AND Fast stochastic > the stochastic level; −1 when close[2] > close[1] AND close < close[1] AND Fast stochastic > Slow stochastic AND Fast stochastic < the stochastic level; otherwise retain the prior state (initially 0)
Calculation: Volume flow = close − (high + low) / 2 + (high + low + close) / 3 − prior bar’s (high + low + close) / 3
Calculation: Signed volume = volume when Volume flow > the factor × close / 100; −volume when Volume flow < −factor × close / 100; otherwise 0
Calculation: Cumulative volume element = prior cumulative volume element + ((Signed volume / SMA(volume, lookback)) / lookback) × 100 (initially 0)
Calculation: Volume state = 1 when Cumulative volume element > its prior-bar and two-bars-prior values; −1 when it is less than both; otherwise retain the prior state (initially 0)
Long: Reversal state = 1 AND Volume state = 1
Short: Reversal state = −1 AND Volume state = −1
Exit: long, Reversal state ≠ 1 OR Volume state ≠ 1 AND Reversal state ≠ −1 OR Volume state ≠ −1
Exit: short, Reversal state ≠ 1 OR Volume state ≠ 1 AND Reversal state ≠ −1 OR Volume state ≠ −1