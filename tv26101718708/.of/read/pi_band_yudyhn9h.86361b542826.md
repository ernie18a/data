Calculation: PI ATR = ATR × max(minimum PI Power, smoothed normalized energy ÷ 50), where raw energy = π × ATR² × signed square root of the absolute percentage change in OBV; the sign follows the OBV change. Normalize raw energy to 0–100 using its rolling minimum and maximum, using 50 when they are equal, then smooth it with an EMA.
Calculation: Compression = PI ATR < its longer-lookback SMA × compression ratio
Calculation: Center = EMA of close
Calculation: Upper PI ATR band = Center + PI ATR × band multiplier
Calculation: Lower PI ATR band = Center − PI ATR × band multiplier
Long: Previous bar was in compression AND close > upper PI ATR band AND close > Center AND current state is not long
Short: Previous bar was in compression AND close < lower PI ATR band AND close < Center AND current state is not short
Exit: long or short, NOT in compression AND close < upper PI ATR band AND close > lower PI ATR band