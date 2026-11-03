Calculation: Smoothed stochastic = 100 × (close − lowest low over a lookback) ÷ (highest high over the same lookback − lowest low over the same lookback), smoothed with a shorter lookback
Calculation: Slow stochastic = smoothed stochastic smoothed with a longer lookback
Calculation: 123 signal state = 1 when close two bars ago < previous close AND close > previous close AND smoothed stochastic < slow stochastic AND smoothed stochastic > a threshold; −1 when close two bars ago > previous close AND close < previous close AND smoothed stochastic > slow stochastic AND smoothed stochastic < the threshold; otherwise retain the previous state, initially 0
Calculation: Pivot = (previous completed higher-timeframe bar high + low + close) ÷ 3
Calculation: First resistance = 2 × pivot − previous completed higher-timeframe bar low
Calculation: First support = 2 × pivot − previous completed higher-timeframe bar high
Calculation: Pivot signal state = 1 when close > first resistance; −1 when close < first support; otherwise retain the previous state, initially 0
Long: 123 signal state = 1 AND pivot signal state = 1
Short: 123 signal state = −1 AND pivot signal state = −1
Exit: long, 123 signal state ≠ 1 OR pivot signal state ≠ 1
Exit: short, 123 signal state ≠ −1 OR pivot signal state ≠ −1