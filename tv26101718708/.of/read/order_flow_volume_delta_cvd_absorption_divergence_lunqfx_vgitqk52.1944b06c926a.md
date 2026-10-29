Calculation: Volume delta = volume × (2 × close − high − low) ÷ max(high − low, minimum price increment)
Calculation: CVD = running sum of volume delta, reset at the configured session or week boundary, or never
Calculation: Absorption = volume exceeds its longer-term average by a sensitivity factor AND candle body is smaller than an ATR-based threshold
Long: CVD ≥ 0 OR a confirmed price swing low is lower than the prior confirmed swing low AND CVD at the newer pivot is higher than at the prior pivot OR absorption occurs AND volume delta ≥ 0
Short: CVD < 0 OR a confirmed price swing high is higher than the prior confirmed swing high AND CVD at the newer pivot is lower than at the prior pivot OR absorption occurs AND volume delta < 0