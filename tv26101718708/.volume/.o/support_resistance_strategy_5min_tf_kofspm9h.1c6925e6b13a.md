Calculation: Resistance = latest non-missing pivot high, using left and right lookbacks, from the prior bar
Calculation: Support = latest non-missing pivot low, using the same left and right lookbacks as Resistance, from the prior bar
Calculation: Volume oscillator = 100 × (5-period EMA of volume − 10-period EMA of volume) ÷ 10-period EMA of volume
Calculation: Long stop = current close − 14-period ATR × long stop multiplier
Calculation: Short stop = current close + 14-period ATR × short stop multiplier
Long: close crosses above Resistance AND Volume oscillator > volume threshold AND open − low ≤ close − open AND no open position AND bar is confirmed AND datetime is within 09:15–14:45 AND close ≥ EMA(close)
Short: close crosses below Support AND Volume oscillator > volume threshold AND open − close ≥ high − open AND no open position AND bar is confirmed AND datetime is within 09:15–14:45 AND close ≤ EMA(close)
Exit: long, low ≤ Long stop OR datetime hour = 14 AND minute = 55
Exit: short, high ≥ Short stop OR datetime hour = 14 AND minute = 55