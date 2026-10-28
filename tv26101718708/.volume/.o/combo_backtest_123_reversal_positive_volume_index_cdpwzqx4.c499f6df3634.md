Calculation: Fast stochastic = simple moving average of stochastic %K
Calculation: Slow stochastic = simple moving average of Fast stochastic
Calculation: Reversal direction = +1 when the close two bars ago < the previous close AND the current close > the previous close AND Fast stochastic < Slow stochastic AND Fast stochastic > level; -1 when the close two bars ago > the previous close AND the current close < the previous close AND Fast stochastic > Slow stochastic AND Fast stochastic < level; otherwise retain the previous direction
Calculation: Positive-volume cumulative index = previous index + current close percentage change when current volume > previous volume; otherwise previous index
Calculation: Positive-volume index direction = +1 when the index > its EMA; -1 when the index < its EMA; otherwise retain the previous direction
Long: Reversal direction = +1 AND Positive-volume index direction = +1
Short: Reversal direction = -1 AND Positive-volume index direction = -1
Exit: any, NOT (Reversal direction = +1 AND Positive-volume index direction = +1) AND NOT (Reversal direction = -1 AND Positive-volume index direction = -1)