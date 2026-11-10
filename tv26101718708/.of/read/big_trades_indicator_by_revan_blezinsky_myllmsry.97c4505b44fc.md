Calculation: Buy direction = for the selected direction method: close > open OR (close = open AND close >= previous close); OR close > (high + low) / 2 OR (close = (high + low) / 2 AND close >= previous close); OR close > previous close OR (close = previous close AND close >= open), respectively. Treat an unavailable comparison as false.
Calculation: Volume ratio = volume / simple moving average of volume when that average > 0; otherwise 0.
Calculation: Volatility factor = clamp ATR / close divided by the simple moving average of ATR / close to [0.5, 2.0]; use 0 for ATR / close when close <= 0, and use 1 for the ratio when its average is not > 0.
Calculation: Effective spike threshold = spike threshold multiplied by volatility factor when dynamic scaling is selected; otherwise spike threshold.
Calculation: Effective extreme threshold = extreme threshold multiplied by volatility factor when dynamic scaling is selected; otherwise extreme threshold.
Calculation: Directional streaks = initialize buy and sell counts to 0. On each bar with volume ratio >= effective spike threshold and an available volume average, increment the count for the current direction and reset the opposite count to 0. On other bars, retain both counts in big-trade sequence mode or reset both to 0 in consecutive-bar mode.
Long: Buy direction = true
Short: Buy direction = false
Long: Volume average is available AND volume ratio >= effective spike threshold AND buy direction = true
Short: Volume average is available AND volume ratio >= effective spike threshold AND buy direction = false
Long: Volume average is available AND volume ratio >= effective extreme threshold AND buy direction = true
Short: Volume average is available AND volume ratio >= effective extreme threshold AND buy direction = false
Long: Buy streak = momentum sequence length
Short: Sell streak = momentum sequence length