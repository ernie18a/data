Long: HLC3 >= EMA(close, lookback)
Short: HLC3 < EMA(close, lookback)
Long: close > open
Short: close < open
Calculation: Intrabar volume delta = sum(volume of T1 bars with close > open) - sum(volume of T1 bars with close < open), taking the T1 values within each chart bar, including a T1 bar still forming
Long: Intrabar volume delta > 0
Short: Intrabar volume delta <= 0