Calculation: True range = max(high − low, abs(high − previous close), abs(low − previous close))
Calculation: Volume ratio = volume / average volume over the volume lookback
Calculation: Close location = (close − low) / max(high − low, minimum tick)
Calculation: Body fraction = abs(close − open) / max(high − low, minimum tick)
Calculation: Upper wick = high − max(close, open); lower wick = min(close, open) − low
Calculation: ATR expansion = ATR / ATR from the longer lookback; volatility compression ratio = ATR from the shorter lookback / ATR from the longer lookback
Calculation: Volatility breakout event = true range > ATR × selected sensitivity multiplier AND (close location > 0.68 OR close location < 0.32) AND (volume confirmation is disabled OR volume ratio > 1.15)
Calculation: Structure break event = (close > prior highest high over the structure lookback OR close < prior lowest low over that lookback) AND breakout distance in ATR units > 0.10 AND (volume confirmation is disabled OR volume ratio > 1.15)
Calculation: Volume shock event = volume ratio > selected sensitivity multiplier AND (true range > 0.85 × ATR OR body fraction > 0.55)
Calculation: Absorption reversal event = volume ratio > 0.85 × selected volume sensitivity multiplier AND body fraction < 0.38 AND (upper wick > 0.42 × bar range OR lower wick > 0.42 × bar range)
Calculation: Regime shift event = (ATR expansion > 1.35 AND volatility compression ratio from 3 bars earlier < 0.90) OR (ADX − ADX from 5 bars earlier > 6 AND true range > 0.90 × ATR)
Calculation: Selected event = the event family selected by the event-type setting, or at least two of the five event families above when composite is selected
Calculation: Event direction = sign of the sum of directional contributions from all five event families: volatility breakout contributes +1 when close location > 0.68, otherwise −1; structure break contributes +1 for an upside break, otherwise −1; volume shock contributes +1 when close > open, −1 when close < open, otherwise 0; absorption contributes +1 when lower wick > upper wick, otherwise −1; regime shift contributes +1 when close > close 5 bars earlier, otherwise −1
Calculation: Marking direction = event direction when nonzero; otherwise +1 when close > close over the pre-event lookback, −1 when close < close over that lookback, otherwise 0
Long: Selected event AND event bar is confirmed AND sufficient history exists for the pre-event lookback, projection horizon, and warmup AND no selected event occurred within the minimum event gap AND marking direction > 0
Short: Selected event AND event bar is confirmed AND sufficient history exists for the pre-event lookback, projection horizon, and warmup AND no selected event occurred within the minimum event gap AND marking direction < 0