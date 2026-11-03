Calculation: Fast stochastic = the short-term simple moving average of %K, where %K = 100 × (close − lowest low over the lookback) / (highest high over the lookback − lowest low over the lookback)
Calculation: Slow stochastic = the longer-term simple moving average of Fast stochastic
Calculation: 123 reversal state = 1 when close two bars ago < prior close AND current close > prior close AND Fast stochastic < Slow stochastic AND Fast stochastic > the threshold; −1 when close two bars ago > prior close AND current close < prior close AND Fast stochastic > Slow stochastic AND Fast stochastic < the threshold; otherwise retain the previous state, initially 0
Calculation: PVO = 100 × (short-term EMA of volume − long-term EMA of volume) / long-term EMA of volume
Calculation: PVO state = −1 when PVO > its signal EMA; 1 when PVO < its signal EMA; otherwise retain the previous state, initially 0
Long: 123 reversal state = 1 AND PVO state = 1
Short: 123 reversal state = −1 AND PVO state = −1
Exit: long, 123 reversal state ≠ 1 OR PVO state ≠ 1
Exit: short, 123 reversal state ≠ −1 OR PVO state ≠ −1