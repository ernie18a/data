Calculation: Fast stochastic = SMA(Stochastic(close, high, low, P1), P2)
Calculation: Slow stochastic = SMA(Fast stochastic, P3)
Calculation: Reversal signal state = if close two bars ago < prior close AND close > prior close AND Fast stochastic < Slow stochastic AND Fast stochastic > P4 then 1; else if close two bars ago > prior close AND close < prior close AND Fast stochastic > Slow stochastic AND Fast stochastic < P4 then -1; else previous state, initially 0
Calculation: Relative strength ratio average = SMA(traded instrument close / benchmark close, P5)
Calculation: Relative strength position state = if Relative strength ratio average > P6 then 1; else if Relative strength ratio average < P7 then -1; else if previous state = 1 AND Relative strength ratio average < P8 then 0; else if previous state = -1 AND Relative strength ratio average > P8 then 0; else previous state, initially 0
Calculation: Trade state = if Reversal signal state = 1 AND Relative strength position state = 1 then 1; else if Reversal signal state = -1 AND Relative strength position state = -1 then -1; else 0; invert the result when the direction reversal setting is enabled
Long: Trade state = 1
Short: Trade state = -1
Exit: Long, Trade state = 0
Exit: Short, Trade state = 0