Calculation: Up count = number of bars in the lookback window whose close is greater than the preceding close.
Calculation: Down count = number of bars in the same lookback window whose close is less than the preceding close.
Calculation: Volume change = 100 × (SMA of volume over the lookback window − SMA of volume over an independently configured baseline window) / baseline SMA; use 0 when the baseline SMA is not positive.
Calculation: Price change = 100 × (close − close at the start of the lookback window) / close at the start of the lookback window; use 0 when that past close is not positive.
Calculation: Entry ATR = ATR on the first bar of the current uninterrupted run of the corresponding long or short condition; entry price is that bar's close. A new first bar replaces the previous entry and its levels.
Long: Up count >= momentum threshold AND volume change >= volume threshold AND price change >= price threshold.
Short: Down count >= momentum threshold AND volume change >= volume threshold AND price change <= negative price threshold.
Exit: long, low <= entry price − stop multiplier × entry ATR.
Exit: short, high >= entry price + stop multiplier × entry ATR.
Exit: long, high >= entry price + target multiplier × entry ATR, for each of three independently configured target multipliers.
Exit: short, low <= entry price − target multiplier × entry ATR, for each of three independently configured target multipliers.