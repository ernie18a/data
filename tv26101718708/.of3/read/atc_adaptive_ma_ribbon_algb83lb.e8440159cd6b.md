Calculation: Regime = Trend if Regime[1] = Trend and ADX(ADX length) >= trend threshold - hysteresis buffer, Range if Regime[1] = Range and ADX(ADX length) <= range threshold + hysteresis buffer, Trend if ADX(ADX length) > trend threshold, Range if ADX(ADX length) < range threshold, otherwise Transition
Calculation: Length multiplier = trend multiplier if Regime = Trend, range multiplier if Regime = Range, otherwise 1
Calculation: Fast = HMA(close, round(fast base length × Length multiplier))
Calculation: Medium = EMA(close, round(medium base length × Length multiplier))
Calculation: Slow = EMA(close, round(slow base length × Length multiplier))
Calculation: Anchor = EMA(close, round(anchor base length × Length multiplier))
Calculation: Bull tally = count of true among (Fast > Medium, Medium > Slow, Slow > Anchor, Fast > Anchor, Fast > Fast[1], Medium > Medium[1], Slow > Slow[1], Anchor > Anchor[1])
Calculation: Bear tally = count of true among (Fast < Medium, Medium < Slow, Slow < Anchor, Fast < Anchor, Fast <= Fast[1], Medium <= Medium[1], Slow <= Slow[1], Anchor <= Anchor[1])
Calculation: Bias = Bullish if Bull tally > Bear tally, Bearish if Bear tally > Bull tally, otherwise Neutral
Calculation: Confirmed Bias = Bias if the last alignment hysteresis values of Bias, including the current one, are all equal, otherwise Confirmed Bias[1]
Long: Confirmed Bias = Bullish
Short: Confirmed Bias = Bearish
Long: close > Anchor
Short: close < Anchor