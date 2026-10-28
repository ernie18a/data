Calculation: Confirmed swing high/low = a bar whose high/low is higher/lower than the same number of bars on each side; use the latest confirmed pivot.
Calculation: Rolling median volume = median volume over a rolling window capped at a fixed maximum length.
Long: low < latest confirmed swing low AND close > latest confirmed swing low AND the pivot is within the liquidity-pool lookback AND volume > rolling median volume
Short: high > latest confirmed swing high AND close < latest confirmed swing high AND the pivot is within the liquidity-pool lookback AND volume > rolling median volume