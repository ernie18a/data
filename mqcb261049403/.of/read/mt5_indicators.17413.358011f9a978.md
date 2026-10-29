Calculation: Stochastic = 100 × sum over the slowing lookback of (close − rolling period low) / sum over the same lookback of (rolling period high − rolling period low)
Calculation: Upper and lower bands = moving average of Stochastic ± its standard deviation; while bearish, cap the upper band at its prior value, and while bullish, floor the lower band at its prior value
Calculation: Trend state = bullish when Stochastic > prior upper band; bearish when Stochastic < prior lower band; otherwise retain the prior trend state
Long: Trend state is bullish AND prior trend state was not bullish
Short: Trend state is bearish AND prior trend state was not bearish