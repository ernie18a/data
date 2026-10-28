Calculation: Fast stochastic = SMA of the chart-bar stochastic oscillator over a smoothing lookback
Calculation: Slow stochastic = SMA of Fast stochastic over an additional smoothing lookback
Calculation: Chart-bar stochastic oscillator = 100 × (close − lowest low over its lookback) ÷ (highest high over its lookback − lowest low over its lookback)
Calculation: Reversal state = 1 when close two bars ago < close one bar ago AND current close > close one bar ago AND Fast stochastic < Slow stochastic AND Fast stochastic > the level; −1 when close two bars ago > close one bar ago AND current close < close one bar ago AND Fast stochastic > Slow stochastic AND Fast stochastic < the level; otherwise retain the prior state, initially 0
Calculation: PVO = 100 × (EMA of volume over the shorter lookback − EMA of volume over the longer lookback) ÷ EMA of volume over the longer lookback
Calculation: PVO state = 1 when PVO > its signal EMA; −1 when PVO < its signal EMA; otherwise retain the prior state, initially 0
Calculation: Combined state = 1 when Reversal state = 1 AND PVO state = 1; −1 when Reversal state = −1 AND PVO state = −1; otherwise 0
Calculation: Trade state = Combined state when reverse mode is off; −Combined state when reverse mode is on
Long: Trade state = 1
Short: Trade state = −1
Exit: long, Trade state = 0
Exit: short, Trade state = 0