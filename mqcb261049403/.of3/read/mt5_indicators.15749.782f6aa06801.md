Calculation: Direction = if Round(JMA(FATL(applied price, FATL lookback), JMA lookback, phase), decimal precision) > its prior value then 1; if lower then -1; otherwise previous Direction
Long: Direction = 1
Short: Direction = -1
Calculation: T1 Direction = on T1 bars, if Round(JMA(FATL(applied price, FATL lookback), JMA lookback, phase), decimal precision) > its prior T1 value then 1; if lower then -1; otherwise previous T1 Direction
Long: On chart bars using T1's still-forming bar, T1 Direction = 1
Short: On chart bars using T1's still-forming bar, T1 Direction = -1