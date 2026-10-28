Calculation: Quiet reading = on bars where volume is lower than the prior bar, multiply a running index by 1 + the close-to-close return; compare it with its EMA and scale the difference by the range of that EMA over a longer lookback.
Calculation: Loud reading = on bars where volume is higher than the prior bar, multiply a running index by 1 + the close-to-close return; compare it with its EMA and scale the difference by the range of that EMA over a longer lookback.
Calculation: Trend reading = (RSI + MFI + normalized Bollinger position + one third of stochastic position) / 2, using the current chart bars.
Calculation: Crowd reading = trend reading + loud reading.
Calculation: Trend average = EMA of the trend reading.
Long: quiet reading crosses above trend average AND quiet reading > 0 AND crowd reading < 0 AND close > open AND the last reported side is not long.
Short: quiet reading crosses below 0 AND crowd reading > trend reading AND crowd reading > trend average AND quiet reading < trend average AND close < open AND the last reported side is not short.