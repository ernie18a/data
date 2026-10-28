Calculation: Prior swing low = lowest low over the swing lookback, excluding the current bar
Calculation: Prior swing high = highest high over the swing lookback, excluding the current bar
Calculation: Long ATR trail = ratchet upward to the greater of the prior trail and highest high over the ATR lookback minus ATR × multiplier when close is above the prior trail; otherwise reset to highest high over the ATR lookback minus ATR × multiplier
Calculation: Short ATR trail = ratchet downward to the lesser of the prior trail and lowest low over the ATR lookback plus ATR × multiplier when close is below the prior trail; otherwise reset to lowest low over the ATR lookback plus ATR × multiplier
Calculation: Failure flag count = count of true conditions: close below EMA; low below prior swing low; RSI below its rollover level and below prior-bar RSI; close below open and volume above its moving average × volume multiplier; close below long ATR trail
Calculation: Failure flag count = count of true conditions: close above EMA; high above prior swing high; RSI above 100 minus its rollover level and above prior-bar RSI; close above open and volume above its moving average × volume multiplier; close above short ATR trail
Exit: long, failure flag count >= exit threshold OR close < long ATR trail
Exit: short, failure flag count >= exit threshold OR close > short ATR trail