Calculation: Fast stochastic = stochastic %K smoothed over a shorter lookback.
Calculation: Slow stochastic = fast stochastic smoothed over a longer lookback.
Calculation: Prior-period high and low = high and low of the last completed bar of the selected higher timeframe.
Long: close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > threshold AND close > prior-period low
Short: close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < threshold AND close < prior-period high
Exit: Long, NOT (close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > threshold AND close > prior-period low) AND NOT (close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < threshold AND close < prior-period high)
Exit: Short, NOT (close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > threshold AND close > prior-period low) AND NOT (close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < threshold AND close < prior-period high)