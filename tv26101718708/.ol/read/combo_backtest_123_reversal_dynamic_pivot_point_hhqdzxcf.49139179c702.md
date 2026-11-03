Calculation: Stochastic oscillator = 100 × (close − lowest low over the lookback) / (highest high over the lookback − lowest low over the lookback)
Calculation: Fast stochastic = simple moving average of the stochastic oscillator over a shorter smoothing lookback
Calculation: Slow stochastic = simple moving average of fast stochastic over a longer smoothing lookback
Calculation: 123 reversal state = 1 when close two bars ago < close one bar ago AND close > close one bar ago AND fast stochastic < slow stochastic AND fast stochastic > the level; −1 when close two bars ago > close one bar ago AND close < close one bar ago AND fast stochastic > slow stochastic AND fast stochastic < the level; otherwise retain the prior state
Calculation: Pivot = (high + low + close of the last completed higher-timeframe bar) / 3
Calculation: First resistance = Pivot + (Pivot − low of the last completed higher-timeframe bar)
Calculation: First support = Pivot − (high of the last completed higher-timeframe bar − Pivot)
Calculation: Pivot state = 1 when close > first resistance; −1 when close < first support; otherwise retain the prior state
Long: 123 reversal state = 1 AND pivot state = 1
Short: 123 reversal state = −1 AND pivot state = −1
Exit: any, NOT (123 reversal state = 1 AND pivot state = 1) AND NOT (123 reversal state = −1 AND pivot state = −1)