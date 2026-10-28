Calculation: Linear-regression momentum = linear regression of close − average((highest high + lowest low) / 2, average close), using the same lookback for all three calculations
Calculation: Long trailing stop = the greater of the prior long trailing stop and highest close over the ATR lookback − ATR × multiplier; initialize to the latter value
Calculation: Short trailing stop = the lesser of the prior short trailing stop and lowest close over the ATR lookback + ATR × multiplier; initialize to the latter value
Long: Position is flat AND close crosses above the upper Bollinger Band AND linear-regression momentum > 0 AND volume > average volume × factor AND ADX > threshold AND close > EMA
Short: Position is flat AND close crosses below the lower Bollinger Band AND linear-regression momentum < 0 AND volume > average volume × factor AND ADX > threshold AND close < EMA
Exit: long, close crosses below the long trailing stop OR close < EMA
Exit: short, close crosses above the short trailing stop OR close > EMA