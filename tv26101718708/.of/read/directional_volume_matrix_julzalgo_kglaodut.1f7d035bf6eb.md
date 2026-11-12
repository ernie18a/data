Calculation: BuyStrength and SellStrength per bar, with range = high - low (floored at a tiny positive value), body = close - open, upperWick = high - max(open, close), lowerWick = min(open, close) - low, candleTotal = |body| + upperWick + lowerWick (tiny positive value if 0), closePos = (close - low) / range, bodyRatio = body / range. BuyStrength = wClose * closePos + wWick * lowerWick / candleTotal + wBody * max(bodyRatio, 0). SellStrength = wClose * (1 - closePos) + wWick * upperWick / candleTotal + wBody * max(-bodyRatio, 0). Weights satisfy wClose > wBody > wWick, all positive.
Calculation: EstBuyVol = volume * BuyStrength / (BuyStrength + SellStrength); EstSellVol = volume * SellStrength / (BuyStrength + SellStrength) (0 if the denominator is 0).
Calculation: Delta = sum of EstBuyVol over the last N bars including the current bar minus sum of EstSellVol over the same N bars.
Long: Delta >= 0
Short: Delta < 0
Long: close >= open
Short: close < open