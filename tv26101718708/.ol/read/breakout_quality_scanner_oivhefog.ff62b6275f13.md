Calculation: Prior range high = highest high over the range lookback, excluding the current bar
Calculation: Prior range low = lowest low over the range lookback, excluding the current bar
Calculation: Volume average = average volume over the volume lookback
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Candle range = high - low
Long: close > prior range high AND cooldown since the prior breakout has elapsed AND no prior breakout is still being monitored
Short: close < prior range low AND cooldown since the prior breakout has elapsed AND no prior breakout is still being monitored
Long: On the final bar of the monitoring window after a bullish breakout, close is above the breakout close adjusted by the holding tolerance AND NOT (close < open AND candle range > 0 AND upper wick / candle range >= rejection-wick threshold AND volume > prior-bar volume AND volume > volume average)
Short: On the final bar of the monitoring window after a bearish breakout, close is below the breakout close adjusted by the holding tolerance AND NOT (close > open AND candle range > 0 AND lower wick / candle range >= rejection-wick threshold AND volume > prior-bar volume AND volume > volume average)
Exit: long, during the monitoring window after a bullish breakout, (close < open AND candle range > 0 AND upper wick / candle range >= rejection-wick threshold AND volume > prior-bar volume AND volume > volume average) OR close < breakout-bar low
Exit: short, during the monitoring window after a bearish breakout, (close > open AND candle range > 0 AND lower wick / candle range >= rejection-wick threshold AND volume > prior-bar volume AND volume > volume average) OR close > breakout-bar high