Calculation: Prior breakout high = highest high over the selected lookback, excluding the current bar
Calculation: Relative volume = current volume / simple moving average of volume over the selected lookback, including the current bar
Calculation: Stoch RSI K = simple moving average of the stochastic value of RSI over the selected lookback
Calculation: Stoch RSI D = simple moving average of Stoch RSI K over the selected lookback
Long: abs(close - fast EMA) / close * 100 <= consolidation threshold AND close >= highest high over the selected 52-week lookback * (1 - proximity threshold / 100) AND close > prior breakout high AND relative volume >= minimum threshold AND (fast EMA crosses above slow EMA OR close > fast EMA) AND Stoch RSI K > Stoch RSI D AND Stoch RSI K < maximum threshold
Exit: Long, close crosses below slow EMA OR close crosses below fast EMA