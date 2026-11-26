Calculation: adaptive length = max(minimum length, round(base length * (1 + (1 - ATR(atr length) / SMA(ATR(atr length), atr average length)) * adaptive factor)))
Calculation: HiLo state = 1 if close > SMA(high, adaptive length); else -1 if close < SMA(low, adaptive length); else HiLo state[1]
Calculation: Bull flip = HiLo state = 1 AND HiLo state[1] != 1
Calculation: Bear flip = HiLo state = -1 AND HiLo state[1] != -1
Calculation: Force = round(min(volume cap, volume weight * volume / SMA(volume, volume length)) + min(body cap, body weight * abs(close - open) / (high - low)) + min(ATR distance cap, ATR distance weight * abs(close - open) / ATR(atr length)))
Calculation: POC distance = (close - POC(profile lookback, profile rows)) / ATR(atr length)
Calculation: Last swing high = most recent non-NA value of pivot high(high, pivot length, pivot length)
Calculation: Prior swing high = second most recent non-NA value of pivot high(high, pivot length, pivot length)
Calculation: Last swing low = most recent non-NA value of pivot low(low, pivot length, pivot length)
Calculation: Prior swing low = second most recent non-NA value of pivot low(low, pivot length, pivot length)
Long: Bull flip AND (Force < force threshold OR POC distance <= -POC tolerance)
Long: Bull flip AND Force >= force threshold AND POC distance > -POC tolerance AND Force < premium threshold
Long: Bull flip AND Force >= premium threshold AND POC distance > -POC tolerance
Long: HiLo state = 1
Long: pivot high(high, pivot length, pivot length) is not NA AND Last swing high > Prior swing high
Long: pivot low(low, pivot length, pivot length) is not NA AND Last swing low > Prior swing low
Long: Last swing high > Prior swing high AND Last swing low > Prior swing low
Long: close > VAH(profile lookback, profile rows, value area percent)
Short: Bear flip AND (Force < force threshold OR POC distance >= POC tolerance)
Short: Bear flip AND Force >= force threshold AND POC distance < POC tolerance AND Force < premium threshold
Short: Bear flip AND Force >= premium threshold AND POC distance < POC tolerance
Short: HiLo state = -1
Short: pivot high(high, pivot length, pivot length) is not NA AND Last swing high < Prior swing high
Short: pivot low(low, pivot length, pivot length) is not NA AND Last swing low < Prior swing low
Short: Last swing high < Prior swing high AND Last swing low < Prior swing low
Short: close < VAL(profile lookback, profile rows, value area percent)