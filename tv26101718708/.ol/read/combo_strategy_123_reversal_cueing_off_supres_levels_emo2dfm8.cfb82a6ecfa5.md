Calculation: Fast Stochastic = simple moving average of the Stochastic %K over a shorter lookback
Calculation: Slow Stochastic = simple moving average of Fast Stochastic over a longer lookback
Long: close[2] < close[1] AND close > close[1] AND Fast Stochastic < Slow Stochastic AND Fast Stochastic > Level AND low >= the previous completed higher-timeframe weekly high
Short: close[2] > close[1] AND close < close[1] AND Fast Stochastic > Slow Stochastic AND Fast Stochastic < Level AND high <= the previous completed higher-timeframe weekly low